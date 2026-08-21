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
/// CORRIGIDO: todas as notificações agora gravam titleKey/messageKey/
/// params em vez de texto final em português — o NotificationCard
/// monta a frase certa na hora, no idioma atual da app. title/message
/// continuam preenchidos com o texto em português como fallback (por
/// segurança e para não quebrar leituras antigas).
///
/// IMPORTANTE: isto só corre enquanto a app está aberta. Para entrega
/// real com a app fechada (background/terminated), o equivalente
/// server-side já existe em Cloud Functions (index.js).
class NotificationScheduler {
  static final NotificationScheduler _instance = NotificationScheduler._internal();
  factory NotificationScheduler() => _instance;
  NotificationScheduler._internal();

  final NotificationRepository _repository = NotificationRepository();
  final NotificationPreferencesService _preferencesService =
      NotificationPreferencesService();
  Timer? _periodicTimer;

  bool _isRunning = false;

  void startPeriodicChecks({int intervalMinutes = 30}) {
    _periodicTimer?.cancel();
    _periodicTimer = Timer.periodic(
      Duration(minutes: intervalMinutes),
      (_) => runAllChecks(),
    );
  }

  void stopPeriodicChecks() {
    _periodicTimer?.cancel();
    _periodicTimer = null;
  }

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
        if (prefs.financeEnabled) _checkLowAccountBalance(),
        if (prefs.financeEnabled) _checkStaleAssets(),
      ]);
    } catch (e) {
      debugPrint('[NotificationScheduler] Error running checks: $e');
    } finally {
      _isRunning = false;
    }
  }

  // ─── Contact checks ───────────────────────────────────────────────

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
      final periodKey = '${now.year}_${weekAnchor.month}_${weekAnchor.day}';
      final notificationId = 'notif_contact_${contact.id}_$periodKey';

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

      final isLong = contact.daysSinceLastContact >= 999;
      final firstName = contact.name.split(' ').first;

      final notification = AppNotification(
        id: notificationId,
        category: NotificationCategory.contacts,
        title: 'Contatos',
        message: isLong
            ? 'Você não fala com ${contact.name} há muito tempo. Que tal ligar para $firstName?'
            : 'Você não fala com ${contact.name} há ${contact.daysSinceLastContact} dias. Que tal ligar para $firstName?',
        timestamp: now,
        relatedId: contact.id,
        titleKey: 'notif_cat_contatos',
        messageKey: isLong
            ? 'notif_msg_contact_overdue_long'
            : 'notif_msg_contact_overdue_days',
        params: {
          'name': contact.name,
          'firstName': firstName,
          if (!isLong) 'days': '${contact.daysSinceLastContact}',
        },
      );

      await _repository.addNotification(notification);
    }
  }

  // ─── Task checks ──────────────────────────────────────────────────

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

      final isSoon = diff.inHours < 1;
      final label = isSoon ? 'em menos de 1 hora' : 'em ${diff.inHours} horas';

      final notification = AppNotification(
        id: 'notif_task_${task.id}_${now.millisecondsSinceEpoch}',
        category: NotificationCategory.tasks,
        title: 'Tarefas',
        message: "Tarefa '${task.title}' vence $label.",
        timestamp: now,
        relatedId: task.id,
        titleKey: 'notif_cat_tarefas',
        messageKey: isSoon ? 'notif_msg_task_upcoming_soon' : 'notif_msg_task_upcoming_hours',
        params: {
          'title': task.title,
          if (!isSoon) 'hours': '${diff.inHours}',
        },
      );

      await _repository.addNotification(notification);
    }
  }

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
      final messageKey = daysLate <= 0
          ? 'notif_msg_task_overdue_today'
          : (daysLate == 1 ? 'notif_msg_task_overdue_1day' : 'notif_msg_task_overdue_days');
      final label = daysLate <= 0 ? 'hoje' : (daysLate == 1 ? 'há 1 dia' : 'há $daysLate dias');

      final notification = AppNotification(
        id: notificationId,
        category: NotificationCategory.tasks,
        title: 'Tarefas',
        message: "Tarefa '${task.title}' venceu $label e ainda não foi concluída.",
        timestamp: now,
        relatedId: task.id,
        titleKey: 'notif_cat_tarefas',
        messageKey: messageKey,
        params: {
          'title': task.title,
          if (daysLate > 1) 'days': '$daysLate',
        },
      );

      await _repository.addNotification(notification);
    }
  }

  // ─── Goal progress checks ─────────────────────────────────────────

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

      final isCompleted = bucket == '100';
      final message = isCompleted
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
        titleKey: 'notif_cat_metas',
        messageKey: isCompleted ? 'notif_msg_goal_completed' : 'notif_msg_goal_milestone',
        params: {
          'title': goal.title,
          if (!isCompleted) 'pct': bucket,
        },
      );

      await _repository.addNotification(notification);
    }
  }

  // ─── Recurring bills checks ───────────────────────────────────────

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

      final messageKey = daysUntil == 0
          ? 'notif_msg_recurring_today'
          : (daysUntil == 1 ? 'notif_msg_recurring_tomorrow' : 'notif_msg_recurring_days');
      final when = daysUntil == 0 ? 'hoje' : (daysUntil == 1 ? 'amanhã' : 'em $daysUntil dias');

      final notification = AppNotification(
        id: notificationId,
        category: NotificationCategory.finance,
        title: 'Finanças',
        message: "Lembrete: pagamento de '${recurring.title}' vence $when.",
        timestamp: now,
        relatedId: recurring.id,
        titleKey: 'notif_cat_financas',
        messageKey: messageKey,
        params: {
          'title': recurring.title,
          if (daysUntil > 1) 'days': '$daysUntil',
        },
      );

      await _repository.addNotification(notification);
    }
  }

  // ─── Budget checks ─────────────────────────────────────────────────

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
            titleKey: 'notif_cat_financas',
            messageKey: 'notif_msg_budget_over',
            params: {
              'category': category,
              'spent': 'R\$${spent.toStringAsFixed(2)}',
              'limit': 'R\$${monthlyLimit.toStringAsFixed(2)}',
            },
          );
          await _repository.addNotification(notification);
        }
      } else if (ratio >= 0.8) {
        final notificationId = 'notif_budget_warn_${doc.id}_${now.year}_${now.month}';
        final existingSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('notifications')
            .where('id', isEqualTo: notificationId)
            .limit(1)
            .get();

        if (existingSnapshot.docs.isEmpty) {
          final pct = (ratio * 100).round();
          final notification = AppNotification(
            id: notificationId,
            category: NotificationCategory.finance,
            title: 'Finanças',
            message: 'Está perto do limite do orçamento de $category este mês '
                '($pct% usado).',
            timestamp: now,
            relatedId: doc.id,
            titleKey: 'notif_cat_financas',
            messageKey: 'notif_msg_budget_warn',
            params: {
              'category': category,
              'pct': '$pct',
            },
          );
          await _repository.addNotification(notification);
        }
      }
    }
  }

  /// Cria notificações quando o saldo calculado de uma conta fica
  /// negativo ou muito baixo. Saldo = initialBalance + soma das
  /// transações ligadas a essa conta.
  Future<void> _checkLowAccountBalance() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    const lowBalanceThreshold = 50.0;
    final now = DateTime.now();

    final accountsSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('accounts')
        .get();

    final transactionsSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .get();

    final balanceDeltaByAccount = <String, double>{};
    for (final doc in transactionsSnapshot.docs) {
      final data = doc.data();
      final accountId = data['accountId'] as String?;
      if (accountId == null) continue;
      final amount = (data['amount'] as num?)?.toDouble() ?? 0;
      final isIncome = data['type'] == 'income';
      balanceDeltaByAccount[accountId] =
          (balanceDeltaByAccount[accountId] ?? 0) + (isIncome ? amount : -amount);
    }

    for (final doc in accountsSnapshot.docs) {
      final data = doc.data();
      final initialBalance = (data['initialBalance'] as num?)?.toDouble() ?? 0;
      final delta = balanceDeltaByAccount[doc.id] ?? 0;
      final currentBalance = initialBalance + delta;

      if (currentBalance >= lowBalanceThreshold) continue;

      final name = data['name'] as String? ?? '';
      final isNegative = currentBalance < 0;

      final dayKey = '${now.year}_${now.month}_${now.day}';
      final notificationId = 'notif_low_balance_${doc.id}_$dayKey';

      final existing = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('notifications')
          .where('id', isEqualTo: notificationId)
          .limit(1)
          .get();
      if (existing.docs.isNotEmpty) continue;

      final amountLabel = 'R\$${currentBalance.toStringAsFixed(2)}';
      final message = isNegative
          ? "A conta '$name' está com saldo negativo: $amountLabel."
          : "A conta '$name' está com saldo baixo: $amountLabel.";

      final notification = AppNotification(
        id: notificationId,
        category: NotificationCategory.finance,
        title: 'Finanças',
        message: message,
        timestamp: now,
        relatedId: doc.id,
        titleKey: 'notif_cat_financas',
        messageKey: isNegative ? 'notif_msg_balance_negative' : 'notif_msg_balance_low',
        params: {
          'name': name,
          'amount': amountLabel,
        },
      );

      await _repository.addNotification(notification);
    }
  }

  /// Avisa quando um ativo não é atualizado há 30+ dias.
  Future<void> _checkStaleAssets() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    const staleDaysThreshold = 30;
    final now = DateTime.now();

    final assetsSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('assets')
        .get();

    for (final doc in assetsSnapshot.docs) {
      final data = doc.data();
      final updatedAt = data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null;
      if (updatedAt == null) continue;

      final daysSinceUpdate = now.difference(updatedAt).inDays;
      if (daysSinceUpdate < staleDaysThreshold) continue;

      final bucket = daysSinceUpdate ~/ 30;
      final notificationId = 'notif_stale_asset_${doc.id}_$bucket';

      final existing = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('notifications')
          .where('id', isEqualTo: notificationId)
          .limit(1)
          .get();
      if (existing.docs.isNotEmpty) continue;

      final name = data['name'] as String? ?? '';
      final notification = AppNotification(
        id: notificationId,
        category: NotificationCategory.finance,
        title: 'Finanças',
        message: "O valor de '$name' não é atualizado há $daysSinceUpdate dias. "
            "Vale a pena confirmar se ainda está correto.",
        timestamp: now,
        relatedId: doc.id,
        titleKey: 'notif_cat_financas',
        messageKey: 'notif_msg_stale_asset',
        params: {
          'name': name,
          'days': '$daysSinceUpdate',
        },
      );

      await _repository.addNotification(notification);
    }
  }

  // ─── Helper: create notification for "all tasks done" ─────────────

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
      titleKey: 'notif_cat_tarefas',
      messageKey: 'notif_msg_all_tasks_done',
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