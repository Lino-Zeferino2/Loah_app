import 'package:flutter/material.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/services/task_service.dart';
import '../../core/services/goal_service.dart';
import '../../core/services/notification_scheduler.dart';
import '../../core/theme/app_theme.dart';
import '../../models/goal_model.dart';
import '../../models/task_model.dart';
import '../../widgets/loah_card.dart';
import '../goals/goal_detail_screen.dart';
import 'add_task_screen.dart';
import 'widgets/related_goal_card.dart';

/// "Loah - Detalhes da Tarefa": shows everything about one [TaskModel]
/// — status, related goal (if any), description, due date, priority —
/// plus quick actions to mark it done or open the edit form.
///
/// Lê e escreve tarefas diretamente no Firestore via [TaskService].
class TaskDetailScreen extends StatefulWidget {
  final TaskModel task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final TaskService _taskService = TaskService();
  final GoalService _goalService = GoalService();

  late TaskModel _task = widget.task;
  GoalModel? _relatedGoal;

  @override
  void initState() {
    super.initState();
    _loadRelatedGoal();
  }

  Future<void> _loadRelatedGoal() async {
    final goalId = _task.goalId;
    if (goalId != null) {
      final goal = await _goalService.getGoal(goalId);
      if (mounted) setState(() => _relatedGoal = goal);
    }
  }

