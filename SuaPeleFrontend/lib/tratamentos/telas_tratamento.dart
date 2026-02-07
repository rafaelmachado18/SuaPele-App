import 'dart:math';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../core/app_config.dart';
import '../core/notification_service.dart';
import '../widgets/custom_widgets.dart';


class TelaTratamentos extends StatefulWidget {
  const TelaTratamentos({super.key});
  @override
  State<TelaTratamentos> createState() => _TelaTratamentosState();
}

class _TelaTratamentosState extends State<TelaTratamentos> {
  final _dio = Dio(BaseOptions(baseUrl: baseUrl));
  Key _refreshKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tratamentos")),
      body: FutureBuilder<Response>(
        key: _refreshKey,
        future: _dio.get("Tratamento/paciente/${UsuarioLogado.id}"),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final lista = (snapshot.data?.data as List? ?? []).reversed.toList();
          if (lista.isEmpty) return const Center(child: Text("Nenhum plano registrado."));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: lista.length,
            itemBuilder: (ctx, i) => Card(
              child: ListTile(
                leading: const Icon(Icons.medication, color: Colors.pink),
                title: Text(lista[i]['titulo'] ?? "Plano de Cuidado"),
                subtitle: Text("Data: ${lista[i]['dataInicio'].toString().substring(0, 10)}"),
                onTap: () async {
                  await Navigator.push(context, MaterialPageRoute(builder: (c) => TelaDetalhesTratamento(tratamento: lista[i])));
                  setState(() => _refreshKey = UniqueKey());
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (c) => const TelaCadastroTratamento()));
          setState(() { _refreshKey = UniqueKey(); });
        },
        label: const Text("NOVO PLANO"), icon: const Icon(Icons.add),
      ),
    );
  }
}

// Novo plano de tratamento
class TelaCadastroTratamento extends StatefulWidget {
  const TelaCadastroTratamento({super.key});
  @override
  State<TelaCadastroTratamento> createState() => _TelaCadastroTratamentoState();
}

class _TelaCadastroTratamentoState extends State<TelaCadastroTratamento> {
  final _titulo = TextEditingController();
  final _obs = TextEditingController();

  final _dio = Dio(BaseOptions(baseUrl: baseUrl));

  List<Map<String, dynamic>> _itens = [];
  int? _lesaoId;
  bool _isSaving = false;

