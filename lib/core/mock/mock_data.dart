import 'package:flutter/material.dart';
import '../../models/goal_model.dart';
import '../../models/task_model.dart';
import '../../models/contact_model.dart';
import '../../models/transaction_model.dart';
import '../../models/asset_model.dart';
import '../../models/account_model.dart';
import '../../models/budget_model.dart';
import '../../models/recurring_transaction_model.dart';

/// Single source of mock data for the whole app.
///
/// Today this is just static Dart lists — no persistence, no network.
/// When we migrate to Firebase, this class gets replaced by real
/// repositories, but every screen already reads goals/tasks *through*
/// this class, so the migration won't touch screen code.
class MockData {
  MockData._();
  static final List<RecurringTransactionModel> recurringTransactions = [
    const RecurringTransactionModel(
      id: 'recurring_salary',
      title: 'Salário Mensal',
      category: 'Salário',
      amount: 4200,
      type: TransactionType.income,
      accountId: 'acc_checking',
      dayOfMonth: 5,
    ),
    const RecurringTransactionModel(
      id: 'recurring_rent',
      title: 'Aluguel',
      category: 'Moradia',
      amount: 1200,
      type: TransactionType.expense,
      accountId: 'acc_checking',
      dayOfMonth: 10,
    ),
    const RecurringTransactionModel(
      id: 'recurring_netflix',
      title: 'Netflix',
      category: 'Lazer',
      amount: 44.90,
      type: TransactionType.expense,
      accountId: 'acc_credit_card',
      dayOfMonth: 15,
    ),
    const RecurringTransactionModel(
      id: 'recurring_spotify',
      title: 'Spotify',
      category: 'Lazer',
      amount: 21.90,
      type: TransactionType.expense,
      accountId: 'acc_credit_card',
      dayOfMonth: 20,
    ),
  ];
  static final List<BudgetModel> budgets = [
    const BudgetModel(id: 'budget_food', category: 'Alimentação', monthlyLimit: 800),
    const BudgetModel(id: 'budget_transport', category: 'Transporte', monthlyLimit: 250),
    const BudgetModel(id: 'budget_shopping', category: 'Compras', monthlyLimit: 300),
    const BudgetModel(id: 'budget_housing', category: 'Moradia', monthlyLimit: 1200),
  ];
  static final List<AccountModel> accounts = [
    const AccountModel(
      id: 'acc_checking',
      name: 'Conta Corrente',
      type: AccountType.corrente,
      initialBalance: 500,
    ),
    const AccountModel(
      id: 'acc_savings',
      name: 'Poupança',
      type: AccountType.poupanca,
      initialBalance: 3750,
    ),
    const AccountModel(
      id: 'acc_credit_card',
      name: 'Cartão de Crédito',
      type: AccountType.cartaoCredito,
    ),
    const AccountModel(
      id: 'acc_wallet',
      name: 'Carteira',
      type: AccountType.carteira,
      initialBalance: 150,
    ),
  ];
  static final List<AssetModel> assets = [
    AssetModel(
      id: 'asset_emergency_fund',
      name: 'Reserva de Emergência',
      type: AssetType.emergencyFund,
      currentValue: 4250,
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    AssetModel(
      id: 'asset_stocks_b3',
      name: 'Carteira B3',
      type: AssetType.stocks,
      currentValue: 8600,
      notes: 'PETR4, VALE3, ITUB4',
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    AssetModel(
      id: 'asset_apartment',
      name: 'Apartamento',
      type: AssetType.realEstate,
      currentValue: 320000,
      notes: 'Imóvel residencial, financiado',
      updatedAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    AssetModel(
      id: 'asset_checking_account',
      name: 'Conta Corrente',
      type: AssetType.cash,
      currentValue: 1850,
      updatedAt: DateTime.now().subtract(const Duration(hours: 6)),
    ),
  ];
 
static final List<TransactionModel> transactions = [
    TransactionModel(
      id: 'txn_market',
      title: 'Mercado Central',
      category: 'Alimentação',
      amount: 146.20,
      type: TransactionType.expense,
      date: DateTime.now().subtract(const Duration(hours: 3)),
      accountId: 'acc_checking',
    ),
    TransactionModel(
      id: 'txn_salary',
      title: 'Salário Mensal',
      category: 'Salário',
      amount: 4200.00,
      type: TransactionType.income,
      date: DateTime.now().subtract(const Duration(days: 1)),
      accountId: 'acc_checking',
    ),
    TransactionModel(
      id: 'txn_uber',
      title: 'Uber',
      category: 'Transporte',
      amount: 32.50,
      type: TransactionType.expense,
      date: DateTime.now().subtract(const Duration(days: 4)),
      accountId: 'acc_credit_card',
    ),
    TransactionModel(
      id: 'txn_clothes',
      title: 'Loja de Roupas',
      category: 'Compras',
      amount: 210.00,
      type: TransactionType.expense,
      date: DateTime.now().subtract(const Duration(days: 5)),
      accountId: 'acc_credit_card',
    ),
    TransactionModel(
      id: 'txn_rent',
      title: 'Aluguel',
      category: 'Moradia',
      amount: 1200.00,
      type: TransactionType.expense,
      date: DateTime.now().subtract(const Duration(days: 8)),
      accountId: 'acc_checking',
    ),
  ];

static final List<ContactModel> contacts = [
    ContactModel(
      id: 'contact_alice',
      name: 'Alice Ferreira',
      relationshipTag: 'Namorada',
      isFavorite: true,
      desiredContactFrequencyDays: 2,
      interactions: [
        ContactInteraction(date: DateTime.now().subtract(const Duration(hours: 5)), type: InteractionType.message),
        ContactInteraction(date: DateTime.now().subtract(const Duration(days: 1)), type: InteractionType.call),
      ],
    ),
    const ContactModel(
      id: 'contact_bruno',
      name: 'Bruno Alves',
      relationshipTag: 'Amigo',
      isFavorite: true,
    ),
    ContactModel(
      id: 'contact_carlos',
      name: 'Carlos Souza',
      relationshipTag: 'Pai',
      isFavorite: true,
      desiredContactFrequencyDays: 7,
      interactions: [
        ContactInteraction(date: DateTime.now().subtract(const Duration(days: 12)), type: InteractionType.call),
      ],
    ),
    const ContactModel(
      id: 'contact_diana',
      name: 'Diana Ferreira',
      relationshipTag: 'Mãe',
      isFavorite: true,
    ),
    const ContactModel(
      id: 'contact_adriana',
      name: 'Adriana Silva',
      email: 'adriana.silva@loah.app',
      relationshipTag: 'Colega',
    ),
    const ContactModel(
      id: 'contact_andre',
      name: 'Andre Martins',
      phone: '+55 11 98877-6655',
      relationshipTag: 'Conhecido',
    ),
    const ContactModel(
      id: 'contact_beatriz',
      name: 'Beatriz Gomes',
      email: 'beatriz@empresa.com.br',
      relationshipTag: 'Amiga',
    ),
    const ContactModel(
      id: 'contact_caio',
      name: 'Caio Castro',
      email: 'caio.analyst@tech.io',
      relationshipTag: 'Familiar',
    ),
    const ContactModel(
      id: 'contact_clarice',
      name: 'Clarice Lispector',
      email: 'clarice@letras.org',
      relationshipTag: 'Conhecida',
    ),
  ];
  static final List<GoalModel> goals = [
    GoalModel(
      id: 'goal_emergency_fund',
      title: 'Reserva de Emergência',
      category: 'Finanças',
      term: GoalTerm.curtoPrazo,
      progressMode: GoalProgressMode.manualValue,
      current: 4250,
      target: 5000,
      progressColor: Colors.brown.shade400,
    ),
    const GoalModel(
      id: 'goal_daily_workout',
      title: 'Treino Diário',
      category: 'Saúde',
      term: GoalTerm.curtoPrazo,
      progressMode: GoalProgressMode.manualValue,
      current: 12,
      target: 30,
    ),
    const GoalModel(
      id: 'goal_eurotrip',
      title: 'Eurotrip 2024',
      category: 'Viagem',
      description: 'Poupar para passagens e hospedagem em Paris e Roma.',
      term: GoalTerm.medioPrazo,
      progressMode: GoalProgressMode.manualValue,
      current: 2500,
      target: 10000,
      imageAsset: 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=800',
    ),
    // Checklist-mode example: progress comes from linked tasks below,
    // not from a manual current/target value.
    const GoalModel(
      id: 'goal_cloud_certification',
      title: 'Certificação Cloud',
      category: 'Carreira',
      term: GoalTerm.medioPrazo,
      progressMode: GoalProgressMode.taskChecklist,
      progressColor: Colors.green,
    ),
    // Same style as the reference screenshot: a manualValue goal that
    // ALSO has milestone tasks (which don't drive the %, just organize
    // the sub-steps), a photo background and a target date.
    GoalModel(
      id: 'goal_buy_car',
      title: 'Comprar um Carro',
      category: 'Financeiro',
      description:
          'Meta para adquirir um veículo seminovo para facilitar a locomoção '
          'diária e viagens em família. Foco em modelos híbridos ou econômicos.',
      term: GoalTerm.medioPrazo,
      progressMode: GoalProgressMode.manualValue,
      current: 16250,
      target: 25000,
      progressColor: Colors.lightBlueAccent,
      targetDate: DateTime(2024, 12, 1),
      imageAsset: 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=800',
    ),
    const GoalModel(
      id: 'goal_apartment_downpayment',
      title: 'Entrada do Apartamento',
      category: 'Investimento',
      description: 'Investimento de longo prazo.',
      term: GoalTerm.longoPrazo,
      progressMode: GoalProgressMode.manualValue,
      current: 1500,
      target: 12500,
    ),
  ];

  static final List<TaskModel> tasks = [
    const TaskModel(
      id: 'task_quarterly_planning_meeting',
      title: 'Reunião de Planejamento Trimestral',
      description: 'Preparar apresentação e KPIs do departamento financeiro.',
      priority: TaskPriority.alta,
      dueLabel: '09:00',
    ),
    const TaskModel(
      id: 'task_review_budget_today',
      title: 'Revisar orçamento mensal',
      tag: 'Finanças',
      priority: TaskPriority.media,
      dueLabel: 'Hoje',
    ),
    const TaskModel(
      id: 'task_leg_workout',
      title: 'Treino de pernas (Academia)',
      description: 'Focar em resistência e alongamento.',
      dueLabel: 'Amanhã',
    ),
    const TaskModel(
      id: 'task_groceries',
      title: 'Comprar mantimentos',
      description: 'Lista no app de notas.',
      dueLabel: 'Sáb, 3 Out',
    ),
    const TaskModel(
      id: 'task_reply_emails',
      title: 'Responder e-mails acumulados',
      isDone: true,
    ),
    // Sub-tasks for the Cloud Certification goal (checklist-mode) —
    // note the matching goalId. 2/4 done = 50% progress.
    const TaskModel(
      id: 'task_cloud_module_1',
      title: 'Módulo 1 — Fundamentos',
      goalId: 'goal_cloud_certification',
      isDone: true,
    ),
    const TaskModel(
      id: 'task_cloud_module_2',
      title: 'Módulo 2 — Redes e Segurança',
      goalId: 'goal_cloud_certification',
      isDone: true,
    ),
    const TaskModel(
      id: 'task_cloud_module_3',
      title: 'Módulo 3 — Armazenamento',
      goalId: 'goal_cloud_certification',
    ),
    const TaskModel(
      id: 'task_cloud_module_4',
      title: 'Módulo 4 — Simulado final',
      goalId: 'goal_cloud_certification',
    ),
    // Milestones for "Comprar um Carro" — organizational only, they
    // don't drive its % alone (see GoalProgress.of: a manualValue goal
    // WITH linked tasks averages value-progress and task-progress).
    TaskModel(
      id: 'task_car_down_payment',
      title: 'Guardar R\$ 5.000 de entrada',
      goalId: 'goal_buy_car',
      isDone: true,
      completedAt: DateTime(2024, 10, 15),
    ),
    TaskModel(
      id: 'task_car_research_suv',
      title: 'Pesquisar modelos de SUV',
      description:
          'Analisar o consumo, espaço interno e custo-benefício de pelo menos '
          '3 modelos híbridos. Focar em opções com boa revenda no mercado brasileiro.',
      goalId: 'goal_buy_car',
      priority: TaskPriority.media,
      status: TaskStatus.emProgresso,
      createdAt: DateTime(2024, 10, 18),
      dueDate: DateTime(2024, 10, 25),
    ),
    const TaskModel(
      id: 'task_car_test_drive',
      title: 'Agendar test-drives',
      goalId: 'goal_buy_car',
    ),
  ];
}