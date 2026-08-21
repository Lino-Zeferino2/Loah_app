import 'package:flutter/material.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/app_notification.dart';
import '../../../widgets/labeled_progress_bar.dart';

/// One notification row: colored accent bar on the left (matching the
/// category), an icon badge, title + relative timestamp, the message,
/// an optional progress bar (goals), and whatever action buttons
/// [actions] provides — the screen builds those per-category, since
/// they need real callbacks (log a call, mark a bill paid...).
///
/// NOTA: notification.title/notification.message não são traduzidos
/// aqui — vêm já prontos do Firestore, gerados no momento da criação
/// da notificação (client scheduler / Cloud Functions). Apenas o
/// rótulo de tempo relativo ("Agora", "2h atrás"...) usa AppLocales.
class NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback? onTap;
  final List<Widget> actions;

  const NotificationCard({
    super.key,
    required this.notification,
    this.onTap,
    this.actions = const [],
  });

  Color _categoryColor(BuildContext context) {
    final colors = context.loahColors;
    return switch (notification.category) {
      NotificationCategory.contacts => colors.accentBlue,
      NotificationCategory.tasks => colors.positive,
      NotificationCategory.goals => Colors.deepPurpleAccent,
      NotificationCategory.finance => colors.negative,
      NotificationCategory.system => context.textSecondary,
    };
  }

  IconData _categoryIcon() => switch (notification.category) {
        NotificationCategory.contacts => Icons.person_outline,
        NotificationCategory.tasks => Icons.schedule,
        NotificationCategory.goals => Icons.trending_up,
        NotificationCategory.finance => Icons.account_balance_wallet_outlined,
        NotificationCategory.system => Icons.check_circle_outline,
      };

  // CORRIGIDO: recebe loc como parâmetro para traduzir o tempo
  // relativo ("Agora", "5 min", "2h atrás", "Ontem", "3d atrás").
  String _relativeLabel(AppLocales loc) {
    final diff = DateTime.now().difference(notification.timestamp);
    if (diff.inMinutes < 1) return loc.translate('notif_agora');
    if (diff.inMinutes < 60) {
      return loc.translate('notif_min_atras').replaceAll('{n}', '${diff.inMinutes}');
    }
    if (diff.inHours < 24) {
      return loc.translate('notif_h_atras').replaceAll('{n}', '${diff.inHours}');
    }
    if (diff.inDays == 1) return loc.translate('notif_ontem');
    return loc.translate('notif_dias_atras').replaceAll('{n}', '${diff.inDays}');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.loahColors;
    final color = _categoryColor(context);
    final loc = AppLocales.of(context);

    final isUnread = !notification.isRead;

    return Container(
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isUnread ? color.withValues(alpha: 0.3) : colors.border,
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: isUnread ? color : color.withValues(alpha: 0.3),
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: onTap,
                borderRadius: const BorderRadius.horizontal(right: Radius.circular(14)),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: color.withValues(alpha: 0.15),
                                child: Icon(_categoryIcon(), size: 16, color: color),
                              ),
                              if (isUnread)
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Colors.blueAccent,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              // Não traduzido: gerado no Firestore.
                              notification.title,
                              style: TextStyle(
                                color: color,
                                fontWeight: isUnread ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                          ),
                          Text(
                            _relativeLabel(loc),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isUnread ? context.textSecondary : context.textSecondary.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        // Não traduzido: gerado no Firestore.
                        notification.message,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isUnread ? null : context.textSecondary.withValues(alpha: 0.7),
                        ),
                      ),
                      if (notification.progress != null) ...[
                        const SizedBox(height: 10),
                        LabeledProgressBar(progress: notification.progress!, color: color),
                      ],
                      if (actions.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Row(children: actions),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}