  void _toggleDone() async {
    final wasDone = _task.isDone;
    final updated = _task.copyWith(isDone: !_task.isDone);
    try {
      await _taskService.updateTask(updated);
      if (mounted) setState(() => _task = updated);

      // Se acabou de marcar como concluída, verifica se todas as
      // tarefas independentes foram completadas e envia notificação.
      if (!wasDone && updated.isDone) {
        NotificationScheduler().checkAllTasksDone();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocales.of(context).translate('taskDetail_erro_atualizar')}$e')),
        );
      }
    }
  }

  Future<void> _editTask() async {
    final updated = await Navigator.of(context).push<TaskModel?>(
      MaterialPageRoute(builder: (_) => AddTaskScreen(existingTask: _task)),
    );
    if (updated == null) return;

    try {
      final stillExists = await _taskService.getTask(updated.id);
      if (stillExists == null) {
        if (mounted) Navigator.of(context).pop();
        return;
      }
      if (mounted) {
        setState(() {
          _task = updated;
          _loadRelatedGoal();
        });
      }
    } catch (_) {
      if (mounted) Navigator.of(context).pop();
    }
  }


  Future<void> _showStatusPicker() async {
    const statuses = TaskStatus.values;
    final selected = _task.effectiveStatus;
    final result = await showModalBottomSheet<TaskStatus>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.loahColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocales.of(ctx).translate('taskDetail_alterar_status'),
                style: Theme.of(ctx)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              for (final status in statuses) ...[
                InkWell(
                  onTap: () => Navigator.of(ctx).pop(status),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                      color: status == selected
                          ? _statusColor(context, status).withValues(alpha: 0.10)
                          : null,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          status == TaskStatus.pendente
                              ? Icons.radio_button_unchecked
                              : status == TaskStatus.emProgresso
                                  ? Icons.trending_up
                                  : Icons.check_circle,
                          size: 20,
                          color: _statusColor(context, status),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _statusLabel(ctx, status),
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              _statusSubtitle(ctx, status),
                              style: Theme.of(ctx).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        const Spacer(),
                        if (status == selected)
                          Icon(Icons.check, size: 20, color: _statusColor(context, status)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 4),
              ],
            ],
          ),
        ),
      ),
    );

    if (result == null || result == _task.effectiveStatus) return;

    final updated = _task.copyWith(
      isDone: result == TaskStatus.concluida,
      status: result == TaskStatus.concluida ? null : result,
    );
    try {
      await _taskService.updateTask(updated);
      if (mounted) setState(() => _task = updated);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocales.of(context).translate('taskDetail_erro_status')}$e')),
        );
      }
    }
  }

  String _statusLabel(BuildContext context, TaskStatus status) {
    final loc = AppLocales.of(context);
    return switch (status) {
      TaskStatus.pendente => loc.translate('status_nao_iniciada'),
      TaskStatus.emProgresso => loc.translate('status_em_progresso'),
      TaskStatus.concluida => loc.translate('status_concluida'),
    };
  }

  String _statusSubtitle(BuildContext context, TaskStatus status) {
    final loc = AppLocales.of(context);
    return switch (status) {
      TaskStatus.pendente => loc.translate('taskDetail_status_pendente_sub'),
      TaskStatus.emProgresso => loc.translate('taskDetail_status_progresso_sub'),
      TaskStatus.concluida => loc.translate('taskDetail_status_concluida_sub'),
    };
  }

  Color _statusColor(BuildContext context, TaskStatus status) {
    final colors = context.loahColors;
    return switch (status) {
      TaskStatus.pendente => context.textSecondary,
      TaskStatus.emProgresso => Colors.deepPurpleAccent,
      TaskStatus.concluida => colors.positive,
    };
  }

  String _priorityShortLabel(BuildContext context, TaskPriority priority) {
    final loc = AppLocales.of(context);
    return switch (priority) {
      TaskPriority.alta => loc.translate('prio_alta_short'),
      TaskPriority.media => loc.translate('prio_media_short'),
      TaskPriority.baixa => loc.translate('prio_baixa_short'),
    };
  }

  Color _priorityColor(BuildContext context, TaskPriority priority) {
    final colors = context.loahColors;
    return switch (priority) {
      TaskPriority.alta => colors.negative,
      TaskPriority.media => Colors.orange,
      TaskPriority.baixa => Colors.blueGrey,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.loahColors;
    final task = _task;
    final goal = _relatedGoal;
    final statusColor = _statusColor(context, task.effectiveStatus);

    return Scaffold(
      appBar: AppBar(title: Text(AppLocales.of(context).translate('taskDetail_titulo'))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            LoahCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          task.title,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          _statusLabel(context, task.effectiveStatus),
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (task.createdAt != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_outlined,
                            size: 14, color: colors.accentBlue),
                        const SizedBox(width: 6),
                        Text(
                          AppLocales.of(context)
                              .translate('task_created_label')
                              .replaceAll('{date}', TaskModel.longDate(task.createdAt!)),
                          style: TextStyle(color: colors.accentBlue, fontSize: 12.5),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            if (goal != null) ...[
              _SectionLabel(AppLocales.of(context).translate('taskDetail_meta_label')),
              const SizedBox(height: 8),
              RelatedGoalCard(
                goal: goal,
                trailingIcon: Icons.chevron_right,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => GoalDetailScreen(goal: goal)),
                ),
              ),
              const SizedBox(height: 20),
            ],

            if (task.description != null) ...[
              _SectionLabel(AppLocales.of(context).translate('taskDetail_descricao_label')),
              const SizedBox(height: 8),
              LoahCard(
                child: Text(
                  task.description!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.4),
                ),
              ),
              const SizedBox(height: 20),
            ],

            if (task.dueDate != null)
              _InfoRow(
                icon: Icons.calendar_today_outlined,
                label: AppLocales.of(context).translate('taskDetail_data_entrega'),
                trailing: Text(
                  AppLocales.of(context)
                      .translate('due_date_long_label')
                      .replaceAll('{date}', TaskModel.longDate(task.dueDate!)),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            if (task.priority != null)
              _InfoRow(
                icon: Icons.flag_outlined,
                label: AppLocales.of(context).translate('taskDetail_prioridade'),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: _priorityColor(context, task.priority!).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    _priorityShortLabel(context, task.priority!),
                    style: TextStyle(
                      color: _priorityColor(context, task.priority!),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            GestureDetector(
              onTap: () => _showStatusPicker(),
              child: _InfoRow(
                icon: Icons.sync_outlined,
                label: AppLocales.of(context).translate('taskDetail_status'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _statusLabel(context, task.effectiveStatus),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.chevron_right, size: 18, color: context.textSecondary),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _toggleDone,
                icon: Icon(task.isDone ? Icons.replay : Icons.check_circle_outline, size: 18),
                label: Text(
                  task.isDone
                      ? AppLocales.of(context).translate('taskDetail_reabrir')
                      : AppLocales.of(context).translate('taskDetail_marcar_concluida'),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.accentBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _editTask,
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: Text(AppLocales.of(context).translate('taskDetail_editar')),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
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

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget trailing;

  const _InfoRow({required this.icon, required this.label, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: LoahCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 18, color: context.textSecondary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
