import 'package:flutter/material.dart';
import '../../core/mock/mock_data.dart';
import '../../core/mock/transaction_filters.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/transaction_model.dart';
import '../../widgets/loah_app_bar_simple.dart';
import 'add_transaction_screen.dart';
import 'widgets/transaction_filter_sheet.dart';
import 'widgets/transaction_list_item.dart';

/// "Loah - Histórico": every transaction ever lançada, searchable,
/// filterable (tipo/categoria/conta) and grouped by month with each
/// month's net total.
class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  String _query = '';
  TransactionFilters _filters = const TransactionFilters();

  static const _monthFull = [
    'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
    'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
  ];

  List<String> get _availableCategories =>
      MockData.transactions.map((t) => t.category).toSet().toList()..sort();

  Future<void> _openFilters() async {
    final result = await showModalBottomSheet<TransactionFilters>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.loahColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => TransactionFilterSheet(
        availableCategories: _availableCategories,
        availableAccounts: MockData.accounts,
        initialFilters: _filters,
      ),
    );
    if (result != null) setState(() => _filters = result);
  }

  Future<void> _editTransaction(TransactionModel t) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AddTransactionScreen(existingTransaction: t)),
    );
    setState(() {});
  }

  /// Filtered transactions grouped by month (most recent month first,
  /// transactions within each month most recent first).
  Map<DateTime, List<TransactionModel>> get _grouped {
    final filtered = MockData.transactions.where((t) {
      if (!_filters.matches(t)) return false;
      if (_query.isNotEmpty && !t.title.toLowerCase().contains(_query.toLowerCase())) return false;
      return true;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    final grouped = <DateTime, List<TransactionModel>>{};
    for (final t in filtered) {
      final monthKey = DateTime(t.date.year, t.date.month, 1);
      grouped.putIfAbsent(monthKey, () => []).add(t);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.loahColors;
    final grouped = _grouped;
    final months = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return Scaffold(
      appBar: const LoahAppBarSimple(title: 'Histórico'),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (v) => setState(() => _query = v),
                      decoration: InputDecoration(
                        hintText: 'Buscar transações...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        filled: true,
                        fillColor: colors.cardBackgroundAlt,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: colors.cardBackgroundAlt,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                          onPressed: _openFilters,
                          icon: Icon(
                            Icons.tune,
                            size: 20,
                            color: _filters.isActive ? colors.accentBlue : context.textSecondary,
                          ),
                        ),
                      ),
                      if (_filters.isActive)
                        Positioned(
                          top: 6,
                          right: 6,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: colors.accentBlue,
                              shape: BoxShape.circle,
                              border: Border.all(color: colors.cardBackgroundAlt, width: 1.5),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: months.isEmpty
                  ? Center(
                      child: Text(
                        'Nenhuma transação encontrada.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                      children: [
                        for (final month in months) ...[
                          _MonthHeader(
                            label: '${_monthFull[month.month - 1]} ${month.year}',
                            transactions: grouped[month]!,
                          ),
                          const SizedBox(height: 10),
                          for (final t in grouped[month]!) ...[
                            TransactionListItem(transaction: t, onTap: () => _editTransaction(t)),
                            const SizedBox(height: 8),
                          ],
                          const SizedBox(height: 12),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Month header with the net total for that month (income - expense),
/// colored green/red accordingly.
class _MonthHeader extends StatelessWidget {
  final String label;
  final List<TransactionModel> transactions;

  const _MonthHeader({required this.label, required this.transactions});

  @override
  Widget build(BuildContext context) {
    final colors = context.loahColors;
    final net = transactions.fold<double>(
      0,
      (sum, t) => sum + (t.isIncome ? t.amount : -t.amount),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        Text(
          '${net >= 0 ? '+ ' : '- '}${CurrencyFormatter.format(net.abs())}',
          style: TextStyle(
            color: net >= 0 ? colors.positive : colors.negative,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}