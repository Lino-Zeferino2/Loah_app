import 'package:flutter/material.dart';
import '../../core/mock/asset_visuals.dart';
import '../../core/mock/mock_data.dart';
import '../../core/theme/app_theme.dart';
import '../../models/asset_model.dart';
import '../../widgets/chip_selector.dart';

/// "Loah - Novo/Editar Ativo": form to create or edit an [AssetModel].
/// Pass [existingAsset] to edit in place (fields pre-fill, saving
/// updates the same id, and a delete action appears); leave it null to
/// create a new one.
class AddAssetScreen extends StatefulWidget {
  final AssetModel? existingAsset;

  const AddAssetScreen({super.key, this.existingAsset});

  bool get isEditing => existingAsset != null;

  @override
  State<AddAssetScreen> createState() => _AddAssetScreenState();
}

class _AddAssetScreenState extends State<AddAssetScreen> {
  late final _nameController =
      TextEditingController(text: widget.existingAsset?.name ?? '');
  late final _valueController = TextEditingController(
    text: widget.existingAsset != null
        ? widget.existingAsset!.currentValue.toStringAsFixed(2)
        : '',
  );
  late final _notesController =
      TextEditingController(text: widget.existingAsset?.notes ?? '');

  late AssetType _type = widget.existingAsset?.type ?? AssetType.cash;

  String? _nameError;
  String? _valueError;

  @override
  void dispose() {
    _nameController.dispose();
    _valueController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double? _parseValue() {
    final raw = _valueController.text.trim().replaceAll(',', '.');
    if (raw.isEmpty) return null;
    return double.tryParse(raw);
  }

  void _submit() {
    final name = _nameController.text.trim();
    final value = _parseValue();

    var hasError = false;
    if (name.isEmpty) {
      setState(() => _nameError = 'Dê um nome para o ativo.');
      hasError = true;
    }
    if (value == null || value < 0) {
      setState(() => _valueError = 'Informe um valor válido.');
      hasError = true;
    }
    if (hasError) return;

    final existing = widget.existingAsset;
    final asset = AssetModel(
      id: existing?.id ?? 'asset_${DateTime.now().microsecondsSinceEpoch}',
      name: name,
      type: _type,
      currentValue: value!,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      updatedAt: DateTime.now(),
    );

    if (existing != null) {
      final index = MockData.assets.indexWhere((a) => a.id == existing.id);
      if (index != -1) MockData.assets[index] = asset;
    } else {
      MockData.assets.add(asset);
    }

    Navigator.of(context).pop(asset);
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
                'Excluir Ativo',
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

    MockData.assets.removeWhere((a) => a.id == widget.existingAsset!.id);
    Navigator.of(context).pop(widget.existingAsset);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.loahColors;
    final isEditing = widget.isEditing;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Editar Ativo' : 'Novo Ativo')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SectionLabel('NOME'),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              onChanged: (_) {
                if (_nameError != null) setState(() => _nameError = null);
              },
              decoration: InputDecoration(
                hintText: 'Ex: Carteira B3',
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

            _SectionLabel('TIPO'),
            const SizedBox(height: 8),
            ChipSelector<AssetType>(
              options: [for (final t in AssetType.values) ChipOption(t.label, t)],
              selected: _type,
              onChanged: (v) => setState(() => _type = v),
            ),
            const SizedBox(height: 20),

            _SectionLabel('VALOR ATUAL'),
            const SizedBox(height: 8),
            TextField(
              controller: _valueController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) {
                if (_valueError != null) setState(() => _valueError = null);
              },
              decoration: InputDecoration(
                prefixText: 'R\$ ',
                hintText: '0,00',
                errorText: _valueError,
                filled: true,
                fillColor: colors.cardBackgroundAlt,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            _SectionLabel('NOTAS (OPCIONAL)'),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Ex: PETR4, VALE3 — ou detalhes do imóvel...',
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
                    'Excluir Ativo',
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
                  isEditing ? 'Salvar Alterações' : 'Adicionar Ativo',
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