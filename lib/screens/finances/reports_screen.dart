import 'package:flutter/material.dart';
import '../../core/mock/report_summary.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/finance_service.dart';
import '../../models/account_model.dart';
import '../../models/transaction_model.dart';
import '../../widgets/loah_app_bar_simple.dart';
import '../../widgets/loah_card.dart';
import '../../widgets/section_header.dart';
import 'widgets/balance_bar_chart.dart';
import 'widgets/category_comparison_row.dart';

/// "Loah - Relatórios": monthly account-balance evolution and category
/// comparison. Dados do Firebase via [FinanceService].
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final FinanceService _financeService = FinanceService();
  List<AccountModel> _accounts = [];
  List<TransactionModel> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final accts = await _financeService.getAllAccounts();
      final txns = await _financeService.getAllTransactions();
      if (mounted) setState(() { _accounts = accts; _transactions = txns; });
    } catch (_) {
      if (mounted) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final accounts = _accounts;
    final transactions = _transactions;
    final history = ReportSummary.balanceHistory(accounts, transactions, months: 6);
    final comparisons = ReportSummary.categoryComparison(transactions);

    return Scaffold(
      appBar: const LoahAppBarSimple(title: 'Relatórios'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            LoahCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(title: 'Evolução do Saldo (6 meses)'),
                  const SizedBox(height: 4),
                  Text(
                    'Soma do saldo de todas as contas, reconstruído a partir das '
                    'transações lançadas.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  BalanceBarChart(points: history),
                ],
              ),
            ),
            const SizedBox(height: 20),
            LoahCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(title: 'Gasto por Categoria'),
                  const SizedBox(height: 4),
                  Text(
                    'Este mês comparado ao mês anterior.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  if (comparisons.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'Sem despesas suficientes ainda para comparar períodos.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    )
                  else
                    for (final comparison in comparisons)
                      CategoryComparisonRow(comparison: comparison),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                'Nota: o Patrimônio (ações, imóveis) ainda não tem histórico ao '
                'longo do tempo — hoje só guardamos o valor atual de cada ativo. '
                'Esse gráfico usa apenas o saldo das Contas, que já tem histórico '
                'real via as transações.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}