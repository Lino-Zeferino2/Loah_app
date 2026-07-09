import 'package:flutter/material.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/navigation/navigation_controller.dart';
import '../../models/task_model.dart';
import '../../widgets/loah_app_bar.dart';
import '../../widgets/loah_avatar_action.dart';
import '../../widgets/loah_drawer.dart';
import '../../widgets/section_header.dart';
import 'add_task_screen.dart';
import 'widgets/task_list_item.dart';
import 'widgets/task_search_bar.dart';

/// "Loah - Tarefas": search, today's tasks, upcoming tasks and a
/// collapsible list of completed items.
class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final List<TaskModel> _today = [
    const TaskModel(
      id: 'task_quarterly_planning_meeting',
      title: 'Reunião de Planejamento Trimestral',
      subtitle: 'Preparar apresentação e KPIs do departamento financeiro.',
      priority: TaskPriority.alta,
      dueLabel: '09:00',
    ),
    const TaskModel(
      id: 'task_review_budget_today',
      title: 'Revisar orçamento mensal',
      tag: 'Finanças',
      priority: TaskPriority.media,
      dueLabel: 'Hoje',
    ),
  ];

  final List<TaskModel> _upcoming = [
    const TaskModel(
      id: 'task_leg_workout',
      title: 'Treino de pernas (Academia)',
      subtitle: 'Focar em resistência e alongamento.',
      dueLabel: 'Amanhã',
    ),
    const TaskModel(
      id: 'task_groceries',
      title: 'Comprar mantimentos',
      subtitle: 'Lista no app de notas.',
      dueLabel: 'Sáb, 3 Out',
    ),
  ];

  final List<TaskModel> _done = [
    const TaskModel(
      id: 'task_reply_emails',
      title: 'Responder e-mails acumulados',
      subtitle: 'Concluído às 08:30',
      isDone: true,
    ),
  ];

  bool _showDone = false;

  void _toggle(List<TaskModel> list, int index) {
    setState(() => list[index] = list[index].copyWith(isDone: !list[index].isDone));
  }

  Future<void> _addStandaloneTask() async {
    final created = await Navigator.of(context).push<TaskModel?>(
      MaterialPageRoute(builder: (_) => const AddTaskScreen()),
    );
    if (created == null) return;

    if (created.goalId != null) return;

    setState(() {
      final isToday = created.dueDate != null &&
          _isSameDay(created.dueDate!, DateTime.now());
      if (isToday) {
        _today.add(created);
      } else {
        _upcoming.add(created);
      }
    });
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final nav = LoahNavigationController.of(context);
    return Scaffold(
      drawer: LoahDrawer(currentIndex: nav.currentIndex, onNavigate: nav.navigateTo),
      appBar: const LoahAppBar(title: 'Minhas Tarefas', actions: [LoahAvatarAction()]),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text('Quinta-feira, 24 de Outubro',
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: AppSpacing.md),
            TaskSearchBar(onFilterTap: () {}),
            const SizedBox(height: AppSpacing.lg),
            SectionHeader(
              title: 'Hoje',
              trailing: CircleAvatar(
                radius: 9,
                child: Text('${_today.length}',
                    style: const TextStyle(fontSize: 10, color: Colors.white)),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            for (var i = 0; i < _today.length; i++) ...[
              TaskListItem(task: _today[i], onToggle: () => _toggle(_today, i)),
              const SizedBox(height: AppSpacing.md),
            ],
            const SizedBox(height: AppSpacing.sm),
            const SectionHeader(title: 'Próximos Dias'),
            const SizedBox(height: AppSpacing.md),
            for (var i = 0; i < _upcoming.length; i++) ...[
              TaskListItem(task: _upcoming[i], onToggle: () => _toggle(_upcoming, i)),
              const SizedBox(height: AppSpacing.md),
            ],
            const SizedBox(height: AppSpacing.sm),
            InkWell(
              onTap: () => setState(() => _showDone = !_showDone),
              child: Row(
                children: [
                  Text('Concluídos',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  Icon(_showDone ? Icons.expand_less : Icons.expand_more, size: 20),
                ],
              ),
            ),
            if (_showDone) ...[
              const SizedBox(height: AppSpacing.md),
              for (var i = 0; i < _done.length; i++) ...[
                TaskListItem(task: _done[i], onToggle: () => _toggle(_done, i)),
                const SizedBox(height: AppSpacing.md),
              ],
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'tasks_fab',
        onPressed: _addStandaloneTask,
        child: const Icon(Icons.add),
      ),
    );
  }
}