import 'package:flutter/material.dart';

// --- BOTÕES DE AÇÃO (Usados no Cadastro de Tratamento) ---
class ActionIcon extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const ActionIcon({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: onTap,
        child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color)),
              const SizedBox(height: 5),
              Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold))
            ]
        )
    );
  }
}

// --- CARD GRANDE DA HOME (Usado na ConteudoHome) ---
class BigCard extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const BigCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(bottom: 12),
        width: double.infinity,
        height: 100,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(24)),
        child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(24),
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                    children: [
                      Icon(icon, size: 40, color: Colors.white),
                      const SizedBox(width: 20),
                      Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                            Text(subtitle, style: const TextStyle(color: Colors.white70))
                          ]
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 18)
                    ]
                )
            )
        )
    );
  }
}