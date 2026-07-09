import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/task_model.dart';

/// Three-way segmented selector for [TaskPriority], displayed in the
/// UI order Baixa → Média → Alta (the enum's declared order is
/// alta/media/baixa, which is why this widget defines its own display
/// order rather than iterating `TaskPriority.values`).
class PrioritySelector extends StatelessWidget {
  static const _displayOrder = [TaskPriority.baixa, TaskPriority.media, TaskPriority.alta];

  final TaskPriority selected;
  final ValueChanged<TaskPriority> onChanged;

  const PrioritySelector({super.key, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colors = context.loahColors;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.cardBackgroundAlt,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          for (final priority in _displayOrder)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(priority),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: priority == selected ? colors.accentBlue : Colors.transparent,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    priority.shortLabel,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: priority == selected ? Colors.white : context.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}