  void _addItem(int tipo) async {
    final nC = TextEditingController();

    if (tipo == 2) {
      DateTime? d = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365))
      );

      if (d != null) {
        TimeOfDay? t = await showTimePicker(
          context: context,
          initialTime: const TimeOfDay(hour: 9, minute: 0),
        );

        if (t != null) {
          final String horaFormatada = "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}";
          setState(() => _itens.add({
            "nome": "Consulta Médica",
            "frequencia": "${d.day}/${d.month}/${d.year}",
            "horario": horaFormatada,
            "tipo": tipo,
            "dataRef": d
          }));
        }
      }
    } else if (tipo == 1) {
      final fC = TextEditingController();
      showDialog(context: context, builder: (ctx) => AlertDialog(
          title: const Text("Frequência de Fotos"),
          content: TextField(controller: fC, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "A cada quantos dias?")),
          actions: [
            ElevatedButton(onPressed: () {
              if (fC.text.isNotEmpty) {
                setState(() => _itens.add({"nome": "Nova Foto", "frequencia": "A cada ${fC.text} dias", "horario": "12:00", "tipo": tipo}));
                Navigator.pop(ctx);
              }
            }, child: const Text("ADICIONAR"))
          ]));
    } else {
      final dosC = TextEditingController();

      showDialog(context: context, builder: (ctx) => AlertDialog(
          title: const Text("Novo Medicamento"),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: nC, decoration: const InputDecoration(labelText: "Nome do Remédio")),
            const SizedBox(height: 10),
            TextField(controller: dosC, decoration: const InputDecoration(labelText: "Dosagem (Ex: 500mg, 1 cp)")),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CANCELAR")),
            ElevatedButton(
                onPressed: () async {
                  if (nC.text.isNotEmpty && dosC.text.isNotEmpty) {
                    String nomeRemedio = nC.text;
                    String dosagemRemedio = dosC.text;
                    Navigator.pop(ctx);
                    TimeOfDay? t = await showTimePicker(
                      context: context,
                      initialTime: const TimeOfDay(hour: 8, minute: 0),
                    );
                    if (t != null) {
                      final String horaFormatada = "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}";
                      setState(() {
                        _itens.add({
                          "nome": nomeRemedio,
                          "dosagem": dosagemRemedio,
                          "frequencia": "Diário",
                          "horario": horaFormatada,
                          "tipo": tipo
                        });
                      });
                    }
                  }
                },
                child: const Text("PRÓXIMO")
            )
          ]));
    }
  }

  Future<void> _salvar() async {
    if (_titulo.text.isEmpty || _itens.isEmpty) return;
    setState(() => _isSaving = true);

    try {

      final meds = _itens.where((i) => i['tipo'] == 0).map((i) => {
        "nome": i['nome'],
        "dosagem": i['dosagem'],
        "frequencia": "${i['horario']}:00", // Formato HH:mm:ss
        "instrucoesEspecificas": "Via App"
      }).toList();

      // Salva o Tratamento e recebe o ID do back
      final responseTratamento = await _dio.post('Tratamento/cadastrar', data: {
        "titulo": _titulo.text,
        "observacoesGerais": _obs.text,
        "pacienteId": UsuarioLogado.id,
        "lesaoId": _lesaoId, // <--- SEU LESÃO ID ESTÁ AQUI
        "dataInicio": DateTime.now().toIso8601String(),
        "medicamentos": meds
      });

      // pega o id craido pelo backend
      final int tratamentoIdGerado = responseTratamento.data['id'] ?? responseTratamento.data['Id'];

      // 3. Salva os Lembretes um por um
      for (var item in _itens) {
        await _dio.post('Lembrete/cadastrar', data: {
          "tipo": item['tipo'],
          "horario": "${item['horario']}:00",
          "diasSemana": "${item['nome']} - ${_titulo.text}",
          "pacienteId": UsuarioLogado.id,
          "tratamentoId": tratamentoIdGerado,
          "lesaoId": _lesaoId,
          "ativo": true
        });
      }

      if (!mounted) return;
      Navigator.pop(context);

    } catch (e) {
      debugPrint("ERRO: $e");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erro ao salvar o plano completo.")));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Novo Plano")),
      body: _isSaving ? const Center(child: CircularProgressIndicator()) : SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TextField(controller: _titulo, decoration: const InputDecoration(labelText: "Título do Plano", border: OutlineInputBorder())),
        const SizedBox(height: 12),
        FutureBuilder<Response>(
            future: Dio(BaseOptions(baseUrl: baseUrl)).get("Lesao/paciente/${UsuarioLogado.id}"),
            builder: (c, s) {
              if (!s.hasData) return const LinearProgressIndicator();
              final l = s.data?.data as List? ?? [];
              return DropdownButtonFormField<int>(
                isExpanded: true,
                decoration: const InputDecoration(labelText: "Vincular a uma Mancha", border: OutlineInputBorder()),
                value: _lesaoId,
                items: l.map<DropdownMenuItem<int>>((i) => DropdownMenuItem<int>(value: i['id'], child: Text("${i['regiaoCorpo']} (${i['status']})", overflow: TextOverflow.ellipsis))).toList(),
                onChanged: (v) => setState(() => _lesaoId = v),
              );
            }
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _obs,
          maxLines: 3,
          decoration: const InputDecoration(labelText: "Instruções Médicas", border: OutlineInputBorder()),
        ),
        const SizedBox(height: 30),
        const Text("Adicionar Item:", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        SizedBox(
          width: double.infinity,
          child: Wrap(
            spacing: 25, runSpacing: 15, alignment: WrapAlignment.center,
            children: [
              ActionIcon(label: "Remédio", icon: Icons.medication, color: Colors.pink, onTap: () => _addItem(0)),
              ActionIcon(label: "Foto", icon: Icons.camera_alt, color: Colors.blue, onTap: () => _addItem(1)),
              ActionIcon(label: "Consulta", icon: Icons.event, color: Colors.orange, onTap: () => _addItem(2)),
            ],
          ),
        ),
        const SizedBox(height: 25),
        const Divider(),
        ..._itens.map((i) => Card(child: ListTile(
            title: Text(i['nome']),
            subtitle: Text("${i['dosagem'] ?? ''} | ${i['frequencia']} | ${i['horario']}"),
            trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => setState(() => _itens.remove(i)))
        ))),
        const SizedBox(height: 30),
        SizedBox(width: double.infinity, height: 55, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.pink), onPressed: _itens.isEmpty ? null : _salvar, child: const Text("SALVAR PLANO COMPLETO", style: TextStyle(color: Colors.white))))
      ])),
    );
  }
}


class TelaDetalhesTratamento extends StatefulWidget {
  final Map<String, dynamic> tratamento;
  const TelaDetalhesTratamento({super.key, required this.tratamento});

  @override
  State<TelaDetalhesTratamento> createState() => _TelaDetalhesTratamentoState();
}

class _TelaDetalhesTratamentoState extends State<TelaDetalhesTratamento> {
  late Map<String, dynamic> _dadosTratamento;
  bool _isLoading = false;
  final _dio = Dio(BaseOptions(baseUrl: baseUrl));

  @override
  void initState() {
    super.initState();
    _dadosTratamento = widget.tratamento;
  }

  Future<void> _recarregarTratamento() async {
    try {
      final id = _dadosTratamento['id'] ?? _dadosTratamento['Id'];
      final res = await _dio.get("Tratamento/$id");
      setState(() => _dadosTratamento = res.data);
    } catch (e) { debugPrint("Erro ao recarregar: $e"); }
  }

