import '../models/transaction_model.dart';

/// A monthly recurring transaction — salary, rent, a subscription.
/// [dayOfMonth] is when it's due (clamped to 1-28 to sidestep
/// short-month edge cases like Feb 30th). [lastGeneratedMonth] tracks
/// the last year/month it already turned into a real
/// [TransactionModel], so `RecurringEngine` never double-charges the
/// same month.
class RecurringTransactionModel {
  /// Stable identifier — maps to a Firestore document ID later.
  final String id;

  final String title;
  final String category;
  final double amount;
  final TransactionType type;
  final String? accountId;
  final int dayOfMonth;
  final bool active;

  /// Marker for "already generated for this year/month" — only the
  /// year and month matter, day is always 1.
  final DateTime? lastGeneratedMonth;

  const RecurringTransactionModel({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.type,
    this.accountId,
    required this.dayOfMonth,
    this.active = true,
    this.lastGeneratedMonth,
  });

  RecurringTransactionModel copyWith({
    String? title,
    String? category,
    double? amount,
    TransactionType? type,
    String? accountId,
    int? dayOfMonth,
    bool? active,
    DateTime? lastGeneratedMonth,
  }) {
    return RecurringTransactionModel(
      id: id,
      title: title ?? this.title,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      accountId: accountId ?? this.accountId,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      active: active ?? this.active,
      lastGeneratedMonth: lastGeneratedMonth ?? this.lastGeneratedMonth,
    );
  }
}