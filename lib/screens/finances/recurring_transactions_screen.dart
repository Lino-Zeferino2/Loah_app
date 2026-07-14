import 'package:flutter/material.dart';
import '../../core/mock/mock_data.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/recurring_transaction_model.dart';
import '../../models/transaction_model.dart';
import '../../widgets/loah_app_bar_simple.dart';
import '../../widgets/loah_card.dart';
import 'add_recurring_transaction_screen.dart';
import 'widgets/recurring_transaction_card.dart';

/// "Loah - Recorrentes": salary, rent, subscriptions — anything that
/// repeats every month without the user re-entering it. Active items
/// are turned into real transactions automatically by [RecurringEngine]
/// once their due day arrives (see `finances_screen.dart`'s `initState`).
class RecurringTransactionsScreen extends StatefulWidget {
  const RecurringTransactionsScreen({super.key});

  @override
  State<RecurringTransactionsScreen> createState() => _RecurringTransactionsScreenState();
}

class _RecurringTransactionsScreenState extends State<RecurringTransactionsScreen> {
  void _toggleActive(RecurringTransactionModel item, bool value) {
    setState(() {
      final index = MockData.recurringTransactions.indexWhere((r) => r.id == item.id);
      if (index != -1) {
        MockData.recurringTransactions[index] = item.copyWith(active: value);
      }
    });
  }

  Future<void> _add() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AddRecurringTransactionScreen()),
    );
    setState(() {});
  }

  Future<void> _edit(RecurringTransactionModel item) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AddRecurringTransactionScreen(existingRecurring: item)),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final items = MockData.recurringTransactions;
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