  void _adicionarRemedio() async {
    final nC = TextEditingController();
    final dC = TextEditingController();

    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text("Novo Medicamento"),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: nC, decoration: const InputDecoration(labelText: "Nome")),
        TextField(controller: dC, decoration: const InputDecoration(labelText: "Dosagem")),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CANCELAR")),
        ElevatedButton(onPressed: () async {
          if (nC.text.isNotEmpty) {
            Navigator.pop(ctx);
            TimeOfDay? t = await showTimePicker(context: context, initialTime: TimeOfDay.now());
            if (t != null) await _salvarNovoMedicamento(nC.text, dC.text, t);
          }
        }, child: const Text("ADICIONAR"))
      ],
    ));
  }

  Future<void> _salvarNovoMedicamento(String nome, String dose, TimeOfDay hora) async {
    setState(() => _isLoading = true);
    try {
      final idT = _dadosTratamento['id'] ?? _dadosTratamento['Id'];
      final String horaF = "${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}";

      await _dio.post('Medicamento/cadastrar', data: {
        "nome": nome, "dosagem": dose, "frequencia": horaF, "tratamentoId": idT
      });

      await _dio.post('Lembrete/cadastrar', data: {
        "tipo": 0, "horario": "$horaF:00", "diasSemana": "$nome (${_dadosTratamento['titulo']})", "pacienteId": UsuarioLogado.id, "tratamentoId": idT, "ativo": true
      });

      await _recarregarTratamento();
    } finally { setState(() => _isLoading = false); }
  }

  void _editarFrequenciaFotos() async {
    final fC = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text("Editar Frequência"),
      content: TextField(controller: fC, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Intervalo de dias")),
      actions: [
        ElevatedButton(onPressed: () async {
          if (fC.text.isNotEmpty) {
            Navigator.pop(ctx);
            setState(() => _isLoading = true);
            await _dio.post('Lembrete/cadastrar', data: {
              "tipo": 1, "horario": "12:00:00", "diasSemana": "Foto - ${_dadosTratamento['titulo']}", "pacienteId": UsuarioLogado.id, "tratamentoId": _dadosTratamento['id'] ?? _dadosTratamento['Id'], "ativo": true
            });
            setState(() => _isLoading = false);
          }
        }, child: const Text("SALVAR"))
      ],
    ));
  }

  void _editarConsulta() async {
    DateTime? d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
    if (d != null) {
      TimeOfDay? t = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 9, minute: 0));
      if (t != null) {
        final String horaF = "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}";
        setState(() => _isLoading = true);
        await _dio.post('Lembrete/cadastrar', data: {
          "tipo": 2, "horario": "$horaF:00", "diasSemana": "Consulta - ${_dadosTratamento['titulo']}", "pacienteId": UsuarioLogado.id, "tratamentoId": _dadosTratamento['id'] ?? _dadosTratamento['Id'], "ativo": true
        });
        setState(() => _isLoading = false);
      }
    }
  }

  void _confirmarRemoverTratamento() {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text("Apagar Plano?"),
      content: const Text("Isso removerá o tratamento e todos os lembretes vinculados."),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CANCELAR")),
        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red), onPressed: () async {
          final id = _dadosTratamento['id'] ?? _dadosTratamento['Id'];
          await _dio.delete("Tratamento/$id");
          Navigator.pop(ctx); Navigator.pop(context);
        }, child: const Text("APAGAR", style: TextStyle(color: Colors.white)))
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    final meds = _dadosTratamento['medicamentos'] as List? ?? [];
    return Scaffold(
      appBar: AppBar(title: Text(_dadosTratamento['titulo'] ?? "Detalhes"), actions: [ IconButton(onPressed: _confirmarRemoverTratamento, icon: const Icon(Icons.delete_outline, color: Colors.red)) ]),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text("Instruções Médicas:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        Text(_dadosTratamento['observacoesGerais'] ?? "Nenhuma instrução."),
        const Divider(height: 40),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text("Medicamentos:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.pink)),
          IconButton(onPressed: _adicionarRemedio, icon: const Icon(Icons.add_circle, color: Colors.pink, size: 28))
        ]),
        ...meds.map((m) => Card(child: ListTile(leading: const Icon(Icons.medication, color: Colors.pink), title: Text(m['nome']), subtitle: Text("Dose: ${m['dosagem']} | Hora: ${m['frequencia']}")))),
        const SizedBox(height: 30),
        const Text("Agenda de Ações:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue)),
        Card(child: ListTile(leading: const Icon(Icons.camera_alt, color: Colors.blue), title: const Text("Frequência de Fotos"), subtitle: const Text("Toque para mudar"), trailing: const Icon(Icons.edit, size: 20), onTap: _editarFrequenciaFotos)),
        Card(child: ListTile(leading: const Icon(Icons.event, color: Colors.orange), title: const Text("Data da Consulta"), subtitle: const Text("Toque para reagendar"), trailing: const Icon(Icons.edit, size: 20), onTap: _editarConsulta)),
      ])),
    );
  }
}