import 'package:flutter/material.dart';
import 'package:loah_app/core/services/help_center_service.dart';
import 'package:loah_app/core/theme/app_theme.dart';
import 'package:loah_app/models/help_center_models.dart';
import 'package:loah_app/core/l10n/app_localizations.dart';
class AboutLoahScreen extends StatefulWidget {
  const AboutLoahScreen({super.key});

  @override
  State<AboutLoahScreen> createState() => _AboutLoahScreenState();
}

class _AboutLoahScreenState extends State<AboutLoahScreen> {
  final HelpCenterService _service = HelpCenterService();
  AboutLoahContent? _content;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadContent();
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
      debugPrint('[AboutLoahScreen] Erro ao carregar conteúdo: $e');
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // NOVO: idioma atual do dispositivo/app, usado para escolher
    // entre o texto Pt/En guardado no Firestore.
    
final languageCode = AppLocales.of(context).languageCode;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sobre Loah'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  // CORRIGIDO: era _content?.aboutUs (campo único).
                  // Agora usa aboutUs(languageCode), que já trata do
                  // fallback para PT se o EN estiver vazio.
                  _content != null && _content!.aboutUs(languageCode).isNotEmpty
                      ? _content!.aboutUs(languageCode)
                      : 'Loah é um aplicativo feito para te ajudar a organizar sua vida financeira e alcançar objetivos com mais clareza.',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '• Planejamento e metas',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 8),
                        Text('• Finanças com visão clara'),
                        SizedBox(height: 8),
                        Text('• Tarefas para manter o progresso'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Versão atual: 1.0.0',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                if (_content?.updatedAt != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Última atualização: ${_formatDate(_content!.updatedAt!)}',
                    style: TextStyle(
                      color: context.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}