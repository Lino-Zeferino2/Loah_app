import 'package:flutter/material.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/utils/transaction_categories.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/finance_service.dart';
import '../../models/account_model.dart';
import '../../models/recurring_transaction_model.dart';
import '../../models/transaction_model.dart';
import '../../widgets/chip_selector.dart';

/// "Loah - Nova/Editar Recorrência": form to create or edit a
/// [RecurringTransactionModel]. Salva no Firestore via [FinanceService].
class AddRecurringTransactionScreen extends StatefulWidget {
  final RecurringTransactionModel? existingRecurring;

  const AddRecurringTransactionScreen({super.key, this.existingRecurring});

  bool get isEditing => existingRecurring != null;

  @override
  State<AddRecurringTransactionScreen> createState() => _AddRecurringTransactionScreenState();
}

class _AddRecurringTransactionScreenState extends State<AddRecurringTransactionScreen> {
  final FinanceService _financeService = FinanceService();
  List<AccountModel> _accounts = [];

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
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    final accts = await _financeService.getAllAccounts();
    if (mounted) {
      setState(() {
        _accounts = accts;
        final id = widget.existingRecurring?.accountId;
        final matches = accts.where((a) => a.id == id);
        _account = matches.isNotEmpty ? matches.first : (accts.isNotEmpty ? accts.first : null);
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

  Future<void> _submit() async {
    final loc = AppLocales.of(context);
    final title = _titleController.text.trim();
    final amount = double.tryParse(_amountController.text.trim().replaceAll(',', '.'));

    var hasError = false;
    if (title.isEmpty) {
      setState(() => _titleError = loc.translate('addRec_nome_erro'));
      hasError = true;
    }
    if (amount == null || amount <= 0) {
      setState(() => _amountError = loc.translate('addRec_valor_erro'));
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

    try {
      if (existing != null) {
        await _financeService.updateRecurring(recurring);
      } else {
        await _financeService.addRecurring(recurring);
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${loc.translate('addRec_erro_salvar')}$e')),
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
                loc.translate('addRec_excluir_titulo'),
                style: Theme.of(sheetContext)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                loc.translate('addRec_excluir_msg'),
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
                      child: Text(loc.translate('addRec_cancelar')),
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
                      child: Text(loc.translate('addRec_excluir_confirmar')),
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
      await _financeService.deleteRecurring(widget.existingRecurring!.id);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        final loc = AppLocales.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${loc.translate('addRec_erro_excluir')}$e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.loahColors;
    final isEditing = widget.isEditing;
    final loc = AppLocales.of(context);
    final categories = TransactionCategories.forType(_type);

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? loc.translate('addRec_editar') : loc.translate('addRec_novo'))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SectionLabel(loc.translate('addRec_tipo_label')),
            const SizedBox(height: 8),
            ChipSelector<TransactionType>(
              options: [
                ChipOption(loc.translate('addRec_tipo_despesa'), TransactionType.expense),
                ChipOption(loc.translate('addRec_tipo_receita'), TransactionType.income),
              ],
              selected: _type,
              onChanged: _onTypeChanged,
            ),
            const SizedBox(height: 20),

            _SectionLabel(loc.translate('addRec_nome_label')),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              onChanged: (_) {
                if (_titleError != null) setState(() => _titleError = null);
              },
              decoration: InputDecoration(
                hintText: loc.translate('addRec_nome_hint'),
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

            _SectionLabel(loc.translate('addRec_valor_label')),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) {
                if (_amountError != null) setState(() => _amountError = null);
              },
              decoration: InputDecoration(
                prefixText: '${CurrencyFormatter.symbol(context: context)} ',
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

            _SectionLabel(loc.translate('addRec_categoria_label')),
            const SizedBox(height: 8),
ChipSelector<String>(
              options: [for (final c in categories) ChipOption(loc.translateCategory(c), c)],
              selected: _category,
              onChanged: (v) => setState(() => _category = v),
            ),
            const SizedBox(height: 20),

            _SectionLabel(loc.translate('addRec_conta_label')),
            const SizedBox(height: 8),
            if (_accounts.isEmpty)
              Text(
              loc.translate('addRec_conta_vazia'),
                style: Theme.of(context).textTheme.bodySmall,
              )
            else
              ChipSelector<AccountModel>(
                options: [for (final a in _accounts) ChipOption(a.name, a)],
                selected: _account!,
                onChanged: (v) => setState(() => _account = v),
              ),
            const SizedBox(height: 20),

            _SectionLabel(loc.translate('addRec_dia_label')),
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
                      max: 31,
                      divisions: 30,
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
              title: Text(loc.translate('addRec_ativa_label')),
              subtitle: Text(
                _active
                    ? loc.translate('addRec_ativa_sub_on')
                    : loc.translate('addRec_ativa_sub_off'),
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
                  label: Text(
                    loc.translate('addRec_excluir'),
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
                  isEditing ? loc.translate('addRec_salvar') : loc.translate('addRec_criar'),
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

