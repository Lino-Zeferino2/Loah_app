import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/task_model.dart';
import '../../../widgets/loah_card.dart';

/// A single task card inside the Tarefas screen: checkbox, priority
/// pill + due indicator, title, subtitle and an optional tag chip.
///
/// Rendered as its own bordered [LoahCard] (not a plain list row) to
/// match the reference design, where every task sits in its own card.
class TaskListItem extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onToggle;

  const TaskListItem({super.key, required this.task, required this.onToggle});

  Color _priorityColor(BuildContext context, TaskPriority priority) {
    final colors = context.loahColors;
    return switch (priority) {
      TaskPriority.alta => colors.negative,
      TaskPriority.media => colors.positive,
      TaskPriority.baixa => Colors.blueGrey,
    };
  }

  @override
  Widget build(BuildContext context) {
    return LoahCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Checkbox(
              value: task.isDone,
              onChanged: (_) => onToggle(),
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Top row: priority pill (or plain due label) + due/time ---
                if (task.priority != null || task.dueLabel != null) ...[
                  Row(
                    children: [
                      if (task.priority != null)
                        _PriorityPill(
                          label: task.priority!.label,
                          color: _priorityColor(context, task.priority!),
                        )
                      else if (task.dueLabel != null)
                        Text(
                          task.dueLabel!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      const Spacer(),
                      if (task.priority != null && task.dueLabel != null)
                        _DueIndicator(dueLabel: task.dueLabel!)
                      else if (task.priority == null && task.dueLabel != null)
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: context.loahColors.accentBlue,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],

                // --- Title ---
                Text(
                  task.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5,
                    decoration:
                        task.isDone ? TextDecoration.lineThrough : null,
                    color: task.isDone ? context.textSecondary : null,
                  ),
                ),

                // --- Subtitle ---
                if (task.subtitle != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    task.subtitle!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],

                // --- Tag chip (e.g. "Finanças", "Projeto Alpha") ---
                if (task.tag != null) ...[
                  const SizedBox(height: 10),
                  _TagChip(label: task.tag!),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Colored pill used for the task priority, e.g. "Alta Prioridade" on a
/// translucent red background.
class _PriorityPill extends StatelessWidget {
  final String label;
  final Color color;

  const _PriorityPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Trailing due indicator: a clock icon + time for "Hoje" items with an
/// exact hour, or a calendar icon + label otherwise.
class _DueIndicator extends StatelessWidget {
  final String dueLabel;
  const _DueIndicator({required this.dueLabel});

  bool get _looksLikeTime => RegExp(r'^\d{1,2}:\d{2}$').hasMatch(dueLabel);

  @override
  Widget build(BuildContext context) {
    final color = context.textSecondary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          _looksLikeTime ? Icons.schedule : Icons.calendar_today_outlined,
          size: 12,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(dueLabel, style: TextStyle(fontSize: 11, color: color)),
      ],
    );
  }
}

/// Small rounded tag chip, e.g. "Finanças" or "Projeto Alpha" with a
/// pair of overlapping "assignee" dots for team-style tags.
class _TagChip extends StatelessWidget {
  final String label;
  const _TagChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = context.loahColors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 26,
          height: 16,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                child: CircleAvatar(radius: 8, backgroundColor: Colors.cyan.shade300),
              ),
              Positioned(
                left: 10,
                child: CircleAvatar(radius: 8, backgroundColor: Colors.purple.shade300),
              ),
            ],
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: colors.accentBlue,
          ),
        ),
      ],
    );
  }
}
