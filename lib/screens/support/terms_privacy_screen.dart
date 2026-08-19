import 'package:flutter/material.dart';
import 'package:loah_app/core/l10n/app_localizations.dart';
import 'package:loah_app/core/services/help_center_service.dart';
import 'package:loah_app/core/theme/app_theme.dart';
import 'package:loah_app/models/help_center_models.dart';

/// Screen where any user can view the Terms & Conditions and Privacy Policy
/// that were registered by the admin via "Gerir Sobre Loah".
class TermsPrivacyScreen extends StatefulWidget {
  const TermsPrivacyScreen({super.key});

  @override
  State<TermsPrivacyScreen> createState() => _TermsPrivacyScreenState();
}

class _TermsPrivacyScreenState extends State<TermsPrivacyScreen>
    with SingleTickerProviderStateMixin {
  final HelpCenterService _service = HelpCenterService();
  late TabController _tabController;
  AboutLoahContent? _content;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadContent();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadContent() async {
    try {
      final content = await _service.getAboutLoahContent();
      if (mounted) {
        setState(() {
          _content = content;
          _loading = false;
        });
      }
    } catch (e) {
      // CORRIGIDO: catch(_) engolia o erro silenciosamente. Se as
      // Firestore Rules bloquearem leitura sem autenticação (o
      // utilizador ainda não tem conta neste ecrã, no signup), o
      // erro passava despercebido e o placeholder "ainda não
      // definido" aparecia mesmo com dados no Firebase.
      debugPrint('[TermsPrivacyScreen] Erro ao carregar conteúdo: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.loahColors;
    // NOVO: idioma atual do dispositivo/app.
    final languageCode = AppLocales.of(context).languageCode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Termos e Políticas'),
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
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _ContentTab(
                  // CORRIGIDO: era _content?.terms (campo único).
                  content: _content?.terms(languageCode) ?? '',
                  placeholder: 'Os Termos e Condições ainda não foram definidos.',
                ),
                _ContentTab(
                  // CORRIGIDO: era _content?.privacyPolicy (campo único).
                  content: _content?.privacyPolicy(languageCode) ?? '',
                  placeholder: 'A Política de Privacidade ainda não foi definida.',
                ),
              ],
            ),
    );
  }
}

class _ContentTab extends StatelessWidget {
  final String content;
  final String placeholder;

  const _ContentTab({
    required this.content,
    required this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.loahColors;

    if (content.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.description_outlined,
                size: 64,
                color: context.textSecondary.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 16),
              Text(
                placeholder,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: context.textSecondary,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 52),
        decoration: BoxDecoration(
          color: colors.cardBackgroundAlt,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.border),
        ),
        child: Text(
          content,
          style: const TextStyle(
            height: 1.6,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}