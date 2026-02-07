import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../core/app_config.dart';

// --- 1. TELA DE LISTAGEM DE MANCHAS (HISTÓRICO) ---
class TelaHistorico extends StatefulWidget {
  const TelaHistorico({super.key});
  @override
  State<TelaHistorico> createState() => _TelaHistoricoState();
}

class _TelaHistoricoState extends State<TelaHistorico> {
  final _dio = Dio(BaseOptions(baseUrl: baseUrl));
  Key _refreshKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Minhas Manchas")),
      body: FutureBuilder<Response>(
        key: _refreshKey,
        future: _dio.get("Lesao/paciente/${UsuarioLogado.id}"),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final lista = snapshot.data?.data as List? ?? [];
          if (lista.isEmpty) {
            return const Center(child: Text("Nenhuma mancha registrada."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: lista.length,
            itemBuilder: (ctx, i) => Card(
              child: ListTile(
                leading: const Icon(Icons.history, color: Colors.green),
                title: Text(lista[i]['regiaoCorpo'] ?? "Local"),
                subtitle: Text("Status: ${lista[i]['status']}"),
                onTap: () async {
                  // Ao voltar da tela de detalhes, atualizamos a lista
                  await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (c) => TelaDetalhesHistorico(lesao: lista[i]))
                  );
                  setState(() { _refreshKey = UniqueKey(); });
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

// --- 2. TELA DE DETALHES, ANÁLISE E EXCLUSÃO ---
class TelaDetalhesHistorico extends StatefulWidget {
  final Map<String, dynamic> lesao;
  const TelaDetalhesHistorico({super.key, required this.lesao});
  @override
  State<TelaDetalhesHistorico> createState() => _TelaDetalhesHistoricoState();
}

class _TelaDetalhesHistoricoState extends State<TelaDetalhesHistorico> {
  late Map<String, dynamic> _currentLesao;
  bool _isProcessing = false;
  final _dio = Dio(BaseOptions(baseUrl: baseUrl));

  // Variáveis para o seletor de médico
  final _emailManualController = TextEditingController();
  int? _medicoId;
  List<dynamic> _meusMedicos = [];

  @override
  void initState() {
    super.initState();
    _currentLesao = widget.lesao;
    _carregarMedicos(); // Busca médicos cadastrados no perfil
  }

  Future<void> _carregarMedicos() async {
    try {
      final res = await _dio.get("ProfissionalDeSaude/agenda/paciente/${UsuarioLogado.id}");
      if (res.data != null) setState(() => _meusMedicos = res.data as List);
    } catch (_) {}
  }

  // Função para disparar análise (mesma lógica da Nova Análise)
  Future<void> _analisarNovamente() async {
    setState(() => _isProcessing = true);
    try {
      final id = _currentLesao['id'] ?? _currentLesao['Id'];
      final List fotos = _currentLesao['fotos'] ?? [];

      // Mapeia as fotos existentes para enviar ao backend
      List<String> base64Imagens = fotos.map((f) => f['caminhoArquivo'].toString()).toList();

      final response = await _dio.post('Lesao/$id/analisar', data: {
        "imagensBase64": base64Imagens,
        "profissionalDeSaudeId": _medicoId,
        "emailMedico": _emailManualController.text.isNotEmpty ? _emailManualController.text : null
      });

      if (response.statusCode == 200) {
        // Atualiza a lesão localmente com o novo diagnóstico
        final resUpdate = await _dio.get('Lesao/$id');
        setState(() {
          _currentLesao = resUpdate.data;
          _isProcessing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Análise enviada com sucesso!")));
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro na análise: $e")));
    }
  }

  Future<void> _excluirLesao() async {
    setState(() => _isProcessing = true);
    try {
      final id = _currentLesao['id'] ?? _currentLesao['Id'];
      await _dio.delete('Lesao/$id');

      if (!mounted) return;
      Navigator.pop(context); // Fecha o Dialog
      Navigator.pop(context); // Volta para a lista
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mancha removida com sucesso.")));
    } catch (e) {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro ao excluir: $e")));
    }
  }

  void _confirmarExclusao() {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Apagar Registro?"),
          content: const Text("Tem certeza que deseja apagar esta mancha? Esta ação removerá fotos e análises permanentemente."),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CANCELAR")),
            ElevatedButton.icon(
                icon: const Icon(Icons.delete_outline),
                onPressed: _excluirLesao,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                label: const Text("APAGAR AGORA")
            ),
          ],
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    final List diagnos = _currentLesao['preDiagnosticos'] ?? [];
    final List fotos = _currentLesao['fotos'] ?? [];
    final bool temAnalise = diagnos.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentLesao['regiaoCorpo'] ?? "Detalhes"),
        actions: [
          TextButton.icon(
            onPressed: _confirmarExclusao,
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            label: const Text("Apagar", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          )
        ],
      ),
      body: _isProcessing
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- EXIBIÇÃO DE FOTOS ---
              if (fotos.isNotEmpty)
                SizedBox(
                  height: 250,
                  child: PageView.builder(
                    itemCount: fotos.length,
                    itemBuilder: (ctx, i) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.memory(base64Decode(fotos[i]['caminhoArquivo']), fit: BoxFit.cover)
                      ),
                    ),
                  ),
                )
              else
                Container(height: 150, width: double.infinity, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.05), borderRadius: BorderRadius.circular(15)), child: const Icon(Icons.image_not_supported)),

              const SizedBox(height: 25),
              const Text("Relato do Paciente:", style: TextStyle(fontWeight: FontWeight.bold)),
              Text(_currentLesao['descricaoTextual'] ?? "N/A"),
              const Divider(height: 30),

              // --- SEÇÃO DE DIAGNÓSTICO ---
              const Text("Diagnóstico IA:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
              const SizedBox(height: 10),
              Container(
                  padding: const EdgeInsets.all(15),
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blue.withOpacity(0.1))
                  ),
                  child: temAnalise
                      ? Text(diagnos.last['resultadoIA'], style: const TextStyle(fontSize: 16))
                      : Column(
                    children: [
                      const Text("Não analisado ainda. Escolha o destino:"),
                      const SizedBox(height: 15),

                      // Dropdown de Médicos
                      DropdownButtonFormField<int>(
                        value: _medicoId,
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: "Médico da Minha Agenda", border: OutlineInputBorder(), fillColor: Colors.white, filled: true),
                        items: _meusMedicos.map((m) => DropdownMenuItem<int>(value: m['id'], child: Text(m['nome'] ?? "Médico"))).toList(),
                        onChanged: (v) {
                          setState(() {
                            _medicoId = v;
                            if (v != null) _emailManualController.clear();
                          });
                        },
                      ),
                      const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text("OU")),

                      // E-mail Manual
                      TextField(
                          controller: _emailManualController,
                          onChanged: (v) { if (v.isNotEmpty) setState(() => _medicoId = null); },
                          decoration: const InputDecoration(labelText: "Digitar E-mail Manualmente", border: OutlineInputBorder(), prefixIcon: Icon(Icons.email), fillColor: Colors.white, filled: true)
                      ),

                      const SizedBox(height: 15),
                      ElevatedButton.icon(
                        onPressed: _analisarNovamente,
                        icon: const Icon(Icons.auto_awesome),
                        label: const Text("SOLICITAR ANÁLISE AGORA"),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                      )
                    ],
                  )
              ),
            ],
          )
      ),
    );
  }
}