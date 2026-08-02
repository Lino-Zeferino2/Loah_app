import 'package:flutter/material.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/utils/transaction_categories.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/finance_service.dart';
import '../../models/account_model.dart';
import '../../models/transaction_model.dart';
import '../../widgets/chip_selector.dart';

/// "Loah - Nova/Editar Transação": form to create or edit a
/// [TransactionModel]. Salva diretamente no Firestore via [FinanceService].
class AddTransactionScreen extends StatefulWidget {
  final TransactionModel? existingTransaction;

  /// When opening the form from an account detail screen, pre-select
  /// that account so the new transaction is linked to it by default.
  final String? preselectedAccountId;

  const AddTransactionScreen({super.key, this.existingTransaction, this.preselectedAccountId});

  bool get isEditing => existingTransaction != null;

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final FinanceService _financeService = FinanceService();
  List<AccountModel> _accounts = [];

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
  AccountModel? _account;

  String? _titleError;
  String? _amountError;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    final accts = await _financeService.getAllAccounts();
    if (mounted) {
      setState(() {
        _accounts = accts;
        if (_account == null) {
          final id = widget.existingTransaction?.accountId ?? widget.preselectedAccountId;
          if (id != null) {
            _account = accts.where((a) => a.id == id).firstOrNull;
          }
          _account ??= accts.isNotEmpty ? accts.first : null;
        }
      });
    }
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

  Future<void> _submit() async {
    final loc = AppLocales.of(context);
    if (_accounts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.translate('addTxn_sem_conta')),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final title = _titleController.text.trim();
    final amount = _parseAmount();

    var hasError = false;
    if (title.isEmpty) {
      setState(() => _titleError = loc.translate('addTxn_nome_erro'));
      hasError = true;
    }
    if (amount == null || amount <= 0) {
      setState(() => _amountError = loc.translate('addTxn_valor_erro'));
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

    try {
      if (existing != null) {
        await _financeService.updateTransaction(transaction);
      } else {
        await _financeService.addTransaction(transaction);
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${loc.translate('addTxn_erro_salvar')}$e')),
        );
      }
    }
  }

Future<void> _delete() async {
    final sheetLoc = AppLocales.of(context);
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
                sheetLoc.translate('addTxn_excluir_titulo'),
                style: Theme.of(sheetContext)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                sheetLoc.translate('addTxn_excluir_msg'),
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
                      child: Text(sheetLoc.translate('addTxn_cancelar')),
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
                      child: Text(sheetLoc.translate('addTxn_excluir_confirmar')),
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
      await _financeService.deleteTransaction(widget.existingTransaction!.id);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        final loc = AppLocales.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${loc.translate('addTxn_erro_excluir')}$e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.loahColors;
    final isEditing = widget.isEditing;
    final categories = TransactionCategories.forType(_type);
    final loc = AppLocales.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? loc.translate('addTxn_editar') : loc.translate('addTxn_novo'))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SectionLabel(loc.translate('addTxn_tipo_label')),
            const SizedBox(height: 8),
            ChipSelector<TransactionType>(
              options: [
                ChipOption(loc.translate('addTxn_tipo_despesa'), TransactionType.expense),
                ChipOption(loc.translate('addTxn_tipo_receita'), TransactionType.income),
              ],
              selected: _type,
              onChanged: _onTypeChanged,
            ),
            const SizedBox(height: 20),

            _SectionLabel(loc.translate('addTxn_valor_label')),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) {
                if (_amountError != null) setState(() => _amountError = null);
              },
              decoration: InputDecoration(
                prefixText: '${CurrencyFormatter.symbol(context: context)} ',
                hintText: loc.translate('addTxn_valor_hint'),
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

            _SectionLabel(loc.translate('addTxn_nome_label')),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              onChanged: (_) {
                if (_titleError != null) setState(() => _titleError = null);
              },
              decoration: InputDecoration(
                hintText: loc.translate('addTxn_nome_hint'),
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

            _SectionLabel(loc.translate('addTxn_categoria_label')),
            const SizedBox(height: 8),
            ChipSelector<String>(
              options: [for (final c in categories) ChipOption(loc.translateCategory(c), c)],
              selected: _category,
              onChanged: (v) => setState(() => _category = v),
            ),
            const SizedBox(height: 20),

            _SectionLabel(loc.translate('addTxn_conta_label')),
            const SizedBox(height: 8),
            if (_accounts.isEmpty)
              Text(
                loc.translate('addTxn_conta_vazia'),
                style: Theme.of(context).textTheme.bodySmall,
              )
            else
              ChipSelector<AccountModel>(
                options: [for (final a in _accounts) ChipOption(a.name, a)],
                selected: _account!,
                onChanged: (v) => setState(() => _account = v),
              ),
            const SizedBox(height: 20),

            _SectionLabel(loc.translate('addTxn_data_label')),
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
                  label: Text(
                    loc.translate('addTxn_excluir'),
                    style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
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
                  isEditing ? loc.translate('addTxn_salvar') : loc.translate('addTxn_adicionar'),
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