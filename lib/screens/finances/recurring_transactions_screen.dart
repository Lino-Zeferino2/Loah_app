import 'package:flutter/material.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/services/finance_service.dart';
import '../../models/recurring_transaction_model.dart';
import '../../models/transaction_model.dart'; // TransactionType
import 'add_recurring_transaction_screen.dart';
import 'widgets/recurring_transaction_card.dart';

class RecurringTransactionsScreen extends StatefulWidget {
  const RecurringTransactionsScreen({super.key});

  @override
  State<RecurringTransactionsScreen> createState() => _RecurringTransactionsScreenState();
}

class _RecurringTransactionsScreenState extends State<RecurringTransactionsScreen> {
  final FinanceService _financeService = FinanceService();
  List<RecurringTransactionModel> _recurring = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final items = await _financeService.getAllRecurring();
      if (mounted) setState(() { _recurring = items; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggleActive(RecurringTransactionModel item) async {
    try {
      final updated = item.copyWith(active: !item.active);
      await _financeService.updateRecurring(updated);
      _loadData();
    } catch (e) {
      if (mounted) {
        final loc = AppLocales.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${loc.translate('recurring_erro_atualizar')}$e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.loahColors;
    final loc = AppLocales.of(context);

    final totalIncome = _recurring
        .where((r) => r.active && r.type == TransactionType.income)
        .fold<double>(0, (s, r) => s + r.amount);
    final totalExpense = _recurring
        .where((r) => r.active && r.type == TransactionType.expense)
        .fold<double>(0, (s, r) => s + r.amount);

    return Scaffold(
      appBar: AppBar(title: Text(loc.translate('recurring_titulo'))),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _SummaryTile(
                          label: loc.translate('recurring_receitas_mes'),
                          value: CurrencyFormatter.format(totalIncome, context: context),
                          color: Colors.greenAccent,
                          colors: colors,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _SummaryTile(
                          label: loc.translate('recurring_despesas_mes'),
                          value: CurrencyFormatter.format(totalExpense, context: context),
                          color: Colors.redAccent,
                          colors: colors,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (_recurring.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text(
                          loc.translate('recurring_sem_itens'),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    )
                  else
                    for (final r in _recurring) ...[
                      RecurringTransactionCard(
                        recurring: r,
                        onActiveChanged: (_) => _toggleActive(r),
                        onTap: () async {
                          final result = await Navigator.of(context).push<bool>(
                            MaterialPageRoute(
                              builder: (_) => AddRecurringTransactionScreen(existingRecurring: r),
                            ),
                          );
                          if (result == true) _loadData();
                        },
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colors.accentBlue,
        heroTag: 'recurring_fab',
        onPressed: () async {
          final result = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => const AddRecurringTransactionScreen()),
          );
          if (result == true) _loadData();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final LoahColors colors;

  const _SummaryTile({
    required this.label,
    required this.value,
    required this.color,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

