import 'package:flutter/material.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';

/// Blue call-to-action card: "Novo Item / Adicione uma tarefa, meta ou
/// transação rapidamente." with a "Criar" button.
class NewItemCard extends StatelessWidget {
  final VoidCallback onCreate;

  const NewItemCard({super.key, required this.onCreate});

  @override
  Widget build(BuildContext context) {
    final colors = context.loahColors;
    final loc = AppLocales.of(context);
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
          Text(
            loc.translate('newItem_titulo'),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            loc.translate('newItem_descricao'),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
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
              child: Text(loc.translate('newItem_criar')),
            ),
          ),
        ],
      ),
    );
  }
}
