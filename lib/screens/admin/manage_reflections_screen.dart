import 'package:flutter/material.dart';
import 'package:loah_app/core/theme/app_theme.dart';

/// Admin screen to manage daily reflections ("Reflexões do Dia").
/// Placeholder — to be implemented with full CRUD functionality.
class ManageReflectionsScreen extends StatelessWidget {
  const ManageReflectionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.loahColors;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerir Reflexões do Dia'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.auto_stories_outlined,
                size: 80,
                color: colors.accentBlue.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 24),
              Text(
                'Gestão de Reflexões',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'Aqui poderá criar, editar e apagar as reflexões diárias '
                'que aparecem no Dashboard dos utilizadores.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: context.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.cardBackgroundAlt,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _placeholderRow(Icons.add_photo_alternate_outlined, 'Adicionar nova reflexão'),
                    const Divider(height: 24),
                    _placeholderRow(Icons.edit_outlined, 'Editar reflexão existente'),
                    const Divider(height: 24),
                    _placeholderRow(Icons.delete_outline, 'Remover reflexão'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholderRow(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

