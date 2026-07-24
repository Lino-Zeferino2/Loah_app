import 'package:flutter/material.dart';
import '../../core/mock/account_balance.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/services/finance_service.dart';
import '../../models/account_model.dart';
import '../../models/transaction_model.dart';
import '../../widgets/loah_app_bar_simple.dart';
import '../../widgets/loah_card.dart';
import 'add_account_screen.dart';
import 'widgets/account_card.dart';

/// "Loah - Contas": total balance across every account/wallet, plus the
/// list of individual accounts, all data from Firebase via [FinanceService].
class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  final FinanceService _financeService = FinanceService();
  List<AccountModel> _accounts = [];
  List<TransactionModel> _transactions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final accts = await _financeService.getAllAccounts();
      final txns = await _financeService.getAllTransactions();
      if (mounted) {
        setState(() {
          _accounts = accts;
          _transactions = txns;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _addAccount() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const AddAccountScreen()),
    );
    if (result == true) _loadData();
  }

  Future<void> _editAccount(AccountModel account) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => AddAccountScreen(existingAccount: account)),
    );
    if (result == true) _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final accounts = _accounts;
    final transactions = _transactions;
    final total = AccountBalance.totalOf(accounts, transactions);

    return Scaffold(
      appBar: const LoahAppBarSimple(title: 'Contas'),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadData,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    LoahCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SALDO TOTAL (TODAS AS CONTAS)',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  letterSpacing: 0.5,
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
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (accounts.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text(
                            'Nenhuma conta cadastrada ainda. Toque no + para adicionar a primeira.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      )
                    else
                      for (final account in accounts) ...[
                        AccountCard(
                          account: account,
                          allTransactions: transactions,
                          onTap: () => _editAccount(account),
                        ),
                        const SizedBox(height: 10),
                      ],
                  ],
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'accounts_fab',
        onPressed: _addAccount,
        child: const Icon(Icons.add),
      ),
    );
  }
}
