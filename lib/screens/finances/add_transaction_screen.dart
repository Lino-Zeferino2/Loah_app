import 'package:flutter/material.dart';
import '../../core/mock/mock_data.dart';
import '../../core/mock/transaction_categories.dart';
import '../../core/theme/app_theme.dart';
import '../../models/account_model.dart';
import '../../models/transaction_model.dart';
import '../../widgets/chip_selector.dart';

/// "Loah - Nova/Editar Transação": form to create or edit a
/// [TransactionModel]. Pass [existingTransaction] to edit in place
/// (fields pre-fill, saving updates the same id, and a delete action
/// appears); leave it null to create a new one.
class AddTransactionScreen extends StatefulWidget {
  final TransactionModel? existingTransaction;

  const AddTransactionScreen({super.key, this.existingTransaction});

  bool get isEditing => existingTransaction != null;

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  late final _titleController =
      TextEditingController(text: widget.existingTransaction?.title ?? '');
  late final _amountController = TextEditingController(
    text: widget.existingTransaction != null
        ? widget.existingTransaction!.amount.toStringAsFixed(2)
        : '',
  );

  late TransactionType _type = widget.existingTransaction?.type ?? TransactionType.expense;
  late String _category = widget.existingTransaction?.category ??
      TransactionCategories.forType(_type).first;
  late DateTime _date = widget.existingTransaction?.date ?? DateTime.now();
  late AccountModel? _account = _initialAccount();

  String? _titleError;
  String? _amountError;

  AccountModel? _initialAccount() {
    final id = widget.existingTransaction?.accountId;
    final matches = MockData.accounts.where((a) => a.id == id);
    if (matches.isNotEmpty) return matches.first;
    return MockData.accounts.isNotEmpty ? MockData.accounts.first : null;
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
      // Reset category if it doesn't belong to the new type's list.
      if (!TransactionCategories.forType(type).contains(_category)) {
        _category = TransactionCategories.forType(type).first;
      }
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 3)),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _date = DateTime(picked.year, picked.month, picked.day, _date.hour, _date.minute));
    }
  }

  double? _parseAmount() {
    final raw = _amountController.text.trim().replaceAll(',', '.');
    if (raw.isEmpty) return null;
    return double.tryParse(raw);
  }

  void _submit() {
    final title = _titleController.text.trim();
    final amount = _parseAmount();

    var hasError = false;
    if (title.isEmpty) {
      setState(() => _titleError = 'Dê um nome para a transação.');
      hasError = true;
    }
    if (amount == null || amount <= 0) {
      setState(() => _amountError = 'Informe um valor válido.');
      hasError = true;
    }
    if (hasError) return;

    final existing = widget.existingTransaction;
    final transaction = TransactionModel(
      id: existing?.id ?? 'txn_${DateTime.now().microsecondsSinceEpoch}',
      title: title,
      category: _category,
      amount: amount!,
      type: _type,
      date: _date,
      accountId: _account?.id,
    );

    if (existing != null) {
      final index = MockData.transactions.indexWhere((t) => t.id == existing.id);
      if (index != -1) MockData.transactions[index] = transaction;
    } else {
      MockData.transactions.add(transaction);
    }

    Navigator.of(context).pop(transaction);
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
                'Excluir Transação',
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

    MockData.transactions.removeWhere((t) => t.id == widget.existingTransaction!.id);
    Navigator.of(context).pop(widget.existingTransaction);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.loahColors;
    final isEditing = widget.isEditing;
    final categories = TransactionCategories.forType(_type);

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Editar Transação' : 'Nova Transação')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SectionLabel('TIPO'),
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

            _SectionLabel('VALOR'),
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

            _SectionLabel('NOME'),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              onChanged: (_) {
                if (_titleError != null) setState(() => _titleError = null);
              },
              decoration: InputDecoration(
                hintText: 'Ex: Mercado Central',
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

            _SectionLabel('CATEGORIA'),
            const SizedBox(height: 8),
            ChipSelector<String>(
              options: [for (final c in categories) ChipOption(c, c)],
              selected: _category,
              onChanged: (v) => setState(() => _category = v),
            ),
            const SizedBox(height: 20),

            _SectionLabel('CONTA'),
            const SizedBox(height: 8),
            if (MockData.accounts.isEmpty)
              Text(
                'Nenhuma conta cadastrada — crie uma na tela de Contas antes de lançar transações.',
                style: Theme.of(context).textTheme.bodySmall,
              )
            else
              ChipSelector<AccountModel>(
                options: [for (final a in MockData.accounts) ChipOption(a.name, a)],
                selected: _account!,
                onChanged: (v) => setState(() => _account = v),
              ),
            const SizedBox(height: 20),

            _SectionLabel('DATA'),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: colors.cardBackgroundAlt,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 18, color: context.textSecondary),
                    const SizedBox(width: 10),
                    Text(
                      '${_date.day.toString().padLeft(2, '0')}/'
                      '${_date.month.toString().padLeft(2, '0')}/'
                      '${_date.year}',
                    ),
                  ],
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
                    'Excluir Transação',
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
                  isEditing ? 'Salvar Alterações' : 'Adicionar Transação',
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