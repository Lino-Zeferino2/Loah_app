import 'package:flutter/material.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/services/finance_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/account_balance.dart';
import '../../core/utils/account_visuals.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/account_model.dart';
import '../../models/transaction_model.dart';
import '../../widgets/loah_app_bar_simple.dart';
import '../../widgets/loah_card.dart';
import 'add_account_screen.dart';
import 'add_transaction_screen.dart';
import 'widgets/transaction_list_item.dart';

/// "Loah - Detalhes da Conta": header with the live balance, a summary
/// of initial balance/income/expenses, quick actions (edit account,
/// add transaction), the account's own transaction history and the
/// delete-account flow. Lê e escreve diretamente via [FinanceService].
class AccountDetailScreen extends StatefulWidget {
  final AccountModel account;

  const AccountDetailScreen({super.key, required this.account});

  @override
  State<AccountDetailScreen> createState() => _AccountDetailScreenState();
}

class _AccountDetailScreenState extends State<AccountDetailScreen> {
  final FinanceService _financeService = FinanceService();

  late AccountModel _account = widget.account;
  List<TransactionModel> _transactions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final txns = await _financeService.getAllTransactions();
      final accts = await _financeService.getAllAccounts();
      if (mounted) {
        setState(() {
          _transactions = txns;
          final fresh = accts.where((a) => a.id == _account.id).firstOrNull;
          if (fresh != null) _account = fresh;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<TransactionModel> get _accountTransactions {
    final list = _transactions.where((t) => t.accountId == _account.id).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  Future<void> _editAccount() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => AddAccountScreen(existingAccount: _account)),
    );
    if (result == true) _loadData();
  }

  Future<void> _addTransaction() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddTransactionScreen(preselectedAccountId: _account.id),
      ),
    );
    if (result == true) _loadData();
  }

  Future<void> _editTransaction(TransactionModel t) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => AddTransactionScreen(existingTransaction: t)),
    );
    if (result == true) _loadData();
  }

  Future<void> _deleteAccount() async {
    final loc = AppLocales.of(context);
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: context.loahColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.translate('addAcc_excluir_titulo'),
                style: Theme.of(sheetContext)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                loc.translate('addAcc_excluir_msg'),
                style: Theme.of(sheetContext).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(sheetContext).pop(false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(loc.translate('addAcc_cancelar')),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.of(sheetContext).pop(true),
                      child: Text(loc.translate('addAcc_excluir_confirmar')),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await _financeService.deleteAccount(_account.id);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        final loc = AppLocales.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${loc.translate('addAcc_erro_excluir')}$e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.loahColors;
    final loc = AppLocales.of(context);
    final accountTransactions = _accountTransactions;
    final balance = AccountBalance.of(_account, _transactions);
    final income = accountTransactions
        .where((t) => t.isIncome)
        .fold<double>(0, (sum, t) => sum + t.amount);
    final expense = accountTransactions
        .where((t) => !t.isIncome)
        .fold<double>(0, (sum, t) => sum + t.amount);

    return Scaffold(
      appBar: LoahAppBarSimple(title: _account.name),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  // Header card: type icon, name, type label and live balance.
                  LoahCard(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: _account.type.color.withValues(alpha: 0.15),
                          child: Icon(_account.type.icon, size: 30, color: _account.type.color),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _account.name,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          loc.translateAccountType(_account.type),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          loc.translate('accountDetail_saldo_atual'),
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          CurrencyFormatter.format(balance, context: context),
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: balance < 0 ? colors.negative : _account.type.color,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Summary: initial balance, income and expenses.
                  LoahCard(
                    child: Row(
                      children: [
                        _SummaryItem(
                          label: loc.translate('accountDetail_saldo_inicial'),
                          value: CurrencyFormatter.format(_account.initialBalance, context: context),
                        ),
                        _SummaryItem(
                          label: loc.translate('accountDetail_receitas'),
                          value: CurrencyFormatter.format(income, context: context),
                          valueColor: colors.positive,
                        ),
                        _SummaryItem(
                          label: loc.translate('accountDetail_despesas'),
                          value: CurrencyFormatter.format(expense, context: context),
                          valueColor: colors.negative,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _editAccount,
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          label: Text(loc.translate('addAcc_editar')),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.accentBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _addTransaction,
                          icon: const Icon(Icons.add, size: 18),
                          label: Text(loc.translate('addTxn_adicionar')),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  Text(
                    loc.translate('accountDetail_transacoes'),
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  if (accountTransactions.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          loc.translate('accountDetail_sem_transacoes'),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    )
                  else
                    for (final t in accountTransactions) ...[
                      TransactionListItem(transaction: t, onTap: () => _editTransaction(t)),
                      const SizedBox(height: AppSpacing.sm),
                    ],

                  const SizedBox(height: AppSpacing.xl),
                  OutlinedButton.icon(
                    onPressed: _deleteAccount,
                    icon: Icon(Icons.delete_outline, size: 18, color: colors.negative),
                    label: Text(
                      loc.translate('addAcc_excluir'),
                      style: TextStyle(color: colors.negative, fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.negative,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      side: BorderSide(color: colors.negative.withValues(alpha: 0.4)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 3*AppSpacing.lg),
                ],
              ),
            ),
    );
  }
}

/// One column of the summary card (initial balance / income / expenses).
class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _SummaryItem({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: valueColor,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

