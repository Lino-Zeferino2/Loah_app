import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/services/task_service.dart';
import '../../core/navigation/navigation_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../models/task_model.dart';
import '../../widgets/loah_app_bar.dart';
import '../../widgets/loah_avatar_action.dart';
import '../../widgets/loah_drawer.dart';
import '../../widgets/section_header.dart';
import 'add_task_screen.dart';
import 'task_detail_screen.dart';
import 'widgets/task_list_item.dart';
import 'widgets/task_search_bar.dart';
import 'widgets/task_filter_sheet.dart';

/// "Loah - Tarefas": search, today's tasks, upcoming tasks and a
/// collapsible list of completed items.
///
/// Lê tarefas diretamente do Firestore via [TaskService].
class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final TaskService _taskService = TaskService();

  bool _showDone = false;
  String _query = '';
  TaskFilters _filters = const TaskFilters();

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Verifica se a tarefa vence hoje.
  bool _isDueToday(TaskModel task) {
    if (task.dueDate != null) return _isSameDay(task.dueDate!, DateTime.now());
    if (task.dueLabel == null) return false;
    if (task.dueLabel == 'Hoje') return true;
    return RegExp(r'^\d{1,2}:\d{2}$').hasMatch(task.dueLabel!);
  }

  /// Verifica se a tarefa vence amanhã.
  bool _isDueTomorrow(TaskModel task) {
    if (task.dueDate != null) {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      return _isSameDay(task.dueDate!, tomorrow);
    }
    return task.dueLabel == 'Amanhã';
  }

  /// Verifica se a tarefa vence esta semana.
  bool _isDueThisWeek(TaskModel task) {
    if (task.dueDate == null) return false;
    final now = DateTime.now();
    final weekEnd = now.add(const Duration(days: 7));
    return task.dueDate!.isAfter(now.subtract(const Duration(days: 1))) &&
        task.dueDate!.isBefore(weekEnd);
  }

  /// Verifica se a tarefa vence este mês.
  bool _isDueThisMonth(TaskModel task) {
    if (task.dueDate == null) return false;
    final now = DateTime.now();
    return task.dueDate!.month == now.month && task.dueDate!.year == now.year;
  }

  bool _passesFilters(TaskModel task) {
    // Status filter
    if (_filters.statusFilter.isNotEmpty &&
        !_filters.statusFilter.contains(task.effectiveStatus)) {
      return false;
    }
    // Priority filter
    if (_filters.priorityFilter.isNotEmpty) {
      if (task.priority == null) return false;
      if (!_filters.priorityFilter.contains(task.priority)) return false;
    }
    // Date filter
    if (_filters.dateFilter != null) {
      switch (_filters.dateFilter) {
        case 'hoje':
          if (!_isDueToday(task)) return false;
        case 'amanha':
          if (!_isDueTomorrow(task)) return false;
        case 'esta_semana':
          if (!_isDueThisWeek(task)) return false;
        case 'este_mes':
          if (!_isDueThisMonth(task)) return false;
      }
    }
    return true;
  }

  Future<void> _toggle(TaskModel task) async {
    final updated = task.copyWith(isDone: !task.isDone);
    await _taskService.updateTask(updated);
    setState(() {});
  }

  Future<void> _openTask(TaskModel task) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TaskDetailScreen(task: task)),
    );
    setState(() {});
  }

  Future<void> _addStandaloneTask() async {
    await Navigator.of(context).push<TaskModel?>(
      MaterialPageRoute(builder: (_) => const AddTaskScreen()),
    );
    setState(() {});
  }

  Future<void> _openFilters() async {
    final result = await showModalBottomSheet<TaskFilters>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.loahColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => TaskFilterSheet(initialFilters: _filters),
    );
    if (result != null) setState(() => _filters = result);
  }

  @override
  Widget build(BuildContext context) {
    final nav = LoahNavigationController.of(context);

    return Scaffold(
      drawer: LoahDrawer(currentIndex: nav.currentIndex, onNavigate: nav.navigateTo),
      appBar: const LoahAppBar(title: 'Minhas Tarefas', actions: [LoahAvatarAction()]),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: _taskService.getTasksStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text('Erro ao carregar tarefas: ${snapshot.error}'),
              );
            }

            final allTasks = <TaskModel>[];
            if (snapshot.hasData) {
              for (final doc in snapshot.data!.docs) {
                final data = doc.data() as Map<String, dynamic>;
                allTasks.add(TaskModel(
                  id: doc.id,
                  title: data['title'] ?? '',
                  subtitle: data['subtitle'],
                  tag: data['tag'],
                  dueLabel: data['dueLabel'],
                  priority: data['priority'] != null
                      ? TaskPriority.values.firstWhere(
                          (p) => p.name == data['priority'],
                          orElse: () => TaskPriority.baixa,
                        )
                      : null,
                  isDone: data['isDone'] ?? false,
                  goalId: data['goalId'],
                  completedAt: data['completedAt'] != null
                      ? (data['completedAt'] as Timestamp).toDate()
                      : null,
                  description: data['description'],
                  dueDate: data['dueDate'] != null
                      ? (data['dueDate'] as Timestamp).toDate()
                      : null,
                  createdAt: data['createdAt'] != null
                      ? (data['createdAt'] as Timestamp).toDate()
                      : null,
                  status: data['status'] != null
                      ? TaskStatus.values.firstWhere(
                          (s) => s.name == data['status'],
                          orElse: () => TaskStatus.pendente,
                        )
                      : null,
                ));
              }
            }

            final standalone = allTasks.where((t) => t.goalId == null).toList();
            final filtered = standalone.where((t) {
              if (_query.isNotEmpty &&
                  !t.title.toLowerCase().contains(_query.toLowerCase())) {
                return false;
              }
              return _passesFilters(t);
            }).toList();

            final today = filtered.where((t) => !t.isDone && _isDueToday(t)).toList();
            final upcoming = filtered.where((t) => !t.isDone && !_isDueToday(t)).toList();
            final done = filtered.where((t) => t.isDone).toList();

            return ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                Text('Quinta-feira, 24 de Outubro',
                    style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: AppSpacing.md),
                TaskSearchBar(
                  onChanged: (v) => setState(() => _query = v),
                  onFilterTap: _openFilters,
                ),
                if (_filters.isActive) ...[
                  const SizedBox(height: AppSpacing.sm),
                  _ActiveFiltersBar(
                    filters: _filters,
                    onClear: () => setState(() => _filters = const TaskFilters()),
                  ),
                ],
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
                if (today.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'Nenhuma tarefa para hoje.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  )
                else
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
                if (upcoming.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'Nenhuma tarefa futura.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  )
                else
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
                      Icon(
                        _showDone ? Icons.expand_less : Icons.expand_more,
                        size: 20,
                      ),
                    ],
                  ),
                ),
                if (_showDone) ...[
                  const SizedBox(height: AppSpacing.md),
                  if (done.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'Nenhuma tarefa concluída.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    )
                  else
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
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        heroTag: 'tasks_fab',
        onPressed: _addStandaloneTask,
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Barra de filtros ativos com opção de limpar.
class _ActiveFiltersBar extends StatelessWidget {
  final TaskFilters filters;
  final VoidCallback onClear;

  const _ActiveFiltersBar({
    required this.filters,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[];
    for (final status in filters.statusFilter) {
      chips.add(_FilterChip(label: status.label));
    }
    for (final priority in filters.priorityFilter) {
      chips.add(_FilterChip(label: priority.shortLabel));
    }
    if (filters.dateFilter != null) {
      final dateLabels = {
        'hoje': 'Hoje',
        'amanha': 'Amanhã',
        'esta_semana': 'Esta Semana',
        'este_mes': 'Este Mês',
      };
      chips.add(_FilterChip(label: dateLabels[filters.dateFilter] ?? filters.dateFilter!));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            ...chips,
            GestureDetector(
              onTap: onClear,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.close, size: 12, color: Colors.redAccent),
                    SizedBox(width: 4),
                    Text(
                      'Limpar',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  const _FilterChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: context.loahColors.accentBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: context.loahColors.accentBlue.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: context.loahColors.accentBlue,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
