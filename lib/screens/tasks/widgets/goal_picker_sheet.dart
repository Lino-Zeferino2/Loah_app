import 'package:flutter/material.dart';
import '../../../models/goal_model.dart';
import '../../goals/widgets/goal_term_section.dart'; // GoalTermVisuals (icon/color)

/// Bottom sheet listing goals, plus a "remove link" option, used when
/// picking a goal for a task.
///
/// Receives [goals] from the caller (e.g. fetched from Firestore) so
/// this widget stays a pure UI component.
///
/// Capped to 70% of screen height with an internally-scrolling list.
class GoalPickerSheet extends StatelessWidget {
  final List<GoalModel> goals;
  final GoalModel? currentSelection;

  const GoalPickerSheet({
    super.key,
    required this.goals,
    required this.currentSelection,
  });

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.7;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(
                'Vincular a uma meta',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.close),
                    title: const Text('Nenhuma (tarefa avulsa)'),
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  for (final goal in goals)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        radius: 16,
                        backgroundColor: goal.progressColor.withValues(alpha: 0.15),
                        child: Icon(goal.term.icon, size: 16, color: goal.progressColor),
                      ),
                      title: Text(goal.title),
                      trailing: goal.id == currentSelection?.id
                          ? const Icon(Icons.check, size: 18)
                          : null,
                      onTap: () => Navigator.of(context).pop(goal),
                    ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
