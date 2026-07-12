import 'package:flutter/material.dart';
import '../../core/mock/asset_visuals.dart';
import '../../core/mock/mock_data.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/asset_model.dart';
import '../../widgets/labeled_progress_bar.dart';
import '../../widgets/loah_card.dart';
import 'add_asset_screen.dart';
import 'widgets/asset_card.dart';

/// "Loah - Patrimônio": total net worth plus a breakdown by asset type
/// (Reserva de Emergência, Ações, Imóveis, Dinheiro em Conta...) and
/// the full list of individual assets underneath.
class AssetsScreen extends StatefulWidget {
  const AssetsScreen({super.key});

  @override
  State<AssetsScreen> createState() => _AssetsScreenState();
}

class _AssetsScreenState extends State<AssetsScreen> {
  double get _total =>
      MockData.assets.fold<double>(0, (sum, a) => sum + a.currentValue);

  /// Assets grouped by type, in [AssetType.values] order, skipping
  /// empty groups.
  Map<AssetType, List<AssetModel>> get _grouped {
    final grouped = <AssetType, List<AssetModel>>{};
    for (final type in AssetType.values) {
      final matches = MockData.assets.where((a) => a.type == type).toList();
      if (matches.isNotEmpty) grouped[type] = matches;
    }
    return grouped;
  }

  Future<void> _addAsset() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AddAssetScreen()),
    );
    setState(() {});
  }

  Future<void> _editAsset(AssetModel asset) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AddAssetScreen(existingAsset: asset)),
    );
    setState(() {});
  }

  Future<void> _quickUpdate(AssetModel asset) async {
    final controller = TextEditingController(text: asset.currentValue.toStringAsFixed(2));
    final newValue = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.loahColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Atualizar Valor',
              style: Theme.of(sheetContext)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(asset.name, style: Theme.of(sheetContext).textTheme.bodyMedium),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                prefixText: 'R\$ ',
                filled: true,
                fillColor: context.loahColors.cardBackgroundAlt,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  final value = double.tryParse(controller.text.trim().replaceAll(',', '.'));
                  Navigator.of(sheetContext).pop(value);
                },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Salvar'),
              ),
            ),
          ],
        ),
      ),
    );
    if (newValue == null) return;

    setState(() {
      final index = MockData.assets.indexWhere((a) => a.id == asset.id);
      if (index != -1) {
        MockData.assets[index] =
            asset.copyWith(currentValue: newValue, updatedAt: DateTime.now());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final total = _total;
    final grouped = _grouped;

    return Scaffold(
      appBar: const LoahAppBarSimple(title: 'Patrimônio'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            LoahCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PATRIMÔNIO TOTAL',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          letterSpacing: 0.6,
                          color: context.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    CurrencyFormatter.format(total),
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 18),
                  for (final type in grouped.keys) ...[
                    LabeledProgressBar(
                      label: type.label,
                      progress: total == 0
                          ? 0
                          : grouped[type]!.fold<double>(0, (s, a) => s + a.currentValue) / total,
                      color: type.color,
                    ),
                    const SizedBox(height: 10),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            for (final type in grouped.keys) ...[
              Row(
                children: [
                  Icon(type.icon, size: 16, color: type.color),
                  const SizedBox(width: 6),
                  Text(
                    type.label,
                    style: TextStyle(fontWeight: FontWeight.w700, color: type.color),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              for (final asset in grouped[type]!) ...[
                AssetCard(
                  asset: asset,
                  onTap: () => _editAsset(asset),
                  onQuickUpdate: () => _quickUpdate(asset),
                ),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 10),
            ],
            if (grouped.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'Nenhum ativo cadastrado ainda. Toque no + para adicionar o primeiro.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'assets_fab',
        onPressed: _addAsset,
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Minimal app bar for pushed sub-screens that aren't one of the four
/// main tabs (so no drawer/menu icon — just a back arrow + title).
class LoahAppBarSimple extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const LoahAppBarSimple({super.key, required this.title});

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) => AppBar(title: Text(title));
}