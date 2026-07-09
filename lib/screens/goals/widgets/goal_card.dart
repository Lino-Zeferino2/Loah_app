import 'package:flutter/material.dart';
import '../../../core/mock/goal_progress.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models/goal_model.dart';
import '../../../models/task_model.dart';
import '../../../widgets/labeled_progress_bar.dart';
import '../../../widgets/loah_card.dart';

/// A single goal entry, e.g. "Reserva de Emergência" or "Eurotrip 2024".
/// Shows an optional cover image, category tag and progress bar.
///
/// Needs [allTasks] (not just the ones linked to this goal) because
/// [GoalProgress.of] handles both progress modes uniformly.
class GoalCard extends StatelessWidget {
  final GoalModel goal;
  final List<TaskModel> allTasks;
  final IconData icon;
  final VoidCallback? onTap;

  const GoalCard({
    super.key,
    required this.goal,
    required this.allTasks,
    this.icon = Icons.flag_outlined,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.loahColors;
    final progress = GoalProgress.of(goal, allTasks);
    final progressPercent = (progress * 100).round();

    final caption = goal.progressMode == GoalProgressMode.manualValue
        ? '${CurrencyFormatter.format(goal.current ?? 0)} / ${CurrencyFormatter.format(goal.target ?? 0)}'
        : () {
            final linked = GoalProgress.linkedTasks(goal, allTasks);
            final done = linked.where((t) => t.isDone).length;
            return '$done de ${linked.length} tarefas concluídas';
          }();

    return LoahCard(
      padding: const EdgeInsets.all(0),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (goal.imageAsset != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: AspectRatio(
                aspectRatio: 16 / 8,
                child: Image.network(goal.imageAsset!, fit: BoxFit.cover),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: colors.accentBlue.withValues(alpha: 0.15),
                      child: Icon(icon, size: 14, color: colors.accentBlue),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(goal.title,
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                    ),
                    Text(
                      '$progressPercent%',
                      style: TextStyle(
                        color: colors.accentBlue,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(goal.category, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 10),
                LabeledProgressBar(progress: progress, color: goal.progressColor),
                const SizedBox(height: 6),
                Text(caption, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}