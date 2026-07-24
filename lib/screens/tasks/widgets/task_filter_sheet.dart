import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/task_model.dart';

/// Filtros para a tela de tarefas.
class TaskFilters {
  final Set<TaskStatus> statusFilter;
  final Set<TaskPriority> priorityFilter;
  final String? dateFilter; // 'hoje', 'amanha', 'esta_semana', 'este_mes', null = todos

  const TaskFilters({
    this.statusFilter = const {},
    this.priorityFilter = const {},
    this.dateFilter,
  });

  bool get isActive =>
      statusFilter.isNotEmpty ||
      priorityFilter.isNotEmpty ||
      dateFilter != null;

  TaskFilters copyWith({
    Set<TaskStatus>? statusFilter,
    Set<TaskPriority>? priorityFilter,
    String? dateFilter,
    bool clearDate = false,
  }) {
    return TaskFilters(
      statusFilter: statusFilter ?? this.statusFilter,
      priorityFilter: priorityFilter ?? this.priorityFilter,
      dateFilter: clearDate ? null : (dateFilter ?? this.dateFilter),
    );
  }
}

/// Modal de filtros profissionais para a tela de tarefas.
class TaskFilterSheet extends StatefulWidget {
  final TaskFilters initialFilters;

  const TaskFilterSheet({super.key, required this.initialFilters});

  @override
  State<TaskFilterSheet> createState() => _TaskFilterSheetState();
}

class _TaskFilterSheetState extends State<TaskFilterSheet> {
  late Set<TaskStatus> _statusFilter;
  late Set<TaskPriority> _priorityFilter;
  late String? _dateFilter;

  @override
  void initState() {
    super.initState();
    _statusFilter = Set.from(widget.initialFilters.statusFilter);
    _priorityFilter = Set.from(widget.initialFilters.priorityFilter);
    _dateFilter = widget.initialFilters.dateFilter;
  }

  void _toggleStatus(TaskStatus status) {
    setState(() {
      if (_statusFilter.contains(status)) {
        _statusFilter.remove(status);
      } else {
        _statusFilter.add(status);
      }
    });
  }

  void _togglePriority(TaskPriority priority) {
    setState(() {
      if (_priorityFilter.contains(priority)) {
        _priorityFilter.remove(priority);
      } else {
        _priorityFilter.add(priority);
      }
    });
  }

  void _setDateFilter(String? filter) {
    setState(() {
      _dateFilter = _dateFilter == filter ? null : filter;
    });
  }

  void _clearAll() {
    setState(() {
      _statusFilter.clear();
      _priorityFilter.clear();
      _dateFilter = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.loahColors;
    final hasActiveFilters =
        _statusFilter.isNotEmpty || _priorityFilter.isNotEmpty || _dateFilter != null;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filtrar Tarefas',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (hasActiveFilters)
                      TextButton(
                        onPressed: _clearAll,
                        child: const Text('Limpar tudo'),
                      ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Status Section
            Text(
              'STATUS',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    letterSpacing: 0.6,
                    color: context.textSecondary,
                  ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: TaskStatus.values.map((status) {
                final selected = _statusFilter.contains(status);
                final statusColor = switch (status) {
                  TaskStatus.pendente => context.textSecondary,
                  TaskStatus.emProgresso => Colors.deepPurpleAccent,
                  TaskStatus.concluida => colors.positive,
                };
                return GestureDetector(
                  onTap: () => _toggleStatus(status),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? statusColor.withValues(alpha: 0.15)
                          : colors.cardBackgroundAlt,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: selected ? statusColor : colors.border,
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (selected)
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: Icon(Icons.check, size: 14, color: statusColor),
                          ),
                        Text(
                          status.label,
                          style: TextStyle(
                            color: selected ? statusColor : null,
                            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Priority Section
            Text(
              'PRIORIDADE',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    letterSpacing: 0.6,
                    color: context.textSecondary,
                  ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: TaskPriority.values.map((priority) {
                final selected = _priorityFilter.contains(priority);
                final priorityColor = switch (priority) {
                  TaskPriority.alta => colors.negative,
                  TaskPriority.media => colors.positive,
                  TaskPriority.baixa => Colors.blueGrey,
                };
                return GestureDetector(
                  onTap: () => _togglePriority(priority),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? priorityColor.withValues(alpha: 0.15)
                          : colors.cardBackgroundAlt,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: selected ? priorityColor : colors.border,
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (selected)
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: Icon(Icons.check, size: 14, color: priorityColor),
                          ),
                        Text(
                          priority.shortLabel,
                          style: TextStyle(
                            color: selected ? priorityColor : null,
                            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Date Section
            Text(
              'DATA',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    letterSpacing: 0.6,
                    color: context.textSecondary,
                  ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _DateChip(
                  label: 'Hoje',
                  value: 'hoje',
                  selected: _dateFilter == 'hoje',
                  onTap: () => _setDateFilter('hoje'),
                  colors: colors,
                ),
                _DateChip(
                  label: 'Amanhã',
                  value: 'amanha',
                  selected: _dateFilter == 'amanha',
                  onTap: () => _setDateFilter('amanha'),
                  colors: colors,
                ),
                _DateChip(
                  label: 'Esta Semana',
                  value: 'esta_semana',
                  selected: _dateFilter == 'esta_semana',
                  onTap: () => _setDateFilter('esta_semana'),
                  colors: colors,
                ),
                _DateChip(
                  label: 'Este Mês',
                  value: 'este_mes',
                  selected: _dateFilter == 'este_mes',
                  onTap: () => _setDateFilter('este_mes'),
                  colors: colors,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Apply Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(TaskFilters(
                    statusFilter: _statusFilter,
                    priorityFilter: _priorityFilter,
                    dateFilter: _dateFilter,
                  ));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.accentBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Aplicar Filtros',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Chip de data para o filtro.
class _DateChip extends StatelessWidget {
  final String label;
  final String value;
  final bool selected;
  final VoidCallback onTap;
  final LoahColors colors;

  const _DateChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? colors.accentBlue.withValues(alpha: 0.15)
              : colors.cardBackgroundAlt,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: selected ? colors.accentBlue : colors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Icon(Icons.check, size: 14, color: colors.accentBlue),
              ),
            Text(
              label,
              style: TextStyle(
                color: selected ? colors.accentBlue : null,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
