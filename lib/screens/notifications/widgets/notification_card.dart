import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/app_notification.dart';
import '../../../widgets/labeled_progress_bar.dart';

/// One notification row: colored accent bar on the left (matching the
/// category), an icon badge, title + relative timestamp, the message,
/// an optional progress bar (goals), and whatever action buttons
/// [actions] provides — the screen builds those per-category, since
/// they need real callbacks (log a call, mark a bill paid...).
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

  String _relativeLabel() {
    final diff = DateTime.now().difference(notification.timestamp);
    if (diff.inMinutes < 1) return 'Agora';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min';
    if (diff.inHours < 24) return '${diff.inHours}h atrás';
    if (diff.inDays == 1) return 'Ontem';
    return '${diff.inDays}d atrás';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.loahColors;
    final color = _categoryColor(context);

    return Container(
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: color,
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
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: color.withValues(alpha: 0.15),
                            child: Icon(_categoryIcon(), size: 16, color: color),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(color: color, fontWeight: FontWeight.w700),
                            ),
                          ),
                          Text(_relativeLabel(), style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(notification.message, style: Theme.of(context).textTheme.bodyMedium),
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