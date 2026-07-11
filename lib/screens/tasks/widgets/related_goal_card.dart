import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/goal_model.dart';
import '../../../widgets/loah_card.dart';
import '../../goals/widgets/goal_term_section.dart'; // GoalTermVisuals (icon/color)

/// A card showing a related goal's icon, title and term — used in three
/// places:
/// - **Locked** (task created from within a Goal Detail screen): shows
///   a lock icon, not tappable.
/// - **Editable** (Add/Edit Task form, standalone flow): shows a close
///   icon (tap to unlink) and is tappable to change the goal.
/// - **Read-only navigation** (Task Detail screen): shows a chevron and
///   is tappable to open that goal's detail screen.
class RelatedGoalCard extends StatelessWidget {
  final GoalModel goal;
  final IconData trailingIcon;
  final VoidCallback? onTap;

  const RelatedGoalCard({
    super.key,
    required this.goal,
    required this.trailingIcon,
    this.onTap,
  });

  /// Locked variant: shows a lock icon, not tappable.
  const RelatedGoalCard.locked({super.key, required this.goal})
      : trailingIcon = Icons.lock_outline,
        onTap = null;

  @override
  Widget build(BuildContext context) {
    return LoahCard(
      onTap: onTap,
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: goal.progressColor.withValues(alpha: 0.15),
            child: Icon(goal.term.icon, size: 18, color: goal.progressColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(goal.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                Text(
                  'Meta de ${goal.term.label}',
                  style: TextStyle(fontSize: 12, color: goal.progressColor),
                ),
              ],
            ),
          ),
          Icon(trailingIcon, size: 18, color: context.textSecondary),
        ],
      ),
    );
  }
}

/// Shown when no goal is attached — tappable to open the goal picker.
class NoGoalCard extends StatelessWidget {
  final VoidCallback onTap;
  const NoGoalCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return LoahCard(
      onTap: onTap,
      child: Row(
        children: [
          Icon(Icons.link_outlined, size: 18, color: context.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Nenhuma meta selecionada (tarefa avulsa)',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Icon(Icons.chevron_right, size: 18, color: context.textSecondary),
        ],
      ),
    );
  }
}