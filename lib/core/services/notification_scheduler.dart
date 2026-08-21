import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/app_notification.dart';
import '../../models/contact_model.dart';
import '../../models/goal_model.dart';
import '../../models/task_model.dart';
import '../../models/recurring_transaction_model.dart';
import '../../models/transaction_model.dart';
import 'notification_preferences_service.dart';
import 'notification_repository.dart';

/// Client-side notification scheduler that runs periodically to check
/// for noteworthy events and writes them to Firestore as notifications.
///
/// AMPLIADO com:
///   - Marcos de meta completos (25/50/75/90/100%)
///   - Tarefas vencidas (além de "a vencer")
///   - Antecedência de tarefa configurável (NotificationPreferences)
///   - Aviso preventivo de orçamento (80%) além do aviso de estouro
///   - Respeita as preferências de notificação do utilizador
///
/// IMPORTANTE: isto só corre enquanto a app está aberta. Para entrega
/// real com a app fechada (background/terminated), é necessário um
/// job equivalente correndo em Cloud Functions com Cloud Scheduler.
class NotificationScheduler {
  static final NotificationScheduler _instance = NotificationScheduler._internal();
  factory NotificationScheduler() => _instance;
  NotificationScheduler._internal();

  final NotificationRepository _repository = NotificationRepository();
  final NotificationPreferencesService _preferencesService =
      NotificationPreferencesService();
  Timer? _periodicTimer;

  /// Whether a check is currently running.
  bool _isRunning = false;

  /// Start periodic checks every [interval] minutes.
  void startPeriodicChecks({int intervalMinutes = 30}) {
    _periodicTimer?.cancel();
    _periodicTimer = Timer.periodic(
      Duration(minutes: intervalMinutes),
      (_) => runAllChecks(),
    );
  }

  /// Stop periodic checks.
  void stopPeriodicChecks() {
    _periodicTimer?.cancel();
    _periodicTimer = null;
  }

  /// Run all notification checks immediately, respecting the user's
  /// notification preferences.
  Future<void> runAllChecks() async {
    if (_isRunning) return;
    _isRunning = true;

    try {
      final prefs = await _preferencesService.getPreferences();

      await Future.wait([
        if (prefs.contactsEnabled) _checkOverdueContacts(),
        if (prefs.tasksEnabled) _checkUpcomingTasks(prefs.taskReminderLeadHours),
        if (prefs.tasksEnabled) _checkOverdueTasks(),
        if (prefs.goalsEnabled) _checkGoalProgress(),
        if (prefs.financeEnabled) _checkRecurringBills(),
        if (prefs.financeEnabled) _checkOverBudget(),
      ]);
    } catch (e) {
      debugPrint('[NotificationScheduler] Error running checks: $e');
    } finally {
      _isRunning = false;
    }
  }

  // ─── Contact checks ───────────────────────────────────────────────

  /// Creates notifications for contacts that are overdue (no interaction
  /// within the desired frequency).
  Future<void> _checkOverdueContacts() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('contacts')
        .get();

