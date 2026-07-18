import 'package:flutter/material.dart';

class HelpCenterContactSection extends StatelessWidget {
  const HelpCenterContactSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final border = scheme.onSurface.withValues(alpha: 0.10);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fale conosco',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Nossa equipe de suporte está disponível de Seg. a Sex., das 09h às 18h.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.65),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
              label: const Text('Conversar via Chat'),
              style: FilledButton.styleFrom(
                backgroundColor: scheme.primary,
                foregroundColor: scheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.mail_outline_rounded, size: 18),
              label: const Text('Enviar E-mail'),
              style: FilledButton.styleFrom(
                backgroundColor: scheme.brightness == Brightness.dark
                    ? scheme.onSurface.withValues(alpha: 0.15)
                    : scheme.onSurface.withValues(alpha: 0.06),
                foregroundColor: scheme.onSurface,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: border),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              const _OnlineDot(),
              const SizedBox(width: 8),
              Text(
                'Time online agora',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OnlineDot extends StatelessWidget {
  const _OnlineDot();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.9),
        shape: BoxShape.circle,
      ),
    );
  }
}



