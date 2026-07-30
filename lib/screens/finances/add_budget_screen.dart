import 'package:flutter/material.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/utils/transaction_categories.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/finance_service.dart';
import '../../models/budget_model.dart';
import '../../widgets/chip_selector.dart';

/// "Loah - Novo/Editar Orçamento": form to create or edit a
/// [BudgetModel]. Salva diretamente no Firestore via [FinanceService].
class AddBudgetScreen extends StatefulWidget {
  final BudgetModel? existingBudget;

  const AddBudgetScreen({super.key, this.existingBudget});

  bool get isEditing => existingBudget != null;

  @override
  State<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends State<AddBudgetScreen> {
  final FinanceService _financeService = FinanceService();
  List<BudgetModel> _existingBudgets = [];

  late final _limitController = TextEditingController(
    text: widget.existingBudget != null
        ? widget.existingBudget!.monthlyLimit.toStringAsFixed(2)
        : '',
  );

  late String? _category = widget.existingBudget?.category;
  String? _limitError;

  @override
  void initState() {
    super.initState();
    _loadBudgets();
  }

  Future<void> _loadBudgets() async {
    final budgets = await _financeService.getAllBudgets();
    if (mounted) {
      setState(() {
        _existingBudgets = budgets;
        _category ??= _firstAvailableCategory();
      });
    }
  }

  List<String> get _availableCategories {
    final used = _existingBudgets
        .where((b) => b.id != widget.existingBudget?.id)
        .map((b) => b.category)
        .toSet();
    return TransactionCategories.expense.where((c) => !used.contains(c)).toList();
  }

  String? _firstAvailableCategory() {
    final available = _availableCategories;
    return available.isEmpty ? null : available.first;
  }

  @override
  void dispose() {
    _limitController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final loc = AppLocales.of(context);
    final limit = double.tryParse(_limitController.text.trim().replaceAll(',', '.'));
    if (_category == null) return;

    if (limit == null || limit <= 0) {
      setState(() => _limitError = loc.translate('addBudget_erro_valor'));
      return;
    }

    final existing = widget.existingBudget;
    final budget = BudgetModel(
      id: existing?.id ?? 'budget_${DateTime.now().microsecondsSinceEpoch}',
      category: _category!,
      monthlyLimit: limit,
    );

    try {
      if (existing != null) {
        await _financeService.updateBudget(budget);
      } else {
        await _financeService.addBudget(budget);
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${loc.translate('addBudget_erro_salvar')}$e')),
        );
      }
    }
  }

  Future<void> _delete() async {
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
                loc.translate('addBudget_excluir_titulo'),
                style: Theme.of(sheetContext)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                loc.translate('addBudget_excluir_msg'),
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
                      child: Text(loc.translate('addBudget_cancelar')),
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
                      child: Text(loc.translate('addBudget_excluir_confirmar')),
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
      await _financeService.deleteBudget(widget.existingBudget!.id);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        final loc = AppLocales.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${loc.translate('addBudget_erro_excluir')}$e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.loahColors;
    final isEditing = widget.isEditing;
    final loc = AppLocales.of(context);
    final available = _availableCategories;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? loc.translate('addBudget_editar') : loc.translate('addBudget_novo'))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SectionLabel(loc.translate('addBudget_categoria_label')),
            const SizedBox(height: 8),
            if (available.isEmpty && _category == null)
              Text(
                loc.translate('addBudget_todas_categorias'),
                style: Theme.of(context).textTheme.bodySmall,
              )
            else
              ChipSelector<String>(
                options: [for (final c in available) ChipOption(c, c)],
                selected: _category ?? available.firstOrNull ?? TransactionCategories.expense.first,
                onChanged: (v) => setState(() => _category = v),
              ),
            const SizedBox(height: 20),

            _SectionLabel(loc.translate('addBudget_limite_label')),
            const SizedBox(height: 8),
            TextField(
              controller: _limitController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) {
                if (_limitError != null) setState(() => _limitError = null);
              },
              decoration: InputDecoration(
                prefixText: '${CurrencyFormatter.symbol(context: context)} ',
                hintText: '0,00',
                errorText: _limitError,
                filled: true,
                fillColor: colors.cardBackgroundAlt,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 28),

            if (isEditing) ...[
              Center(
                child: TextButton.icon(
                  onPressed: _delete,
                  icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                  label: Text(
                    loc.translate('addBudget_excluir'),
                    style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _category == null ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.accentBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  isEditing ? loc.translate('addBudget_salvar') : loc.translate('addBudget_criar'),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            letterSpacing: 0.6,
            color: context.textSecondary,
          ),
    );
  }
}

