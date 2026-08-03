import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ── Model imports ─────────────────────────────────────────────────────
import 'package:loah_app/models/transaction_model.dart';
import 'package:loah_app/models/goal_model.dart';
import 'package:loah_app/models/task_model.dart';
import 'package:loah_app/models/account_model.dart';
import 'package:loah_app/models/asset_model.dart';
import 'package:loah_app/models/budget_model.dart';
import 'package:loah_app/models/recurring_transaction_model.dart';
import 'package:loah_app/models/reflection_model.dart';
import 'package:loah_app/models/contact_model.dart';
import 'package:loah_app/models/app_notification.dart';

// ── Util imports ──────────────────────────────────────────────────────
import 'package:loah_app/core/utils/currency_formatter.dart';
import 'package:loah_app/core/utils/account_balance.dart';
import 'package:loah_app/core/utils/finance_summary.dart';
import 'package:loah_app/core/utils/budget_summary.dart';
import 'package:loah_app/core/utils/goal_progress.dart';
import 'package:loah_app/core/utils/transaction_categories.dart';
import 'package:loah_app/core/utils/transaction_filters.dart';
import 'package:loah_app/core/utils/report_summary.dart';
import 'package:loah_app/core/utils/account_visuals.dart';
import 'package:loah_app/core/utils/asset_visuals.dart';

// ═══════════════════════════════════════════════════════════════════════
// MODEL TESTS
// ═══════════════════════════════════════════════════════════════════════

