import 'package:flutter/material.dart';
import '../../core/mock/mock_data.dart';
import '../../core/mock/transaction_categories.dart';
import '../../core/theme/app_theme.dart';
import '../../models/account_model.dart';
import '../../models/recurring_transaction_model.dart';
import '../../models/transaction_model.dart';
import '../../widgets/chip_selector.dart';

/// "Loah - Nova/Editar Recorrência": form to create or edit a
/// [RecurringTransactionModel]. Pass [existingRecurring] to edit in
/// place; leave it null to create a new one.
class AddRecurringTransactionScreen extends StatefulWidget {
  final RecurringTransactionModel? existingRecurring;

  const AddRecurringTransactionScreen({super.key, this.existingRecurring});

  bool get isEditing => existingRecurring != null;

  @override
  State<AddRecurringTransactionScreen> createState() => _AddRecurringTransactionScreenState();
}

class _AddRecurringTransactionScreenState extends State<AddRecurringTransactionScreen> {
  late final _titleController =
      TextEditingController(text: widget.existingRecurring?.title ?? '');
  late final _amountController = TextEditingController(
    text: widget.existingRecurring != null
        ? widget.existingRecurring!.amount.toStringAsFixed(2)
        : '',
  );

  late TransactionType _type = widget.existingRecurring?.type ?? TransactionType.expense;
  late String _category =
      widget.existingRecurring?.category ?? TransactionCategories.forType(_type).first;
  late int _dayOfMonth = widget.existingRecurring?.dayOfMonth ?? 5;
  late bool _active = widget.existingRecurring?.active ?? true;
  AccountModel? _account;

  String? _titleError;
  String? _amountError;

  @override
  void initState() {
    super.initState();
    final id = widget.existingRecurring?.accountId;
    final matches = MockData.accounts.where((a) => a.id == id);
    _account = matches.isNotEmpty
        ? matches.first
        : (MockData.accounts.isNotEmpty ? MockData.accounts.first : null);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _onTypeChanged(TransactionType type) {
    setState(() {
      _type = type;
      if (!TransactionCategories.forType(type).contains(_category)) {
        _category = TransactionCategories.forType(type).first;
      }
    });
  }

  void _submit() {
    final title = _titleController.text.trim();
    final amount = double.tryParse(_amountController.text.trim().replaceAll(',', '.'));

    var hasError = false;
    if (title.isEmpty) {
      setState(() => _titleError = 'Dê um nome para a recorrência.');
      hasError = true;
    }
    if (amount == null || amount <= 0) {
      setState(() => _amountError = 'Informe um valor válido.');
      hasError = true;
    }
    if (hasError) return;

    final existing = widget.existingRecurring;
    final recurring = RecurringTransactionModel(
      id: existing?.id ?? 'recurring_${DateTime.now().microsecondsSinceEpoch}',
      title: title,
      category: _category,
      amount: amount!,
      type: _type,
      accountId: _account?.id,
      dayOfMonth: _dayOfMonth,
      active: _active,
      lastGeneratedMonth: existing?.lastGeneratedMonth,
    );

    if (existing != null) {
      final index = MockData.recurringTransactions.indexWhere((r) => r.id == existing.id);
      if (index != -1) MockData.recurringTransactions[index] = recurring;
    } else {
      MockData.recurringTransactions.add(recurring);
    }

    Navigator.of(context).pop(recurring);
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
                'Excluir Recorrência',
                style: Theme.of(sheetContext)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'As transações já geradas por ela não serão apagadas. Tem certeza?',
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

    MockData.recurringTransactions.removeWhere((r) => r.id == widget.existingRecurring!.id);
    Navigator.of(context).pop(widget.existingRecurring);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.loahColors;
    final isEditing = widget.isEditing;
    final categories = TransactionCategories.forType(_type);

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Editar Recorrência' : 'Nova Recorrência')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const _SectionLabel('TIPO'),
            const SizedBox(height: 8),
            ChipSelector<TransactionType>(
              options: const [
                ChipOption('Despesa', TransactionType.expense),
                ChipOption('Receita', TransactionType.income),
              ],
              selected: _type,
              onChanged: _onTypeChanged,
            ),
            const SizedBox(height: 20),

            const _SectionLabel('NOME'),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              onChanged: (_) {
                if (_titleError != null) setState(() => _titleError = null);
              },
              decoration: InputDecoration(
                hintText: 'Ex: Netflix',
                errorText: _titleError,
                filled: true,
                fillColor: colors.cardBackgroundAlt,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            const _SectionLabel('VALOR'),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) {
                if (_amountError != null) setState(() => _amountError = null);
              },
              decoration: InputDecoration(
                prefixText: 'R\$ ',
                hintText: '0,00',
                errorText: _amountError,
                filled: true,
                fillColor: colors.cardBackgroundAlt,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            const _SectionLabel('CATEGORIA'),
            const SizedBox(height: 8),
            ChipSelector<String>(
              options: [for (final c in categories) ChipOption(c, c)],
              selected: _category,
              onChanged: (v) => setState(() => _category = v),
            ),
            const SizedBox(height: 20),

            const _SectionLabel('CONTA'),
            const SizedBox(height: 8),
            if (MockData.accounts.isEmpty)
              Text(
                'Nenhuma conta cadastrada — crie uma na tela de Contas primeiro.',
                style: Theme.of(context).textTheme.bodySmall,
              )
            else
              ChipSelector<AccountModel>(
                options: [for (final a in MockData.accounts) ChipOption(a.name, a)],
                selected: _account!,
                onChanged: (v) => setState(() => _account = v),
              ),
            const SizedBox(height: 20),

            const _SectionLabel('DIA DO MÊS'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: colors.cardBackgroundAlt,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: _dayOfMonth.toDouble(),
                      min: 1,
                      max: 28,
                      divisions: 27,
                      activeColor: colors.accentBlue,
                      label: 'Dia $_dayOfMonth',
                      onChanged: (v) => setState(() => _dayOfMonth = v.round()),
                    ),
                  ),
                  SizedBox(
                    width: 44,
                    child: Text(
                      'Dia $_dayOfMonth',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Ativa'),
              subtitle: Text(
                _active
                    ? 'Gera a transação automaticamente todo mês.'
                    : 'Pausada — não gera transações até ser reativada.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              value: _active,
              activeThumbColor: colors.accentBlue,
              onChanged: (v) => setState(() => _active = v),
            ),
            const SizedBox(height: 20),

            if (isEditing) ...[
              Center(
                child: TextButton.icon(
                  onPressed: _delete,
                  icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                  label: const Text(
                    'Excluir Recorrência',
                    style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.accentBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  isEditing ? 'Salvar Alterações' : 'Criar Recorrência',
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