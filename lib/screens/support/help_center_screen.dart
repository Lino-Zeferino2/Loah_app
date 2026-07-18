import 'package:flutter/material.dart';

import 'widgets/help_center_contact_section.dart';


class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCategory {
  final IconData icon;
  final String label;

  const _HelpCategory({required this.icon, required this.label});
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  static const _categories = [
    _HelpCategory(icon: Icons.flag_outlined, label: 'Metas'),
    _HelpCategory(icon: Icons.check_circle_outline, label: 'Tarefas'),
    _HelpCategory(
      icon: Icons.account_balance_wallet_outlined,
      label: 'Finanças',
    ),
    _HelpCategory(icon: Icons.people_outline_rounded, label: 'Contactos'),
    _HelpCategory(icon: Icons.person_outline_rounded, label: 'Minha Conta'),
  ];

  static const _popularArticles = [
    'Como criar uma meta compartilhada?',
    'Como sincronizar contactos?',
    'Gerenciar plano Pro',
    'Esqueci minha senha, o que fazer?',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: scheme.primary,
          ),
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
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth < 420 ? 18.0 : 28.0;

            return SingleChildScrollView(
              padding:
                  EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8),
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
                  const _SectionLabel(text: 'CATEGORIAS'),
                  const SizedBox(height: 12),
                  const _CategoryGrid(categories: _categories),
                  const SizedBox(height: 24),
                  const _SectionLabel(text: 'ARTIGOS POPULARES'),
                  const SizedBox(height: 12),
                  const _PopularArticlesList(titles: _popularArticles),
                  const SizedBox(height: 24),
                  const _SectionLabel(text: 'AINDA PRECISA DE AJUDA?'),
                  const SizedBox(height: 12),
                  const HelpCenterContactSection(),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
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
  final List<_HelpCategory> categories;

  const _CategoryGrid({required this.categories});

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
          itemBuilder: (context, i) => _CategoryCard(category: gridItems[i]),
        ),
        if (lastItem != null) ...[
          const SizedBox(height: 12),
          _CategoryCard(category: lastItem, fullWidth: true),
        ],
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final _HelpCategory category;
  final bool fullWidth;

  const _CategoryCard({required this.category, this.fullWidth = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final border = scheme.onSurface.withValues(alpha: 0.10);

    return InkWell(
      onTap: () {},
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
              child: Icon(category.icon, size: 20, color: scheme.primary),
            ),
            const SizedBox(height: 10),
            Text(
              category.label,
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
  final List<String> titles;

  const _PopularArticlesList({required this.titles});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(titles.length, (i) {
        return Padding(
          padding: EdgeInsets.only(bottom: i == titles.length - 1 ? 0 : 10),
          child: _PopularArticleTile(title: titles[i]),
        );
      }),
    );
  }
}

class _PopularArticleTile extends StatelessWidget {
  final String title;

  const _PopularArticleTile({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final border = scheme.onSurface.withValues(alpha: 0.10);

    return InkWell(
      onTap: () {},
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
              child:
                  Icon(Icons.article_outlined, size: 16, color: scheme.primary),
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