    for (final doc in snapshot.docs) {
      final contact = _contactFromDoc(doc);
      if (!contact.isOverdue) continue;

      final now = DateTime.now();
      final weekAnchor = DateTime.utc(now.year, 1, 1)
          .add(Duration(days: (contact.desiredContactFrequencyDays ?? 7) * (now.weekday - 1)));
      final periodKey =
          '${now.year}_${weekAnchor.month}_${weekAnchor.day}';
      final notificationId =
          'notif_contact_${contact.id}_$periodKey';

      final idCheck = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('notifications')
          .where('id', isEqualTo: notificationId)
          .limit(1)
          .get();

      if (idCheck.docs.isNotEmpty) continue;

      final pendingCheck = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('notifications')
          .where('relatedId', isEqualTo: contact.id)
          .where('isRead', isEqualTo: false)
          .limit(1)
          .get();

      if (pendingCheck.docs.isNotEmpty) continue;

      final daysLabel = contact.daysSinceLastContact >= 999
          ? 'há muito tempo'
          : 'há ${contact.daysSinceLastContact} dias';
      final notification = AppNotification(
        id: notificationId,
        category: NotificationCategory.contacts,
        title: 'Contatos',
        message: 'Você não fala com ${contact.name} $daysLabel. '
            'Que tal ligar para ${contact.name.split(' ').first}?',
        timestamp: now,
        relatedId: contact.id,
      );

      await _repository.addNotification(notification);
    }
  }

  // ─── Task checks ──────────────────────────────────────────────────

  /// Creates notifications for tasks due within [leadHours] hours.
  Future<void> _checkUpcomingTasks(int leadHours) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final now = DateTime.now();
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .get();

    for (final doc in snapshot.docs) {
      final task = _taskFromDoc(doc);
      if (task.isDone || task.dueDate == null) continue;

      final diff = task.dueDate!.difference(now);
      if (diff.inHours < 0 || diff.inHours > leadHours) continue;

      final existingSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('notifications')
          .where('relatedId', isEqualTo: task.id)
          .where('isRead', isEqualTo: false)
          .limit(1)
          .get();

      if (existingSnapshot.docs.isNotEmpty) continue;

      final label = diff.inHours < 1 ? 'em menos de 1 hora' : 'em ${diff.inHours} horas';
      final notification = AppNotification(
        id: 'notif_task_${task.id}_${now.millisecondsSinceEpoch}',
        category: NotificationCategory.tasks,
        title: 'Tarefas',
        message: "Tarefa '${task.title}' vence $label.",
        timestamp: now,
        relatedId: task.id,
      );

      await _repository.addNotification(notification);
    }
  }

  /// NOVO: cria notificações para tarefas já vencidas e ainda não
  /// concluídas. Re-notifica uma vez por dia enquanto continuar em
  /// atraso, para não deixar a tarefa cair no esquecimento.
  Future<void> _checkOverdueTasks() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final now = DateTime.now();
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .get();

    for (final doc in snapshot.docs) {
      final task = _taskFromDoc(doc);
      if (task.isDone || task.dueDate == null) continue;
      if (!task.dueDate!.isBefore(now)) continue;

      final dayKey = '${now.year}_${now.month}_${now.day}';
      final notificationId = 'notif_task_overdue_${task.id}_$dayKey';

      final existing = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('notifications')
          .where('id', isEqualTo: notificationId)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) continue;

      final daysLate = now.difference(task.dueDate!).inDays;
      final label = daysLate <= 0
          ? 'hoje'
          : (daysLate == 1 ? 'há 1 dia' : 'há $daysLate dias');

      final notification = AppNotification(
        id: notificationId,
        category: NotificationCategory.tasks,
        title: 'Tarefas',
        message: "Tarefa '${task.title}' venceu $label e ainda não foi concluída.",
        timestamp: now,
        relatedId: task.id,
      );

      await _repository.addNotification(notification);
    }
  }

  // ─── Goal progress checks ─────────────────────────────────────────

  /// AMPLIADO: marcos em 25%, 50%, 75%, 90% e 100% (conclusão),
  /// em vez de apenas 50% e 75%.
  Future<void> _checkGoalProgress() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final now = DateTime.now();
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('goals')
        .get();

    const milestoneThresholds = [1.0, 0.9, 0.75, 0.5, 0.25];
    const milestoneKeys = ['100', '90', '75', '50', '25'];

    for (final doc in snapshot.docs) {
      final goal = _goalFromDoc(doc);
      if (goal.progressMode != GoalProgressMode.manualValue ||
          goal.target == null ||
          goal.target! <= 0) {
        continue;
      }

      final rawProgress = (goal.current ?? 0) / goal.target!;
      final progress = rawProgress.clamp(0.0, 1.5);

      String? bucket;
      for (var i = 0; i < milestoneThresholds.length; i++) {
        if (progress >= milestoneThresholds[i]) {
          bucket = milestoneKeys[i];
          break;
        }
      }
      if (bucket == null) continue;

      final notificationId = 'notif_goal_${goal.id}_$bucket';
      final existingSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('notifications')
          .where('id', isEqualTo: notificationId)
          .limit(1)
          .get();

      if (existingSnapshot.docs.isNotEmpty) continue;

      final message = bucket == '100'
          ? "Parabéns! Você concluiu a meta '${goal.title}'! 🎉"
          : "Sua meta '${goal.title}' atingiu $bucket% de conclusão!";

      final notification = AppNotification(
        id: notificationId,
        category: NotificationCategory.goals,
        title: 'Metas',
        message: message,
        timestamp: now,
        relatedId: goal.id,
        progress: progress > 1.0 ? 1.0 : progress,
      );

      await _repository.addNotification(notification);
    }
  }

  // ─── Recurring bills checks ───────────────────────────────────────

  /// Creates notifications for recurring transactions due within the
  /// next 3 days.
  Future<void> _checkRecurringBills() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final now = DateTime.now();
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('recurringTransactions')
        .get();

    for (final doc in snapshot.docs) {
      final recurring = _recurringFromDoc(doc);
      if (!recurring.active) continue;

      var dueThisMonth = DateTime(now.year, now.month, recurring.dayOfMonth);
      if (dueThisMonth.isBefore(DateTime(now.year, now.month, now.day))) {
        dueThisMonth = DateTime(now.year, now.month + 1, recurring.dayOfMonth);
      }
      final daysUntil = dueThisMonth.difference(DateTime(now.year, now.month, now.day)).inDays;
      if (daysUntil < 0 || daysUntil > 3) continue;

      final notificationId =
          'notif_recurring_${recurring.id}_${dueThisMonth.year}_${dueThisMonth.month}';

      final existingSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('notifications')
          .where('id', isEqualTo: notificationId)
          .limit(1)
          .get();

      if (existingSnapshot.docs.isNotEmpty) continue;

      final when = daysUntil == 0 ? 'hoje' : (daysUntil == 1 ? 'amanhã' : 'em $daysUntil dias');
      final notification = AppNotification(
        id: notificationId,
        category: NotificationCategory.finance,
        title: 'Finanças',
        message: "Lembrete: pagamento de '${recurring.title}' vence $when.",
        timestamp: now,
        relatedId: recurring.id,
      );

      await _repository.addNotification(notification);
    }
  }

  // ─── Budget checks ─────────────────────────────────────────────────

  /// AMPLIADO: aviso preventivo aos 80% do limite (categoria "warn"),
  /// além do aviso de estouro já existente aos 100%+ (categoria "over").
  Future<void> _checkOverBudget() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    final budgetsSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('budgets')
        .get();

    final transactionsSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
        .where('type', isEqualTo: 'expense')
        .get();

    final categoryExpenses = <String, double>{};
    for (final doc in transactionsSnapshot.docs) {
      final data = doc.data();
      final category = data['category'] as String? ?? 'Outros';
      final amount = (data['amount'] as num?)?.toDouble() ?? 0;
      categoryExpenses[category] = (categoryExpenses[category] ?? 0) + amount;
    }

    for (final doc in budgetsSnapshot.docs) {
      final data = doc.data();
      final category = data['category'] as String? ?? '';
      final monthlyLimit = (data['monthlyLimit'] as num?)?.toDouble() ?? 0;
      final spent = categoryExpenses[category] ?? 0;

      if (monthlyLimit <= 0) continue;
      final ratio = spent / monthlyLimit;

      if (ratio >= 1.0) {
        final notificationId = 'notif_budget_over_${doc.id}_${now.year}_${now.month}';
        final existingSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('notifications')
            .where('id', isEqualTo: notificationId)
            .limit(1)
            .get();

        if (existingSnapshot.docs.isEmpty) {
          final notification = AppNotification(
            id: notificationId,
            category: NotificationCategory.finance,
            title: 'Finanças',
            message: 'Você ultrapassou o orçamento de $category este mês. '
                'Gastou R\$${spent.toStringAsFixed(2)} de R\$${monthlyLimit.toStringAsFixed(2)}.',
            timestamp: now,
            relatedId: doc.id,
          );
          await _repository.addNotification(notification);
        }
      } else if (ratio >= 0.8) {
        // NOVO: aviso preventivo antes de chegar a estourar.
        final notificationId = 'notif_budget_warn_${doc.id}_${now.year}_${now.month}';
        final existingSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('notifications')
            .where('id', isEqualTo: notificationId)
            .limit(1)
            .get();

        if (existingSnapshot.docs.isEmpty) {
          final notification = AppNotification(
            id: notificationId,
            category: NotificationCategory.finance,
            title: 'Finanças',
            message: 'Está perto do limite do orçamento de $category este mês '
                '(${(ratio * 100).round()}% usado).',
            timestamp: now,
            relatedId: doc.id,
          );
          await _repository.addNotification(notification);
        }
      }
    }
  }

  // ─── Helper: create notification for "all tasks done" ─────────────

  /// Creates a "system" notification when all standalone tasks for the
  /// day are completed.
  Future<void> checkAllTasksDone() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final prefs = await _preferencesService.getPreferences();
    if (!prefs.systemEnabled) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .get();

    final standaloneTasks = snapshot.docs
        .map((doc) => _taskFromDoc(doc))
        .where((t) => t.goalId == null)
        .toList();

    if (standaloneTasks.isEmpty) return;
    if (!standaloneTasks.every((t) => t.isDone)) return;

    final existingSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .where('id', isEqualTo: 'notif_system_all_done')
        .where('isRead', isEqualTo: false)
        .limit(1)
        .get();

    if (existingSnapshot.docs.isNotEmpty) return;

    final notification = AppNotification(
      id: 'notif_system_all_done_${DateTime.now().millisecondsSinceEpoch}',
      category: NotificationCategory.system,
      title: 'Tarefas',
      message: 'Você completou todas as tarefas diárias. Bom trabalho!',
      timestamp: DateTime.now(),
    );

    await _repository.addNotification(notification);
  }

  // ─── Document parsers ─────────────────────────────────────────────

  ContactModel _contactFromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ContactModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'],
      phone: data['phone'],
      relationshipTag: data['relationshipTag'] ?? 'Amigo',
      avatarUrl: data['avatarUrl'],
      isFavorite: data['isFavorite'] ?? false,
      desiredContactFrequencyDays: data['desiredContactFrequencyDays'],
      interactions: _parseInteractions(data['interactions']),
    );
  }

  List<ContactInteraction> _parseInteractions(dynamic raw) {
    if (raw == null || raw is! List) return [];
    return raw.map((e) {
      final map = e as Map<String, dynamic>;
      return ContactInteraction(
        date: (map['date'] as Timestamp).toDate(),
        type: InteractionType.values.firstWhere(
          (t) => t.name == map['type'],
          orElse: () => InteractionType.other,
        ),
        note: map['note'],
      );
    }).toList();
  }

  TaskModel _taskFromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TaskModel(
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
    );
  }

  GoalModel _goalFromDoc(DocumentSnapshot doc) {
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
  }

  RecurringTransactionModel _recurringFromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RecurringTransactionModel(
      id: doc.id,
      title: data['title'] ?? '',
      category: data['category'] ?? 'Outros',
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      type: data['type'] == 'income'
          ? TransactionType.income
          : TransactionType.expense,
      accountId: data['accountId'],
      dayOfMonth: data['dayOfMonth'] ?? 1,
      active: data['active'] ?? true,
      lastGeneratedMonth: data['lastGeneratedMonth'] != null
          ? (data['lastGeneratedMonth'] as Timestamp).toDate()
          : null,
    );
  }
}