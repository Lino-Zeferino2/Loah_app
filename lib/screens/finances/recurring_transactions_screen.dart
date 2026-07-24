import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/services/finance_service.dart';
import '../../models/recurring_transaction_model.dart';
import '../../models/transaction_model.dart';
import '../../widgets/loah_app_bar_simple.dart';
import '../../widgets/loah_card.dart';
import 'add_recurring_transaction_screen.dart';
import 'widgets/recurring_transaction_card.dart';

/// "Loah - Recorrentes": recurring transactions from Firebase.
class RecurringTransactionsScreen extends StatefulWidget {
  const RecurringTransactionsScreen({super.key});

  @override
  State<RecurringTransactionsScreen> createState() => _RecurringTransactionsScreenState();
}

class _RecurringTransactionsScreenState extends State<RecurringTransactionsScreen> {
  final FinanceService _financeService = FinanceService();
  List<RecurringTransactionModel> _items = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final items = await _financeService.getAllRecurring();
      if (mounted) setState(() { _items = items; });
    } catch (_) {
      if (mounted) {}
    }
  }

  Future<void> _toggleActive(RecurringTransactionModel item, bool value) async {
    try {
      await _financeService.updateRecurring(item.copyWith(active: value));
      _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar: $e')),
        );
      }
    }
  }

  Future<void> _add() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const AddRecurringTransactionScreen()),
    );
    if (result == true) _loadData();
  }

  Future<void> _edit(RecurringTransactionModel item) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => AddRecurringTransactionScreen(existingRecurring: item)),
    );
    if (result == true) _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
    final activeIncome = items
        .where((r) => r.active && r.type == TransactionType.income)
        .fold<double>(0, (sum, r) => sum + r.amount);
    final activeExpense = items
        .where((r) => r.active && r.type == TransactionType.expense)
        .fold<double>(0, (sum, r) => sum + r.amount);

    return Scaffold(
      appBar: const LoahAppBarSimple(title: 'Recorrentes'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            LoahCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('RECEITAS/MÊS', style: Theme.of(context).textTheme.labelSmall),
                        Text(
                          CurrencyFormatter.format(activeIncome),
                          style: TextStyle(
                            color: context.loahColors.positive,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('DESPESAS/MÊS', style: Theme.of(context).textTheme.labelSmall),
                        Text(
                          CurrencyFormatter.format(activeExpense),
                          style: TextStyle(
                            color: context.loahColors.negative,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'Nenhuma recorrência cadastrada ainda. Toque no + para adicionar a primeira.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              )
            else
              for (final item in items) ...[
                RecurringTransactionCard(
                  recurring: item,
                  onTap: () => _edit(item),
                  onActiveChanged: (v) => _toggleActive(item, v),
                ),
                const SizedBox(height: 10),
              ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'recurring_fab',
        onPressed: _add,
        child: const Icon(Icons.add),
      ),
    );
  }
}