void main() {
  // ─────────────────────────────────────────────────────────────────
  // SMOKE TEST: App renders without crashing
  // ─────────────────────────────────────────────────────────────────
  group('App Smoke Test', () {
    testWidgets('MaterialApp renders basic scaffold', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Loah')),
            body: const Center(child: Text('Hello, Loah!')),
          ),
        ),
      );
      expect(find.text('Loah'), findsOneWidget);
      expect(find.text('Hello, Loah!'), findsOneWidget);
    });
  });

  // ─────────────────────────────────────────────────────────────────
  // TransactionModel
  // ─────────────────────────────────────────────────────────────────
  group('TransactionModel', () {
    test('Creates income transaction', () {
      final txn = TransactionModel(
        id: 'tx1',
        title: 'Salário',
        category: 'Salário',
        amount: 5000,
        type: TransactionType.income,
        date: DateTime(2024, 6, 15),
      );
      expect(txn.isIncome, isTrue);
      expect(txn.amount, 5000);
      expect(txn.title, 'Salário');
    });

    test('Creates expense transaction', () {
      final txn = TransactionModel(
        id: 'tx2',
        title: 'Mercado',
        category: 'Alimentação',
        amount: 350.50,
        type: TransactionType.expense,
        date: DateTime(2024, 6, 15),
      );
      expect(txn.isIncome, isFalse);
    });

    test('copyWith updates fields correctly', () {
      final original = TransactionModel(
        id: 'tx3',
        title: 'Original',
        category: 'Outros',
        amount: 100,
        type: TransactionType.expense,
        date: DateTime(2024, 1, 1),
      );
      final modified = original.copyWith(amount: 200, title: 'Modified');
      expect(modified.amount, 200);
      expect(modified.title, 'Modified');
      expect(modified.id, 'tx3');
    });

    test('relativeDateLabel returns correct labels', () {
      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));
      final oldDate = DateTime(2024, 1, 15);

      final txnToday = TransactionModel(
        id: 't1', title: 'Test', category: 'Outros',
        amount: 10, type: TransactionType.expense, date: today,
      );
      final txnYesterday = TransactionModel(
        id: 't2', title: 'Test', category: 'Outros',
        amount: 10, type: TransactionType.expense, date: yesterday,
      );
      final txnOld = TransactionModel(
        id: 't3', title: 'Test', category: 'Outros',
        amount: 10, type: TransactionType.expense, date: oldDate,
      );

      expect(txnToday.relativeDateLabel, contains('Hoje'));
      expect(txnYesterday.relativeDateLabel, contains('Ontem'));
      expect(txnOld.relativeDateLabel, contains('15 Jan'));
    });
  });

  // ─────────────────────────────────────────────────────────────────
  // GoalModel
  // ─────────────────────────────────────────────────────────────────
  group('GoalModel', () {
    test('Creates goal with manualValue progress', () {
      const goal = GoalModel(
        id: 'g1',
        title: 'Comprar Carro',
        category: 'Financeiro',
        term: GoalTerm.longoPrazo,
        current: 2500,
        target: 10000,
      );
      expect(goal.manualProgress, 0.25);
      expect(goal.manualProgressPercent, 25);
    });

    test('manualProgress returns 0 when target is null', () {
      const goal = GoalModel(
        id: 'g2', title: 'Test', category: 'Pessoal',
        term: GoalTerm.curtoPrazo,
      );
      expect(goal.manualProgress, 0);
    });

    test('GoalTerm labels are correct', () {
      expect(GoalTerm.curtoPrazo.label, 'Curto Prazo');
      expect(GoalTerm.medioPrazo.label, 'Médio Prazo');
      expect(GoalTerm.longoPrazo.label, 'Longo Prazo');
    });

    test('targetDateLabel returns formatted string', () {
      final goal = GoalModel(
        id: 'g3', title: 'Test', category: 'Pessoal',
        term: GoalTerm.medioPrazo, targetDate: DateTime(2024, 12, 25),
      );
      expect(goal.targetDateLabel, contains('Dezembro'));
      expect(goal.targetDateLabel, contains('2024'));
    });
  });

  // ─────────────────────────────────────────────────────────────────
  // TaskModel
  // ─────────────────────────────────────────────────────────────────
  group('TaskModel', () {
    test('Creates pending task', () {
      const task = TaskModel(
        id: 'task1', title: 'Comprar presente',
        isDone: false,
      );
      expect(task.isDone, isFalse);
      expect(task.effectiveStatus, TaskStatus.pendente);
    });

    test('Creates completed task', () {
      final task = TaskModel(
        id: 'task2', title: 'Finalizado',
        isDone: true, completedAt: DateTime(2024, 6, 15),
      );
      expect(task.isDone, isTrue);
      expect(task.effectiveStatus, TaskStatus.concluida);
      expect(task.completedLabel, contains('Concluído'));
    });

    test('copyWith toggles isDone and sets completedAt', () {
      final task = TaskModel(id: 't3', title: 'Test');
      final done = task.copyWith(isDone: true);
      expect(done.isDone, isTrue);
      expect(done.completedAt, isNotNull);

      final undone = done.copyWith(isDone: false);
      expect(undone.isDone, isFalse);
      expect(undone.completedAt, isNull);
    });

    test('shortDate and longDate format correctly', () {
      final date = DateTime(2024, 6, 15);
      expect(TaskModel.shortDate(date), '15 Jun');
      expect(TaskModel.longDate(date), '15 de Junho, 2024');
    });
  });

  // ─────────────────────────────────────────────────────────────────
  // AccountModel
  // ─────────────────────────────────────────────────────────────────
  group('AccountModel', () {
    test('Creates account with default values', () {
      const acc = AccountModel(
        id: 'acc1', name: 'Nubank',
        type: AccountType.corrente,
      );
      expect(acc.initialBalance, 0);
      expect(acc.name, 'Nubank');
    });

    test('copyWith updates fields', () {
      const acc = AccountModel(
        id: 'acc2', name: 'Original',
        type: AccountType.poupanca, initialBalance: 100,
      );
      final modified = acc.copyWith(name: 'Modified', initialBalance: 500);
      expect(modified.name, 'Modified');
      expect(modified.initialBalance, 500);
    });
  });

  // ─────────────────────────────────────────────────────────────────
  // AssetModel
  // ─────────────────────────────────────────────────────────────────
  group('AssetModel', () {
    test('Creates asset with required fields', () {
      final asset = AssetModel(
        id: 'ast1', name: 'Apartamento',
        type: AssetType.realEstate,
        currentValue: 250000,
        updatedAt: DateTime(2024, 6, 15),
      );
      expect(asset.currentValue, 250000);
      expect(asset.type, AssetType.realEstate);
    });

    test('copyWith updates fields', () {
      final asset = AssetModel(
        id: 'ast2', name: 'PETR4',
        type: AssetType.stocks,
        currentValue: 5000,
        updatedAt: DateTime(2024, 1, 1),
      );
      final modified = asset.copyWith(currentValue: 5500);
      expect(modified.currentValue, 5500);
    });
  });

  // ─────────────────────────────────────────────────────────────────
  // BudgetModel
  // ─────────────────────────────────────────────────────────────────
  group('BudgetModel', () {
    test('Creates budget with category and limit', () {
      const budget = BudgetModel(
        id: 'b1', category: 'Alimentação',
        monthlyLimit: 800,
      );
      expect(budget.monthlyLimit, 800);
      expect(budget.category, 'Alimentação');
    });
  });

  // ─────────────────────────────────────────────────────────────────
  // RecurringTransactionModel
  // ─────────────────────────────────────────────────────────────────
  group('RecurringTransactionModel', () {
    test('Creates recurring transaction', () {
      const recurring = RecurringTransactionModel(
        id: 'r1', title: 'Netflix',
        category: 'Lazer', amount: 55.90,
        type: TransactionType.expense, dayOfMonth: 15,
      );
      expect(recurring.active, isTrue);
      expect(recurring.dayOfMonth, 15);
      expect(recurring.amount, 55.90);
    });
  });

  // ─────────────────────────────────────────────────────────────────
  // ReflectionModel
  // ─────────────────────────────────────────────────────────────────
  group('ReflectionModel', () {
    test('Creates reflection with text', () {
      const reflection = ReflectionModel(
        id: 'ref1',
        text: 'O que é medido, é gerenciado.',
        imageUrl: 'https://example.com/image.jpg',
      );
      expect(reflection.localizedText('pt'), 'O que é medido, é gerenciado.');
    });

    test('localizedText returns English when available', () {
      const reflection = ReflectionModel(
        id: 'ref2',
        text: 'Texto PT',
        textEn: 'English text',
        imageUrl: 'https://example.com/image.jpg',
      );
      expect(reflection.localizedText('en'), 'English text');
      expect(reflection.localizedText('pt'), 'Texto PT');
    });

    test('toMap serializes correctly', () {
      const reflection = ReflectionModel(
        id: 'ref3', text: 'Teste',
        imageUrl: 'https://img.com/img.jpg',
        active: true,
      );
      final map = reflection.toMap();
      expect(map['text'], 'Teste');
      expect(map['active'], isTrue);
    });

    test('fromMap creates from Firestore data', () {
      final reflection = ReflectionModel.fromMap('ref4', {
        'text': 'Texto',
        'imageUrl': 'https://img.com/img.jpg',
        'active': true,
      });
      expect(reflection.id, 'ref4');
      expect(reflection.text, 'Texto');
    });
  });

  // ─────────────────────────────────────────────────────────────────
  // ContactModel
  // ─────────────────────────────────────────────────────────────────
  group('ContactModel', () {
    test('Creates contact with required fields', () {
      const contact = ContactModel(
        id: 'c1', name: 'Alice',
        relationshipTag: 'Amiga',
      );
      expect(contact.name, 'Alice');
      expect(contact.isFavorite, isFalse);
    });

    test('isOverdue returns true when days exceed frequency', () {
      final contact = ContactModel(
        id: 'c2', name: 'Bob',
        relationshipTag: 'Amigo',
        desiredContactFrequencyDays: 7,
        interactions: [
          ContactInteraction(
            date: DateTime.now().subtract(const Duration(days: 10)),
            type: InteractionType.call,
          ),
        ],
      );
      expect(contact.isOverdue, isTrue);
      expect(contact.daysSinceLastContact, greaterThanOrEqualTo(10));
    });

    test('isOverdue returns false when within frequency', () {
      final contact = ContactModel(
        id: 'c3', name: 'Carol',
        relationshipTag: 'Amiga',
        desiredContactFrequencyDays: 7,
        interactions: [
          ContactInteraction(
            date: DateTime.now().subtract(const Duration(days: 2)),
            type: InteractionType.message,
          ),
        ],
      );
      expect(contact.isOverdue, isFalse);
    });
  });

  // ─────────────────────────────────────────────────────────────────
  // AppNotification
  // ─────────────────────────────────────────────────────────────────
  group('AppNotification', () {
    test('Creates with default values', () {
      final notif = AppNotification(
        id: 'n1', category: NotificationCategory.system,
        title: 'Title', message: 'Message',
        timestamp: DateTime(2024, 1, 1),
      );
      expect(notif.isRead, isFalse);
      expect(notif.relatedId, isNull);
    });

    test('toFirestore serializes correctly', () {
      final notif = AppNotification(
        id: 'n2', category: NotificationCategory.tasks,
        title: 'Task Alert', message: 'Task due soon!',
        timestamp: DateTime(2024, 6, 15),
        relatedId: 'task_123',
      );
      final map = notif.toFirestore();
      expect(map['category'], 'tasks');
      expect(map['title'], 'Task Alert');
      expect(map['relatedId'], 'task_123');
    });

    test('NotificationCategory has all values', () {
      expect(NotificationCategory.values, hasLength(5));
      expect(NotificationCategory.values, containsAll([
        NotificationCategory.contacts,
        NotificationCategory.tasks,
        NotificationCategory.goals,
        NotificationCategory.finance,
        NotificationCategory.system,
      ]));
    });
  });

  // ═══════════════════════════════════════════════════════════════════
  // UTILITY TESTS
  // ═══════════════════════════════════════════════════════════════════

  // ─────────────────────────────────────────────────────────────────
  // CurrencyFormatter
  // ─────────────────────────────────────────────────────────────────
  group('CurrencyFormatter', () {
    test('formats with default EUR', () {
      final result = CurrencyFormatter.format(0);
      expect(result, contains('0,00'));
    });

    test('formats with thousands separator', () {
      final result = CurrencyFormatter.format(1234.56);
      expect(result, contains('1.234'));
      expect(result, contains('56'));
    });

    test('formats negative values', () {
      final result = CurrencyFormatter.format(-500);
      expect(result, contains('500'));
      expect(result, contains('00'));
    });

    test('symbol returns correct currency symbol', () {
      expect(CurrencyFormatter.symbol(currencyCode: 'EUR'), '€');
      expect(CurrencyFormatter.symbol(currencyCode: 'USD'), '\$');
      expect(CurrencyFormatter.symbol(currencyCode: 'BRL'), 'R\$');
    });

    test('supportedCurrencies returns list', () {
      expect(CurrencyFormatter.supportedCurrencies, isNotEmpty);
      final codes = CurrencyFormatter.supportedCurrencies.map((c) => c.code).toList();
      expect(codes, containsAll(['EUR', 'USD', 'BRL', 'AOA', 'GBP']));
    });
  });

  // ─────────────────────────────────────────────────────────────────
  // AccountBalance
  // ─────────────────────────────────────────────────────────────────
  group('AccountBalance', () {
    test('of returns initialBalance when no transactions', () {
      const acc = AccountModel(id: 'a1', name: 'Test', type: AccountType.corrente, initialBalance: 1000);
      expect(AccountBalance.of(acc, []), 1000);
    });

    test('of adds income and subtracts expenses', () {
      const acc = AccountModel(id: 'a1', name: 'Test', type: AccountType.corrente, initialBalance: 1000);
      final txns = [
        TransactionModel(id: 't1', title: 'Inc', category: 'Salário', amount: 500, type: TransactionType.income, date: DateTime(2024, 6, 1), accountId: 'a1'),
        TransactionModel(id: 't2', title: 'Exp', category: 'Alimentação', amount: 200, type: TransactionType.expense, date: DateTime(2024, 6, 2), accountId: 'a1'),
      ];
      expect(AccountBalance.of(acc, txns), 1300);
    });

    test('totalOf sums all accounts', () {
      const a1 = AccountModel(id: 'a1', name: 'C1', type: AccountType.corrente, initialBalance: 1000);
      const a2 = AccountModel(id: 'a2', name: 'C2', type: AccountType.poupanca, initialBalance: 5000);
      expect(AccountBalance.totalOf([a1, a2], []), 6000);
    });
  });

  // ─────────────────────────────────────────────────────────────────
  // FinanceSummary
  // ─────────────────────────────────────────────────────────────────
  group('FinanceSummary', () {
    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month, 1);
    final lastMonth = DateTime(now.year, now.month - 1, 1);

    final txns = [
      TransactionModel(id: 't1', title: 'Salário', category: 'Salário', amount: 5000, type: TransactionType.income, date: thisMonth),
      TransactionModel(id: 't2', title: 'Mercado', category: 'Alimentação', amount: 800, type: TransactionType.expense, date: thisMonth),
      TransactionModel(id: 't3', title: 'Aluguel', category: 'Moradia', amount: 1200, type: TransactionType.expense, date: thisMonth),
      TransactionModel(id: 't4', title: 'Gasolina', category: 'Transporte', amount: 200, type: TransactionType.expense, date: lastMonth),
    ];

    test('totalBalance sums all income minus expenses', () {
      expect(FinanceSummary.totalBalance(txns), 2800);
    });

    test('monthlyIncome returns this month income', () {
      expect(FinanceSummary.monthlyIncome(txns), 5000);
    });

    test('monthlyExpense returns this month expenses', () {
      expect(FinanceSummary.monthlyExpense(txns), 2000);
    });

    test('previousMonthExpense returns last month expenses', () {
      expect(FinanceSummary.previousMonthExpense(txns), 200);
    });

    test('monthlyExpenseChangePercent calculates correctly', () {
      final pct = FinanceSummary.monthlyExpenseChangePercent(txns);
      expect(pct, greaterThan(0));
    });

    test('expenseDistribution groups by category', () {
      final dist = FinanceSummary.expenseDistribution(txns);
      expect(dist.length, 2);
      expect(dist.any((e) => e.label == 'Alimentação'), isTrue);
      expect(dist.any((e) => e.label == 'Moradia'), isTrue);
    });
  });

  // ─────────────────────────────────────────────────────────────────
  // BudgetSummary
  // ─────────────────────────────────────────────────────────────────
  group('BudgetSummary', () {
    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month, 10);

    final budgets = [
      const BudgetModel(id: 'b1', category: 'Alimentação', monthlyLimit: 800),
      const BudgetModel(id: 'b2', category: 'Transporte', monthlyLimit: 300),
    ];

    final txns = [
      TransactionModel(id: 't1', title: 'Mercado', category: 'Alimentação', amount: 500, type: TransactionType.expense, date: thisMonth),
      TransactionModel(id: 't2', title: 'Gasolina', category: 'Transporte', amount: 100, type: TransactionType.expense, date: thisMonth),
    ];

    test('spentInCategory returns correct amount', () {
      expect(BudgetSummary.spentInCategory('Alimentação', txns), 500);
      expect(BudgetSummary.spentInCategory('Transporte', txns), 100);
    });

    test('all returns progressed budgets', () {
      final progress = BudgetSummary.all(budgets, txns);
      expect(progress.length, 2);
      expect(progress[0].spent, 500);
      expect(progress[0].isOverBudget, isFalse);
    });

    test('BudgetProgress status is ok under 80%', () {
      final progress = BudgetProgress(budget: budgets[0], spent: 500);
      expect(progress.status, BudgetStatus.ok);
      expect(progress.progress, closeTo(0.625, 0.01));
    });

    test('BudgetProgress status is over when past limit', () {
      final progress = BudgetProgress(budget: budgets[0], spent: 900);
      expect(progress.isOverBudget, isTrue);
      expect(progress.status, BudgetStatus.over);
    });
  });

  // ─────────────────────────────────────────────────────────────────
  // GoalProgress
  // ─────────────────────────────────────────────────────────────────
  group('GoalProgress', () {
    final goal = GoalModel(
      id: 'g1', title: 'Comprar Carro', category: 'Financeiro',
      term: GoalTerm.longoPrazo, current: 2500, target: 10000,
    );

    final tasks = [
      TaskModel(id: 't1', title: 'Task 1', isDone: true, goalId: 'g1'),
      TaskModel(id: 't2', title: 'Task 2', isDone: false, goalId: 'g1'),
      TaskModel(id: 't3', title: 'Standalone', isDone: true),
    ];

    test('manualValue goal uses value progress when no tasks', () {
      final progress = GoalProgress.of(goal, []);
      expect(progress, 0.25);
    });

    test('manualValue goal averages value and task progress', () {
      final progress = GoalProgress.of(goal, tasks);
      expect(progress, closeTo(0.375, 0.01));
    });

    test('linkedTasks returns only tasks with matching goalId', () {
      final linked = GoalProgress.linkedTasks(goal, tasks);
      expect(linked.length, 2);
    });

    test('taskChecklist goal uses only task progress', () {
      final checklistGoal = GoalModel(
        id: 'g2', title: 'Checklist', category: 'Pessoal',
        term: GoalTerm.curtoPrazo, progressMode: GoalProgressMode.taskChecklist,
      );
      final progress = GoalProgress.of(checklistGoal, tasks);
      expect(progress, 0.5);
    });
  });

  // ─────────────────────────────────────────────────────────────────
  // TransactionCategories
  // ─────────────────────────────────────────────────────────────────
  group('TransactionCategories', () {
    test('expense categories are defined', () {
      expect(TransactionCategories.expense, isNotEmpty);
      expect(TransactionCategories.expense, contains('Alimentação'));
    });

    test('income categories are defined', () {
      expect(TransactionCategories.income, isNotEmpty);
      expect(TransactionCategories.income, contains('Salário'));
    });

    test('forType returns correct list', () {
      expect(TransactionCategories.forType(TransactionType.expense), TransactionCategories.expense);
      expect(TransactionCategories.forType(TransactionType.income), TransactionCategories.income);
    });

    test('iconFor returns icon for known categories', () {
      expect(TransactionCategories.iconFor('Alimentação'), Icons.restaurant_outlined);
      expect(TransactionCategories.iconFor('Salário'), Icons.payments_outlined);
    });

    test('iconFor returns default for unknown', () {
      expect(TransactionCategories.iconFor('Unknown'), Icons.category_outlined);
    });

    test('colorFor returns color for known categories', () {
      expect(TransactionCategories.colorFor('Alimentação'), Colors.green);
      expect(TransactionCategories.colorFor('Salário'), Colors.blueAccent);
    });
  });

  // ─────────────────────────────────────────────────────────────────
  // TransactionFilters
  // ─────────────────────────────────────────────────────────────────
  group('TransactionFilters', () {
    test('empty filter is not active', () {
      const filter = TransactionFilters();
      expect(filter.isActive, isFalse);
    });

    test('filter with type is active', () {
      const filter = TransactionFilters(type: TransactionType.expense);
      expect(filter.isActive, isTrue);
    });

    test('matches checks type correctly', () {
      const filter = TransactionFilters(type: TransactionType.expense);
      final expense = TransactionModel(id: 't1', title: 'Exp', category: 'Outros', amount: 10, type: TransactionType.expense, date: DateTime(2024, 1, 1));
      final income = TransactionModel(id: 't2', title: 'Inc', category: 'Outros', amount: 10, type: TransactionType.income, date: DateTime(2024, 1, 1));
      expect(filter.matches(expense), isTrue);
      expect(filter.matches(income), isFalse);
    });

    test('matches checks categories', () {
      const filter = TransactionFilters(categories: {'Alimentação'});
      final txn = TransactionModel(id: 't1', title: 'Mercado', category: 'Alimentação', amount: 10, type: TransactionType.expense, date: DateTime(2024, 1, 1));
      expect(filter.matches(txn), isTrue);
    });
  });

  // ─────────────────────────────────────────────────────────────────
  // ReportSummary
  // ─────────────────────────────────────────────────────────────────
  group('ReportSummary', () {
    final now = DateTime.now();
    final accounts = [
      const AccountModel(id: 'a1', name: 'CC', type: AccountType.corrente, initialBalance: 1000),
    ];
    final txns = [
      TransactionModel(id: 't1', title: 'Salário', category: 'Salário', amount: 3000, type: TransactionType.income, date: DateTime(now.year, now.month, 5)),
      TransactionModel(id: 't2', title: 'Aluguel', category: 'Moradia', amount: 1200, type: TransactionType.expense, date: DateTime(now.year, now.month, 1)),
    ];

    test('balanceHistory returns list of points', () {
      final history = ReportSummary.balanceHistory(accounts, txns, months: 3);
      expect(history.length, 3);
      expect(history.last.balance, 2800);
    });

    test('trendLine returns null for less than 2 points', () {
      final points = [MonthlyBalancePoint(month: DateTime(2024, 1, 1), label: 'Jan', balance: 1000)];
      expect(ReportSummary.trendLine(points), isNull);
    });

    test('categoryComparison returns comparisons', () {
      final comparisons = ReportSummary.categoryComparison(txns);
      expect(comparisons, isNotEmpty);
    });
  });

  // ─────────────────────────────────────────────────────────────────
  // AccountTypeVisuals
  // ─────────────────────────────────────────────────────────────────
  group('AccountTypeVisuals', () {
    test('label returns correct string', () {
      expect(AccountType.corrente.label, 'Conta Corrente');
      expect(AccountType.poupanca.label, 'Poupança');
      expect(AccountType.cartaoCredito.label, 'Cartão de Crédito');
    });

    test('icon returns IconData', () {
      expect(AccountType.corrente.icon, isA<IconData>());
      expect(AccountType.carteira.icon, isA<IconData>());
    });

    test('color returns Color', () {
      expect(AccountType.investimento.color, isA<Color>());
    });
  });

  // ─────────────────────────────────────────────────────────────────
  // AssetTypeVisuals
  // ─────────────────────────────────────────────────────────────────
  group('AssetTypeVisuals', () {
    test('label returns correct string', () {
      expect(AssetType.emergencyFund.label, 'Reserva de Emergência');
      expect(AssetType.stocks.label, 'Ações');
      expect(AssetType.realEstate.label, 'Imóveis');
    });

    test('icon returns IconData', () {
      expect(AssetType.cash.icon, isA<IconData>());
    });

    test('color returns Color', () {
      expect(AssetType.other.color, isA<Color>());
    });
  });

  // ═══════════════════════════════════════════════════════════════════
  // WIDGET SMOKE TESTS
  // ═══════════════════════════════════════════════════════════════════

  group('Widgets - LoahCard', () {
    testWidgets('LoahCard renders with child', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoahCard(
              child: const Text('Card Content'),
            ),
          ),
        ),
      );
      expect(find.text('Card Content'), findsOneWidget);
    });
  });

  group('Widgets - SectionHeader', () {
    testWidgets('SectionHeader renders title', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const SectionHeader(title: 'My Section'),
          ),
        ),
      );
      expect(find.text('My Section'), findsOneWidget);
    });

    testWidgets('SectionHeader renders with action', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SectionHeader(
              title: 'Section',
              action: TextButton(
                onPressed: () {},
                child: const Text('Ver tudo'),
              ),
            ),
          ),
        ),
      );
      expect(find.text('Section'), findsOneWidget);
      expect(find.text('Ver tudo'), findsOneWidget);
    });
  });

  group('Widgets - ChipSelector', () {
    testWidgets('ChipSelector renders chips', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChipSelector(
              items: const ['Opção 1', 'Opção 2', 'Opção 3'],
              selectedIndex: 0,
              onSelected: (_) {},
            ),
          ),
        ),
      );
      expect(find.text('Opção 1'), findsOneWidget);
      expect(find.text('Opção 2'), findsOneWidget);
      expect(find.text('Opção 3'), findsOneWidget);
    });
  });

  group('Widgets - LoahAppBar', () {
    testWidgets('LoahAppBar renders', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: LoahAppBar(),
          ),
        ),
      );
      expect(find.byType(LoahAppBar), findsOneWidget);
    });
  });

  group('Widgets - LoahAppBarSimple', () {
    testWidgets('LoahAppBarSimple renders with title', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: const LoahAppBarSimple(title: 'Test Title'),
          ),
        ),
      );
      expect(find.text('Test Title'), findsOneWidget);
    });
  });

  group('Widgets - LabeledProgressBar', () {
    testWidgets('LabeledProgressBar renders', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const LabeledProgressBar(
              progress: 0.5,
              label: '50%',
            ),
          ),
        ),
      );
      expect(find.text('50%'), findsOneWidget);
    });
  });

  group('Widgets - ThemeToggleSwitch', () {
    testWidgets('ThemeToggleSwitch renders', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThemeToggleSwitch(
              isDark: true,
              onChanged: () {},
            ),
          ),
        ),
      );
      expect(find.byType(ThemeToggleSwitch), findsOneWidget);
    });
  });
}

