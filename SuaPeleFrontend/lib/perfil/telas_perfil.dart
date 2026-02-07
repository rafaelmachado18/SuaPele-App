import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../core/app_config.dart';
import '../autentificacao/telas_autentificacao.dart'; // Para o Logout voltar ao login

// Tela de Perfil e os medicos do paciente
class TelaPerfil extends StatefulWidget {
  const TelaPerfil({super.key});
  @override
  State<TelaPerfil> createState() => _TelaPerfilState();
}

class _TelaPerfilState extends State<TelaPerfil> {
  final _dio = Dio(BaseOptions(baseUrl: baseUrl));
  Key _refreshKey = UniqueKey();

  void _fazerLogout() {
    UsuarioLogado.id = 0;
    UsuarioLogado.nome = "";
    UsuarioLogado.email = "";
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (c) => const TelaLogin()),
          (route) => false,
    );
  }

  void _irParaCadastroMedico() async {
    final atualizou = await Navigator.push(
        context,
        MaterialPageRoute(builder: (c) => const TelaCadastroMedico())
    );
    if (atualizou == true) setState(() => _refreshKey = UniqueKey());
  }

  Future<void> _removerMedico(int medicoId) async {
    try {
      await _dio.delete("ProfissionalDeSaude/$medicoId");
      setState(() => _refreshKey = UniqueKey());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Médico removido.")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro ao remover: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: const Color(0xFFE91E63),
                      child: Text(
                        UsuarioLogado.nome.isNotEmpty ? UsuarioLogado.nome[0].toUpperCase() : "U",
                        style: const TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(UsuarioLogado.nome, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          Text(UsuarioLogado.email, style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Meus Médicos", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                IconButton(onPressed: _irParaCadastroMedico, icon: const Icon(Icons.person_add, color: Colors.blue))
              ],
            ),
            const Divider(),
            SizedBox(
              height: 300,
              child: FutureBuilder<Response>(
                key: _refreshKey,
                future: _dio.get("ProfissionalDeSaude/agenda/paciente/${UsuarioLogado.id}"),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                  final medicos = (snapshot.data?.data as List? ?? []);
                  if (medicos.isEmpty) return Center(child: Text("Nenhum médico na sua agenda.", style: TextStyle(color: Colors.grey[400])));

                  return ListView.builder(
                    itemCount: medicos.length,
                    itemBuilder: (ctx, i) {
                      final m = medicos[i];
                      return ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.medical_services)),
                        title: Text(m['nome'] ?? "Médico"),
                        subtitle: Text("CRM: ${m['crm'] ?? 'N/A'}"),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => _removerMedico(m['id']),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,

          height: 65,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(

              side: const BorderSide(color: Colors.red, width: 2),
              foregroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _fazerLogout,
            icon: const Icon(Icons.logout, size: 28),
            label: const Text(
              "SAIR DA CONTA",

              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 16,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
          ],
        ),
      ),
    );
  }
}

// tela de cadastro do medico
class TelaCadastroMedico extends StatefulWidget {
  const TelaCadastroMedico({super.key});
  @override
  State<TelaCadastroMedico> createState() => _TelaCadastroMedicoState();
}

class _TelaCadastroMedicoState extends State<TelaCadastroMedico> {
  final _nomeController = TextEditingController();
  final _crmController = TextEditingController();
  final _emailController = TextEditingController();
  final _telController = TextEditingController();
  bool _isDermato = true;
  bool _isLoading = false;

  Future<void> _salvar() async {
    if (_nomeController.text.isEmpty || _crmController.text.isEmpty || _emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Preencha os campos obrigatórios!")));
      return;
    }
    setState(() => _isLoading = true);
    try {
      await Dio().post(
        "${baseUrl}ProfissionalDeSaude/adicionar",
        queryParameters: {"pacienteId": UsuarioLogado.id},
        data: {
          "nome": _nomeController.text,
          "crm": _crmController.text,
          "email": _emailController.text,
          "telefone": _telController.text,
          "dermatologista": _isDermato,
        },
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } on DioException catch (e) {
      String msg = e.response?.data?['erro'] ?? "Erro: CRM já usado em outro cadastro!";
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.redAccent));
    } finally { if (mounted) setState(() => _isLoading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Novo Médico")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            TextField(controller: _nomeController, decoration: const InputDecoration(labelText: "Nome Completo", border: OutlineInputBorder(), prefixIcon: Icon(Icons.person))),
            const SizedBox(height: 15),
            TextField(controller: _crmController, decoration: const InputDecoration(labelText: "CRM", border: OutlineInputBorder(), prefixIcon: Icon(Icons.badge))),
            const SizedBox(height: 15),
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: "E-mail", border: OutlineInputBorder(), prefixIcon: Icon(Icons.email))),
            const SizedBox(height: 15),
            TextField(controller: _telController, decoration: const InputDecoration(labelText: "Telefone", border: OutlineInputBorder(), prefixIcon: Icon(Icons.phone))),
            const SizedBox(height: 15),
            SwitchListTile(title: const Text("É Dermatologista?"), value: _isDermato, onChanged: (v) => setState(() => _isDermato = v)),
            const SizedBox(height: 30),
            _isLoading ? const CircularProgressIndicator() : SizedBox(width: double.infinity, height: 55, child: ElevatedButton.icon(onPressed: _salvar, icon: const Icon(Icons.save), label: const Text("SALVAR MÉDICO"))),
          ],
        ),
      ),
    );
  }
}

