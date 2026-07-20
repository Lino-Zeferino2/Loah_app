import '../../models/app_notification.dart';
import 'budget_summary.dart';
import 'goal_progress.dart';
import 'mock_data.dart';

/// Builds the current list of notifications by scanning existing data
/// — contacts overdue, tasks due soon, goals with meaningful progress,
/// recurring bills due, budgets over limit. Nothing here is stored
/// twice: this always reflects the live state of `MockData`.
class NotificationGenerator {
  NotificationGenerator._();

  static List<AppNotification> generate() {
    final now = DateTime.now();
    final list = <AppNotification>[];

    // --- Contatos: pessoas atrasadas ---
    for (final c in MockData.contacts) {
      if (!c.isOverdue) continue;
      list.add(AppNotification(
        id: 'notif_contact_${c.id}',
        category: NotificationCategory.contacts,
        title: 'Contatos',
        message: 'Você não fala com ${c.name} há ${c.daysSinceLastContact} dias. '
            'Que tal ligar para ${c.name.split(' ').first}?',
        timestamp: now,
        relatedId: c.id,
      ));
    }

    // --- Tarefas: vencendo nas próximas 24h ---
    for (final t in MockData.tasks) {
      if (t.isDone || t.dueDate == null) continue;
      final diff = t.dueDate!.difference(now);
      if (diff.inHours < 0 || diff.inHours > 24) continue;
      final label = diff.inHours < 1 ? 'em menos de 1 hora' : 'em ${diff.inHours} horas';
      list.add(AppNotification(
        id: 'notif_task_${t.id}',
        category: NotificationCategory.tasks,
        title: 'Tarefas',
        message: "Tarefa '${t.title}' vence $label.",
        timestamp: now.subtract(const Duration(minutes: 22)),
        relatedId: t.id,
      ));
    }

    // --- Metas: progresso relevante (50%–99%) ---
    for (final g in MockData.goals) {
      final progress = GoalProgress.of(g, MockData.tasks);
      if (progress < 0.5 || progress >= 1.0) continue;
      list.add(AppNotification(
        id: 'notif_goal_${g.id}',
        category: NotificationCategory.goals,
        title: 'Metas',
        message: "Sua meta '${g.title}' atingiu ${(progress * 100).round()}% de conclusão!",
        timestamp: now.subtract(const Duration(hours: 2)),
        relatedId: g.id,
        progress: progress,
      ));
    }

    // --- Finanças: recorrências vencendo nos próximos 3 dias ---
    for (final r in MockData.recurringTransactions) {
      if (!r.active) continue;
      var dueThisMonth = DateTime(now.year, now.month, r.dayOfMonth);
      if (dueThisMonth.isBefore(DateTime(now.year, now.month, now.day))) {
        dueThisMonth = DateTime(now.year, now.month + 1, r.dayOfMonth);
      }
      final daysUntil = dueThisMonth.difference(DateTime(now.year, now.month, now.day)).inDays;
      if (daysUntil < 0 || daysUntil > 3) continue;
      final when = daysUntil == 0 ? 'hoje' : (daysUntil == 1 ? 'amanhã' : 'em $daysUntil dias');
      list.add(AppNotification(
        id: 'notif_recurring_${r.id}_${dueThisMonth.year}_${dueThisMonth.month}',
        category: NotificationCategory.finance,
        title: 'Finanças',
        message: "Lembrete: pagamento de '${r.title}' vence $when.",
        timestamp: now.subtract(const Duration(hours: 5)),
        relatedId: r.id,
      ));
    }

    // --- Finanças: orçamento estourado ---
    for (final progress in BudgetSummary.all(MockData.budgets, MockData.transactions)) {
      if (!progress.isOverBudget) continue;
      list.add(AppNotification(
        id: 'notif_budget_${progress.budget.id}',
        category: NotificationCategory.finance,
        title: 'Finanças',
        message: 'Você ultrapassou o orçamento de ${progress.budget.category} este mês.',
        timestamp: now.subtract(const Duration(hours: 6)),
        relatedId: progress.budget.id,
      ));
    }

    // --- Sistema: todas as tarefas avulsas do dia concluídas ---
    final standaloneTasks = MockData.tasks.where((t) => t.goalId == null).toList();
    if (standaloneTasks.isNotEmpty && standaloneTasks.every((t) => t.isDone)) {
      list.add(AppNotification(
        id: 'notif_system_all_done',
        category: NotificationCategory.system,
        title: 'Tarefas',
        message: 'Você completou todas as tarefas diárias. Bom trabalho!',
        timestamp: now.subtract(const Duration(days: 1)),
      ));
    }

    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list.where((n) => !MockData.dismissedNotificationIds.contains(n.id)).toList();
  }
}