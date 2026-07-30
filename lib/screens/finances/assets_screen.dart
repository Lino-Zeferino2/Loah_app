import 'package:flutter/material.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/services/finance_service.dart';
import '../../models/asset_model.dart';
import 'add_asset_screen.dart';
import 'widgets/asset_card.dart';

class AssetsScreen extends StatefulWidget {
  const AssetsScreen({super.key});

  @override
  State<AssetsScreen> createState() => _AssetsScreenState();
}

class _AssetsScreenState extends State<AssetsScreen> {
  final FinanceService _financeService = FinanceService();
  List<AssetModel> _assets = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final assets = await _financeService.getAllAssets();
      if (mounted) setState(() { _assets = assets; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _quickUpdate(AssetModel asset) async {
    final loc = AppLocales.of(context);
    final controller = TextEditingController(
      text: asset.currentValue.toStringAsFixed(2),
    );
    final newValue = await showDialog<double>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(loc.translate('addAsset_quick_titulo')),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(hintText: '0,00'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(loc.translate('common_cancelar')),
          ),
          TextButton(
            onPressed: () {
              final v = double.tryParse(controller.text.trim().replaceAll(',', '.'));
              Navigator.of(dialogContext).pop(v);
            },
            child: Text(loc.translate('addAsset_quick_salvar')),
          ),
        ],
      ),
    );
    if (newValue == null || newValue < 0) return;
    try {
      await _financeService.updateAsset(asset.copyWith(currentValue: newValue));
      _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${loc.translate('addAsset_quick_erro')}$e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.loahColors;
    final loc = AppLocales.of(context);
    final total = _assets.fold<double>(0, (sum, a) => sum + a.currentValue);

    return Scaffold(
      appBar: AppBar(title: Text(loc.translate('assets_titulo'))),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: colors.cardBackground,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.translate('assets_total'),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          CurrencyFormatter.format(total, context: context),
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (_assets.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text(
                          loc.translate('assets_sem_ativos'),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    )
                  else
                    for (final a in _assets) ...[
                      AssetCard(
                        asset: a,
                        onTap: () {},
                        onQuickUpdate: () => _quickUpdate(a),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colors.accentBlue,
        heroTag: 'assets_fab',
        onPressed: () async {
          final result = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => const AddAssetScreen()),
          );
          if (result == true) _loadData();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

