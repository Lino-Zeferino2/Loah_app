import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/services/goal_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/goal_model.dart';
import '../../widgets/goal_image.dart';
import '../../widgets/chip_selector.dart';

/// "Loah - Criar/Editar Meta": form for both creating a new [GoalModel]
/// and editing an existing one.
///
/// Pass [existingGoal] to edit it in place (fields pre-filled, saving
/// updates the same goal via [GoalService]); leave it null to create a
/// brand new goal instead.
class AddGoalScreen extends StatefulWidget {
  final GoalModel? existingGoal;

  const AddGoalScreen({super.key, this.existingGoal});

  bool get isEditing => existingGoal != null;

  @override
  State<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> {
  final GoalService _goalService = GoalService();

  static const _categoryKeys = [
    'Financeiro',
    'Saúde',
    'Carreira',
    'Viagem',
    'Investimento',
    'Pessoal',
  ];

  List<ChipOption<String>> _categories(BuildContext context) {
    final loc = AppLocales.of(context);
    return _categoryKeys.map((key) {
      // Use a translated category label; fallback to key itself
      final translated = loc.translate('category_${key.toLowerCase()}');
      return ChipOption(translated == 'category_${key.toLowerCase()}' ? key : translated, key);
    }).toList();
  }

  static const _categoryColors = {
    'Financeiro': Colors.lightBlueAccent,
    'Saúde': Colors.green,
    'Carreira': Colors.deepPurpleAccent,
    'Viagem': Colors.orange,
    'Investimento': Colors.teal,
    'Pessoal': Colors.pinkAccent,
  };

  List<ChipOption<GoalTerm>> _terms(BuildContext context) {
    final loc = AppLocales.of(context);
    return [
      ChipOption(loc.translate('goalTerm_curto_short'), GoalTerm.curtoPrazo),
      ChipOption(loc.translate('goalTerm_medio_short'), GoalTerm.medioPrazo),
      ChipOption(loc.translate('goalTerm_longo_short'), GoalTerm.longoPrazo),
    ];
  }

  late final TextEditingController _titleController =
      TextEditingController(text: widget.existingGoal?.title ?? '');
  late final TextEditingController _descriptionController =
      TextEditingController(text: widget.existingGoal?.description ?? '');
  late final TextEditingController _targetValueController = TextEditingController(
    text: widget.existingGoal?.target != null
        ? widget.existingGoal!.target!.toStringAsFixed(2)
        : '',
  );

  late String _category = widget.existingGoal?.category ?? 'Financeiro';
  late GoalTerm _term = widget.existingGoal?.term ?? GoalTerm.curtoPrazo;
  DateTime? _targetDate;
  String? _imagePath;
  String? _titleError;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _targetDate = widget.existingGoal?.targetDate;
    _imagePath = widget.existingGoal?.imageAsset;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetValueController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );
    if (picked != null) setState(() => _targetDate = picked);
  }

Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: context.loahColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        final sheetLoc = AppLocales.of(sheetContext);
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text(sheetLoc.translate('addGoal_galeria')),
                onTap: () => Navigator.of(sheetContext).pop(ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: Text(sheetLoc.translate('addGoal_camera')),
                onTap: () => Navigator.of(sheetContext).pop(ImageSource.camera),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
    if (source == null) return;

    final picked = await ImagePicker().pickImage(source: source, imageQuality: 80);
    if (picked != null) setState(() => _imagePath = picked.path);
  }

  double? _parseTargetValue() {
    final raw = _targetValueController.text.trim().replaceAll(',', '.');
    if (raw.isEmpty) return null;
    return double.tryParse(raw);
  }
  Future<void> _submit() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _titleError = AppLocales.of(context).translate('addGoal_nome_erro'));
      return;
    }

    setState(() => _isSaving = true);

    final targetValue = _parseTargetValue();
    final hasManualValue = targetValue != null && targetValue > 0;
    final existing = widget.existingGoal;
    final goalId = existing?.id ?? 'goal_${DateTime.now().microsecondsSinceEpoch}';

    final double? current = hasManualValue
        ? (existing?.progressMode == GoalProgressMode.manualValue
            ? (existing!.current ?? 0.0)
            : 0.0)
        : null;

    try {
      // NOVO: se _imagePath é um caminho local (não começa com http),
      // faz upload ao Storage antes de gravar — sem isto, gravava-se
      // o caminho temporário do image_picker diretamente, que deixa
      // de existir entre sessões da app.
      String? finalImageUrl = _imagePath;
      if (_imagePath != null &&
          !_imagePath!.startsWith('http://') &&
          !_imagePath!.startsWith('https://')) {
        finalImageUrl = await _goalService.uploadGoalImage(
          File(_imagePath!),
          goalId: goalId,
        );

        // Se a meta já tinha uma foto antiga diferente, apaga-a do
        // Storage para não acumular ficheiros órfãos.
        if (existing?.imageAsset != null &&
            existing!.imageAsset != finalImageUrl) {
          await _goalService.deleteGoalImage(existing.imageAsset);
        }
      } else if (_imagePath == null && existing?.imageAsset != null) {
        // Utilizador removeu a foto (botão "x") — apaga do Storage.
        await _goalService.deleteGoalImage(existing!.imageAsset);
      }

      final goal = GoalModel(
        id: goalId,
        title: title,
        category: _category,
        term: _term,
        progressMode: hasManualValue ? GoalProgressMode.manualValue : GoalProgressMode.taskChecklist,
        current: current,
        target: hasManualValue ? targetValue : null,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        targetDate: _targetDate,
        imageAsset: finalImageUrl,
        progressColor: _categoryColors[_category] ?? Colors.blue,
      );

      if (existing != null) {
        await _goalService.updateGoal(goal);
      } else {
        await _goalService.addGoal(goal);
      }
      if (mounted) Navigator.of(context).pop(goal);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocales.of(context).translate('addGoal_erro_salvar')}$e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.loahColors;
    final isEditing = widget.isEditing;
    final loc = AppLocales.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? loc.translate('addGoal_editar') : loc.translate('addGoal_novo')),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: colors.accentBlue.withValues(alpha: 0.15),
                    child: Icon(Icons.track_changes_outlined, size: 30, color: colors.accentBlue),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isEditing
                        ? loc.translate('addGoal_subtitle_editar')
                        : loc.translate('addGoal_subtitle_novo'),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colors.accentBlue,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),

            _SectionLabel(loc.translate('addGoal_nome_label')),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              onChanged: (_) {
                if (_titleError != null) setState(() => _titleError = null);
              },
              decoration: InputDecoration(
                hintText: loc.translate('addGoal_nome_hint'),
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

            _SectionLabel(loc.translate('addGoal_foto_label')),
            const SizedBox(height: 8),
            _ImagePickerField(
              imagePath: _imagePath,
              onTap: _pickImage,
              onRemove: () => setState(() => _imagePath = null),
            ),
            const SizedBox(height: 20),

_SectionLabel(loc.translate('addGoal_categoria_label')),
            const SizedBox(height: 8),
            ChipSelector<String>(
              options: _categories(context),
              selected: _category,
              onChanged: (v) => setState(() => _category = v),
            ),
            const SizedBox(height: 20),

            _SectionLabel(loc.translate('addGoal_prazo_label')),
            const SizedBox(height: 8),
            ChipSelector<GoalTerm>(
              options: _terms(context),
              selected: _term,
              onChanged: (v) => setState(() => _term = v),
            ),
            const SizedBox(height: 20),

            _SectionLabel(loc.translate('addGoal_descricao_label')),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: loc.translate('addGoal_descricao_hint'),
                filled: true,
                fillColor: colors.cardBackgroundAlt,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            _SectionLabel(loc.translate('addGoal_data_label')),
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
                      _targetDate == null
                          ? loc.translate('addGoal_data_hint')
                          : '${_targetDate!.day.toString().padLeft(2, '0')}/'
                              '${_targetDate!.month.toString().padLeft(2, '0')}/'
                              '${_targetDate!.year}',
                      style: TextStyle(
                        color: _targetDate == null ? context.textSecondary : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            _SectionLabel(loc.translate('addGoal_valor_label')),
            const SizedBox(height: 8),
            TextField(
              controller: _targetValueController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: loc.translate('addGoal_valor_hint'),
                prefixText: '${CurrencyFormatter.symbol(context: context)} ',
                filled: true,
                fillColor: colors.cardBackgroundAlt,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colors.accentBlue.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_awesome, size: 16, color: colors.accentBlue),
                      const SizedBox(width: 8),
                      Text(
                        loc.translate('addGoal_dica_titulo'),
                        style: TextStyle(
                          color: colors.accentBlue,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    loc.translate('addGoal_dica_body'),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _submit,
                icon: _isSaving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.check_circle_outline, size: 18),
                label: Text(
                  isEditing ? loc.translate('addGoal_salvar') : loc.translate('addGoal_criar'),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.accentBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
            letterSpacing: 0.4,
            fontSize: 12,
            color: context.textSecondary,
          ),
    );
  }
}

class _ImagePickerField extends StatelessWidget {
  final String? imagePath;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _ImagePickerField({
    required this.imagePath,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.loahColors;

    if (imagePath == null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 120,
          width: double.infinity,
          decoration: BoxDecoration(
            color: colors.cardBackgroundAlt,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.border, style: BorderStyle.solid),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_photo_alternate_outlined, size: 26, color: context.textSecondary),
              const SizedBox(height: 6),
Text(
                AppLocales.of(context).translate('addGoal_foto_tap'),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 140,
            width: double.infinity,
            child: GoalImage(path: imagePath!),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: onRemove,
            child: CircleAvatar(
              radius: 14,
              backgroundColor: Colors.black.withValues(alpha: 0.6),
              child: const Icon(Icons.close, size: 16, color: Colors.white),
            ),
          ),
        ),
        Positioned(
          bottom: 8,
          right: 8,
          child: GestureDetector(
            onTap: onTap,
            child: CircleAvatar(
              radius: 14,
              backgroundColor: Colors.black.withValues(alpha: 0.6),
              child: const Icon(Icons.edit, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
