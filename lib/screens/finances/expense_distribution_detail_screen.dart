import 'package:flutter/material.dart';
import '../../core/mock/finance_summary.dart';
import '../../core/mock/mock_data.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../widgets/loah_app_bar_simple.dart';
import '../../widgets/loah_card.dart';
import 'widgets/category_detail_row.dart';
import 'widgets/donut_chart.dart';

/// "Loah - Distribuição de Gastos": full breakdown of this month's
/// expenses — total spent (with vs.-last-month comparison), a donut
/// chart showing how many categories are in play, a color legend, and
/// a detailed per-category list with progress bars.
class ExpenseDistributionDetailScreen extends StatelessWidget {
  const ExpenseDistributionDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.loahColors;
    final transactions = MockData.transactions;

    final total = FinanceSummary.monthlyExpense(transactions);
    final changePercent = FinanceSummary.monthlyExpenseChangePercent(transactions);
    final distribution = FinanceSummary.expenseDistribution(transactions);

    return Scaffold(
      appBar: const LoahAppBarSimple(title: 'Distribuição de Gastos'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            LoahCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL GASTO (ESTE MÊS)',
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
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w800, color: colors.accentBlue),
                  ),
                  if (changePercent != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          changePercent >= 0 ? Icons.trending_up : Icons.trending_down,
                          size: 16,
                          color: changePercent >= 0 ? colors.negative : colors.positive,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${changePercent.abs().toStringAsFixed(0)}% '
                          '${changePercent >= 0 ? 'a mais' : 'a menos'} que o mês passado',
                          style: TextStyle(
                            color: changePercent >= 0 ? colors.negative : colors.positive,
                            fontWeight: FontWeight.w600,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            if (distribution.isEmpty)
              LoahCard(
                child: Text(
                  'Nenhuma despesa registrada este mês ainda.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              )
            else ...[
              LoahCard(
                child: Column(
                  children: [
                    Center(
                      child: DonutChart(
                        categories: distribution,
                        size: 170,
                        centerChild: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Categorias', style: Theme.of(context).textTheme.bodySmall),
                            Text(
                              '${distribution.length}',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        for (final category in distribution)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: category.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(category.label, style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Detalhamento por Categoria',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              for (final category in distribution)
                CategoryDetailRow(category: category, totalSpend: total),
            ],
          ],
        ),
      ),
    );
  }
}