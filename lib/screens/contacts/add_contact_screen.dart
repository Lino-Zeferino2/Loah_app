import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/services/contact_service.dart';
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
static const _relationshipValues = [
    'Familiar',
    'Amigo',
    'Namorada',
    'Pai',
    'Mãe',
    'Conhecido',
    'Colega',
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
  bool _isSaving = false; // NOVO
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
              title: Text(AppLocales.of(sheetContext).translate('addContact_escolher_galeria')),
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(AppLocales.of(sheetContext).translate('addContact_tirar_foto')),
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


Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = AppLocales.of(context).translate('addContact_nome_erro'));
      return;
    }

    setState(() => _isSaving = true); // NOVO

    final existing = widget.existingContact;
    final contactId = existing?.id ?? 'contact_${DateTime.now().microsecondsSinceEpoch}';

    try {
      final contactService = ContactService();

      String? avatarUrl = _avatarPath;
      final pickedFile = _avatarPath;
      if (pickedFile != null &&
          !pickedFile.startsWith('http://') &&
          !pickedFile.startsWith('https://')) {
        avatarUrl = await contactService.uploadAvatar(
          File(pickedFile),
          contactId: contactId,
        );

        if (existing?.avatarUrl != null &&
            existing!.avatarUrl!.startsWith('http')) {
          await contactService.deleteAvatar(existing.avatarUrl);
        }
      }

      final contact = ContactModel(
        id: contactId,
        name: name,
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : '$_countryDialCode ${_phoneController.text.trim()}',
        relationshipTag: _relationship,
        avatarUrl: avatarUrl,
        isFavorite: existing?.isFavorite ?? false,
        desiredContactFrequencyDays: existing?.desiredContactFrequencyDays,
        interactions: existing?.interactions ?? const [],
      );

      if (existing != null) {
        await contactService.updateContact(contact);
      } else {
        await contactService.addContact(contact);
      }

      if (!mounted) return;
      Navigator.of(context).pop(contact);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppLocales.of(context).translate('addContact_erro_salvar')}$e')),
      );
    } finally {
      // NOVO: garante que o loading desliga tanto no sucesso quanto no
      // erro. Não faz setState se a tela já foi fechada (Navigator.pop
      // no caminho de sucesso já desmontou o widget).
      if (mounted) setState(() => _isSaving = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    final loc = AppLocales.of(context);
    final colors = context.loahColors;
    final isEditing = widget.isEditing;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? loc.translate('addContact_titulo_editar') : loc.translate('addContact_titulo_novo')),
               actions: [
          TextButton(
            onPressed: _isSaving ? null : _submit,
            child: _isSaving
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(colors.accentBlue),
                    ),
                  )
                : Text(
                    loc.translate('addContact_salvar'),
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
                    loc.translate('addContact_toque_foto'),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),

            _SectionLabel(loc.translate('addContact_nome_label')),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              onChanged: (_) {
                if (_nameError != null) setState(() => _nameError = null);
              },
              decoration: InputDecoration(
              hintText: loc.translate('addContact_nome_hint'),
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

            _SectionLabel(loc.translate('addContact_email_label')),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: loc.translate('addContact_email_hint'),
                filled: true,
                fillColor: colors.cardBackgroundAlt,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            _SectionLabel(loc.translate('addContact_telefone_label')),
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
                      hintText: loc.translate('addContact_telefone_hint'),
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

_SectionLabel(loc.translate('addContact_grau_label')),
            const SizedBox(height: 8),
            
              ChipSelector<String>(
              options: _relationshipValues
                  .map((v) => ChipOption(loc.translateRelationshipTag(v), v))
                  .toList(),selected: _relationship,
              onChanged: (v) => setState(() => _relationship = v),
            ),
            const SizedBox(height: 28),

                      SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _submit,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.save_outlined, size: 18),
                label: Text(
                  isEditing ? loc.translate('addContact_salvar_alteracoes') : loc.translate('addContact_salvar_contato'),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.accentBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),],
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