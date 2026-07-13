import 'package:flutter/material.dart';
import '../../core/mock/account_balance.dart';
import '../../core/mock/mock_data.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/account_model.dart';
import '../../widgets/loah_app_bar_simple.dart';
import '../../widgets/loah_card.dart';
import 'add_account_screen.dart';
import 'widgets/account_card.dart';

/// "Loah - Contas": total balance across every account/wallet, plus the
/// list of individual accounts (Conta Corrente, Poupança, Cartão de
/// Crédito, Carteira...), each showing its live balance.
class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  Future<void> _addAccount() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AddAccountScreen()),
    );
    setState(() {});
  }

  Future<void> _editAccount(AccountModel account) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AddAccountScreen(existingAccount: account)),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final accounts = MockData.accounts;
    final transactions = MockData.transactions;
    final total = AccountBalance.totalOf(accounts, transactions);

    return Scaffold(
      appBar: const LoahAppBarSimple(title: 'Contas'),
      body: SafeArea(
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
      floatingActionButton: FloatingActionButton(
        heroTag: 'accounts_fab',
        onPressed: _addAccount,
        child: const Icon(Icons.add),
      ),
    );
  }
}