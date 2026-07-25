import 'package:flutter/material.dart';
import '../../models/account_model.dart';

/// Icon, color and label for each [AccountType] — kept as pure lookups
/// (not fields on the model) so every account of the same type always
/// renders consistently.
extension AccountTypeVisuals on AccountType {
  String get label => switch (this) {
        AccountType.corrente => 'Conta Corrente',
        AccountType.poupanca => 'Poupança',
        AccountType.cartaoCredito => 'Cartão de Crédito',
        AccountType.carteira => 'Carteira',
        AccountType.investimento => 'Investimento',
        AccountType.outro => 'Outro',
      };

  IconData get icon => switch (this) {
        AccountType.corrente => Icons.account_balance_outlined,
        AccountType.poupanca => Icons.savings_outlined,
        AccountType.cartaoCredito => Icons.credit_card_outlined,
        AccountType.carteira => Icons.account_balance_wallet_outlined,
        AccountType.investimento => Icons.show_chart,
        AccountType.outro => Icons.category_outlined,
      };

  Color get color => switch (this) {
        AccountType.corrente => Colors.lightBlueAccent,
        AccountType.poupanca => Colors.teal,
        AccountType.cartaoCredito => Colors.deepPurpleAccent,
        AccountType.carteira => Colors.orange,
        AccountType.investimento => Colors.green,
        AccountType.outro => Colors.blueGrey,
      };
}