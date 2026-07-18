import 'package:flutter/material.dart';

class AboutLoahScreen extends StatelessWidget {
  const AboutLoahScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sobre Loah'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Loah é um aplicativo feito para te ajudar a organizar sua vida financeira e alcançar objetivos com mais clareza.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• Planejamento e metas',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8),
                  Text('• Finanças com visão clara'),
                  SizedBox(height: 8),
                  Text('• Tarefas para manter o progresso'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Versão atual: 2.4.0',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

