import 'package:flutter/material.dart';

enum TransactionType { income, expense }

/// A single financial movement (an expense or an income), shown in the
/// "Finanças" screen history and used to derive totals, monthly
/// income/expense sums, and the expense-distribution chart.
class TransactionModel {
  /// Stable identifier — maps to a Firestore document ID later.
  final String id;

  final String title;
  final String category;
  final double amount;
  final TransactionType type;
  final DateTime date;

  const TransactionModel({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.type,
    required this.date,
  });

  bool get isIncome => type == TransactionType.income;

  static const _monthAbbrev = [
    'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
    'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez',
  ];

  /// e.g. "Hoje, 14:20", "Ontem, 09:00", or "02 Mai" for older dates —
  /// used as the subtitle in the transaction list.
  String get relativeDateLabel {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(date.year, date.month, date.day);
    final diff = today.difference(day).inDays;

    final hm = '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';

    if (diff == 0) return 'Hoje, $hm';
    if (diff == 1) return 'Ontem, $hm';
    return '${date.day.toString().padLeft(2, '0')} ${_monthAbbrev[date.month - 1]}';
  }
}

/// A slice of the expense-distribution donut chart (e.g. Alimentação).
/// Built by grouping [TransactionModel]s by category — see
/// `FinanceSummary` in `core/mock/finance_summary.dart`.
class ExpenseCategoryModel {
  final String label;
  final double amount;
  final Color color;

  const ExpenseCategoryModel({
    required this.label,
    required this.amount,
    required this.color,
  });
}