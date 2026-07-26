import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loah_app/core/services/help_center_service.dart';
import 'package:loah_app/core/theme/app_theme.dart';
import 'package:loah_app/models/help_center_models.dart';

/// Admin screen to manage the "About Loah" content with 3 tabs:
///   1. Termos de Uso
///   2. Política de Privacidade
///   3. Sobre Nós
///
/// Each tab has a multiline TextField for editing and a "Guardar" button.
class ManageAboutLoahScreen extends StatefulWidget {
  const ManageAboutLoahScreen({super.key});

  @override
  State<ManageAboutLoahScreen> createState() => _ManageAboutLoahScreenState();
}

class _ManageAboutLoahScreenState extends State<ManageAboutLoahScreen>
    with SingleTickerProviderStateMixin {
  final HelpCenterService _service = HelpCenterService();
  late TabController _tabController;

  // Controllers for each field
  final _termsController = TextEditingController();
  final _privacyController = TextEditingController();
  final _aboutUsController = TextEditingController();

  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadContent();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _termsController.dispose();
    _privacyController.dispose();
    _aboutUsController.dispose();
    super.dispose();
  }

  Future<void> _loadContent() async {
    setState(() => _loading = true);
    try {
      final content = await _service.getAboutLoahContent();
      _termsController.text = content.terms;
      _privacyController.text = content.privacyPolicy;
      _aboutUsController.text = content.aboutUs;
    } catch (_) {
      // Keep defaults on error
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _saveContent() async {
    setState(() => _saving = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      final content = AboutLoahContent(
        terms: _termsController.text.trim(),
        privacyPolicy: _privacyController.text.trim(),
        aboutUs: _aboutUsController.text.trim(),
        lastUpdatedBy: user?.uid ?? '',
      );
      await _service.updateAboutLoahContent(content);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Conteúdo guardado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao guardar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.loahColors;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerir Sobre Loah'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: colors.accentBlue,
          labelColor: colors.accentBlue,
          unselectedLabelColor: context.textSecondary,
          tabs: const [
            Tab(icon: Icon(Icons.description_outlined), text: 'Termos'),
            Tab(icon: Icon(Icons.shield_outlined), text: 'Privacidade'),
            Tab(icon: Icon(Icons.info_outline), text: 'Sobre Nós'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _ContentTab(
                  controller: _termsController,
                  hint: 'Escreva os Termos de Uso...',
                  saving: _saving,
                  onSave: _saveContent,
                ),
                _ContentTab(
                  controller: _privacyController,
                  hint: 'Escreva a Política de Privacidade...',
                  saving: _saving,
                  onSave: _saveContent,
                ),
                _ContentTab(
                  controller: _aboutUsController,
                  hint: 'Escreva o texto "Sobre Nós"...',
                  saving: _saving,
                  onSave: _saveContent,
                ),
              ],
            ),
    );
  }
}

/// A single tab with a multiline text field and a save button.
class _ContentTab extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool saving;
  final VoidCallback onSave;

  const _ContentTab({
    required this.controller,
    required this.hint,
    required this.saving,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.loahColors;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: colors.cardBackgroundAlt,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.border),
            ),
            child: TextField(
              controller: controller,
              maxLines: null,
              minLines: 16,
              style: const TextStyle(height: 1.5),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: context.textSecondary.withValues(alpha: 0.5)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: saving ? null : onSave,
              icon: saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(
                saving ? 'A Guardar...' : 'Guardar Alterações',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.accentBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

