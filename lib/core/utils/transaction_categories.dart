import 'package:flutter/material.dart';
import '../../models/transaction_model.dart';

/// Category lists and icon/color lookup for transactions. Kept as
/// static data (not a per-transaction field) so every transaction in a
/// category always renders consistently — same icon, same color —
/// without needing to store that on each individual record.
class TransactionCategories {
  TransactionCategories._();

  static const expense = ['Alimentação', 'Moradia', 'Transporte', 'Compras', 'Saúde', 'Lazer', 'Outros'];
  static const income = ['Salário', 'Freelance', 'Investimentos', 'Outros'];

  static List<String> forType(TransactionType type) =>
      type == TransactionType.income ? income : expense;

  static IconData iconFor(String category) => switch (category) {
        'Alimentação' => Icons.restaurant_outlined,
        'Moradia' => Icons.home_outlined,
        'Transporte' => Icons.directions_car_outlined,
        'Compras' => Icons.shopping_bag_outlined,
        'Saúde' => Icons.favorite_outline,
        'Lazer' => Icons.sports_esports_outlined,
        'Salário' => Icons.payments_outlined,
        'Freelance' => Icons.laptop_mac_outlined,
        'Investimentos' => Icons.trending_up,
        _ => Icons.category_outlined,
      };

  static Color colorFor(String category) => switch (category) {
        'Alimentação' => Colors.green,
        'Moradia' => Colors.orange,
        'Transporte' => Colors.redAccent,
        'Compras' => Colors.purpleAccent,
        'Saúde' => Colors.teal,
        'Lazer' => Colors.pinkAccent,
        'Salário' => Colors.blueAccent,
        'Freelance' => Colors.cyan,
        'Investimentos' => Colors.amber,
        _ => Colors.blueGrey,
      };
}