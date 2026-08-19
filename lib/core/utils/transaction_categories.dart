import 'package:flutter/material.dart';
import '../../models/transaction_model.dart';

/// Category lists and icon/color lookup for transactions. Kept as
/// static data (not a per-transaction field) so every transaction in a
/// category always renders consistently — same icon, same color —
/// without needing to store that on each individual record.
class TransactionCategories {
  TransactionCategories._();

  // NOVO: listas ampliadas para cobrir os padrões de gasto/receita mais
  // comuns, além das categorias originais.
  static const expense = [
    'Alimentação',
    'Moradia',
    'Transporte',
    'Compras',
    'Saúde',
    'Lazer',
    'Educação',
    'Assinaturas',
    'Seguros',
    'Impostos',
    'Dívidas',
    'Cuidados Pessoais',
    'Presentes',
    'Comunicação',
    'Outros',
  ];

  static const income = [
    'Salário',
    'Freelance',
    'Investimentos',
    'Reembolsos',
    'Bônus',
    'Aluguel',
    'Pensão',
    'Vendas',
    'Outros',
  ];

  static List<String> forType(TransactionType type) =>
      type == TransactionType.income ? income : expense;

  static IconData iconFor(String category) => switch (category) {
        'Alimentação' => Icons.restaurant_outlined,
        'Moradia' => Icons.home_outlined,
        'Transporte' => Icons.directions_car_outlined,
        'Compras' => Icons.shopping_bag_outlined,
        'Saúde' => Icons.favorite_outline,
        'Lazer' => Icons.sports_esports_outlined,
        // NOVO: ícones das categorias de despesa adicionadas.
        'Educação' => Icons.school_outlined,
        'Assinaturas' => Icons.subscriptions_outlined,
        'Seguros' => Icons.shield_outlined,
        'Impostos' => Icons.receipt_long_outlined,
        'Dívidas' => Icons.credit_score_outlined,
        'Cuidados Pessoais' => Icons.spa_outlined,
        'Presentes' => Icons.card_giftcard_outlined,
        'Comunicação' => Icons.phone_iphone_outlined,
        'Salário' => Icons.payments_outlined,
        'Freelance' => Icons.laptop_mac_outlined,
        'Investimentos' => Icons.trending_up,
        // NOVO: ícones das categorias de receita adicionadas.
        'Reembolsos' => Icons.replay_outlined,
        'Bônus' => Icons.stars_outlined,
        'Aluguel' => Icons.apartment_outlined,
        'Pensão' => Icons.elderly_outlined,
        'Vendas' => Icons.sell_outlined,
        _ => Icons.category_outlined,
      };

  static Color colorFor(String category) => switch (category) {
        'Alimentação' => Colors.green,
        'Moradia' => Colors.orange,
        'Transporte' => Colors.redAccent,
        'Compras' => Colors.purpleAccent,
        'Saúde' => Colors.teal,
        'Lazer' => Colors.pinkAccent,
        // NOVO: cores das categorias de despesa adicionadas.
        'Educação' => Colors.indigo,
        'Assinaturas' => Colors.deepPurple,
        'Seguros' => Colors.brown,
        'Impostos' => Colors.grey,
        'Dívidas' => Colors.deepOrange,
        'Cuidados Pessoais' => Colors.pink,
        'Presentes' => Colors.red,
        'Comunicação' => Colors.lightBlue,
        'Salário' => Colors.blueAccent,
        'Freelance' => Colors.cyan,
        'Investimentos' => Colors.amber,
        // NOVO: cores das categorias de receita adicionadas.
        'Reembolsos' => Colors.lightGreen,
        'Bônus' => Colors.amberAccent,
        'Aluguel' => Colors.brown,
        'Pensão' => Colors.blueGrey,
        'Vendas' => Colors.deepPurpleAccent,
        _ => Colors.blueGrey,
      };
}