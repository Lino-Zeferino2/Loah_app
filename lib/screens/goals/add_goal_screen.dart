import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/mock/mock_data.dart';
import '../../core/theme/app_theme.dart';
import '../../models/goal_model.dart';
import '../../widgets/goal_image.dart';
import 'widgets/chip_selector.dart';
import 'widgets/goal_term_section.dart'; // GoalTermVisuals (icon/color/shortLabel)

/// "Loah - Criar Meta": form to create a new [GoalModel].
///
/// Leaving "Valor Alvo" empty creates a checklist-mode goal (progress
/// comes from linked sub-tasks, added later via the Goal Detail
/// screen); filling it in creates a manualValue goal (progress comes
/// from current/target). This mirrors the same duality already used
/// throughout the rest of the app — no separate "goal type" toggle
/// needed, the presence of a target value decides it.
class AddGoalScreen extends StatefulWidget {
  const AddGoalScreen({super.key});

  @override
  State<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> {
  static const _categories = [
    ChipOption('Financeiro', 'Financeiro'),
    ChipOption('Saúde', 'Saúde'),
    ChipOption('Carreira', 'Carreira'),
    ChipOption('Viagem', 'Viagem'),
    ChipOption('Investimento', 'Investimento'),
    ChipOption('Pessoal', 'Pessoal'),
  ];

  static const _categoryColors = {
    'Financeiro': Colors.lightBlueAccent,
    'Saúde': Colors.green,
    'Carreira': Colors.deepPurpleAccent,
    'Viagem': Colors.orange,
    'Investimento': Colors.teal,
    'Pessoal': Colors.pinkAccent,
  };

  static final _terms = [
    ChipOption(GoalTerm.curtoPrazo.shortLabel, GoalTerm.curtoPrazo),
    ChipOption(GoalTerm.medioPrazo.shortLabel, GoalTerm.medioPrazo),
    ChipOption(GoalTerm.longoPrazo.shortLabel, GoalTerm.longoPrazo),
  ];

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetValueController = TextEditingController();

  String _category = 'Financeiro';
  GoalTerm _term = GoalTerm.curtoPrazo;
  DateTime? _targetDate;
  File? _imageFile;
  String? _titleError;

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
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Escolher da Galeria'),
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Tirar Foto'),
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.camera),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (source == null) return;

    final picked = await ImagePicker().pickImage(source: source, imageQuality: 80);
    if (picked != null) setState(() => _imageFile = File(picked.path));
  }

  double? _parseTargetValue() {
    final raw = _targetValueController.text.trim().replaceAll(',', '.');
    if (raw.isEmpty) return null;
    return double.tryParse(raw);
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _titleError = 'Dê um nome para a meta.');
      return;
    }

    final targetValue = _parseTargetValue();
    final hasManualValue = targetValue != null && targetValue > 0;

    final goal = GoalModel(
      id: 'goal_${DateTime.now().microsecondsSinceEpoch}',
      title: title,
      category: _category,
      term: _term,
      progressMode: hasManualValue ? GoalProgressMode.manualValue : GoalProgressMode.taskChecklist,
      current: hasManualValue ? 0 : null,
      target: hasManualValue ? targetValue : null,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      targetDate: _targetDate,
      imageAsset: _imageFile?.path,
      progressColor: _categoryColors[_category] ?? Colors.blue,
    );

    MockData.goals.add(goal);
    Navigator.of(context).pop(goal);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.loahColors;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Meta'),
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
                    'Defina seus objetivos e acompanhe sua evolução passo a passo.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colors.accentBlue,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),

            _SectionLabel('Nome da Meta'),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              onChanged: (_) {
                if (_titleError != null) setState(() => _titleError = null);
              },
              decoration: InputDecoration(
                hintText: 'Ex: Comprar um Carro',
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

            _SectionLabel('Foto da Meta (Opcional)'),
            const SizedBox(height: 8),
            _ImagePickerField(imageFile: _imageFile, onTap: _pickImage, onRemove: () {
              setState(() => _imageFile = null);
            }),
            const SizedBox(height: 20),

            _SectionLabel('Categoria'),
            const SizedBox(height: 8),
            ChipSelector<String>(
              options: _categories,
              selected: _category,
              onChanged: (v) => setState(() => _category = v),
            ),
            const SizedBox(height: 20),

            _SectionLabel('Prazo'),
            const SizedBox(height: 8),
            ChipSelector<GoalTerm>(
              options: _terms,
              selected: _term,
              onChanged: (v) => setState(() => _term = v),
            ),
            const SizedBox(height: 20),

            _SectionLabel('Descrição'),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Detalhes sobre sua meta...',
                filled: true,
                fillColor: colors.cardBackgroundAlt,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            _SectionLabel('Data Alvo'),
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
                          ? 'dd/mm/aaaa'
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

            _SectionLabel('Valor Alvo (Opcional)'),
            const SizedBox(height: 8),
            TextField(
              controller: _targetValueController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: '0,00',
                prefixText: 'R\$ ',
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
                        'Dica de Especialista',
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
                    'Metas claras e com prazos definidos têm 3x mais chances de '
                    'serem concluídas. Você está no caminho certo!',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.check_circle_outline, size: 18),
                label: const Text('Criar Meta', style: TextStyle(fontWeight: FontWeight.w700)),
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

/// Tappable cover-photo field: an empty dashed placeholder when no
/// image is picked yet, or a preview thumbnail with a remove button
/// once one has been chosen.
class _ImagePickerField extends StatelessWidget {
  final File? imageFile;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _ImagePickerField({
    required this.imageFile,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.loahColors;

    if (imageFile == null) {
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
                'Toque para adicionar uma foto',
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
            child: GoalImage(path: imageFile!.path),
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