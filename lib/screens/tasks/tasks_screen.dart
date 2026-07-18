import 'package:flutter/material.dart';
import 'package:loah_app/core/theme/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/mock/mock_data.dart';
import '../../core/navigation/navigation_controller.dart';
import '../../models/task_model.dart';
import '../../widgets/loah_app_bar.dart';
import '../../widgets/loah_avatar_action.dart';
import '../../widgets/loah_drawer.dart';
import '../../widgets/section_header.dart';
import 'add_task_screen.dart';
import 'task_detail_screen.dart';
import 'widgets/task_list_item.dart';
import 'widgets/task_search_bar.dart';

/// "Loah - Tarefas": search, today's tasks, upcoming tasks and a
/// collapsible list of completed items.
///
/// Reads straight from [MockData.tasks] (filtered to non-goal-linked
/// ones — goal sub-tasks live in their own Goal Detail screen) rather
/// than keeping a separate local copy, so toggling/editing/deleting a
/// task here (or from its Detail screen) is always in sync everywhere.
class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  bool _showDone = false;
  String _query = '';

  List<TaskModel> get _standaloneTasks =>
      MockData.tasks.where((t) => t.goalId == null).toList();

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Best-effort "is this due today?" check: uses the real [dueDate]
  /// when present, otherwise falls back to the relative [dueLabel]
  /// text ("Hoje", or a bare time like "09:00") for tasks that only
  /// ever had a label (older seed data / quick-add without a picker).
  bool _looksLikeToday(TaskModel task) {
    if (task.dueDate != null) return _isSameDay(task.dueDate!, DateTime.now());
    if (task.dueLabel == null) return false;
    if (task.dueLabel == 'Hoje') return true;
    return RegExp(r'^\d{1,2}:\d{2}$').hasMatch(task.dueLabel!);
  }

  void _toggle(TaskModel task) {
    setState(() {
      final index = MockData.tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) MockData.tasks[index] = task.copyWith(isDone: !task.isDone);
    });
  }

  Future<void> _openTask(TaskModel task) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TaskDetailScreen(task: task)),
    );
    // TaskDetailScreen writes straight into MockData.tasks (toggle,
    // edit, delete), so a rebuild here is enough to reflect changes.
    setState(() {});
  }

  Future<void> _addStandaloneTask() async {
    await Navigator.of(context).push<TaskModel?>(
      MaterialPageRoute(builder: (_) => const AddTaskScreen()),
    );
    // AddTaskScreen already writes into MockData.tasks either way
    // (standalone or goal-linked) — just rebuild to show it.
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final nav = LoahNavigationController.of(context);

    final filtered = _standaloneTasks.where((t) {
      if (_query.isEmpty) return true;
      return t.title.toLowerCase().contains(_query.toLowerCase());
    }).toList();

    final today = filtered.where((t) => !t.isDone && _looksLikeToday(t)).toList();
    final upcoming = filtered.where((t) => !t.isDone && !_looksLikeToday(t)).toList();
    final done = filtered.where((t) => t.isDone).toList();

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
            TaskSearchBar(onChanged: (v) => setState(() => _query = v), onFilterTap: () {}),
            const SizedBox(height: AppSpacing.lg),
            SectionHeader(
              title: 'Hoje',
              trailing: CircleAvatar(
                radius: 9,
                child: Text('${today.length}',
                    style: const TextStyle(fontSize: 10, color: Colors.white)),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            for (final task in today) ...[
              TaskListItem(
                task: task,
                onToggle: () => _toggle(task),
                onTap: () => _openTask(task),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            const SizedBox(height: AppSpacing.sm),
            const SectionHeader(title: 'Próximos Dias'),
            const SizedBox(height: AppSpacing.md),
            for (final task in upcoming) ...[
              TaskListItem(
                task: task,
                onToggle: () => _toggle(task),
                onTap: () => _openTask(task),
              ),
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
              for (final task in done) ...[
                TaskListItem(
                  task: task,
                  onToggle: () => _toggle(task),
                  onTap: () => _openTask(task),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary ,
        heroTag: 'tasks_fab',
        onPressed: _addStandaloneTask,
        child: const Icon(Icons.add),
      ),
    );
  }
}