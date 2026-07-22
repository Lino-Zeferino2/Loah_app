import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/mock/mock_data.dart';
import '../../core/theme/app_theme.dart';
import '../../models/contact_model.dart';
import '../../widgets/chip_selector.dart';
import '../../widgets/goal_image.dart'; // generic network-or-file image renderer
import 'widgets/country_code_picker_sheet.dart';

/// "Loah - Novo/Editar Contato": form to create a new [ContactModel] or
/// edit an existing one (pass [existingContact]).
///
/// Only "Nome Completo" is required — photo and e-mail are explicitly
/// optional, matching how [ContactModel.email]/[avatarUrl] are already
/// nullable.
class AddContactScreen extends StatefulWidget {
  final ContactModel? existingContact;

  const AddContactScreen({super.key, this.existingContact});

  bool get isEditing => existingContact != null;

  @override
  State<AddContactScreen> createState() => _AddContactScreenState();
}

class _AddContactScreenState extends State<AddContactScreen> {
  static const _relationships = [
    ChipOption('Familiar', 'Familiar'),
    ChipOption('Amigo', 'Amigo'),
    ChipOption('Namorada', 'Namorada'),
    ChipOption('Pai', 'Pai'),
    ChipOption('Mãe', 'Mãe'),
    ChipOption('Conhecido', 'Conhecido'),
    ChipOption('Colega', 'Colega'),
  ];

  late final _nameController =
      TextEditingController(text: widget.existingContact?.name ?? '');
  late final _emailController =
      TextEditingController(text: widget.existingContact?.email ?? '');
  late final _phoneController = TextEditingController(text: _initialPhoneDigits());

  late String _relationship = widget.existingContact?.relationshipTag ?? 'Amigo';
  String _countryFlag = '🇵🇹';
  String _countryDialCode = '+351';
  String? _avatarPath;
  String? _nameError;

  @override
  void initState() {
    super.initState();
    _avatarPath = widget.existingContact?.avatarUrl;
    // Split a stored "+55 11 99999-9999" into dial code + rest, so the
    // form re-populates both the flag box and the number field.
    final phone = widget.existingContact?.phone;
    if (phone != null && phone.startsWith('+')) {
      final spaceIndex = phone.indexOf(' ');
      if (spaceIndex != -1) _countryDialCode = phone.substring(0, spaceIndex);
    }
  }

  String _initialPhoneDigits() {
    final phone = widget.existingContact?.phone;
    if (phone == null) return '';
    final spaceIndex = phone.indexOf(' ');
    return spaceIndex == -1 ? phone : phone.substring(spaceIndex + 1);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
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
    if (picked != null) setState(() => _avatarPath = picked.path);
  }

  Future<void> _pickCountryCode() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.loahColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const CountryCodePickerSheet(),
    );
    if (result == null) return;

    // From the list: "🇧🇷|+55". From manual entry: just "+000" (no flag).
    if (result.contains('|')) {
      final parts = result.split('|');
      setState(() {
        _countryFlag = parts[0];
        _countryDialCode = parts[1];
      });
    } else {
      setState(() {
        _countryFlag = '🏳️';
        _countryDialCode = result;
      });
    }
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = 'Dê um nome para o contato.');
      return;
    }

    final existing = widget.existingContact;
    final contact = ContactModel(
      id: existing?.id ?? 'contact_${DateTime.now().microsecondsSinceEpoch}',
      name: name,
      email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      phone: _phoneController.text.trim().isEmpty
          ? null
          : '$_countryDialCode ${_phoneController.text.trim()}',
      relationshipTag: _relationship,
      avatarUrl: _avatarPath,
      isFavorite: existing?.isFavorite ?? false,
      desiredContactFrequencyDays: existing?.desiredContactFrequencyDays,
      interactions: existing?.interactions ?? const [],
    );

    if (existing != null) {
      final index = MockData.contacts.indexWhere((c) => c.id == existing.id);
      if (index != -1) MockData.contacts[index] = contact;
    } else {
      MockData.contacts.add(contact);
    }

    Navigator.of(context).pop(contact);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.loahColors;
    final isEditing = widget.isEditing;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Contato' : 'Novo Contato'),
        actions: [
          TextButton(
            onPressed: _submit,
            child: Text(
              'Salvar',
              style: TextStyle(color: colors.accentBlue, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickPhoto,
                    child: Stack(
                      children: [
                        ClipOval(
                          child: Container(
                            width: 110,
                            height: 110,
                            color: colors.cardBackgroundAlt,
                            child: _avatarPath == null
                                ? Icon(Icons.person, size: 50, color: context.textSecondary)
                                : GoalImage(path: _avatarPath!),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: colors.accentBlue,
                            child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Toque para adicionar foto',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),

            const _SectionLabel('NOME COMPLETO'),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              onChanged: (_) {
                if (_nameError != null) setState(() => _nameError = null);
              },
              decoration: InputDecoration(
                hintText: 'Nome completo',
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

            const _SectionLabel('E-MAIL (OPCIONAL)'),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'email@exemplo.com',
                filled: true,
                fillColor: colors.cardBackgroundAlt,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            const _SectionLabel('TELEFONE'),
            const SizedBox(height: 8),
            Row(
              children: [
                InkWell(
                  onTap: _pickCountryCode,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      color: colors.cardBackgroundAlt,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_countryFlag, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Text(_countryDialCode, style: const TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(width: 4),
                        Icon(Icons.keyboard_arrow_down, size: 16, color: context.textSecondary),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: '9xxxxxxxx',
                      filled: true,
                      fillColor: colors.cardBackgroundAlt,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            const _SectionLabel('GRAU DE CONEXÃO'),
            const SizedBox(height: 8),
            ChipSelector<String>(
              options: _relationships,
              selected: _relationship,
              onChanged: (v) => setState(() => _relationship = v),
            ),
            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.save_outlined, size: 18),
                label: Text(
                  isEditing ? 'Salvar Alterações' : 'Salvar Contato',
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
            letterSpacing: 0.6,
            color: context.textSecondary,
          ),
    );
  }
}