import 'package:flutter/material.dart';

enum TransactionType { income, expense }

/// A single financial movement shown in the "Finanças" screen history.
class TransactionModel {
  final String title;
  final String subtitle;
  final double amount;
  final TransactionType type;
  final IconData icon;

  const TransactionModel({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.type,
    required this.icon,
  });

  bool get isIncome => type == TransactionType.income;
}

/// A slice of the expense-distribution donut chart (e.g. Alimentação).
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
