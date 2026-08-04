import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ── App controllers ────────────────────────────────────────────────
import 'package:loah_app/core/currency/currency_controller.dart';
import 'package:loah_app/core/l10n/locale_controller.dart';
import 'package:loah_app/core/theme/app_theme.dart';
import 'package:loah_app/core/theme/theme_controller.dart';

// ── Models ─────────────────────────────────────────────────────────
import 'package:loah_app/models/account_model.dart';
import 'package:loah_app/models/app_notification.dart';
import 'package:loah_app/models/asset_model.dart';
import 'package:loah_app/models/budget_model.dart';
import 'package:loah_app/models/contact_model.dart';
import 'package:loah_app/models/goal_model.dart';
import 'package:loah_app/models/recurring_transaction_model.dart';
import 'package:loah_app/models/task_model.dart';
import 'package:loah_app/models/transaction_model.dart';

// ── Utils ──────────────────────────────────────────────────────────
import 'package:loah_app/core/utils/budget_summary.dart';

// ── Dashboard widgets ──────────────────────────────────────────────
import 'package:loah_app/screens/dashboard/widgets/balance_card.dart';
import 'package:loah_app/screens/dashboard/widgets/pending_tasks_card.dart';
import 'package:loah_app/screens/dashboard/widgets/new_item_card.dart';
import 'package:loah_app/screens/dashboard/widgets/goals_summary_card.dart';
import 'package:loah_app/screens/dashboard/widgets/daily_reflection_card.dart';

// ── Goals widgets ──────────────────────────────────────────────────
import 'package:loah_app/screens/goals/widgets/goal_card.dart';
import 'package:loah_app/screens/goals/widgets/goal_term_section.dart';

// ── Finances widgets ───────────────────────────────────────────────
import 'package:loah_app/screens/finances/widgets/transaction_list_item.dart';
import 'package:loah_app/screens/finances/widgets/account_card.dart';
import 'package:loah_app/screens/finances/widgets/budget_card.dart';
import 'package:loah_app/screens/finances/widgets/total_balance_card.dart';
import 'package:loah_app/screens/finances/widgets/asset_card.dart';
import 'package:loah_app/screens/finances/widgets/recurring_transaction_card.dart';
import 'package:loah_app/screens/finances/widgets/emergency_goal_card.dart';

// ── Tasks widgets ──────────────────────────────────────────────────
import 'package:loah_app/screens/tasks/widgets/task_list_item.dart';

// ── Contacts widgets ───────────────────────────────────────────────
import 'package:loah_app/screens/contacts/widgets/contact_list_tile.dart';

// ── Notifications widgets ──────────────────────────────────────────
import 'package:loah_app/screens/notifications/widgets/notification_card.dart';

/// Stub HTTP client so `Image.network` widgets (DailyReflectionCard,
/// GoalCard with cover image, ContactListTile with avatar) render
/// without hitting the real network during tests.
class _MockHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _MockHttpClient();
}

/// A 1x1 transparent PNG used as the "response body" for any network
/// image request, so the image decoder has valid bytes to work with.
final List<int> _kTinyPng = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==',
);

