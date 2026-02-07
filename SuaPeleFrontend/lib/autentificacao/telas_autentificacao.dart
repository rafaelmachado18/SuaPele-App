import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../core/app_config.dart';
import '../home/telas_home.dart';
import '../main.dart';


// --- TELA LOGIN ---
class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});
  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _isLoading = false;

  Future<void> _fazerLogin() async {
    if (_emailController.text.isEmpty || _senhaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Preencha e-mail e senha.")));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final response = await Dio().post("${baseUrl}Paciente/login", data: {
        "email": _emailController.text,
        "senha": _senhaController.text
      });
      if (response.statusCode == 200 && response.data != null) {
        UsuarioLogado.id = response.data['id'] ?? 0;
        UsuarioLogado.nome = response.data['nome'] ?? "Usuário";
        UsuarioLogado.email = response.data['email'] ?? "";
        if (!mounted) return;
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const TelaPrincipal()));
      }
    } catch (e) {
      String mensagem = "Erro ao conectar.";
      if (e is DioException) {
        if (e.response?.statusCode == 401) mensagem = "E-mail ou senha incorretos.";
        else if (e.response?.data != null && e.response?.data['mensagem'] != null) mensagem = e.response?.data['mensagem'];
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensagem)));
    } finally { if (mounted) setState(() => _isLoading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/ic_launcher.png', height: 80, fit: BoxFit.contain),
              const SizedBox(height: 10),
              const Text("Sua Pele", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFE91E63))),
              const SizedBox(height: 40),
              TextField(controller: _emailController, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: "E-mail", border: OutlineInputBorder(), prefixIcon: Icon(Icons.email))),
              const SizedBox(height: 15),
              TextField(controller: _senhaController, obscureText: true, decoration: const InputDecoration(labelText: "Senha", border: OutlineInputBorder(), prefixIcon: Icon(Icons.lock))),
              const SizedBox(height: 25),
              _isLoading ? const CircularProgressIndicator() : SizedBox(width: double.infinity, height: 50, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE91E63), foregroundColor: Colors.white), onPressed: _fazerLogin, child: const Text("ENTRAR"))),
              const SizedBox(height: 15),
              TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TelaCadastro())), child: const Text("Ainda não tem conta? Cadastre-se")),
            ],
          ),
        ),
      ),
    );
  }
}

// --- TELA CADASTRO ---
class TelaCadastro extends StatefulWidget {
  const TelaCadastro({super.key});
  @override
  State<TelaCadastro> createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro> {
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  DateTime? _dataNascimento;
  String? _sexoSelecionado;
  bool _isLoading = false;

  Future<void> _cadastrar() async {
    if (_nomeController.text.isEmpty || _emailController.text.isEmpty || _senhaController.text.isEmpty || _dataNascimento == null || _sexoSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Preencha todos os campos.")));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final response = await Dio().post("${baseUrl}Paciente/cadastrar", data: {
        "nome": _nomeController.text,
        "email": _emailController.text,
        "SenhaHash": _senhaController.text,
        "dataNascimento": _dataNascimento!.toIso8601String(),
        "Sexo": _sexoSelecionado,
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        final dados = response.data;
        UsuarioLogado.id = dados['id'] ?? 0;
        UsuarioLogado.nome = dados['nome'] ?? _nomeController.text;
        UsuarioLogado.email = dados['email'] ?? _emailController.text;
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (c) => const TelaPrincipal()), (route) => false);
      }
    } catch (e) {
      String msgErro = "Erro ao cadastrar.";
      if (e is DioException && e.response?.data is Map) msgErro = e.response?.data['mensagem'] ?? msgErro;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msgErro), backgroundColor: Colors.red));
    } finally { if (mounted) setState(() => _isLoading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Criar Conta")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            TextField(controller: _nomeController, decoration: const InputDecoration(labelText: "Nome", border: OutlineInputBorder(), prefixIcon: Icon(Icons.person))),
            const SizedBox(height: 15),
            TextField(controller: _emailController, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: "E-mail", border: OutlineInputBorder(), prefixIcon: Icon(Icons.email))),
            const SizedBox(height: 15),
            TextField(controller: _senhaController, obscureText: true, decoration: const InputDecoration(labelText: "Senha", border: OutlineInputBorder(), prefixIcon: Icon(Icons.lock))),
            const SizedBox(height: 15),
            InkWell(
              onTap: () async {
                final d = await showDatePicker(context: context, initialDate: DateTime(2000), firstDate: DateTime(1900), lastDate: DateTime.now());
                if (d != null) setState(() => _dataNascimento = d);
              },
              child: InputDecorator(decoration: const InputDecoration(labelText: "Data de Nascimento", border: OutlineInputBorder(), prefixIcon: Icon(Icons.calendar_today)), child: Text(_dataNascimento == null ? "Selecionar" : "${_dataNascimento!.day}/${_dataNascimento!.month}/${_dataNascimento!.year}")),
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: "Sexo Biológico", border: OutlineInputBorder(), prefixIcon: Icon(Icons.people)),
              value: _sexoSelecionado,
              items: const [DropdownMenuItem(value: "M", child: Text("Masculino")), DropdownMenuItem(value: "F", child: Text("Feminino"))],
              onChanged: (v) => setState(() => _sexoSelecionado = v),
            ),
            const SizedBox(height: 30),
            _isLoading ? const CircularProgressIndicator() : SizedBox(width: double.infinity, height: 50, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white), onPressed: _cadastrar, child: const Text("CADASTRAR"))),
          ],
        ),
      ),
    );
  }
}