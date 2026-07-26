import 'package:flutter/material.dart';
import 'package:loah_app/core/theme/app_theme.dart';

/// Admin screen to manage Help Center content ("Central de Ajuda").
/// Placeholder — to be implemented with full CRUD functionality.
class ManageHelpCenterScreen extends StatelessWidget {
  const ManageHelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.loahColors;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerir Central de Ajuda'),
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
                Icons.support_agent_outlined,
                size: 80,
                color: colors.accentBlue.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 24),
              Text(
                'Gestão do Help Center',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'Aqui poderá gerir os artigos, categorias e conteúdos '
                'da Central de Ajuda da aplicação.',
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
                    _placeholderRow(Icons.article_outlined, 'Gerir artigos'),
                    const Divider(height: 24),
                    _placeholderRow(Icons.category_outlined, 'Gerir categorias'),
                    const Divider(height: 24),
                    _placeholderRow(Icons.visibility_outlined, 'Pré-visualizar alterações'),
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

