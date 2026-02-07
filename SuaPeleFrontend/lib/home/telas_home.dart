import 'package:flutter/material.dart';
import '../core/app_config.dart';
import '../widgets/custom_widgets.dart';
import '../main.dart';
import '../analise/telas_analise.dart';
import '../manchas/telas_manchas.dart';
import '../perfil/telas_perfil.dart';
import '../tratamentos/telas_tratamento.dart';
import '../tratamentos/telas_lembretes.dart';

// Tela Principal
class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({super.key});
  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  int _navIndex = 1; // Comeca em home

  @override
  Widget build(BuildContext context) {
    // Para o a navegacao no widget de barra no canto inferior da tela
    final List<Widget> telas = [
      const TelaLembretes(),
      const ConteudoHome(),
      const TelaPerfil(),
    ];

    return Scaffold(
      appBar: AppBar(

        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                'Olá, ${UsuarioLogado.nome}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, height: 1.2)
            ),
            const Text(
                'Sua Pele',
                style: TextStyle(fontSize: 12, height: 1.0)
            ),
          ],
        ),
        actions: [

          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(right: 16.0),
            child: Image.asset(
              'assets/images/ic_launcher.png', // coloca nosso simbolo

              height: 38,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
      body: telas[_navIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _navIndex,
        onDestinationSelected: (i) => setState(() => _navIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.alarm), label: 'Lembretes'),
          NavigationDestination(icon: Icon(Icons.home), label: 'Início'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}

//  Widget que tem os 3 blocos principais da home
class ConteudoHome extends StatelessWidget {
  const ConteudoHome({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [

          SizedBox(
            height: 200, // Ajuste este número para o tamanho que desejar
            width: double.infinity, // Faz com que ocupe toda a largura
            child: BigCard(
              title: 'Nova Análise',
              subtitle: 'Usar câmera inteligente',
              icon: Icons.camera_alt_rounded,
              color: const Color(0xFF2196F3),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const TelaNovaAnalise())),
            ),
          ),

          const SizedBox(height: 20), // Espaçamento entre os cards


          SizedBox(
            height: 200,
            width: double.infinity,
            child: BigCard(
              title: 'Minhas Manchas',
              subtitle: 'Ver histórico e evolução',
              icon: Icons.history_rounded,
              color: const Color(0xFF4CAF50),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const TelaHistorico())),
            ),
          ),

          const SizedBox(height: 20),

          // 3. Bloco de Tratamentos
          SizedBox(
            height: 200,
            width: double.infinity,
            child: BigCard(
              title: 'Tratamentos',
              subtitle: 'Receitas e Agenda',
              icon: Icons.medication_rounded,
              color: const Color(0xFFE91E63),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const TelaTratamentos())),
            ),
          ),
        ],
      ),
    );
  }
}