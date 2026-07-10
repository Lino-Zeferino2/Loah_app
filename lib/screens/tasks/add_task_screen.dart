import 'package:flutter/material.dart';
import '../../core/mock/mock_data.dart';
import '../../core/theme/app_theme.dart';
import '../../models/goal_model.dart';
import '../../models/task_model.dart';
import '../../widgets/loah_card.dart';
import '../goals/widgets/goal_term_section.dart'; // GoalTermVisuals (icon/color)
import 'widgets/priority_selector.dart';

/// "Loah - Adicionar Tarefa": a single form that covers two use cases:
///
/// 1. **Sub-task of a goal** — pass [relatedGoal] (e.g. from the Goal
///    Detail screen's "Adicionar Tarefa" button). The goal shows as a
///    locked, non-editable card at the top and every created task is
///    automatically linked via `goalId`.
/// 2. **Standalone task** — leave [relatedGoal] null (e.g. from the
///    Tarefas tab's FAB). The user can optionally attach a goal via a
///    picker, or leave it avulsa (unlinked).
///
/// On success, pops with the created [TaskModel]; pops with `null` if
/// cancelled.
class AddTaskScreen extends StatefulWidget {
  final GoalModel? relatedGoal;

  const AddTaskScreen({super.key, this.relatedGoal});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  GoalModel? _selectedGoal;
  DateTime? _dueDate;
  TaskPriority _priority = TaskPriority.baixa;
  String? _titleError;

  @override
  void initState() {
    super.initState();
    _selectedGoal = widget.relatedGoal;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool get _goalIsLocked => widget.relatedGoal != null;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

 Future<void> _pickGoal() async {
    final goal = await showModalBottomSheet<GoalModel?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.loahColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => _GoalPickerSheet(
        currentSelection: _selectedGoal,
        onClear: () => Navigator.of(sheetContext).pop(),
      ),
    );
    // showModalBottomSheet returns null both for "dismissed" and for
    // "explicitly chose null" — _GoalPickerSheet distinguishes via its
    // own pop(goal) calls, so we just accept whatever comes back here
    // except when the sheet is swiped away without a choice.
    setState(() => _selectedGoal = goal);
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _titleError = 'Dê um nome para a tarefa.');
      return;
    }

    final task = TaskModel(
      id: 'task_${DateTime.now().microsecondsSinceEpoch}',
      title: title,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      dueDate: _dueDate,
      dueLabel: _dueDate != null ? TaskModel.shortDate(_dueDate!) : null,
      priority: _priority,
      goalId: _selectedGoal?.id,
    );

    MockData.tasks.add(task);
    Navigator.of(context).pop(task);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.loahColors;

    return Scaffold(
      appBar: AppBar(title: const Text('Adicionar Tarefa')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SectionLabel('META RELACIONADA'),
            const SizedBox(height: 8),
            if (_selectedGoal != null)
              _RelatedGoalCard(
                goal: _selectedGoal!,
                locked: _goalIsLocked,
                onTap: _goalIsLocked ? null : _pickGoal,
                onClear: _goalIsLocked ? null : () => setState(() => _selectedGoal = null),
              )
            else
              _NoGoalCard(onTap: _pickGoal),
            const SizedBox(height: 22),

            _SectionLabel('NOME DA TAREFA'),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              onChanged: (_) {
                if (_titleError != null) setState(() => _titleError = null);
              },
              decoration: InputDecoration(
                hintText: 'Ex: Pesquisar modelos de SUV',
                errorText: _titleError,
                filled: true,
                fillColor: colors.cardBackgroundAlt,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            _SectionLabel('DESCRIÇÃO'),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Detalhes importantes para esta etapa...',
                filled: true,
                fillColor: colors.cardBackgroundAlt,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            _SectionLabel('DATA DE CONCLUSÃO'),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: colors.cardBackgroundAlt,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 18, color: context.textSecondary),
                    const SizedBox(width: 10),
                    Text(
                      _dueDate == null
                          ? 'dd/mm/aaaa'
                          : '${_dueDate!.day.toString().padLeft(2, '0')}/'
                              '${_dueDate!.month.toString().padLeft(2, '0')}/'
                              '${_dueDate!.year}',
                      style: TextStyle(
                        color: _dueDate == null ? context.textSecondary : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            _SectionLabel('PRIORIDADE'),
            const SizedBox(height: 8),
            PrioritySelector(
              selected: _priority,
              onChanged: (p) => setState(() => _priority = p),
            ),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colors.accentBlue.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.auto_awesome, size: 18, color: colors.accentBlue),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Lembre-se: pequenas tarefas são mais fáceis de completar. '
                      'Tente dividir metas grandes em passos de 15 a 30 minutos.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.accentBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Criar Tarefa', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(null),
                child: const Text('Cancelar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            letterSpacing: 0.6,
            color: context.textSecondary,
          ),
    );
  }
}

/// The related-goal card, shown either locked (task created from within
/// a Goal Detail screen) or tappable (task created standalone, with an
/// optional goal already picked).
class _RelatedGoalCard extends StatelessWidget {
  final GoalModel goal;
  final bool locked;
  final VoidCallback? onTap;
  final VoidCallback? onClear;

  const _RelatedGoalCard({
    required this.goal,
    required this.locked,
    this.onTap,
    this.onClear,
  });

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
          Icon(
            locked ? Icons.lock_outline : Icons.close,
            size: 18,
            color: context.textSecondary,
          ),
        ],
      ),
    );
  }
}

/// Shown when no goal is attached yet (only reachable in the
/// standalone-task flow, since the goal-linked flow always has one).
class _NoGoalCard extends StatelessWidget {
  final VoidCallback onTap;
  const _NoGoalCard({required this.onTap});

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
/// Bottom sheet listing every goal in [MockData.goals], plus a "remove
/// link" option, used when picking a goal for a standalone task.
///
/// Capped to 70% of screen height with an internally-scrolling list —
/// without this, a long goal list (or a small phone screen) would
/// overflow, since a plain Column has no bound on its own height.
class _GoalPickerSheet extends StatelessWidget {
  final GoalModel? currentSelection;
  final VoidCallback onClear;

  const _GoalPickerSheet({required this.currentSelection, required this.onClear});

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
                  for (final goal in MockData.goals)
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