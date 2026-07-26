import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loah_app/core/services/help_center_service.dart';
import 'package:loah_app/core/theme/app_theme.dart';
import 'package:loah_app/models/help_center_models.dart';

/// Admin screen to manage Help Center content with 3 tabs:
///   1. Categorias – CRUD for FAQ categories
///   2. FAQs     – CRUD for articles (questions & answers)
///   3. Mensagens – View & reply to user support messages
class ManageHelpCenterScreen extends StatefulWidget {
  const ManageHelpCenterScreen({super.key});

  @override
  State<ManageHelpCenterScreen> createState() => _ManageHelpCenterScreenState();
}

class _ManageHelpCenterScreenState extends State<ManageHelpCenterScreen>
    with SingleTickerProviderStateMixin {
  final HelpCenterService _service = HelpCenterService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.loahColors;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerir Central de Ajuda'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: colors.accentBlue,
          labelColor: colors.accentBlue,
          unselectedLabelColor: context.textSecondary,
          tabs: const [
            Tab(icon: Icon(Icons.category_outlined), text: 'Categorias'),
            Tab(icon: Icon(Icons.article_outlined), text: 'FAQs'),
            Tab(icon: Icon(Icons.message_outlined), text: 'Mensagens'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _CategoriesTab(service: _service),
          _FaqsTab(service: _service),
          _MessagesTab(service: _service),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
//  TAB 1 – CATEGORIES
// ════════════════════════════════════════════════════════════════════

class _CategoriesTab extends StatelessWidget {
  final HelpCenterService service;

  const _CategoriesTab({required this.service});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_category',
        onPressed: () => _openCategorySheet(context, null),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: service.getCategoriesStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Erro ao carregar categorias',
                  style: TextStyle(color: context.textSecondary)),
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
                  Icon(Icons.category_outlined,
                      size: 64,
                      color: context.textSecondary.withValues(alpha: 0.4)),
                  const SizedBox(height: 16),
                  Text('Nenhuma categoria criada.',
                      style: TextStyle(color: context.textSecondary)),
                  const SizedBox(height: 8),
                  Text('Toque no + para adicionar.',
                      style: TextStyle(
                          color: context.textSecondary, fontSize: 12)),
                ],
              ),
            );
          }

          return ReorderableListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
            itemCount: docs.length,
            onReorderItem: (oldIndex, newIndex) async {
              // Reorder logic – update order field
              final items = docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return FaqCategory.fromMap(doc.id, data);
              }).toList();
              final item = items.removeAt(oldIndex);
              items.insert(newIndex, item);
              for (int i = 0; i < items.length; i++) {
                await service.updateCategory(items[i].copyWith(order: i));
              }
            },
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final category = FaqCategory.fromMap(doc.id, data);

              return _CategoryTile(
                key: ValueKey(category.id),
                category: category,
                onEdit: () => _openCategorySheet(context, category),
                onToggle: () async {
                  await service.updateCategory(
                    category.copyWith(active: !category.active),
                  );
                },
                onDelete: () => _confirmDeleteCategory(context, category),
              );
            },
          );
        },
      ),
    );
  }

  void _openCategorySheet(BuildContext context, FaqCategory? existing) {
    final nameController =
        TextEditingController(text: existing?.name ?? '');
    String selectedIcon = existing?.iconName ?? 'help_outline';
    final isEditing = existing != null;

    showDialog(
      context: context,
      useSafeArea: false,
      builder: (ctx) {
        return Dialog.fullscreen(
          backgroundColor: context.loahColors.cardBackground,
          child: Scaffold(
            backgroundColor: context.loahColors.cardBackground,
            appBar: AppBar(
              title: Text(
                isEditing ? 'Editar Categoria' : 'Nova Categoria',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              leading: IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            body: StatefulBuilder(
              builder: (ctx, setSheetState) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          hintText: 'Nome da categoria',
                          filled: true,
                          fillColor: context.loahColors.cardBackgroundAlt,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('Ícone',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          'help_outline',
                          'flag_outlined',
                          'check_circle_outline',
                          'account_balance_wallet_outlined',
                          'people_outline_rounded',
                          'person_outline_rounded',
                          'settings_outlined',
                          'security_outlined',
                          'payment_outlined',
                          'support_agent_outlined',
                        ].map((iconName) {
                          final selected = selectedIcon == iconName;
                          return GestureDetector(
                            onTap: () => setSheetState(() => selectedIcon = iconName),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: selected
                                    ? context.loahColors.accentBlue
                                        .withValues(alpha: 0.2)
                                    : context.loahColors.cardBackgroundAlt,
                                borderRadius: BorderRadius.circular(12),
                                border: selected
                                    ? Border.all(
                                        color: context.loahColors.accentBlue,
                                        width: 2)
                                    : null,
                              ),
                              child: Icon(
                                _getIconData(iconName),
                                color: selected
                                    ? context.loahColors.accentBlue
                                    : context.textSecondary,
                                size: 22,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            final name = nameController.text.trim();
                            if (name.isEmpty) return;
                            if (isEditing) {
                              await service.updateCategory(existing.copyWith(
                                name: name,
                                iconName: selectedIcon,
                              ));
                            } else {
                              final maxOrder = await _getMaxOrder();
                              await service.addCategory(FaqCategory(
                                id: '',
                                name: name,
                                iconName: selectedIcon,
                                order: maxOrder + 1,
                              ));
                            }
                            if (ctx.mounted) Navigator.of(ctx).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.loahColors.accentBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            isEditing ? 'Guardar Alterações' : 'Criar Categoria',
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 15),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<int> _getMaxOrder() async {
    final snap = await service.getCategoriesStream().first;
    if (snap.docs.isEmpty) return 0;
    int max = 0;
    for (final doc in snap.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final order = data['order'] as int? ?? 0;
      if (order > max) max = order;
    }
    return max;
  }

  void _confirmDeleteCategory(BuildContext context, FaqCategory category) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Apagar Categoria'),
        content: Text(
            'Tem a certeza que deseja apagar "${category.name}"?\n\nOs artigos associados também serão removidos.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              await service.deleteCategory(category.id);
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Apagar'),
          ),
        ],
      ),
    );
  }

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
}

class _CategoryTile extends StatelessWidget {
  final FaqCategory category;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _CategoryTile({
    super.key,
    required this.category,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.loahColors;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: category.active
          ? colors.cardBackgroundAlt
          : colors.cardBackgroundAlt.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: category.active
            ? BorderSide.none
            : BorderSide(color: colors.border, width: 0.5),
      ),
      child: ListTile(
        leading: Icon(
          _getIconData(category.iconName),
          color: category.active ? colors.accentBlue : context.textSecondary,
        ),
        title: Text(
          category.name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: category.active ? null : context.textSecondary,
          ),
        ),
        subtitle: Text('Ordem: ${category.order}',
            style: TextStyle(
                color: context.textSecondary, fontSize: 11)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                category.active
                    ? Icons.toggle_on_outlined
                    : Icons.toggle_off_outlined,
                color: category.active
                    ? colors.accentBlue
                    : context.textSecondary,
                size: 22,
              ),
              onPressed: onToggle,
              visualDensity: VisualDensity.compact,
            ),
            IconButton(
              icon: Icon(Icons.edit_outlined,
                  size: 18, color: colors.accentBlue),
              onPressed: onEdit,
              visualDensity: VisualDensity.compact,
            ),
            IconButton(
              icon: Icon(Icons.delete_outline,
                  size: 18,
                  color: Colors.redAccent.withValues(alpha: 0.7)),
              onPressed: onDelete,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }

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
}

// ════════════════════════════════════════════════════════════════════
//  TAB 2 – FAQs (ARTICLES)
// ════════════════════════════════════════════════════════════════════

class _FaqsTab extends StatefulWidget {
  final HelpCenterService service;

  const _FaqsTab({required this.service});

  @override
  State<_FaqsTab> createState() => _FaqsTabState();
}

class _FaqsTabState extends State<_FaqsTab> {
  String? _selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_faq',
        onPressed: () => _openArticleSheet(context, null),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Category filter
          StreamBuilder<QuerySnapshot>(
            stream: widget.service.getCategoriesStream(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox.shrink();
              final categories = snapshot.data!.docs
                  .map((doc) => FaqCategory.fromMap(
                      doc.id, doc.data() as Map<String, dynamic>))
                  .toList();

              return SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _FilterChip(
                      label: 'Todas',
                      selected: _selectedCategoryId == null,
                      onTap: () => setState(() => _selectedCategoryId = null),
                    ),
                    const SizedBox(width: 8),
                    ...categories.map((cat) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _FilterChip(
                            label: cat.name,
                            selected: _selectedCategoryId == cat.id,
                            onTap: () => setState(
                                () => _selectedCategoryId = cat.id),
                          ),
                        )),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 4),
          // Articles list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _selectedCategoryId != null
                  ? widget.service
                      .getArticlesByCategoryStream(_selectedCategoryId!)
                  : widget.service.getArticlesStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Erro ao carregar artigos',
                        style: TextStyle(color: context.textSecondary)),
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
                        Icon(Icons.article_outlined,
                            size: 64,
                            color:
                                context.textSecondary.withValues(alpha: 0.4)),
                        const SizedBox(height: 16),
                        Text('Nenhum artigo encontrado.',
                            style: TextStyle(color: context.textSecondary)),
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
                    final article = FaqArticle.fromMap(doc.id, data);

                    return _ArticleTile(
                      article: article,
                      onEdit: () =>
                          _openArticleSheet(context, article),
                      onTogglePopular: () async {
                        await widget.service.updateArticle(
                          article.copyWith(popular: !article.popular),
                        );
                      },
                      onDelete: () =>
                          _confirmDeleteArticle(context, article),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _openArticleSheet(BuildContext context, FaqArticle? existing) {
    final questionController =
        TextEditingController(text: existing?.question ?? '');
    final answerController =
        TextEditingController(text: existing?.answer ?? '');
    String selectedCategoryId = existing?.categoryId ?? '';
    bool popular = existing?.popular ?? false;
    final isEditing = existing != null;

    showDialog(
      context: context,
      useSafeArea: false,
      builder: (ctx) {
        return Dialog.fullscreen(
          backgroundColor: context.loahColors.cardBackground,
          child: Scaffold(
            backgroundColor: context.loahColors.cardBackground,
            appBar: AppBar(
              title: Text(
                isEditing ? 'Editar Artigo' : 'Novo Artigo',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              leading: IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            body: StatefulBuilder(
              builder: (ctx, setSheetState) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category selector
                      StreamBuilder<QuerySnapshot>(
                        stream: widget.service.getCategoriesStream(),
                        builder: (ctx, snap) {
                          if (!snap.hasData) return const SizedBox.shrink();
                          final categories = snap.data!.docs.map((doc) {
                            final d = doc.data() as Map<String, dynamic>;
                            return FaqCategory.fromMap(doc.id, d);
                          }).toList();

                          return DropdownButtonFormField<String>(
                            initialValue: selectedCategoryId.isEmpty
                                ? null
                                : selectedCategoryId,
                            decoration: InputDecoration(
                              hintText: 'Selecionar categoria',
                              filled: true,
                              fillColor: context.loahColors.cardBackgroundAlt,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            items: categories
                                .where((c) => c.active)
                                .map((cat) => DropdownMenuItem(
                                      value: cat.id,
                                      child: Text(cat.name),
                                    ))
                                .toList(),
                            onChanged: (val) =>
                                setSheetState(() => selectedCategoryId = val ?? ''),
                          );
                        },
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: questionController,
                        decoration: InputDecoration(
                          hintText: 'Pergunta',
                          filled: true,
                          fillColor: context.loahColors.cardBackgroundAlt,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: answerController,
                        maxLines: 6,
                        decoration: InputDecoration(
                          hintText: 'Resposta',
                          filled: true,
                          fillColor: context.loahColors.cardBackgroundAlt,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.all(14),
                        ),
                      ),
                      const SizedBox(height: 12),

                      SwitchListTile(
                        title: const Text('Marcar como Popular'),
                        value: popular,
                        onChanged: (val) =>
                            setSheetState(() => popular = val),
                        contentPadding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            final question = questionController.text.trim();
                            final answer = answerController.text.trim();
                            if (question.isEmpty ||
                                answer.isEmpty ||
                                selectedCategoryId.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Preencha todos os campos obrigatórios.'),
                                ),
                              );
                              return;
                            }
                            if (isEditing) {
                              await widget.service.updateArticle(existing.copyWith(
                                question: question,
                                answer: answer,
                                categoryId: selectedCategoryId,
                                popular: popular,
                              ));
                            } else {
                              await widget.service.addArticle(FaqArticle(
                                id: '',
                                categoryId: selectedCategoryId,
                                question: question,
                                answer: answer,
                                popular: popular,
                              ));
                            }
                            if (ctx.mounted) Navigator.of(ctx).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.loahColors.accentBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            isEditing ? 'Guardar Alterações' : 'Criar Artigo',
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 15),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

void _confirmDeleteArticle(BuildContext context, FaqArticle article) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Apagar Artigo'),
        content: Text(
            'Tem a certeza que deseja apagar o artigo "${article.question}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              await widget.service.deleteArticle(article.id);
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Apagar'),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.loahColors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? colors.accentBlue.withValues(alpha: 0.15)
              : colors.cardBackgroundAlt,
          borderRadius: BorderRadius.circular(20),
          border: selected
              ? Border.all(color: colors.accentBlue, width: 1.5)
              : Border.all(color: colors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: selected ? colors.accentBlue : context.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _ArticleTile extends StatelessWidget {
  final FaqArticle article;
  final VoidCallback onEdit;
  final VoidCallback onTogglePopular;
  final VoidCallback onDelete;

  const _ArticleTile({
    required this.article,
    required this.onEdit,
    required this.onTogglePopular,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.loahColors;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: article.popular
          ? colors.accentBlue.withValues(alpha: 0.06)
          : colors.cardBackgroundAlt,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: article.popular
            ? BorderSide(color: colors.accentBlue.withValues(alpha: 0.3))
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    article.question,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (article.popular)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Popular',
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              article.answer,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: context.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '👁 ${article.views} visualizações',
                  style: TextStyle(
                    color: context.textSecondary,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(width: 8),
                if (article.createdAt != null)
                  Text(
                    _formatDate(article.createdAt!),
                    style: TextStyle(
                      color: context.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    article.popular
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: article.popular ? Colors.amber : context.textSecondary,
                    size: 20,
                  ),
                  onPressed: onTogglePopular,
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  icon: Icon(Icons.edit_outlined,
                      size: 18, color: colors.accentBlue),
                  onPressed: onEdit,
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline,
                      size: 18,
                      color: Colors.redAccent.withValues(alpha: 0.7)),
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

// ════════════════════════════════════════════════════════════════════
//  TAB 3 – USER MESSAGES
// ════════════════════════════════════════════════════════════════════

class _MessagesTab extends StatelessWidget {
  final HelpCenterService service;

  const _MessagesTab({required this.service});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: service.getMessagesStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Erro ao carregar mensagens',
                style: TextStyle(color: context.textSecondary)),
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
                Icon(Icons.message_outlined,
                    size: 64,
                    color: context.textSecondary.withValues(alpha: 0.4)),
                const SizedBox(height: 16),
                Text('Nenhuma mensagem recebida.',
                    style: TextStyle(color: context.textSecondary)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            final message = HelpMessage.fromMap(doc.id, data);

            return _MessageTile(
              message: message,
              onTap: () => _openMessageDetail(context, message),
            );
          },
        );
      },
    );
  }

  void _openMessageDetail(BuildContext context, HelpMessage message) async {
    // Mark as read
    if (!message.read) {
      await service.markMessageAsRead(message.id);
    }

    if (!context.mounted) return;

    showDialog(
      context: context,
      useSafeArea: false,
      builder: (ctx) {
        final replyController = TextEditingController(
          text: message.adminReply ?? '',
        );

        return Dialog.fullscreen(
          backgroundColor: context.loahColors.cardBackground,
          child: Scaffold(
            backgroundColor: context.loahColors.cardBackground,
            appBar: AppBar(
              title: const Text('Detalhes da Mensagem',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              leading: IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            body: StatefulBuilder(
              builder: (ctx, setSheetState) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User info
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: context.loahColors.accentBlue
                                .withValues(alpha: 0.15),
                            child: Text(
                              message.userName.isNotEmpty
                                  ? message.userName[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                color: context.loahColors.accentBlue,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message.userName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  message.userEmail,
                                  style: TextStyle(
                                    color: context.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _StatusBadge(status: message.status),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        message.subject,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        message.message,
                        style: TextStyle(
                          color: context.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      if (message.adminReply != null &&
                          message.adminReply!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: context.loahColors.accentBlue
                                .withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: context.loahColors.accentBlue
                                  .withValues(alpha: 0.2),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.reply,
                                      size: 16,
                                      color: context.loahColors.accentBlue),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Resposta do Admin',
                                    style: TextStyle(
                                      color: context.loahColors.accentBlue,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(message.adminReply!,
                                  style: const TextStyle(height: 1.4)),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),

                      // Status update
                      Row(
                        children: [
                          const Text('Status:',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(width: 8),
                          DropdownButton<HelpMessageStatus>(
                            value: message.status,
                            underline: const SizedBox.shrink(),
                            items: HelpMessageStatus.values.map((s) {
                              return DropdownMenuItem(
                                value: s,
                                child: Text(_statusLabel(s)),
                              );
                            }).toList(),
                            onChanged: (val) async {
                              if (val != null) {
                                await service.updateMessage(
                                  message.copyWith(status: val),
                                );
                                if (ctx.mounted) Navigator.of(ctx).pop();
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: replyController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Escrever resposta...',
                          filled: true,
                          fillColor: context.loahColors.cardBackgroundAlt,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.all(14),
                        ),
                      ),
                      const SizedBox(height: 12),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            final reply = replyController.text.trim();
                            if (reply.isEmpty) return;
                            await service.replyToMessage(message.id, reply);
                            if (ctx.mounted) Navigator.of(ctx).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.loahColors.accentBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Responder',
                            style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 15),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  String _statusLabel(HelpMessageStatus status) {
    switch (status) {
      case HelpMessageStatus.pendente:
        return 'Pendente';
      case HelpMessageStatus.emAndamento:
        return 'Em Andamento';
      case HelpMessageStatus.resolvido:
        return 'Resolvido';
    }
  }
}

class _MessageTile extends StatelessWidget {
  final HelpMessage message;
  final VoidCallback onTap;

  const _MessageTile({required this.message, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.loahColors;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: !message.read
          ? colors.accentBlue.withValues(alpha: 0.06)
          : colors.cardBackgroundAlt,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: !message.read
            ? BorderSide(color: colors.accentBlue.withValues(alpha: 0.3))
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor:
                    colors.accentBlue.withValues(alpha: 0.15),
                child: Text(
                  message.userName.isNotEmpty
                      ? message.userName[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    color: colors.accentBlue,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            message.subject,
                            style: TextStyle(
                              fontWeight:
                                  message.read ? FontWeight.w600 : FontWeight.w700,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _StatusBadge(status: message.status),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      message.message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${message.userName} • ${message.userEmail}',
                      style: TextStyle(
                        color: context.textSecondary.withValues(alpha: 0.7),
                        fontSize: 11,
                      ),
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

class _StatusBadge extends StatelessWidget {
  final HelpMessageStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case HelpMessageStatus.pendente:
        color = Colors.orange;
        label = 'Pendente';
        break;
      case HelpMessageStatus.emAndamento:
        color = Colors.blue;
        label = 'Andamento';
        break;
      case HelpMessageStatus.resolvido:
        color = Colors.green;
        label = 'Resolvido';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

