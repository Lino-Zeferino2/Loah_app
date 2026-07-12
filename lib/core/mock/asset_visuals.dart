import 'package:flutter/material.dart';
import '../../models/asset_model.dart';

/// Icon, color and label for each [AssetType] — kept as pure lookups
/// (not fields on the model) so every asset of the same type always
/// renders consistently.
extension AssetTypeVisuals on AssetType {
  String get label => switch (this) {
        AssetType.emergencyFund => 'Reserva de Emergência',
        AssetType.stocks => 'Ações',
        AssetType.realEstate => 'Imóveis',
        AssetType.cash => 'Dinheiro em Conta',
        AssetType.other => 'Outro',
      };

  IconData get icon => switch (this) {
        AssetType.emergencyFund => Icons.savings_outlined,
        AssetType.stocks => Icons.show_chart,
        AssetType.realEstate => Icons.home_work_outlined,
        AssetType.cash => Icons.account_balance_wallet_outlined,
        AssetType.other => Icons.category_outlined,
      };

  Color get color => switch (this) {
        AssetType.emergencyFund => Colors.teal,
        AssetType.stocks => Colors.green,
        AssetType.realEstate => Colors.orange,
        AssetType.cash => Colors.lightBlueAccent,
        AssetType.other => Colors.blueGrey,
      };
}