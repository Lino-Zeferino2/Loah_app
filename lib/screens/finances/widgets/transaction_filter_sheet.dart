import 'package:flutter/material.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/utils/transaction_filters.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/account_model.dart';
import '../../../models/transaction_model.dart';

/// Bottom sheet for filtering the Histórico list: type (Receita/
/// Despesa/Todas), one or more categories, and one or more accounts.
class TransactionFilterSheet extends StatefulWidget {
  final List<String> availableCategories;
  final List<AccountModel> availableAccounts;
  final TransactionFilters initialFilters;

  const TransactionFilterSheet({
    super.key,
    required this.availableCategories,
    required this.availableAccounts,
    required this.initialFilters,
  });

  @override
  State<TransactionFilterSheet> createState() => _TransactionFilterSheetState();
}

class _TransactionFilterSheetState extends State<TransactionFilterSheet> {
  late TransactionType? _type = widget.initialFilters.type;
  late Set<String> _categories = {...widget.initialFilters.categories};
  late Set<String> _accountIds = {...widget.initialFilters.accountIds};

  @override
  Widget build(BuildContext context) {
    final colors = context.loahColors;
    final loc = AppLocales.of(context);
    final maxHeight = MediaQuery.of(context).size.height * 0.85;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    loc.translate('txnFilter_titulo'),
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  if (_type != null || _categories.isNotEmpty || _accountIds.isNotEmpty)
                    TextButton(
                      onPressed: () => setState(() {
                        _type = null;
                        _categories = {};
                        _accountIds = {};
                      }),
                      child: Text(loc.translate('txnFilter_limpar')),
                    ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      loc.translate('txnFilter_tipo'),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            letterSpacing: 0.5,
                            color: context.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: Text(loc.translate('txnFilter_todas')),
                          selected: _type == null,
                          onSelected: (_) => setState(() => _type = null),
                        ),
                        ChoiceChip(
                          label: Text(loc.translate('txnFilter_receitas')),
                          selected: _type == TransactionType.income,
                          onSelected: (_) => setState(() => _type = TransactionType.income),
                        ),
                        ChoiceChip(
                          label: Text(loc.translate('txnFilter_despesas')),
                          selected: _type == TransactionType.expense,
                          onSelected: (_) => setState(() => _type = TransactionType.expense),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      loc.translate('txnFilter_categoria'),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            letterSpacing: 0.5,
                            color: context.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final category in widget.availableCategories)
                          FilterChip(
                            label: Text(loc.translateCategory(category)),
                            selected: _categories.contains(category),
                            onSelected: (selected) => setState(() {
                              if (selected) {
                                _categories.add(category);
                              } else {
                                _categories.remove(category);
                              }
                            }),
                            selectedColor: colors.accentBlue.withValues(alpha: 0.2),
                            checkmarkColor: colors.accentBlue,
                            backgroundColor: colors.cardBackgroundAlt,
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      loc.translate('txnFilter_conta'),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            letterSpacing: 0.5,
                            color: context.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final account in widget.availableAccounts)
                          FilterChip(
                            label: Text(account.name),
                            selected: _accountIds.contains(account.id),
                            onSelected: (selected) => setState(() {
                              if (selected) {
                                _accountIds.add(account.id);
                              } else {
                                _accountIds.remove(account.id);
                              }
                            }),
                            selectedColor: colors.accentBlue.withValues(alpha: 0.2),
                            checkmarkColor: colors.accentBlue,
                            backgroundColor: colors.cardBackgroundAlt,
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(
                    TransactionFilters(type: _type, categories: _categories, accountIds: _accountIds),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.accentBlue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(loc.translate('txnFilter_aplicar'), style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}