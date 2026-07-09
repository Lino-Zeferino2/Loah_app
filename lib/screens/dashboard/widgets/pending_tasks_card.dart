import 'package:flutter/material.dart';
import '../../../models/task_model.dart';
import '../../../widgets/loah_card.dart';
import '../../../widgets/section_header.dart';

/// "Tarefas Pendentes (3 pendentes)" checklist preview on the Dashboard.
class PendingTasksCard extends StatelessWidget {
  final List<TaskModel> tasks;
  final ValueChanged<int> onToggle;

  const PendingTasksCard({
    super.key,
    required this.tasks,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final pendingCount = tasks.where((t) => !t.isDone).length;
    return LoahCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Tarefas Pendentes',
            trailing: Text(
              '$pendingCount pendentes',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < tasks.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Checkbox(
                    value: tasks[i].isDone,
                    onChanged: (_) => onToggle(i),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tasks[i].title,
                          style: TextStyle(
                            decoration: tasks[i].isDone
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        if (tasks[i].subtitle != null)
                          Text(
                            tasks[i].subtitle!,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
