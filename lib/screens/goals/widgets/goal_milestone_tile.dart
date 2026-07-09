import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/task_model.dart';

/// One row in the "Marcos & Tarefas" list on the Goal Detail screen:
/// a colored accent bar on the left (matching the goal's color), a
/// checkbox, the task title (struck through when done) and a small
/// "Concluído em 15 Out" caption once completed.
class GoalMilestoneTile extends StatelessWidget {
  final TaskModel task;
  final Color accentColor;
  final VoidCallback onToggle;

  const GoalMilestoneTile({
    super.key,
    required this.task,
    required this.accentColor,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.loahColors;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: task.isDone ? accentColor : accentColor.withValues(alpha: 0.35),
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: onToggle,
                borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Row(
                    children: [
                      Checkbox(
                        value: task.isDone,
                        onChanged: (_) => onToggle(),
                        activeColor: accentColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.title,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                decoration: task.isDone ? TextDecoration.lineThrough : null,
                                color: task.isDone ? context.textSecondary : null,
                              ),
                            ),
                            if (task.completedLabel != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  task.completedLabel!,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                          ],
                        ),
                      ),
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