import 'package:flutter/material.dart';
import '../../core/mock/mock_data.dart';
import '../../core/mock/transaction_categories.dart';
import '../../core/theme/app_theme.dart';
import '../../models/budget_model.dart';
import '../../widgets/chip_selector.dart';

/// "Loah - Novo/Editar Orçamento": form to create or edit a
/// [BudgetModel]. Pass [existingBudget] to edit in place; leave it null
/// to create a new one. When creating, categories that already have a
/// budget are hidden from the picker (one budget per category).
class AddBudgetScreen extends StatefulWidget {
  final BudgetModel? existingBudget;

  const AddBudgetScreen({super.key, this.existingBudget});

  bool get isEditing => existingBudget != null;

  @override
  State<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends State<AddBudgetScreen> {
  late final _limitController = TextEditingController(
    text: widget.existingBudget != null
        ? widget.existingBudget!.monthlyLimit.toStringAsFixed(2)
        : '',
  );

  late String? _category = widget.existingBudget?.category ?? _firstAvailableCategory();

  String? _limitError;

  /// Categories that don't already have a budget (excluding the one
  /// currently being edited, so it stays selectable).
  List<String> get _availableCategories {
    final used = MockData.budgets
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

  void _submit() {
    final limit = double.tryParse(_limitController.text.trim().replaceAll(',', '.'));
    if (_category == null) return; // no categories left to budget

    if (limit == null || limit <= 0) {
      setState(() => _limitError = 'Informe um valor válido.');
      return;
    }

    final existing = widget.existingBudget;
    final budget = BudgetModel(
      id: existing?.id ?? 'budget_${DateTime.now().microsecondsSinceEpoch}',
      category: _category!,
      monthlyLimit: limit,
    );

    if (existing != null) {
      final index = MockData.budgets.indexWhere((b) => b.id == existing.id);
      if (index != -1) MockData.budgets[index] = budget;
    } else {
      MockData.budgets.add(budget);
    }

    Navigator.of(context).pop(budget);
  }

  Future<void> _delete() async {
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
                'Excluir Orçamento',
                style: Theme.of(sheetContext)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'Tem certeza? Essa ação não pode ser desfeita.',
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
                      child: const Text('Cancelar'),
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
                      child: const Text('Excluir'),
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

    MockData.budgets.removeWhere((b) => b.id == widget.existingBudget!.id);
    Navigator.of(context).pop(widget.existingBudget);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.loahColors;
    final isEditing = widget.isEditing;
    final available = _availableCategories;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Editar Orçamento' : 'Novo Orçamento')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const _SectionLabel('CATEGORIA'),
            const SizedBox(height: 8),
            if (available.isEmpty && _category == null)
              Text(
                'Todas as categorias de despesa já têm um orçamento definido.',
                style: Theme.of(context).textTheme.bodySmall,
              )
            else
              ChipSelector<String>(
                options: [for (final c in available) ChipOption(c, c)],
                selected: _category!,
                onChanged: (v) => setState(() => _category = v),
              ),
            const SizedBox(height: 20),

            const _SectionLabel('LIMITE MENSAL'),
            const SizedBox(height: 8),
            TextField(
              controller: _limitController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) {
                if (_limitError != null) setState(() => _limitError = null);
              },
              decoration: InputDecoration(
                prefixText: 'R\$ ',
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
                  label: const Text(
                    'Excluir Orçamento',
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
                  isEditing ? 'Salvar Alterações' : 'Criar Orçamento',
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