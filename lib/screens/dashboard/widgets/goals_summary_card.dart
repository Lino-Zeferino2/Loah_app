import 'package:flutter/material.dart';
import '../../../core/mock/goal_progress.dart';
import '../../../models/goal_model.dart';
import '../../../models/task_model.dart';
import '../../../widgets/labeled_progress_bar.dart';
import '../../../widgets/loah_card.dart';
import '../../../widgets/section_header.dart';

/// "Metas Atuais / Ver todas" mini-list shown on the Dashboard.
class GoalsSummaryCard extends StatelessWidget {
  final List<GoalModel> goals;
  final List<TaskModel> allTasks;
  final VoidCallback onSeeAll;

  const GoalsSummaryCard({
    super.key,
    required this.goals,
    required this.allTasks,
    required this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return LoahCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Metas Atuais',
            icon: Icons.track_changes_outlined,
            iconColor: Colors.orange.shade700,
            trailing: GestureDetector(
              onTap: onSeeAll,
              child: Text(
                'Ver todas',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
          const SizedBox(height: 14),
          for (final goal in goals) ...[
            LabeledProgressBar(
              label: goal.title,
              progress: GoalProgress.of(goal, allTasks),
              color: goal.progressColor,
            ),
            if (goal.remainingLabel != null) ...[
              const SizedBox(height: 4),
              Text(
                goal.remainingLabel!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}