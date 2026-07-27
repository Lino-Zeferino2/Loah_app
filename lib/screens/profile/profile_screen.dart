import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loah_app/core/services/user_service.dart';
import 'package:loah_app/core/theme/app_theme.dart';
import 'package:loah_app/screens/contacts/widgets/country_code_picker_sheet.dart';
import 'package:loah_app/widgets/loah_app_bar_simple.dart';

/// "Loah - Perfil": tela para visualizar e editar nome, email, telefone
/// e foto de perfil do utilizador.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  final UserService _userService = UserService();
  final ImagePicker _picker = ImagePicker();

  String _dialCode = '+351';
  String? _photoUrl;
  String? _uid;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    _uid = user.uid;
    _photoUrl = user.photoURL;

    try {
      final doc = await _userService.getUserProfile(user.uid);
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        _nameController.text = (data['name'] as String? ?? user.displayName ?? '');
        _phoneController.text = (data['phoneNumber'] as String? ?? '');
        _emailController.text = (data['email'] as String? ?? user.email ?? '');
        _dialCode = (data['dialCode'] as String? ?? '+351');
        _photoUrl = data['photoUrl'] as String? ?? user.photoURL;
      } else {
        _nameController.text = user.displayName ?? '';
        _emailController.text = user.email ?? '';
      }
    } catch (e) {
      debugPrint('[Profile] Erro ao carregar perfil: $e');
    }

    if (mounted) setState(() => _loading = false);
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: context.loahColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Alterar Foto',
                style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Câmera'),
                onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Galeria'),
                onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null || !mounted) return;

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (pickedFile == null || !mounted) return;

      setState(() => _saving = true);

      // Upload to Firebase Storage
      final file = File(pickedFile.path);
      final storageRef = FirebaseStorage.instance
          .ref('profilePhotos/$_uid/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await storageRef.putFile(file);
      final downloadUrl = await storageRef.getDownloadURL();

      // Update Firestore
      if (_uid != null) {
        await _userService.updateUserProfile(
          uid: _uid!,
          data: {'photoUrl': downloadUrl},
        );
      }

      // Update Firebase Auth profile
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updatePhotoURL(downloadUrl);
        await user.reload();
      }

      if (mounted) {
        setState(() {
          _photoUrl = downloadUrl;
          _saving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto atualizada com sucesso!')),
        );
      }
    } catch (e) {
      debugPrint('[Profile] Erro ao fazer upload da foto: $e');
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar foto: $e')),
        );
      }
    }
  }

  Future<void> _onPickDialCode() async {
    final res = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (_) => const CountryCodePickerSheet(),
    );
    if (res == null || !mounted) return;
    final parts = res.split('|');
    if (parts.length == 2) {
      setState(() => _dialCode = parts[1]);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (_uid == null) return;

    setState(() => _saving = true);

    try {
      final name = _nameController.text.trim();
      final phone = _phoneController.text.trim();

      // Update Firebase Auth display name
      await _userService.updateDisplayName(name);

      // Update Firestore profile
      await _userService.updateUserProfile(
        uid: _uid!,
        data: {
          'name': name,
          'phoneNumber': phone,
          'dialCode': _dialCode,
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil atualizado com sucesso!')),
        );
        Navigator.of(context).pop(true); // return true = profile updated
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  InputDecoration _fieldDecoration({
    required String hint,
    required IconData icon,
    required ColorScheme scheme,
    required Color border,
    required Color fillColor,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: fillColor,
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: scheme.primary),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textSecondary = scheme.onSurface.withValues(alpha: 0.65);
    final border = scheme.onSurface.withValues(alpha: 0.14);
    final cardBackground = scheme.surface;

    return Scaffold(
      appBar: const LoahAppBarSimple(title: 'Meu Perfil'),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // ── Avatar / Photo ──
                      GestureDetector(
                        onTap: _saving ? null : _pickImage,
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 56,
                              backgroundColor: context.loahColors.cardBackgroundAlt,
                              backgroundImage: _photoUrl != null && _photoUrl!.isNotEmpty
                                  ? NetworkImage(_photoUrl!)
                                  : null,
                              child: _photoUrl == null || _photoUrl!.isEmpty
                                  ? Icon(Icons.person, size: 48, color: context.textSecondary)
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: scheme.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: scheme.surface, width: 2),
                                ),
                                child: _saving
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Toque na foto para alterar',
                        style: theme.textTheme.bodySmall?.copyWith(color: textSecondary),
                      ),
                      const SizedBox(height: 28),

                      // ── Name ──
                      Text(
                        'NOME COMPLETO',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: textSecondary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        enabled: !_saving,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        decoration: _fieldDecoration(
                          hint: 'Seu nome completo',
                          icon: Icons.person_outline_rounded,
                          scheme: scheme,
                          border: border,
                          fillColor: cardBackground,
                        ),
                        validator: (v) {
                          if (v?.trim().isEmpty ?? true) return 'Informe seu nome';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // ── Email (read-only) ──
                      Text(
                        'E-MAIL',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: textSecondary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailController,
                        enabled: false,
                        keyboardType: TextInputType.emailAddress,
                        decoration: _fieldDecoration(
                          hint: 'email@exemplo.com',
                          icon: Icons.mail_outline_rounded,
                          scheme: scheme,
                          border: border,
                          fillColor: cardBackground,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Phone ──
                      Text(
                        'TELEMÓVEL',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: textSecondary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          SizedBox(
                            width: 128,
                            child: InkWell(
                              onTap: _onPickDialCode,
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                decoration: BoxDecoration(
                                  color: cardBackground,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: border),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.flag_outlined, size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _dialCode,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.arrow_drop_down_rounded),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: _phoneController,
                              enabled: !_saving,
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.done,
                              decoration: _fieldDecoration(
                                hint: '9xx xxx xxx',
                                icon: Icons.phone_android_outlined,
                                scheme: scheme,
                                border: border,
                                fillColor: cardBackground,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // ── Save Button ──
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saving ? null : _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: scheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _saving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Salvar Alterações',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.check_rounded, size: 20),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
