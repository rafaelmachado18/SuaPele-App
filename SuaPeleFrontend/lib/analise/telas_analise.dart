import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/app_config.dart';

// Tela de captura e envio
class TelaNovaAnalise extends StatefulWidget {
  const TelaNovaAnalise({super.key});
  @override
  State<TelaNovaAnalise> createState() => _TelaNovaAnaliseState();
}

class _TelaNovaAnaliseState extends State<TelaNovaAnalise> {
  final List<File> _images = [];
  bool _loading = false;
  final _descController = TextEditingController();
  final _localController = TextEditingController();
  final _emailManualController = TextEditingController();
  int? _medicoId;
  List<dynamic> _meusMedicos = [];
  final _dio = Dio(BaseOptions(baseUrl: baseUrl));

  @override
  void initState() {
    super.initState();
    _carregarMedicos();
  }

  Future<void> _carregarMedicos() async {
    try {
      final res = await _dio.get("ProfissionalDeSaude/agenda/paciente/${UsuarioLogado.id}");
      if (res.data != null) setState(() => _meusMedicos = res.data as List);
    } catch (_) {}
  }

  void _abrirSeletor() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tirar Foto'),
              onTap: () { Navigator.pop(ctx); _pegarImagem(ImageSource.camera); },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Escolher da Galeria'),
              onTap: () { Navigator.pop(ctx); _pegarImagem(ImageSource.gallery); },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pegarImagem(ImageSource source) async {
    if (source == ImageSource.gallery) {
      final List<XFile> res = await ImagePicker().pickMultiImage(imageQuality: 40);
      if (res.isNotEmpty) {
        setState(() => _images.addAll(res.map((e) => File(e.path))));
      }
    } else {
      final XFile? res = await ImagePicker().pickImage(source: source, imageQuality: 40);
      if (res != null) {
        setState(() => _images.add(File(res.path)));
      }
    }
  }

  Future<void> _salvar(bool analisar) async {
    if (_images.isEmpty) return;
    setState(() => _loading = true);
    try {
      final resC = await _dio.post('Lesao/cadastrar', data: {
        "pacienteId": UsuarioLogado.id,
        "descricaoTextual": _descController.text,
        "regiaoCorpo": _localController.text,
        "status": "Cadastrada",
        "dataRegistro": DateTime.now().toIso8601String(),
      });

      final int id = resC.data['id'] ?? resC.data['Id'];
      List<String> base64Imagens = [];
      for (var file in _images) {
        final bytes = await file.readAsBytes();
        base64Imagens.add(base64Encode(bytes));
      }

      if (analisar) {
        final resA = await _dio.post('Lesao/$id/analisar', data: {
          "imagensBase64": base64Imagens,
          "profissionalDeSaudeId": _medicoId,
          "emailMedico": _emailManualController.text.isNotEmpty ? _emailManualController.text : null
        });

        if (!mounted) return;
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (c) => TelaResultadoAnalise(
                lesaoId: id,
                resultadoIA: resA.data['resultado'] ?? "Análise concluída.",
                imagemLocal: _images.first
            ))
        );
      } else {
        await _dio.post('Lesao/$id/analisar', data: {
          "imagensBase64": base64Imagens,
          "soloSalvar": true
        });
        if (!mounted) return;
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro na comunicação: $e")));
    } finally { if (mounted) setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nova Análise")),
      body: _loading ? const Center(child: CircularProgressIndicator()) : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("Fotos da Mancha *", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.grey.withOpacity(0.05), borderRadius: BorderRadius.circular(20)),
            child: _images.isEmpty
                ? InkWell(onTap: _abrirSeletor, child: const Center(child: Icon(Icons.add_a_photo, size: 40, color: Colors.blue)))
                : ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(10),
              itemCount: _images.length + 1,
              itemBuilder: (ctx, i) {
                if (i == _images.length) {
                  return InkWell(onTap: _abrirSeletor, child: Container(width: 100, margin: const EdgeInsets.only(left: 10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.blue)), child: const Icon(Icons.add, color: Colors.blue)));
                }
                return Stack(
                  children: [
                    Container(width: 140, margin: const EdgeInsets.only(right: 10), child: ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.file(_images[i], fit: BoxFit.cover))),
                    Positioned(right: 15, top: 5, child: CircleAvatar(radius: 12, backgroundColor: Colors.red, child: IconButton(padding: EdgeInsets.zero, icon: const Icon(Icons.close, size: 16, color: Colors.white), onPressed: () => setState(() => _images.removeAt(i)))))
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 25),
          TextField(controller: _localController, decoration: const InputDecoration(labelText: "Onde fica essa mancha? *", border: OutlineInputBorder())),
          const SizedBox(height: 15),
          TextField(controller: _descController, decoration: const InputDecoration(labelText: "Sintomas (Opcional)", border: OutlineInputBorder())),
          const SizedBox(height: 30),
          const Text("Destino do Relatório da IA", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(color: Colors.blue.withOpacity(0.05), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.blue.withOpacity(0.2))),
            child: Column(children: [
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
              const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Row(children: [Expanded(child: Divider()), Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text("OU")), Expanded(child: Divider())])),
              TextField(
                  controller: _emailManualController,
                  onChanged: (v) { if (v.isNotEmpty) setState(() => _medicoId = null); },
                  decoration: const InputDecoration(labelText: "Digitar E-mail Manualmente", border: OutlineInputBorder(), prefixIcon: Icon(Icons.email), fillColor: Colors.white, filled: true)
              ),
            ]),
          ),
          const SizedBox(height: 40),
          Row(children: [
            Expanded(child: OutlinedButton(style: OutlinedButton.styleFrom(fixedSize: const Size.fromHeight(55)), onPressed: () => _salvar(false), child: const Text("SÓ SALVAR"))),
            const SizedBox(width: 15),
            Expanded(child: ElevatedButton.icon(icon: const Icon(Icons.auto_awesome), style: ElevatedButton.styleFrom(fixedSize: const Size.fromHeight(55), backgroundColor: Colors.blue, foregroundColor: Colors.white), onPressed: () => _salvar(true), label: const Text("ANALISAR"))),
          ]),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }
}


class TelaResultadoAnalise extends StatelessWidget { // Tela apos a chaegada da analise feita pelo Gemini
  final int lesaoId;
  final String resultadoIA;
  final File imagemLocal;
  const TelaResultadoAnalise({super.key, required this.lesaoId, required this.resultadoIA, required this.imagemLocal});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Resultado")),
      body: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.file(imagemLocal, height: 200, width: double.infinity, fit: BoxFit.cover)),
        const SizedBox(height: 20),
        const Text("Análise Sugerida pela IA:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        Container(padding: const EdgeInsets.all(15), width: double.infinity, decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Text(resultadoIA)),
        const Spacer(),
        SizedBox(width: double.infinity, height: 55, child: ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("VOLTAR AO INÍCIO"))),
      ])),
    );
  }
}