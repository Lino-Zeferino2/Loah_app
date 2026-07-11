import 'package:flutter/material.dart';
import '../../core/mock/mock_data.dart';
import '../../core/theme/app_theme.dart';
import '../../models/goal_model.dart';
import '../../models/task_model.dart';
import 'widgets/goal_picker_sheet.dart';
import 'widgets/priority_selector.dart';
import 'widgets/related_goal_card.dart';

/// "Loah - Adicionar/Editar Tarefa": a single form covering three use
/// cases:
///
/// 1. **New sub-task of a goal** — pass [relatedGoal] (e.g. from the
///    Goal Detail screen's "Adicionar Tarefa" button). The goal shows
///    as a locked, non-editable card at the top.
/// 2. **New standalone task** — leave both [relatedGoal] and
///    [existingTask] null (e.g. from the Tarefas tab's FAB). The user
///    can optionally attach a goal via a picker, or leave it avulsa.
/// 3. **Editing an existing task** — pass [existingTask]. Every field
///    pre-fills, the related goal becomes editable (even if the task
///    was originally created locked to one), and a "Excluir Tarefa"
///    action appears.
///
/// On success, pops with the created/updated [TaskModel]. Pops with
/// `null` if cancelled. Pops with the *same task marked deleted*
/// (`isDone` untouched, but removed from [MockData.tasks]) when the
/// user deletes it — callers should treat any non-null result as "the
/// list may have changed, refresh".
class AddTaskScreen extends StatefulWidget {
  final GoalModel? relatedGoal;
  final TaskModel? existingTask;

  const AddTaskScreen({super.key, this.relatedGoal, this.existingTask});

  bool get isEditing => existingTask != null;

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  late final _titleController =
      TextEditingController(text: widget.existingTask?.title ?? '');
  late final _descriptionController =
      TextEditingController(text: widget.existingTask?.description ?? '');

  GoalModel? _selectedGoal;
  DateTime? _dueDate;
  TaskPriority _priority = TaskPriority.baixa;
  String? _titleError;

  @override
  void initState() {
    super.initState();
    _dueDate = widget.existingTask?.dueDate;
    _priority = widget.existingTask?.priority ?? TaskPriority.baixa;

    final existingGoalId = widget.existingTask?.goalId ?? widget.relatedGoal?.id;
    if (existingGoalId != null) {
      _selectedGoal = MockData.goals.where((g) => g.id == existingGoalId).firstOrNull;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// The goal card is only locked when *creating* a fresh task directly
  /// from a Goal Detail screen — editing always allows changing (or
  /// removing) the link, even if the task was originally locked.
  bool get _goalIsLocked => !widget.isEditing && widget.relatedGoal != null;

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
      builder: (_) => GoalPickerSheet(currentSelection: _selectedGoal),
    );
    setState(() => _selectedGoal = goal);
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _titleError = 'Dê um nome para a tarefa.');
      return;
    }

    final existing = widget.existingTask;

    final task = TaskModel(
      id: existing?.id ?? 'task_${DateTime.now().microsecondsSinceEpoch}',
      title: title,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      dueDate: _dueDate,
      dueLabel: _dueDate != null ? TaskModel.shortDate(_dueDate!) : null,
      priority: _priority,
      goalId: _selectedGoal?.id,
      // Preserve state that this form doesn't edit directly.
      isDone: existing?.isDone ?? false,
      completedAt: existing?.completedAt,
      createdAt: existing?.createdAt ?? DateTime.now(),
      status: existing?.status,
    );

    if (existing != null) {
      final index = MockData.tasks.indexWhere((t) => t.id == existing.id);
      if (index != -1) MockData.tasks[index] = task;
    } else {
      MockData.tasks.add(task);
    }

    Navigator.of(context).pop(task);
  }

Future<void> _delete() async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: context.loahColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Excluir Tarefa',
                style: Theme.of(sheetContext)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'Tem certeza? Essa ação não pode ser desfeita.',
                style: Theme.of(sheetContext).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(sheetContext).pop(false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.of(sheetContext).pop(true),
                      child: const Text('Excluir'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (confirmed != true || !mounted) return;

    MockData.tasks.removeWhere((t) => t.id == widget.existingTask!.id);
    Navigator.of(context).pop(widget.existingTask); // signal "list changed"
  }
  @override
  Widget build(BuildContext context) {
    final colors = context.loahColors;
    final isEditing = widget.isEditing;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Editar Tarefa' : 'Adicionar Tarefa')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const _SectionLabel('NOME DA TAREFA'),
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

            const _SectionLabel('META RELACIONADA'),
            const SizedBox(height: 8),
            if (_selectedGoal != null)
              RelatedGoalCard(
                goal: _selectedGoal!,
                trailingIcon: _goalIsLocked ? Icons.lock_outline : Icons.close,
                onTap: _goalIsLocked ? null : _pickGoal,
              )
            else
              NoGoalCard(onTap: _pickGoal),
            const SizedBox(height: 20),

            const _SectionLabel('DESCRIÇÃO'),
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

            const _SectionLabel('DATA DE ENTREGA'),
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

            const _SectionLabel('PRIORIDADE'),
            const SizedBox(height: 8),
            PrioritySelector(
              selected: _priority,
              onChanged: (p) => setState(() => _priority = p),
            ),
            const SizedBox(height: 20),

            if (!isEditing)
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
            if (isEditing) ...[
              Center(
                child: TextButton.icon(
                  onPressed: _delete,
                  icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                  label: const Text(
                    'Excluir Tarefa',
                    style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),

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
                child: Text(
                  isEditing ? 'Salvar Alterações' : 'Criar Tarefa',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
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

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}