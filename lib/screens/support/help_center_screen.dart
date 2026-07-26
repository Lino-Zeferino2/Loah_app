import 'package:flutter/material.dart';
import 'package:loah_app/core/services/help_center_service.dart';
import 'package:loah_app/models/help_center_models.dart';
import 'article_detail_screen.dart';
import 'send_message_screen.dart';

/// Dynamic Help Center screen that loads categories and articles from Firebase.
/// Users can search, browse by category, view popular articles, and send messages.
class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final _searchController = TextEditingController();
  final HelpCenterService _service = HelpCenterService();
  List<FaqCategory> _categories = [];
  List<FaqArticle> _popularArticles = [];
  List<FaqArticle> _allArticles = [];
  List<FaqArticle> _searchResults = [];
  bool _isSearching = false;
  bool _isLoading = true;
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final categories = await _service.getActiveCategories();
      final popularArticles = await _service.getPopularArticles();
      final allArticles = await _service.getAllArticles();
      if (mounted) {
        setState(() {
          _categories = categories;
          _popularArticles = popularArticles;
          _allArticles = allArticles;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('HelpCenter - Error loading data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<FaqArticle> get _filteredArticles {
    if (_selectedCategoryId == null) return _allArticles;
    return _allArticles
        .where((a) => a.categoryId == _selectedCategoryId)
        .toList();
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
      return;
    }
    // Debounce search
    Future.delayed(const Duration(milliseconds: 300), () async {
      if (query != _searchController.text) return;
      try {
        final results = await _service.searchArticles(query);
        if (mounted) {
          setState(() {
            _isSearching = true;
            _searchResults = results;
          });
        }
      } catch (_) {}
    });
  }

  Widget _buildFilterChip(String label, bool selected, VoidCallback onTap) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? scheme.primary.withValues(alpha: 0.15)
              : scheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? scheme.primary
                : scheme.onSurface.withValues(alpha: 0.14),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: selected ? scheme.primary : scheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }

  void _openCategoryArticles(FaqCategory category) async {
    final articles = await _service.getArticlesByCategory(category.id);
    if (!mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _CategoryArticlesScreen(
          category: category,
          articles: articles,
          service: _service,
        ),
      ),
    );
  }

  void _openArticleDetail(FaqArticle article) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ArticleDetailScreen(article: article),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: scheme.primary),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Help Center',
          style: theme.textTheme.titleMedium?.copyWith(
            color: scheme.primary,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          if (_isSearching && _searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () {
                _searchController.clear();
              },
            ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : LayoutBuilder(
                builder: (context, constraints) {
                  final horizontalPadding =
                      constraints.maxWidth < 420 ? 18.0 : 28.0;

                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            'Como podemos ajudar?',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: scheme.primary,
                              letterSpacing: -0.4,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        _HelpSearchField(controller: _searchController),
                        const SizedBox(height: 24),

                        if (_isSearching && _searchController.text.isNotEmpty)
                          _buildSearchResults()
                        else ...[
                          // Categories
                          if (_categories.isNotEmpty) ...[
                            const _SectionLabel(text: 'CATEGORIAS'),
                            const SizedBox(height: 12),
                            _CategoryGrid(
                              categories: _categories,
                              onCategoryTap: _openCategoryArticles,
                            ),
                            const SizedBox(height: 24),
                          ],

                          // Popular Articles
                          if (_popularArticles.isNotEmpty) ...[
                            const _SectionLabel(text: 'ARTIGOS POPULARES'),
                            const SizedBox(height: 12),
                            _PopularArticlesList(
                              articles: _popularArticles,
                              onArticleTap: _openArticleDetail,
                            ),
                            const SizedBox(height: 24),
                          ],

                          // All Articles with category filter
                          if (_allArticles.isNotEmpty) ...[
                            const _SectionLabel(text: 'TODAS AS PERGUNTAS'),
                            const SizedBox(height: 12),
                            // Category filter chips
                            SizedBox(
                              height: 40,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: [
                                  _buildFilterChip(
                                    'Todas',
                                    _selectedCategoryId == null,
                                    () => setState(() => _selectedCategoryId = null),
                                  ),
                                  const SizedBox(width: 8),
                                  ..._categories.map((cat) => Padding(
                                        padding: const EdgeInsets.only(right: 8),
                                        child: _buildFilterChip(
                                          cat.name,
                                          _selectedCategoryId == cat.id,
                                          () => setState(
                                              () => _selectedCategoryId = cat.id),
                                        ),
                                      )),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            ..._filteredArticles.map((article) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: _PopularArticleTile(
                                    title: article.question,
                                    onTap: () => _openArticleDetail(article),
                                  ),
                                )),
                            const SizedBox(height: 24),
                          ],

                          // Contact / Send message
                          const _SectionLabel(text: 'AINDA PRECISA DE AJUDA?'),
                          const SizedBox(height: 12),
                          _HelpContactSection(
                            onSendMessage: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const SendMessageScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                        const SizedBox(height: 24),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.search_off_rounded,
                  size: 48,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.3)),
              const SizedBox(height: 12),
              Text(
                'Nenhum artigo encontrado para "${_searchController.text}"',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6)),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel(text: 'RESULTADOS DA PESQUISA'),
        const SizedBox(height: 12),
        ..._searchResults.map((article) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _PopularArticleTile(
                title: article.question,
                onTap: () => _openArticleDetail(article),
              ),
            )),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Text(
      text,
      style: theme.textTheme.labelSmall?.copyWith(
        color: scheme.onSurface.withValues(alpha: 0.55),
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _HelpSearchField extends StatelessWidget {
  final TextEditingController controller;

  const _HelpSearchField({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final border = scheme.onSurface.withValues(alpha: 0.14);

    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: 'Pesquisar artigos, guias...',
        prefixIcon: const Icon(Icons.search_rounded),
        filled: true,
        fillColor: scheme.surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.primary),
        ),
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  final List<FaqCategory> categories;
  final void Function(FaqCategory) onCategoryTap;

  const _CategoryGrid({
    required this.categories,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    final gridItems = categories.length.isOdd
        ? categories.sublist(0, categories.length - 1)
        : categories;
    final lastItem = categories.length.isOdd ? categories.last : null;

    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: gridItems.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
          ),
          itemBuilder: (context, i) =>
              _CategoryCard(category: gridItems[i], onTap: onCategoryTap),
        ),
        if (lastItem != null) ...[
          const SizedBox(height: 12),
          _CategoryCard(
              category: lastItem, fullWidth: true, onTap: onCategoryTap),
        ],
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final FaqCategory category;
  final bool fullWidth;
  final void Function(FaqCategory) onTap;

  const _CategoryCard({
    required this.category,
    this.fullWidth = false,
    required this.onTap,
  });

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'flag_outlined':
        return Icons.flag_outlined;
      case 'check_circle_outline':
        return Icons.check_circle_outline;
      case 'account_balance_wallet_outlined':
        return Icons.account_balance_wallet_outlined;
      case 'people_outline_rounded':
        return Icons.people_outline_rounded;
      case 'person_outline_rounded':
        return Icons.person_outline_rounded;
      case 'settings_outlined':
        return Icons.settings_outlined;
      case 'security_outlined':
        return Icons.security_outlined;
      case 'payment_outlined':
        return Icons.payment_outlined;
      case 'support_agent_outlined':
        return Icons.support_agent_outlined;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final border = scheme.onSurface.withValues(alpha: 0.10);

    return InkWell(
      onTap: () => onTap(category),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: fullWidth ? double.infinity : null,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        decoration: BoxDecoration(
          color: scheme.surface,
          border: Border.all(color: border),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: Icon(_getIconData(category.iconName),
                  size: 20, color: scheme.primary),
            ),
            const SizedBox(height: 10),
            Text(
              category.name,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PopularArticlesList extends StatelessWidget {
  final List<FaqArticle> articles;
  final void Function(FaqArticle) onArticleTap;

  const _PopularArticlesList({
    required this.articles,
    required this.onArticleTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(articles.length, (i) {
        return Padding(
          padding: EdgeInsets.only(bottom: i == articles.length - 1 ? 0 : 10),
          child: _PopularArticleTile(
            title: articles[i].question,
            onTap: () => onArticleTap(articles[i]),
          ),
        );
      }),
    );
  }
}

class _PopularArticleTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _PopularArticleTile({
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final border = scheme.onSurface.withValues(alpha: 0.10);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: scheme.surface,
          border: Border.all(color: border),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.article_outlined,
                  size: 16, color: scheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: scheme.onSurface.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }
}

/// Contact section with send message button.
class _HelpContactSection extends StatelessWidget {
  final VoidCallback onSendMessage;

  const _HelpContactSection({required this.onSendMessage});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final border = scheme.onSurface.withValues(alpha: 0.10);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fale connosco',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Nossa equipe de suporte está disponível de Seg. a Sex., das 09h às 18h.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.65),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onSendMessage,
              icon: const Icon(Icons.send_rounded, size: 18),
              label: const Text('Enviar Mensagem'),
              style: FilledButton.styleFrom(
                backgroundColor: scheme.primary,
                foregroundColor: scheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Respondemos em até 24h',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Internal screen to show articles for a specific category.
class _CategoryArticlesScreen extends StatelessWidget {
  final FaqCategory category;
  final List<FaqArticle> articles;
  final HelpCenterService service;

  const _CategoryArticlesScreen({
    required this.category,
    required this.articles,
    required this.service,
  });

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'flag_outlined':
        return Icons.flag_outlined;
      case 'check_circle_outline':
        return Icons.check_circle_outline;
      case 'account_balance_wallet_outlined':
        return Icons.account_balance_wallet_outlined;
      case 'people_outline_rounded':
        return Icons.people_outline_rounded;
      case 'person_outline_rounded':
        return Icons.person_outline_rounded;
      case 'settings_outlined':
        return Icons.settings_outlined;
      case 'security_outlined':
        return Icons.security_outlined;
      case 'payment_outlined':
        return Icons.payment_outlined;
      case 'support_agent_outlined':
        return Icons.support_agent_outlined;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: scheme.primary),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_getIconData(category.iconName),
                size: 20, color: scheme.primary),
            const SizedBox(width: 8),
            Text(
              category.name,
              style: theme.textTheme.titleMedium?.copyWith(
                color: scheme.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: articles.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.article_outlined,
                        size: 64,
                        color: scheme.onSurface.withValues(alpha: 0.3)),
                    const SizedBox(height: 16),
                    Text(
                      'Nenhum artigo nesta categoria ainda.',
                      style: TextStyle(color: scheme.onSurface.withValues(alpha: 0.6)),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                itemCount: articles.length,
                itemBuilder: (context, index) {
                  final article = articles[index];
                  final border = scheme.onSurface.withValues(alpha: 0.10);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                ArticleDetailScreen(article: article),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          color: scheme.surface,
                          border: Border.all(color: border),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: scheme.primary.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.article_outlined,
                                  size: 16, color: scheme.primary),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    article.question,
                                    style: theme.textTheme.bodyMedium
                                        ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    article.answer,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: scheme.onSurface
                                          .withValues(alpha: 0.5),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: scheme.onSurface.withValues(alpha: 0.4),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}



