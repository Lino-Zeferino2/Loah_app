import 'package:flutter/material.dart';
import '../../core/mock/account_visuals.dart';
import '../../core/mock/mock_data.dart';
import '../../core/theme/app_theme.dart';
import '../../models/account_model.dart';
import '../../widgets/chip_selector.dart';

/// "Loah - Nova/Editar Conta": form to create or edit an [AccountModel].
/// Pass [existingAccount] to edit in place; leave it null to create a
/// new one. Deleting an account does NOT delete its transactions (they
/// simply become unlinked) — see the confirmation copy in [_delete].
class AddAccountScreen extends StatefulWidget {
  final AccountModel? existingAccount;

  const AddAccountScreen({super.key, this.existingAccount});

  bool get isEditing => existingAccount != null;

  @override
  State<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends State<AddAccountScreen> {
  late final _nameController =
      TextEditingController(text: widget.existingAccount?.name ?? '');
  late final _initialBalanceController = TextEditingController(
    text: widget.existingAccount != null
        ? widget.existingAccount!.initialBalance.toStringAsFixed(2)
        : '0,00',
  );

  late AccountType _type = widget.existingAccount?.type ?? AccountType.corrente;

  String? _nameError;

  @override
  void dispose() {
    _nameController.dispose();
    _initialBalanceController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = 'Dê um nome para a conta.');
      return;
    }
    final initialBalance =
        double.tryParse(_initialBalanceController.text.trim().replaceAll(',', '.')) ?? 0;

    final existing = widget.existingAccount;
    final account = AccountModel(
      id: existing?.id ?? 'acc_${DateTime.now().microsecondsSinceEpoch}',
      name: name,
      type: _type,
      initialBalance: initialBalance,
    );

    if (existing != null) {
      final index = MockData.accounts.indexWhere((a) => a.id == existing.id);
      if (index != -1) MockData.accounts[index] = account;
    } else {
      MockData.accounts.add(account);
    }

    Navigator.of(context).pop(account);
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
                'Excluir Conta',
                style: Theme.of(sheetContext)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'As transações já lançadas nessa conta não serão apagadas, '
                'mas ficarão sem conta vinculada. Tem certeza?',
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

    MockData.accounts.removeWhere((a) => a.id == widget.existingAccount!.id);
    Navigator.of(context).pop(widget.existingAccount);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.loahColors;
    final isEditing = widget.isEditing;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Editar Conta' : 'Nova Conta')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const _SectionLabel('NOME'),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              onChanged: (_) {
                if (_nameError != null) setState(() => _nameError = null);
              },
              decoration: InputDecoration(
                hintText: 'Ex: Cartão Nubank',
                errorText: _nameError,
                filled: true,
                fillColor: colors.cardBackgroundAlt,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            const _SectionLabel('TIPO'),
            const SizedBox(height: 8),
            ChipSelector<AccountType>(
              options: [for (final t in AccountType.values) ChipOption(t.label, t)],
              selected: _type,
              onChanged: (v) => setState(() => _type = v),
            ),
            const SizedBox(height: 20),

            const _SectionLabel('SALDO INICIAL'),
            const SizedBox(height: 8),
            TextField(
              controller: _initialBalanceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
              decoration: InputDecoration(
                prefixText: 'R\$ ',
                hintText: '0,00',
                helperText: 'O saldo antes de qualquer transação lançada no app.',
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
                    'Excluir Conta',
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
                  isEditing ? 'Salvar Alterações' : 'Adicionar Conta',
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