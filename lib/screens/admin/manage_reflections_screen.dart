import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loah_app/core/services/reflection_service.dart';
import 'package:loah_app/core/theme/app_theme.dart';
import 'package:loah_app/models/reflection_model.dart';

/// Admin screen to create, list, activate/deactivate, edit and delete
/// daily reflections ("Reflexões do Dia").
class ManageReflectionsScreen extends StatefulWidget {
  const ManageReflectionsScreen({super.key});

  @override
  State<ManageReflectionsScreen> createState() =>
      _ManageReflectionsScreenState();
}

class _ManageReflectionsScreenState extends State<ManageReflectionsScreen> {
  final ReflectionService _reflectionService = ReflectionService();

  /// Open bottom sheet to add a new reflection.
  Future<void> _openAddReflectionSheet() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.loahColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _AddReflectionSheet(
        existingReflection: null,
      ),
    );

    if (result == null || !mounted) return;
    await _handleAddEditResult(result, isEditing: false);
  }

  /// Open bottom sheet to edit an existing reflection.
  Future<void> _openEditReflectionSheet(ReflectionModel reflection) async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.loahColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _AddReflectionSheet(
        existingReflection: reflection,
      ),
    );

    if (result == null || !mounted) return;
    await _handleAddEditResult(result,
        isEditing: true,
        existingId: reflection.id,
        oldImageUrl: reflection.imageUrl);
  }

  /// Process the result from the bottom sheet (add or edit).
  Future<void> _handleAddEditResult(
    Map<String, dynamic> result, {
    required bool isEditing,
    String? existingId,
    String? oldImageUrl,
  }) async {
    final text = result['text'] as String? ?? '';
    final textEn = result['textEn'] as String?;
    final imageFile = result['imageFile'] as File?;
    final keepExistingImage = result['keepExistingImage'] as bool? ?? false;

    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('O texto da reflexão não pode estar vazio.'),
        ),
      );
      return;
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';

      // Determine image URL
      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await _reflectionService.uploadImage(
          imageFile,
          userId: userId,
        );
      } else if (isEditing && keepExistingImage && oldImageUrl != null) {
        imageUrl = oldImageUrl;
      } else {
        imageUrl = '';
      }

      if (isEditing && existingId != null) {
        final reflection = ReflectionModel(
          id: existingId,
          text: text,
          textEn: textEn,
          imageUrl: imageUrl ?? '',
          active: result['active'] as bool? ?? false,
        );
        await _reflectionService.updateReflection(reflection);

        if (!mounted) return;
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reflexão atualizada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final reflection = ReflectionModel(
          id: '',
          text: text,
          textEn: textEn,
          imageUrl: imageUrl ?? '',
          active: false,
        );
        await _reflectionService.addReflection(reflection);

        if (!mounted) return;
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reflexão criada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Confirm and delete a reflection.
  Future<void> _confirmDelete(ReflectionModel reflection) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Apagar Reflexão'),
        content: Text(
          'Tem a certeza que deseja apagar esta reflexão?\n\n"${reflection.text}"',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Apagar'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      await _reflectionService.deleteReflection(
        reflection.id,
        reflection.imageUrl,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reflexão apagada com sucesso.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao apagar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Toggle active state independently (allows multiple active reflections).
  Future<void> _toggleActive(ReflectionModel reflection) async {
    try {
      final updated = reflection.copyWith(active: !reflection.active);
      await _reflectionService.updateReflection(updated);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            updated.active ? 'Reflexão ativada.' : 'Reflexão desativada.',
          ),
          backgroundColor: updated.active ? Colors.green : null,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerir Reflexões do Dia'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_reflection',
        onPressed: _openAddReflectionSheet,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _reflectionService.getReflectionsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erro ao carregar reflexões',
                style: TextStyle(color: context.textSecondary),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.auto_stories_outlined,
                    size: 64,
                    color: context.textSecondary.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhuma reflexão criada ainda.\nToque no + para adicionar.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: context.textSecondary),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final reflection = ReflectionModel.fromMap(doc.id, data);

              return _ReflectionTile(
                reflection: reflection,
                onToggleActive: () => _toggleActive(reflection),
                onEdit: () => _openEditReflectionSheet(reflection),
                onDelete: () => _confirmDelete(reflection),
              );
            },
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Reflection Tile
// ─────────────────────────────────────────────────────────────────

class _ReflectionTile extends StatelessWidget {
  final ReflectionModel reflection;
  final VoidCallback onToggleActive;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ReflectionTile({
    required this.reflection,
    required this.onToggleActive,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.loahColors;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: reflection.active
          ? colors.accentBlue.withValues(alpha: 0.08)
          : colors.cardBackgroundAlt,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: reflection.active
            ? BorderSide(color: colors.accentBlue, width: 1.5)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 64,
                height: 64,
                child: reflection.imageUrl.isNotEmpty
                    ? Image.network(
                        reflection.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: colors.border,
                          child: const Icon(Icons.broken_image, size: 28),
                        ),
                      )
                    : Container(
                        color: colors.border,
                        child: const Icon(Icons.image_outlined, size: 28),
                      ),
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reflection.text,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: reflection.active
                              ? colors.accentBlue.withValues(alpha: 0.15)
                              : Colors.grey.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          reflection.active ? 'Ativa' : 'Inativa',
                          style: TextStyle(
                            color: reflection.active
                                ? colors.accentBlue
                                : Colors.grey,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      if (reflection.createdAt != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(reflection.createdAt!),
                          style: TextStyle(
                            color: context.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            Column(
              children: [
                IconButton(
                  icon: Icon(
                    reflection.active
                        ? Icons.toggle_off_outlined
                        : Icons.toggle_on_outlined,
                    color: reflection.active
                        ? colors.accentBlue
                        : Colors.grey,
                    size: 22,
                  ),
                  tooltip: reflection.active ? 'Desativar' : 'Ativar',
                  onPressed: onToggleActive,
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  color: colors.accentBlue,
                  tooltip: 'Editar',
                  onPressed: onEdit,
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18),
                  color: Colors.redAccent.withValues(alpha: 0.7),
                  tooltip: 'Apagar',
                  onPressed: onDelete,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}

// ─────────────────────────────────────────────────────────────────
//  Add / Edit Reflection Bottom Sheet
// ─────────────────────────────────────────────────────────────────

class _AddReflectionSheet extends StatefulWidget {
  final ReflectionModel? existingReflection;

  const _AddReflectionSheet({this.existingReflection});

  @override
  State<_AddReflectionSheet> createState() => _AddReflectionSheetState();
}

class _AddReflectionSheetState extends State<_AddReflectionSheet> {
  late final TextEditingController _textController;
  late final TextEditingController _textEnController;
  File? _imageFile;
  bool _keepExistingImage = false;
  final ImagePicker _picker = ImagePicker();

  bool get _isEditing => widget.existingReflection != null;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(
      text: widget.existingReflection?.text ?? '',
    );
    _textEnController = TextEditingController(
      text: widget.existingReflection?.textEn ?? '',
    );
    _keepExistingImage =
        widget.existingReflection?.imageUrl.isNotEmpty ?? false;
  }

  @override
  void dispose() {
    _textController.dispose();
    _textEnController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final xfile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
    );
    if (xfile != null) {
      setState(() {
        _imageFile = File(xfile.path);
        _keepExistingImage = false;
      });
    }
  }

  void _submit() {
    Navigator.of(context).pop(<String, dynamic>{
      'text': _textController.text.trim(),
      'textEn': _textEnController.text.trim(),
      'imageFile': _imageFile,
      'keepExistingImage': _keepExistingImage,
      'active': widget.existingReflection?.active ?? false,
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.loahColors;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final hasExistingImage = _isEditing &&
        _imageFile == null &&
        _keepExistingImage &&
        widget.existingReflection!.imageUrl.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              _isEditing ? 'Editar Reflexão' : 'Nova Reflexão',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _textController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Escreva o texto da reflexão (Português)...',
                labelText: 'Português',
                filled: true,
                fillColor: colors.cardBackgroundAlt,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _textEnController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Enter the reflection text (English)...',
                labelText: 'English (optional)',
                filled: true,
                fillColor: colors.cardBackgroundAlt,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
            const SizedBox(height: 16),

            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: colors.cardBackgroundAlt,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.border),
                ),
                clipBehavior: Clip.antiAlias,
                child: _imageFile != null
                    ? Stack(
                        children: [
                          Image.file(
                            _imageFile!,
                            width: double.infinity,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _imageFile = null),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : hasExistingImage
                        ? Stack(
                            children: [
                              Image.network(
                                widget.existingReflection!.imageUrl,
                                width: double.infinity,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () => setState(() {
                                    _keepExistingImage = false;
                                  }),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 40,
                                color: context.textSecondary,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _isEditing
                                    ? 'Tocar para alterar imagem'
                                    : 'Adicionar imagem (opcional)',
                                style: TextStyle(
                                  color: context.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.accentBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _isEditing ? 'Guardar Alterações' : 'Criar Reflexão',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            SizedBox(height: 52 + bottomInset),
          ],
        ),
      ),
    );
  }
}
