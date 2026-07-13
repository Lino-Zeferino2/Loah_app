import '../../models/budget_model.dart';
import '../../models/transaction_model.dart';

enum BudgetStatus { ok, near, over }

/// A budget paired with how much was actually spent this month —
/// everything a screen needs to render one row, computed fresh each
/// time (never stored, never stale).
class BudgetProgress {
  final BudgetModel budget;
  final double spent;

  const BudgetProgress({required this.budget, required this.spent});

  double get progress => budget.monthlyLimit == 0 ? 0 : (spent / budget.monthlyLimit).clamp(0, 1);
  double get remaining => (budget.monthlyLimit - spent).clamp(0, double.infinity);
  bool get isOverBudget => spent > budget.monthlyLimit;

  /// `ok` under 80%, `near` 80–100%, `over` past the limit — drives the
  /// progress bar color in the UI.
  BudgetStatus get status {
    if (isOverBudget) return BudgetStatus.over;
    if (progress >= 0.8) return BudgetStatus.near;
    return BudgetStatus.ok;
  }
}

/// Combines [BudgetModel]s with real spending from the transaction
/// list. Kept as pure functions (not stored fields) so figures are
/// never stale.
class BudgetSummary {
  BudgetSummary._();

  static bool _isCurrentMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  /// This month's spend for a single category.
  static double spentInCategory(String category, List<TransactionModel> transactions) {
    return transactions
        .where((t) => !t.isIncome && t.category == category && _isCurrentMonth(t.date))
        .fold<double>(0, (sum, t) => sum + t.amount);
  }

  /// Every budget paired with its actual spend this month.
  static List<BudgetProgress> all(
    List<BudgetModel> budgets,
    List<TransactionModel> transactions,
  ) {
    return [
      for (final budget in budgets)
        BudgetProgress(
          budget: budget,
          spent: spentInCategory(budget.category, transactions),
        ),
    ];
  }

  static double totalBudgeted(List<BudgetModel> budgets) =>
      budgets.fold<double>(0, (sum, b) => sum + b.monthlyLimit);

  static double totalSpent(List<BudgetModel> budgets, List<TransactionModel> transactions) =>
      budgets.fold<double>(0, (sum, b) => sum + spentInCategory(b.category, transactions));
}