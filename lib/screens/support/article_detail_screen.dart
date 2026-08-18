import 'package:flutter/material.dart';
import 'package:loah_app/core/services/help_center_service.dart';
import 'package:loah_app/models/help_center_models.dart';
import '../../core/l10n/app_localizations.dart';

/// Full-screen detail view for a FAQ article.
class ArticleDetailScreen extends StatefulWidget {
  final FaqArticle article;

  const ArticleDetailScreen({super.key, required this.article});

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  final HelpCenterService _service = HelpCenterService();
  bool _viewsIncremented = false;

  @override
  void initState() {
    super.initState();
    _incrementViews();
  }

  Future<void> _incrementViews() async {
    if (_viewsIncremented) return;
    _viewsIncremented = true;
    try {
      await _service.incrementArticleViews(widget.article.id);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final article = widget.article;
    // NOVO: código do idioma atual, usado para escolher a versão certa
    // da pergunta/resposta.
    final langCode = AppLocales.of(context).languageCode;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: scheme.primary),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Artigo',
          style: theme.textTheme.titleMedium?.copyWith(
            color: scheme.primary,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Popular badge
              if (article.popular)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                      SizedBox(width: 4),
                      Text(
                        'Artigo Popular',
                        style: TextStyle(
                          color: Colors.amber,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),

              // Question
              Text(
                // CORRIGIDO: era article.question (campo que não existe
                // mais no modelo — agora é um método que recebe o idioma).
                article.question(langCode),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: scheme.primary,
                  letterSpacing: -0.3,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 8),

              // Views
              Row(
                children: [
                  Icon(Icons.visibility_outlined,
                      size: 14,
                      color: scheme.onSurface.withValues(alpha: 0.4)),
                  const SizedBox(width: 4),
                  Text(
                    '${article.views + (_viewsIncremented ? 1 : 0)} visualizações',
                    style: TextStyle(
                      color: scheme.onSurface.withValues(alpha: 0.4),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Answer
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: scheme.onSurface.withValues(alpha: 0.08),
                  ),
                ),
                child: SelectableText(
                  // CORRIGIDO: era article.answer.
                  article.answer(langCode),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.7,
                    color: scheme.onSurface,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Feedback section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: scheme.onSurface.withValues(alpha: 0.08),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Este artigo foi útil?',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _FeedbackButton(
                          icon: Icons.thumb_up_outlined,
                          label: 'Sim',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Obrigado pelo seu feedback!'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 16),
                        _FeedbackButton(
                          icon: Icons.thumb_down_outlined,
                          label: 'Não',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Lamentamos. Contacte o suporte para mais ajuda.'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeedbackButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _FeedbackButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: scheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: scheme.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: scheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}