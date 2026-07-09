import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Blue call-to-action card: "Novo Item / Adicione uma tarefa, meta ou
/// transação rapidamente." with a "Criar" button.
class NewItemCard extends StatelessWidget {
  final VoidCallback onCreate;

  const NewItemCard({super.key, required this.onCreate});

  @override
  Widget build(BuildContext context) {
    final colors = context.loahColors;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.accentBlue,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white24,
            child: Icon(Icons.add, color: Colors.white),
          ),
          const SizedBox(height: 10),
          const Text(
            'Novo Item',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Adicione uma tarefa, meta ou transação rapidamente.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onCreate,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: colors.accentBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Criar'),
            ),
          ),
        ],
      ),
    );
  }
}
