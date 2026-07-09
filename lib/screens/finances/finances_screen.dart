import 'package:flutter/material.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/navigation/navigation_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../models/transaction_model.dart';
import '../../widgets/loah_app_bar.dart';
import '../../widgets/loah_drawer.dart';
import '../../widgets/section_header.dart';
import 'widgets/emergency_goal_card.dart';
import 'widgets/expense_distribution_card.dart';
import 'widgets/total_balance_card.dart';
import 'widgets/transaction_list_item.dart';

/// "Loah - Finanças": total balance, emergency-fund goal, expense
/// distribution donut chart and recent transaction history.
class FinancesScreen extends StatelessWidget {
  const FinancesScreen({super.key});

  static final _categories = [
    ExpenseCategoryModel(label: 'Alimentação', amount: 860, color: Colors.green.shade400),
    ExpenseCategoryModel(label: 'Moradia', amount: 1200, color: Colors.orange.shade400),
    ExpenseCategoryModel(label: 'Transporte', amount: 220, color: Colors.red.shade400),
  ];

  static const _transactions = [
    TransactionModel(
      title: 'Mercado Central',
      subtitle: 'Hoje, 14:20 • Alimentação',
      amount: 146.20,
      type: TransactionType.expense,
      icon: Icons.shopping_cart_outlined,
    ),
    TransactionModel(
      title: 'Salário Mensal',
      subtitle: 'Ontem, 09:00 • Renda',
      amount: 4200.00,
      type: TransactionType.income,
      icon: Icons.payments_outlined,
    ),
    TransactionModel(
      title: 'Uber',
      subtitle: '02 Mai • Transporte',
      amount: 32.50,
      type: TransactionType.expense,
      icon: Icons.local_taxi_outlined,
    ),
    TransactionModel(
      title: 'Loja de Roupas',
      subtitle: '01 Mai • Shopping',
      amount: 210.00,
      type: TransactionType.expense,
      icon: Icons.checkroom_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.loahColors;
    final nav = LoahNavigationController.of(context);
    return Scaffold(
      drawer: LoahDrawer(currentIndex: nav.currentIndex, onNavigate: nav.navigateTo),
      appBar: LoahAppBar(
        title: 'Loah',
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.info_outline),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            const TotalBalanceCard(total: 12450.00, income: 4200.00, expense: 2150.00),
            const SizedBox(height: AppSpacing.md),
            const EmergencyGoalCard(target: 15000, progress: 0.68),
            const SizedBox(height: AppSpacing.lg),
            ExpenseDistributionCard(categories: _categories, onDetails: () {}),
            const SizedBox(height: AppSpacing.lg),
            SectionHeader(
              title: 'Transações Recentes',
              trailing: Icon(Icons.filter_list, color: colors.accentBlue, size: 18),
            ),
            const SizedBox(height: 10),
            for (final t in _transactions) ...[
              TransactionListItem(transaction: t),
              const SizedBox(height: AppSpacing.sm),
            ],
            const SizedBox(height: 4),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('VER TODO O HISTÓRICO'),
            ),
          ],
        ),
      ),
     floatingActionButton: FloatingActionButton(
      heroTag: 'finances_fab',
      onPressed: () {},
      child: const Icon(Icons.add),
    ),
    );
  }
}
