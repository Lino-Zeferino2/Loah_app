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
import 'notification_repository.dart';

/// Client-side notification scheduler that runs periodically to check
/// for noteworthy events and writes them to Firestore as notifications.
///
/// This replaces the old [NotificationGenerator] (which generated
/// notifications ephemerally from mock data). Now notifications
/// persist in Firestore and trigger real FCM push notifications
/// via Cloud Functions.
///
/// The scheduler runs:
/// - On app startup
/// - Every 30 minutes while the app is active
/// - When specific data changes (on task completion, contact interaction, etc.)
class NotificationScheduler {
  static final NotificationScheduler _instance = NotificationScheduler._internal();
  factory NotificationScheduler() => _instance;
  NotificationScheduler._internal();

  final NotificationRepository _repository = NotificationRepository();
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

  /// Run all notification checks immediately.
  Future<void> runAllChecks() async {
    if (_isRunning) return;
    _isRunning = true;

    try {
      await Future.wait([
        _checkOverdueContacts(),
        _checkUpcomingTasks(),
        _checkGoalProgress(),
        _checkRecurringBills(),
        _checkOverBudget(),
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

      // Build a deterministic weekly notification ID so we only fire
      // once per week (or per frequency period) per contact — matching
      // the server-side convention.
      final now = DateTime.now();
      final weekAnchor = DateTime.utc(now.year, 1, 1)
          .add(Duration(days: (contact.desiredContactFrequencyDays ?? 7) * (now.weekday - 1)));
      final periodKey =
          '${now.year}_${weekAnchor.month}_${weekAnchor.day}';
      final notificationId =
          'notif_contact_${contact.id}_$periodKey';

      // Check if we already sent this notification for this period
      // Check by ID (deterministic weekly key) first, then by pending
      final idCheck = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('notifications')
          .where('id', isEqualTo: notificationId)
          .limit(1)
          .get();

      if (idCheck.docs.isNotEmpty) continue;

      // Also check if there's any unread notification for this contact
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

  /// Creates notifications for tasks due within the next 24 hours.
  Future<void> _checkUpcomingTasks() async {
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
      if (diff.inHours < 0 || diff.inHours > 24) continue;

      // Check if already notified
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

  // ─── Goal progress checks ─────────────────────────────────────────

  /// Creates notifications for goals that have reached meaningful
  /// progress milestones (50%, 75%, 100%).
  Future<void> _checkGoalProgress() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final now = DateTime.now();
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('goals')
        .get();

    // Fetch all tasks for goal progress calculation
    final tasksSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .get();
    tasksSnapshot.docs.map((doc) => _taskFromDoc(doc)).toList();

    for (final doc in snapshot.docs) {
      final goal = _goalFromDoc(doc);
      // We need to compute progress — for manualValue goals, use current/target
      // For a simplified check, we just look at manualValue percentage
      if (goal.progressMode != GoalProgressMode.manualValue ||
          goal.target == null ||
          goal.target! <= 0) {
        continue;
      }

      final progress = (goal.current ?? 0) / goal.target!;
      if (progress < 0.5 || progress >= 1.0) continue;

      // Check if already notified for this milestone range (50-74% or 75-99%)
      final milestoneBucket = progress < 0.75 ? '50' : '75';
      final existingSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('notifications')
          .where('id', isEqualTo: 'notif_goal_${goal.id}_$milestoneBucket')
          .limit(1)
          .get();

      if (existingSnapshot.docs.isNotEmpty) continue;

      final notification = AppNotification(
        id: 'notif_goal_${goal.id}_$milestoneBucket',
        category: NotificationCategory.goals,
        title: 'Metas',
        message: "Sua meta '${goal.title}' atingiu ${(progress * 100).round()}% de conclusão!",
        timestamp: now,
        relatedId: goal.id,
        progress: progress,
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

      // Check if already notified
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

  // ─── Budget overrun checks ────────────────────────────────────────

  /// Creates notifications when a budget has been exceeded for the month.
  Future<void> _checkOverBudget() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    // Fetch budgets
    final budgetsSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('budgets')
        .get();

    // Fetch this month's transactions for expense calculation
    final transactionsSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
        .where('type', isEqualTo: 'expense')
        .get();

    // Group expenses by category
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

      if (spent <= monthlyLimit) continue;

      // Check if already notified this month
      final notificationId = 'notif_budget_${doc.id}_${now.year}_${now.month}';
      final existingSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('notifications')
          .where('id', isEqualTo: notificationId)
          .limit(1)
          .get();

      if (existingSnapshot.docs.isNotEmpty) continue;

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
  }

  // ─── Helper: create notification for "all tasks done" ─────────────

  /// Creates a "system" notification when all standalone tasks for the
  /// day are completed.
  Future<void> checkAllTasksDone() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

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

