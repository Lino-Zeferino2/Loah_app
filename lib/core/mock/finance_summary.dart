import '../../models/transaction_model.dart';
import 'transaction_categories.dart';

/// Computes finance totals from a list of [TransactionModel]s. Kept as
/// pure functions (not stored fields) so totals are never stale — they
/// always reflect whatever is currently in `MockData.transactions`.
class FinanceSummary {
  FinanceSummary._();

  /// All-time net balance: sum of every income minus every expense.
  static double totalBalance(List<TransactionModel> transactions) {
    return transactions.fold<double>(0, (sum, t) => sum + (t.isIncome ? t.amount : -t.amount));
  }

  static bool _isCurrentMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  /// Sum of income in the current calendar month.
  static double monthlyIncome(List<TransactionModel> transactions) {
    return transactions
        .where((t) => t.isIncome && _isCurrentMonth(t.date))
        .fold<double>(0, (sum, t) => sum + t.amount);
  }

  /// Sum of expenses in the current calendar month.
  static double monthlyExpense(List<TransactionModel> transactions) {
    return transactions
        .where((t) => !t.isIncome && _isCurrentMonth(t.date))
        .fold<double>(0, (sum, t) => sum + t.amount);
  }

  /// This month's expenses grouped by category, for the donut chart —
  /// each category becomes one [ExpenseCategoryModel] slice.
  static List<ExpenseCategoryModel> expenseDistribution(List<TransactionModel> transactions) {
    final byCategory = <String, double>{};
    for (final t in transactions) {
      if (t.isIncome || !_isCurrentMonth(t.date)) continue;
      byCategory[t.category] = (byCategory[t.category] ?? 0) + t.amount;
    }
    final entries = byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value)); // biggest slice first

    return [
      for (final e in entries)
        ExpenseCategoryModel(
          label: e.key,
          amount: e.value,
          color: TransactionCategories.colorFor(e.key),
        ),
    ];
  }
}