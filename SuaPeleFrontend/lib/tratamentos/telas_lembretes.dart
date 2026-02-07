import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../core/app_config.dart';
import '../autentificacao/telas_autentificacao.dart'; // Para o Logout voltar ao login


class TelaLembretes extends StatefulWidget {
  const TelaLembretes({super.key});
  @override
  State<TelaLembretes> createState() => _TelaLembretesState();
}

class _TelaLembretesState extends State<TelaLembretes> {
  final _dio = Dio(BaseOptions(baseUrl: baseUrl));
  Key _refreshKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Response>(
        key: _refreshKey,
        future: _dio.get("Lembrete/ativos/paciente/${UsuarioLogado.id}"),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final lista = (snapshot.data?.data as List? ?? []).reversed.toList();
          if (lista.isEmpty) return const Center(child: Text("Nenhum lembrete para hoje."));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: lista.length,
            itemBuilder: (ctx, i) {
              final l = lista[i];
              int tipo = l['tipo'] ?? 0;
              IconData icon = tipo == 1 ? Icons.camera_alt : tipo == 2 ? Icons.event : Icons.medication;
              Color color = tipo == 1 ? Colors.blue : tipo == 2 ? Colors.orange : Colors.pink;

              return Card(
                color: color.withOpacity(0.05),
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color)),
                  title: Text(l['diasSemana'] ?? "Lembrete", style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Horário: ${l['horario']}"),
                  onTap: () async {
                    await Navigator.push(context, MaterialPageRoute(builder: (c) => TelaDetalhesLembrete(lembrete: l)));
                    setState(() => _refreshKey = UniqueKey());
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}


class TelaDetalhesLembrete extends StatelessWidget {
  final Map<String, dynamic> lembrete;
  const TelaDetalhesLembrete({super.key, required this.lembrete});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detalhes do Aviso")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Configurações do Lembrete", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            ListTile(leading: const Icon(Icons.description, color: Colors.blue), title: const Text("Descrição"), subtitle: Text(lembrete['diasSemana'] ?? "Geral")),
            ListTile(leading: const Icon(Icons.access_time, color: Colors.orange), title: const Text("Horário"), subtitle: Text(lembrete['horario'] ?? "--:--")),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.delete),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                onPressed: () async {
                  await Dio().delete("${baseUrl}Lembrete/${lembrete['id']}");
                  if (!context.mounted) return;
                  Navigator.pop(context);
                },
                label: const Text("APAGAR LEMBRETE"),
              ),
            )
          ],
        ),
      ),
    );
  }
}