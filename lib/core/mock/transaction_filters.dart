import '../../models/transaction_model.dart';

/// Filter state for the Histórico screen: an optional type (income vs
/// expense), a set of categories, and a set of account ids. Empty
/// sets/null type mean "no filter on that dimension".
class TransactionFilters {
  final TransactionType? type;
  final Set<String> categories;
  final Set<String> accountIds;

  const TransactionFilters({
    this.type,
    this.categories = const {},
    this.accountIds = const {},
  });

  bool get isActive => type != null || categories.isNotEmpty || accountIds.isNotEmpty;

  bool matches(TransactionModel t) {
    if (type != null && t.type != type) return false;
    if (categories.isNotEmpty && !categories.contains(t.category)) return false;
    if (accountIds.isNotEmpty && !accountIds.contains(t.accountId)) return false;
    return true;
  }

  TransactionFilters copyWith({
    TransactionType? type,
    Set<String>? categories,
    Set<String>? accountIds,
  }) {
    return TransactionFilters(
      type: type,
      categories: categories ?? this.categories,
      accountIds: accountIds ?? this.accountIds,
    );
  }
}