class _MockHttpClient implements HttpClient {
  @override
  bool autoUncompress = true;
  @override
  Duration? connectionTimeout;
  @override
  int? maxConnectionsPerHost;
  @override
  String? userAgent;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _MockRequest();
  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async =>
      _MockRequest();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockRequest implements HttpClientRequest {
  @override
  final HttpHeaders headers = _MockHeaders();
  @override
  Future<HttpClientResponse> close() async => _MockResponse();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockHeaders implements HttpHeaders {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockResponse implements HttpClientResponse {
  @override
  int get statusCode => 200;
  @override
  int get contentLength => _kTinyPng.length;
  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;
  @override
  bool get isRedirect => false;
  @override
  bool get persistentConnection => true;
  @override
  String get reasonPhrase => 'OK';
  @override
  HttpHeaders get headers => _MockHeaders();

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.value(_kTinyPng).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Wraps [child] in the app's InheritedWidget controllers + a MaterialApp
/// using the real light theme, so widgets that read `context.loahColors`,
/// `AppLocales.of(context)`, `CurrencyController.of(context)` and
/// `LoahThemeController.of(context)` work correctly.
Widget wrapLoah(Widget child) {
  return LoahThemeController(
    themeMode: ThemeMode.light,
    toggleTheme: () {},
    child: LocaleController(
      locale: const Locale('pt'),
      onLocaleChanged: (_) {},
      child: CurrencyController(
        currencyCode: 'BRL',
        onCurrencyChanged: (_) {},
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(body: SingleChildScrollView(child: child)),
        ),
      ),
    ),
  );
}

void main() {
  setUpAll(() {
    HttpOverrides.global = _MockHttpOverrides();
  });

  tearDownAll(() {
    HttpOverrides.global = null;
  });

  // ─────────────────────────────────────────────────────────────
  // DASHBOARD
  // ─────────────────────────────────────────────────────────────
  group('Dashboard widget tests', () {
    testWidgets('BalanceCard renders balance and monthly-goal progress',
        (tester) async {
      await tester.pumpWidget(wrapLoah(
        const BalanceCard(available: 4820.50, progressToGoal: 0.5),
      ));
      // "PATRIMÔNIO TOTAL" label + formatted BRL value
      expect(find.textContaining('PATRIMÔNIO TOTAL'), findsOneWidget);
      expect(find.textContaining('R\$'), findsWidgets);
      expect(find.textContaining('50%'), findsOneWidget);
    });

    testWidgets('PendingTasksCard renders pending task count', (tester) async {
      final tasks = [
        const TaskModel(id: 't1', title: 'Comprar leite', isDone: false),
        const TaskModel(id: 't2', title: 'Revisar orçamento', isDone: true),
      ];
      await tester.pumpWidget(wrapLoah(
        PendingTasksCard(tasks: tasks, onToggle: (_) {}),
      ));
      expect(find.text('Tarefas Pendentes'), findsOneWidget);
      expect(find.text('1 pendentes'), findsOneWidget);
      expect(find.text('Comprar leite'), findsOneWidget);
      expect(find.text('Revisar orçamento'), findsOneWidget);
    });

    testWidgets('NewItemCard creates callback on tap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(wrapLoah(
        NewItemCard(onCreate: () => tapped = true),
      ));
      expect(find.text('Novo Item'), findsOneWidget);
      await tester.tap(find.text('Criar'));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });

    testWidgets('GoalsSummaryCard renders goal titles and see-all',
        (tester) async {
      const goal = GoalModel(
        id: 'g1',
        title: 'Reserva de Emergência',
        category: 'Financeiro',
        term: GoalTerm.longoPrazo,
        current: 2500,
        target: 5000,
      );
      await tester.pumpWidget(wrapLoah(
        GoalsSummaryCard(
          goals: const [goal],
          allTasks: const [],
          onSeeAll: () {},
        ),
      ));
      expect(find.text('Metas Atuais'), findsOneWidget);
      expect(find.text('Reserva de Emergência'), findsOneWidget);
      expect(find.text('Ver todas'), findsOneWidget);
    });

    testWidgets('DailyReflectionCard renders quote', (tester) async {
      await tester.pumpWidget(wrapLoah(
        const DailyReflectionCard(
          quote: 'O que é medido, é gerenciado.',
          imageUrl: 'https://example.com/img.jpg',
        ),
      ));
      expect(find.text('REFLEXÃO DO DIA'), findsOneWidget);
      expect(find.textContaining('O que é medido'), findsOneWidget);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // GOALS
  // ─────────────────────────────────────────────────────────────
  group('Goals widget tests', () {
    testWidgets('GoalCard renders title, category and progress percent',
        (tester) async {
      const goal = GoalModel(
        id: 'g1',
        title: 'Comprar Carro',
        category: 'Financeiro',
        term: GoalTerm.longoPrazo,
        current: 2500,
        target: 10000,
      );
      await tester.pumpWidget(wrapLoah(
        GoalCard(goal: goal, allTasks: const []),
      ));
      expect(find.text('Comprar Carro'), findsOneWidget);
      expect(find.text('Financeiro'), findsOneWidget);
      expect(find.text('25%'), findsOneWidget);
    });

    testWidgets('GoalCard shows task progress for taskChecklist goals',
        (tester) async {
      const checklistGoal = GoalModel(
        id: 'g2',
        title: 'Certificação',
        category: 'Carreira',
        term: GoalTerm.medioPrazo,
        progressMode: GoalProgressMode.taskChecklist,
      );
      final tasks = [
        const TaskModel(id: 't1', title: 'Módulo 1', isDone: true, goalId: 'g2'),
        const TaskModel(id: 't2', title: 'Módulo 2', isDone: true, goalId: 'g2'),
        const TaskModel(id: 't3', title: 'Módulo 3', isDone: false, goalId: 'g2'),
      ];
      await tester.pumpWidget(wrapLoah(
        GoalCard(goal: checklistGoal, allTasks: tasks),
      ));
      expect(find.text('Certificação'), findsOneWidget);
      expect(find.textContaining('2 de 3 tarefas concluídas'), findsOneWidget);
    });

    testWidgets('GoalTermSection renders section heading and goals',
        (tester) async {
      const goal = GoalModel(
        id: 'g1',
        title: 'Etapa Curta',
        category: 'Pessoal',
        term: GoalTerm.curtoPrazo,
        current: 5,
        target: 10,
      );
      await tester.pumpWidget(wrapLoah(
        GoalTermSection(
          term: GoalTerm.curtoPrazo,
          goals: const [goal],
          allTasks: const [],
          onGoalTap: (_) {},
        ),
      ));
      expect(find.text('Curto Prazo'), findsOneWidget);
      expect(find.text('Etapa Curta'), findsOneWidget);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // FINANCES
  // ─────────────────────────────────────────────────────────────
  group('Finances widget tests', () {
    testWidgets('TransactionListItem renders income and expense amounts',
        (tester) async {
      final income = TransactionModel(
        id: 't1',
        title: 'Salário',
        category: 'Salário',
        amount: 5000,
        type: TransactionType.income,
        date: DateTime.now(),
      );
      await tester.pumpWidget(wrapLoah(
        TransactionListItem(transaction: income),
      ));
      expect(find.text('Salário'), findsOneWidget);
      expect(find.textContaining('+ '), findsOneWidget);
    });

    testWidgets('AccountCard renders name and live balance', (tester) async {
      const acc = AccountModel(
        id: 'a1',
        name: 'Nubank',
        type: AccountType.corrente,
        initialBalance: 1000,
      );
      final txns = [
        TransactionModel(
          id: 't1',
          title: 'Depósito',
          category: 'Salário',
          amount: 500,
          type: TransactionType.income,
          date: DateTime(2024, 6, 1),
          accountId: 'a1',
        ),
      ];
      await tester.pumpWidget(wrapLoah(
        AccountCard(account: acc, allTransactions: txns, onTap: () {}),
      ));
      expect(find.text('Nubank'), findsOneWidget);
      expect(find.text('Conta Corrente'), findsOneWidget);
      expect(find.textContaining('1.500'), findsOneWidget);
    });

    testWidgets('BudgetCard renders category and spent amount', (tester) async {
      const budget = BudgetModel(
        id: 'b1',
        category: 'Alimentação',
        monthlyLimit: 800,
      );
      final progress = BudgetProgress(budget: budget, spent: 500);
      await tester.pumpWidget(wrapLoah(
        BudgetCard(progress: progress, onTap: () {}),
      ));
      expect(find.text('Alimentação'), findsOneWidget);
      expect(find.text('63%'), findsOneWidget);
    });

    testWidgets('TotalBalanceCard renders total, income and expense',
        (tester) async {
      await tester.pumpWidget(wrapLoah(
        const TotalBalanceCard(total: 2800, income: 5000, expense: 2200),
      ));
      expect(find.textContaining('SALDO TOTAL'), findsOneWidget);
      expect(find.textContaining('RECEITAS'), findsOneWidget);
      expect(find.textContaining('DESPESAS'), findsOneWidget);
    });

    testWidgets('AssetCard renders name and value', (tester) async {
      final asset = AssetModel(
        id: 'ast1',
        name: 'Apartamento',
        type: AssetType.realEstate,
        currentValue: 250000,
        updatedAt: DateTime(2024, 6, 15),
      );
      await tester.pumpWidget(wrapLoah(
        AssetCard(asset: asset, onTap: () {}, onQuickUpdate: () {}),
      ));
      expect(find.text('Apartamento'), findsOneWidget);
      expect(find.textContaining('250.000'), findsOneWidget);
    });

    testWidgets('RecurringTransactionCard renders title and day', (tester) async {
      const recurring = RecurringTransactionModel(
        id: 'r1',
        title: 'Netflix',
        category: 'Lazer',
        amount: 55.90,
        type: TransactionType.expense,
        dayOfMonth: 15,
      );
      await tester.pumpWidget(wrapLoah(
        RecurringTransactionCard(
          recurring: recurring,
          onTap: () {},
          onActiveChanged: (_) {},
        ),
      ));
      expect(find.text('Netflix'), findsOneWidget);
      expect(find.text('Todo dia 15'), findsOneWidget);
    });

    testWidgets('EmergencyGoalCard renders progress and target', (tester) async {
      await tester.pumpWidget(wrapLoah(
        const EmergencyGoalCard(target: 5000, progress: 0.5),
      ));
      expect(find.text('META: RESERVA DE EMERGÊNCIA'), findsOneWidget);
      expect(find.textContaining('50% concluído'), findsOneWidget);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // TASKS
  // ─────────────────────────────────────────────────────────────
  group('Tasks widget tests', () {
    testWidgets('TaskListItem renders title and priority', (tester) async {
      const task = TaskModel(
        id: 't1',
        title: 'Revisar orçamento',
        priority: TaskPriority.alta,
        dueLabel: 'Hoje',
      );
      await tester.pumpWidget(wrapLoah(
        TaskListItem(task: task, onToggle: () {}, onTap: () {}),
      ));
      expect(find.text('Revisar orçamento'), findsOneWidget);
      expect(find.text('Alta Prioridade'), findsOneWidget);
      expect(find.text('Hoje'), findsOneWidget);
    });

    testWidgets('TaskListItem toggles checkbox on tap', (tester) async {
      var toggled = false;
      const task = TaskModel(id: 't2', title: 'Tarefa simples');
      await tester.pumpWidget(wrapLoah(
        TaskListItem(task: task, onToggle: () => toggled = true, onTap: () {}),
      ));
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();
      expect(toggled, isTrue);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // CONTACTS
  // ─────────────────────────────────────────────────────────────
  group('Contacts widget tests', () {
    testWidgets('ContactListTile renders name and relationship tag',
        (tester) async {
      const contact = ContactModel(
        id: 'c1',
        name: 'Alice Ferreira',
        relationshipTag: 'Namorada',
      );
      await tester.pumpWidget(wrapLoah(
        ContactListTile(
          contact: contact,
          avatarColor: Colors.blue,
          onTap: () {},
          onToggleFavorite: () {},
          onMessage: () {},
        ),
      ));
      expect(find.text('Alice Ferreira'), findsOneWidget);
      expect(find.text('Namorada'), findsOneWidget);
    });

    testWidgets('ContactListTile shows favorite star when favorite',
        (tester) async {
      const contact = ContactModel(
        id: 'c2',
        name: 'Bruno Alves',
        relationshipTag: 'Amigo',
        isFavorite: true,
      );
      await tester.pumpWidget(wrapLoah(
        ContactListTile(
          contact: contact,
          avatarColor: Colors.green,
          onTap: () {},
          onToggleFavorite: () {},
          onMessage: () {},
        ),
      ));
      expect(find.byIcon(Icons.star_rounded), findsOneWidget);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // NOTIFICATIONS
  // ─────────────────────────────────────────────────────────────
  group('Notifications widget tests', () {
    testWidgets('NotificationCard renders title and message', (tester) async {
      final notif = AppNotification(
        id: 'n1',
        category: NotificationCategory.tasks,
        title: 'Tarefa atrasada',
        message: 'Lembre-se de concluir a tarefa.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
      );
      await tester.pumpWidget(wrapLoah(
        NotificationCard(notification: notif),
      ));
      expect(find.text('Tarefa atrasada'), findsOneWidget);
      expect(find.text('Lembre-se de concluir a tarefa.'), findsOneWidget);
    });
  });
}
