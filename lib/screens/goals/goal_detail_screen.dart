import 'package:flutter/material.dart';
import '../../core/mock/goal_progress.dart';
import '../../core/mock/mock_data.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/goal_model.dart';
import '../../models/task_model.dart';
import '../../widgets/goal_image.dart';
import '../tasks/add_task_screen.dart';
import '../tasks/task_detail_screen.dart';
import 'add_goal_screen.dart';
import 'widgets/circular_progress_ring.dart';
import 'widgets/goal_milestone_tile.dart';

/// Detail screen for a single [GoalModel]: a photo header with a
/// circular progress ring overlay, category/date chips, title,
/// description, action buttons, and a "Marcos & Tarefas" checklist of
/// any tasks linked to this goal (regardless of its progress mode).
class GoalDetailScreen extends StatefulWidget {
  final GoalModel goal;

  const GoalDetailScreen({super.key, required this.goal});

  @override
  State<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends State<GoalDetailScreen> {
  // Mutable copy so editing the goal updates this screen immediately —
  // `widget.goal` itself can't change (it's the const passed in when
  // this route was pushed), so we track the current version here and
  // refresh it after returning from AddGoalScreen's edit flow.
  late GoalModel _goal = widget.goal;

  void _toggleTask(TaskModel task) {
    setState(() {
      final index = MockData.tasks.indexWhere((t) => t.id == task.id);
      MockData.tasks[index] = task.copyWith(isDone: !task.isDone);
    });
  }

  Future<void> _addTask() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AddTaskScreen(relatedGoal: _goal)),
    );
    // AddTaskScreen writes straight into MockData.tasks, so a rebuild
    // here is enough to show the newly created milestone.
    setState(() {});
  }

  Future<void> _openTask(TaskModel task) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TaskDetailScreen(task: task)),
    );
    // TaskDetailScreen writes straight into MockData.tasks (toggle,
    // edit, delete), so a rebuild here is enough to reflect changes.
    setState(() {});
  }

  Future<void> _editGoal() async {
    final updated = await Navigator.of(context).push<GoalModel?>(
      MaterialPageRoute(builder: (_) => AddGoalScreen(existingGoal: _goal)),
    );
    if (updated != null) setState(() => _goal = updated);
  }

 Future<void> _adjustProgress() async {
    final controller = TextEditingController();
    final delta = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.loahColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Atualizar Valor',
                style: Theme.of(sheetContext)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  prefixText: 'R\$ ',
                  hintText: '0,00',
                  filled: true,
                  fillColor: context.loahColors.cardBackgroundAlt,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        final value =
                            double.tryParse(controller.text.trim().replaceAll(',', '.'));
                        if (value != null) Navigator.of(sheetContext).pop(-value);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Remover'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        final value =
                            double.tryParse(controller.text.trim().replaceAll(',', '.'));
                        if (value != null) Navigator.of(sheetContext).pop(value);
                      },
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Adicionar'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  child: const Text('Cancelar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (delta == null || delta == 0) return;

    setState(() {
      final newCurrent = (_goal.current ?? 0) + delta;
      // Keep it inside [0, target] — no negative progress, and don't
      // overshoot the target visually (still "concluído" at 100%).
      // Note: num.clamp() returns `num`, not `double`, even when both
      // arguments are doubles — hence the explicit .toDouble() below,
      // otherwise this wouldn't type-check against GoalModel.current.
      final double clamped = (_goal.target != null
              ? newCurrent.clamp(0, _goal.target!)
              : newCurrent.clamp(0, double.infinity))
          .toDouble();
      _goal = _goal.copyWith(current: clamped);

      final index = MockData.goals.indexWhere((g) => g.id == _goal.id);
      if (index != -1) MockData.goals[index] = _goal;
    });
  }
  @override
  Widget build(BuildContext context) {
    final goal = _goal;
    final progress = GoalProgress.of(goal, MockData.tasks);
    final progressPercent = (progress * 100).round();
    // Any task linked to this goal counts as a "milestone" here — even
    // for manualValue goals, where the tasks don't drive the % but are
    // still useful sub-steps (e.g. "Guardar R$ 5.000 de entrada").
    final milestones = GoalProgress.linkedTasks(goal, MockData.tasks);
    final doneCount = milestones.where((t) => t.isDone).length;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 260,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: _GoalHeader(goal: goal, progress: progress, percent: progressPercent),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {},
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Row(
                  children: [
                    _CategoryChip(label: goal.category, color: goal.progressColor),
                    if (goal.targetDateLabel != null) ...[
                      const SizedBox(width: 10),
                      Icon(Icons.calendar_today_outlined, size: 14, color: context.textSecondary),
                      const SizedBox(width: 4),
                      Text(goal.targetDateLabel!, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  goal.title,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                if (goal.description != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    goal.description!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.4),
                  ),
                ],
                if (goal.progressMode == GoalProgressMode.manualValue) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${CurrencyFormatter.format(goal.current ?? 0)} de ${CurrencyFormatter.format(goal.target ?? 0)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: goal.progressColor,
                            ),
                      ),
                      TextButton.icon(
                        onPressed: _adjustProgress,
                        icon: Icon(Icons.tune, size: 16, color: goal.progressColor),
                        label: Text(
                          'Atualizar Valor',
                          style: TextStyle(color: goal.progressColor, fontWeight: FontWeight.w600),
                        ),
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _editGoal,
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: const Text('Editar Meta'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: goal.progressColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _addTask,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Adicionar Tarefa'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 26),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Marcos & Tarefas',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    Text(
                      '$doneCount de ${milestones.length} completas',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (milestones.isEmpty)
                  Text(
                    'Nenhuma tarefa vinculada a esta meta ainda.',
                    style: Theme.of(context).textTheme.bodySmall,
                  )
                else
                  for (final task in milestones)
                    GoalMilestoneTile(
                      task: task,
                      accentColor: goal.progressColor,
                      onToggle: () => _toggleTask(task),
                      onTap: () => _openTask(task),
                    ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

/// Photo (or gradient fallback) header with a dark scrim and the
/// [CircularProgressRing] centered on top.
class _GoalHeader extends StatelessWidget {
  final GoalModel goal;
  final double progress;
  final int percent;

  const _GoalHeader({required this.goal, required this.progress, required this.percent});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (goal.imageAsset != null)
          GoalImage(path: goal.imageAsset!)
        else
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  goal.progressColor.withValues(alpha: 0.55),
                  Colors.black,
                ],
              ),
            ),
          ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.35),
                Colors.black.withValues(alpha: 0.55),
              ],
            ),
          ),
        ),
        Center(
          child: CircularProgressRing(
            progress: progress,
            color: goal.progressColor,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$percent%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Text(
                  'CONCLUÍDO',
                  style: TextStyle(color: Colors.white70, fontSize: 11, letterSpacing: 0.6),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final Color color;
  const _CategoryChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12),
      ),
    );
  }
}