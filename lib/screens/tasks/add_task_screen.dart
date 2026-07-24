import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../core/services/task_service.dart';
import '../../core/services/goal_service.dart';
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
///    Goal Detail screen's "Adicionar Tarefa" button).
/// 2. **New standalone task** — leave both [relatedGoal] and
///    [existingTask] null (e.g. from the Tarefas tab's FAB).
/// 3. **Editing an existing task** — pass [existingTask].
///
/// On success, pops with the created/updated [TaskModel].
class AddTaskScreen extends StatefulWidget {
  final GoalModel? relatedGoal;
  final TaskModel? existingTask;

  const AddTaskScreen({super.key, this.relatedGoal, this.existingTask});

  bool get isEditing => existingTask != null;

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final TaskService _taskService = TaskService();
  final GoalService _goalService = GoalService();

  late final TextEditingController _titleController =
      TextEditingController(text: widget.existingTask?.title ?? '');
  late final TextEditingController _descriptionController =
      TextEditingController(text: widget.existingTask?.description ?? '');

  GoalModel? _selectedGoal;
  DateTime? _dueDate;
  TaskPriority _priority = TaskPriority.baixa;
  String? _titleError;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _dueDate = widget.existingTask?.dueDate;
    _priority = widget.existingTask?.priority ?? TaskPriority.baixa;

    final existingGoalId = widget.existingTask?.goalId ?? widget.relatedGoal?.id;
    if (existingGoalId != null) {
      _loadGoal(existingGoalId);
    }
  }

  Future<void> _loadGoal(String goalId) async {
    final goal = await _goalService.getGoal(goalId);
    if (mounted) setState(() => _selectedGoal = goal);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

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
    final goals = await _goalService.getGoalsStream().first;
    final allGoals = goals.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return GoalModel(
        id: doc.id,
        title: data['title'] ?? '',
        category: data['category'] ?? 'Pessoal',
        term: data['term'] != null
            ? GoalTerm.values.firstWhere(
                (t) => t.name == data['term'],
                orElse: () => GoalTerm.curtoPrazo,
              )
            : GoalTerm.curtoPrazo,
        progressMode: data['progressMode'] != null
            ? GoalProgressMode.values.firstWhere(
                (m) => m.name == data['progressMode'],
                orElse: () => GoalProgressMode.manualValue,
              )
            : GoalProgressMode.manualValue,
        current: (data['current'] as num?)?.toDouble(),
        target: (data['target'] as num?)?.toDouble(),
        imageAsset: data['imageAsset'],
        description: data['description'],
        targetDate: data['targetDate'] != null
            ? (data['targetDate'] as Timestamp).toDate()
            : null,
        progressColor: data['progressColor'] != null
            ? Color(int.parse(data['progressColor']))
            : Colors.blue,
        remainingLabel: data['remainingLabel'],
      );
    }).toList();

    if (!mounted) return;
    final goal = await showModalBottomSheet<GoalModel?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.loahColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => GoalPickerSheet(
        goals: allGoals,
        currentSelection: _selectedGoal,
      ),
    );
    if (mounted) setState(() => _selectedGoal = goal);
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _titleError = 'Dê um nome para a tarefa.');
      return;
    }

    setState(() => _isSaving = true);
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
      isDone: existing?.isDone ?? false,
      completedAt: existing?.completedAt,
      createdAt: existing?.createdAt ?? DateTime.now(),
      status: existing?.status,
    );

    try {
      if (existing != null) {
        await _taskService.updateTask(task);
      } else {
        await _taskService.addTask(task);
      }
      if (mounted) Navigator.of(context).pop(task);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar tarefa: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
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

    try {
      await _taskService.deleteTask(widget.existingTask!.id);
      if (mounted) Navigator.of(context).pop(widget.existingTask);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao excluir tarefa: $e')),
        );
      }
    }
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
                onPressed: _isSaving ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.accentBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
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
