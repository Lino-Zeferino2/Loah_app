/// A monthly spending limit for one expense category (e.g.
/// "Alimentação: R$ 800"). One budget per category — see
/// `BudgetSummary` for how spent-vs-limit is computed.
class BudgetModel {
  /// Stable identifier — maps to a Firestore document ID later.
  final String id;

  /// Must match one of `TransactionCategories.expense`.
  final String category;

  final double monthlyLimit;

  const BudgetModel({
    required this.id,
    required this.category,
    required this.monthlyLimit,
  });

  BudgetModel copyWith({String? category, double? monthlyLimit}) {
    return BudgetModel(
      id: id,
      category: category ?? this.category,
      monthlyLimit: monthlyLimit ?? this.monthlyLimit,
    );
  }
}