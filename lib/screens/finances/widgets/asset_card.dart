import 'package:flutter/material.dart';
import '../../../core/mock/asset_visuals.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models/asset_model.dart';
import '../../../models/task_model.dart'; // TaskModel.shortDate (short date formatter)
import '../../../widgets/loah_card.dart';

/// One row in the Patrimônio list: type icon badge, name, current
/// value, "Atualizado em X" caption, and a quick-update icon button.
class AssetCard extends StatelessWidget {
  final AssetModel asset;
  final VoidCallback onTap;
  final VoidCallback onQuickUpdate;

  const AssetCard({
    super.key,
    required this.asset,
    required this.onTap,
    required this.onQuickUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final color = asset.type.color;

    return LoahCard(
      onTap: onTap,
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color.withValues(alpha: 0.15),
            child: Icon(asset.type.icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(asset.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                Text(
                  CurrencyFormatter.format(asset.currentValue),
                  style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 15),
                ),
                Text(
                  'Atualizado em ${TaskModel.shortDate(asset.updatedAt)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onQuickUpdate,
            icon: Icon(Icons.tune, size: 20, color: context.textSecondary),
            tooltip: 'Atualizar valor',
          ),
        ],
      ),
    );
  }
}