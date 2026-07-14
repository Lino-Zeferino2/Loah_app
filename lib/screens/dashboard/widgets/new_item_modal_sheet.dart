import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/contact_model.dart';
import '../../contacts/add_contact_screen.dart';
import '../../finances/add_asset_screen.dart';
import '../../finances/add_budget_screen.dart';
import '../../finances/add_transaction_screen.dart';
import '../../finances/add_account_screen.dart';
import '../../finances/add_recurring_transaction_screen.dart';
import '../../goals/add_goal_screen.dart';
import '../../tasks/add_task_screen.dart';

/// Modal "Novo" usado no Dashboard.
/// Mantém o mesmo padrão visual (tema e componentes) do resto do app.
class NewItemModalSheet extends StatelessWidget {
  const NewItemModalSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.loahColors;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Criar novo',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Escolha o tipo de item que você deseja adicionar.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),

            _GridItem(
              icon: Icons.track_changes_outlined,
              title: 'Meta',
              onTap: () async {
                Navigator.of(context).pop();
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddGoalScreen()),
                );
              },
              color: colors.accentBlue,
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _GridItem(
                    icon: Icons.check_circle_outline,
                    title: 'Tarefa',
                    onTap: () async {
                      Navigator.of(context).pop();
                      await Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AddTaskScreen()),
                      );
                    },
                    color: colors.accentBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _GridItem(
                    icon: Icons.attach_money_outlined,
                    title: 'Transação',
                    onTap: () async {
                      Navigator.of(context).pop();
                      await Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
                      );
                    },
                    color: colors.accentBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _GridItem(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Conta',
                    onTap: () async {
                      Navigator.of(context).pop();
                      await Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AddAccountScreen()),
                      );
                    },
                    color: colors.accentBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _GridItem(
                    icon: Icons.inventory_2_outlined,
                    title: 'Ativo',
                    onTap: () async {
                      Navigator.of(context).pop();
                      await Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AddAssetScreen()),
                      );
                    },
                    color: colors.accentBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _GridItem(
                    icon: Icons.receipt_long_outlined,
                    title: 'Orçamento',
                    onTap: () async {
                      Navigator.of(context).pop();
                      await Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AddBudgetScreen()),
                      );
                    },
                    color: colors.accentBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _GridItem(
                    icon: Icons.autorenew_outlined,
                    title: 'Recorrente',
                    onTap: () async {
                      Navigator.of(context).pop();
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AddRecurringTransactionScreen(),
                        ),
                      );
                    },
                    color: colors.accentBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            _GridItem(
              icon: Icons.contacts_outlined,
              title: 'Contato',
              onTap: () async {
                Navigator.of(context).pop();
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddContactScreen()),
                );
              },
              color: colors.accentBlue,
            ),
          ],
        ),
      ),
    );
  }
}

class _GridItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color color;

  const _GridItem({
    required this.icon,
    required this.title,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.loahColors;

    return Material(
      color: colors.cardBackgroundAlt,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              Icon(Icons.chevron_right_rounded, size: 18, color: context.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

