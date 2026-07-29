import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/finance_summary.dart';
import '../../core/utils/report_summary.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/finance_service.dart';
import '../../models/account_model.dart';
import '../../models/asset_model.dart';
import '../../models/transaction_model.dart';
import '../../widgets/loah_app_bar_simple.dart';
import '../../widgets/loah_card.dart';
import '../../widgets/section_header.dart';
import '../../core/utils/csv_export.dart';
import '../../core/utils/pdf_export.dart';
import 'widgets/balance_bar_chart.dart';
import 'widgets/category_comparison_row.dart';
import 'widgets/donut_chart.dart';

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
  List<AssetModel> _assets = [];
  bool _exporting = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final accts = await _financeService.getAllAccounts();
      final txns = await _financeService.getAllTransactions();
      final assets = await _financeService.getAllAssets();
      if (mounted) setState(() { _accounts = accts; _transactions = txns; _assets = assets; });
    } catch (_) {
      if (mounted) {}
    }
  }

  Future<void> _exportCsv() async {
    setState(() => _exporting = true);
    try {
      final accounts = _accounts;
      final transactions = _transactions;
      final assets = _assets;

      final csv = CsvExport.fullReportCsv(
        transactions: transactions,
        accounts: accounts,
        assets: assets,
      );

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/loah_relatorio.csv');
      await file.writeAsString(csv);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Relatório Financeiro Loah',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao exportar CSV: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _exportPdf() async {
    setState(() => _exporting = true);
    try {
      final accounts = _accounts;
      final transactions = _transactions;
      final assets = _assets;
      final history = ReportSummary.balanceHistory(accounts, transactions, months: 6);
      final comparisons = ReportSummary.categoryComparison(transactions);

      final pdfBytes = await PdfExport.generateReport(
        accounts: accounts,
        transactions: transactions,
        assets: assets,
        balanceHistory: history,
        comparisons: comparisons,
      );

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/loah_relatorio.pdf');
      await file.writeAsBytes(pdfBytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Relatório Financeiro Loah',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao exportar PDF: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.loahColors;
    final accounts = _accounts;
    final transactions = _transactions;
    final history = ReportSummary.balanceHistory(accounts, transactions, months: 6);
    final comparisons = ReportSummary.categoryComparison(transactions);
    final trend = ReportSummary.trendLine(history);
    final distribution = FinanceSummary.expenseDistribution(transactions);

    return Scaffold(
      appBar: LoahAppBarSimple(
        title: 'Relatórios',
        actions: [
          if (_exporting)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else ...[
            IconButton(
              onPressed: _exportCsv,
              tooltip: 'Exportar CSV',
              icon: Icon(Icons.table_chart_outlined, color: colors.accentBlue),
            ),
            IconButton(
              onPressed: _exportPdf,
              tooltip: 'Exportar PDF',
              icon: Icon(Icons.picture_as_pdf, color: colors.accentBlue),
            ),
          ],
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Balance Evolution + Trend Line ──
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
                  if (trend != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Linha tracejada = tendência linear',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: context.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  BalanceBarChart(points: history, trendLine: trend),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Expense Distribution Pie Chart ──
            if (distribution.isNotEmpty) ...[
              LoahCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(title: 'Distribuição de Gastos (este mês)'),
                    const SizedBox(height: 16),
                    Center(
                      child: DonutChart(
                        categories: distribution,
                        size: 170,
                        centerChild: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Total', style: Theme.of(context).textTheme.bodySmall),
                            Text(
                              CurrencyFormatter.format(
                                distribution.fold<double>(0, (s, c) => s + c.amount),
                                context: context,
                              ),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        for (final cat in distribution)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: cat.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(cat.label, style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // ── Category Comparison ──
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