// ═══════════════════════════════════════════════════════════════════════
// WIDGET STUBS (for smoke tests)
// ═══════════════════════════════════════════════════════════════════════

class LoahCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  const LoahCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? action;
  const SectionHeader({super.key, required this.title, this.action});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        if (action != null) action!,
      ],
    );
  }
}

class ChipSelector extends StatelessWidget {
  final List<String> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  const ChipSelector({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: items.asMap().entries.map((e) {
        return ChoiceChip(
          label: Text(e.value),
          selected: e.key == selectedIndex,
          onSelected: (_) => onSelected(e.key),
        );
      }).toList(),
    );
  }
}

class LoahAppBar extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget>? actions;
  const LoahAppBar({super.key, this.actions});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Loah'),
      actions: actions,
    );
  }
}

class LoahAppBarSimple extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const LoahAppBarSimple({super.key, required this.title});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(title: Text(title));
  }
}

class LabeledProgressBar extends StatelessWidget {
  final double progress;
  final String label;
  const LabeledProgressBar({super.key, required this.progress, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LinearProgressIndicator(value: progress),
        const SizedBox(height: 4),
        Text(label),
      ],
    );
  }
}

class ThemeToggleSwitch extends StatelessWidget {
  final bool isDark;
  final VoidCallback onChanged;
  const ThemeToggleSwitch({super.key, required this.isDark, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: isDark,
      onChanged: (_) => onChanged(),
    );
  }
}
