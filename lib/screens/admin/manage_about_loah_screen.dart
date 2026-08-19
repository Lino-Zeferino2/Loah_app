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
/// CORRIGIDO: cada aba agora tem 2 campos (Português / Inglês) em vez
/// de 1, seguindo o mesmo padrão Pt/En já usado em Categorias e FAQs
/// da Central de Ajuda. O EN continua opcional — só o PT é
/// obrigatório para poder guardar.
class ManageAboutLoahScreen extends StatefulWidget {
  const ManageAboutLoahScreen({super.key});

  @override
  State<ManageAboutLoahScreen> createState() => _ManageAboutLoahScreenState();
}

class _ManageAboutLoahScreenState extends State<ManageAboutLoahScreen>
    with SingleTickerProviderStateMixin {
  final HelpCenterService _service = HelpCenterService();
  late TabController _tabController;

  // NOVO: 2 controllers por secção (Pt/En) em vez de 1.
  final _termsPtController = TextEditingController();
  final _termsEnController = TextEditingController();
  final _privacyPtController = TextEditingController();
  final _privacyEnController = TextEditingController();
  final _aboutUsPtController = TextEditingController();
  final _aboutUsEnController = TextEditingController();

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
    _termsPtController.dispose();
    _termsEnController.dispose();
    _privacyPtController.dispose();
    _privacyEnController.dispose();
    _aboutUsPtController.dispose();
    _aboutUsEnController.dispose();
    super.dispose();
  }

  Future<void> _loadContent() async {
    setState(() => _loading = true);
    try {
      final content = await _service.getAboutLoahContent();
      _termsPtController.text = content.termsPt;
      _termsEnController.text = content.termsEn;
      _privacyPtController.text = content.privacyPolicyPt;
      _privacyEnController.text = content.privacyPolicyEn;
      _aboutUsPtController.text = content.aboutUsPt;
      _aboutUsEnController.text = content.aboutUsEn;
    } catch (e) {
      debugPrint('[ManageAboutLoahScreen] Erro ao carregar conteúdo: $e');
      // Keep defaults on error
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _saveContent() async {
    setState(() => _saving = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      final content = AboutLoahContent(
        termsPt: _termsPtController.text.trim(),
        termsEn: _termsEnController.text.trim(),
        privacyPolicyPt: _privacyPtController.text.trim(),
        privacyPolicyEn: _privacyEnController.text.trim(),
        aboutUsPt: _aboutUsPtController.text.trim(),
        aboutUsEn: _aboutUsEnController.text.trim(),
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
                  ptController: _termsPtController,
                  enController: _termsEnController,
                  hintPt: 'Escreva os Termos de Uso em português...',
                  hintEn: 'Write the Terms of Use in English...',
                  saving: _saving,
                  onSave: _saveContent,
                ),
                _ContentTab(
                  ptController: _privacyPtController,
                  enController: _privacyEnController,
                  hintPt: 'Escreva a Política de Privacidade em português...',
                  hintEn: 'Write the Privacy Policy in English...',
                  saving: _saving,
                  onSave: _saveContent,
                ),
                _ContentTab(
                  ptController: _aboutUsPtController,
                  enController: _aboutUsEnController,
                  hintPt: 'Escreva o texto "Sobre Nós" em português...',
                  hintEn: 'Write the "About Us" text in English...',
                  saving: _saving,
                  onSave: _saveContent,
                ),
              ],
            ),
    );
  }
}

/// A single tab with two multiline text fields (PT/EN) and a save button.
class _ContentTab extends StatelessWidget {
  final TextEditingController ptController;
  final TextEditingController enController;
  final String hintPt;
  final String hintEn;
  final bool saving;
  final VoidCallback onSave;

  const _ContentTab({
    required this.ptController,
    required this.enController,
    required this.hintPt,
    required this.hintEn,
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
          // NOVO: rótulo + campo Português
          const Text('Português',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: colors.cardBackgroundAlt,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.border),
            ),
            child: TextField(
              controller: ptController,
              maxLines: null,
              minLines: 10,
              style: const TextStyle(height: 1.5),
              decoration: InputDecoration(
                hintText: hintPt,
                hintStyle:
                    TextStyle(color: context.textSecondary.withValues(alpha: 0.5)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // NOVO: rótulo + campo Inglês
          const Text('Inglês',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: colors.cardBackgroundAlt,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.border),
            ),
            child: TextField(
              controller: enController,
              maxLines: null,
              minLines: 10,
              style: const TextStyle(height: 1.5),
              decoration: InputDecoration(
                hintText: hintEn,
                hintStyle:
                    TextStyle(color: context.textSecondary.withValues(alpha: 0.5)),
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
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}