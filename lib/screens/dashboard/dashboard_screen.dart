// ignore_for_file: avoid_types_as_parameter_names

import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loah_app/core/theme/app_colors.dart';
import '../../core/constants/app_breakpoints.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/navigation/navigation_controller.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/notification_repository.dart';
import '../../core/services/task_service.dart';
import '../../core/services/goal_service.dart';
import '../../core/services/finance_service.dart';
import '../../core/utils/account_balance.dart';
import '../../core/utils/finance_summary.dart';
import '../../core/theme/app_theme.dart';
import '../notifications/notifications_screen.dart';
import '../../widgets/loah_app_bar.dart';
import '../../widgets/loah_drawer.dart';
import 'widgets/new_item_modal_sheet.dart';
import '../../models/task_model.dart';
import '../../models/goal_model.dart';
import '../../models/transaction_model.dart';
import '../../models/account_model.dart';
import '../../models/asset_model.dart';
import '../../models/reflection_model.dart';
import '../../core/services/reflection_service.dart';
import 'widgets/balance_card.dart';
import 'widgets/daily_reflection_card.dart';
import 'widgets/goals_summary_card.dart';
import 'widgets/new_item_card.dart';
import 'widgets/pending_tasks_card.dart';

/// "Loah - Dashboard": the home screen with a greeting, balance summary,
/// pending tasks, a quick-add card, goal progress and a daily reflection.
///
/// NOVO: os dados (transações, contas, ativos, tarefas, metas) agora
/// vêm de streams em tempo real (.snapshots()), não de buscas únicas.
/// Com a persistência offline do Firestore ativa (ver nota no
/// main.dart), isto tem dois efeitos:
///   1. Se o dispositivo já tiver dados em cache, eles aparecem
///      instantaneamente, mesmo sem rede.
///   2. Quando a rede volta, o Firestore reconecta sozinho e emite um
///      novo snapshot — a tela atualiza automaticamente, sem precisar
///      de nenhum "recarregar" manual.
/// Enquanto o primeiro snapshot de cada fonte ainda não chegou (nem do
/// cache nem do servidor), mostramos um skeleton de carregamento em
/// vez de conteúdo com valores a zero.
///
/// Layout: em mobile (< [AppBreakpoints.desktop]) mantém a lista vertical
/// original. Em desktop, o conteúdo é limitado a uma largura máxima e
/// organizado em 2 colunas (finanças/tarefas à esquerda, metas/reflexão
/// à direita), e o FAB de "novo item" é omitido (o NewItemCard já cobre
/// a mesma ação, e um FAB flutuante sobre um grid largo fica deslocado).
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TaskService _taskService = TaskService();
  final GoalService _goalService = GoalService();
  final FinanceService _financeService = FinanceService();
  final NotificationRepository _notificationRepo = NotificationRepository();
  final ReflectionService _reflectionService = ReflectionService();

  // Limites de itens exibidos no card de "Tarefas Pendentes" no
  // dashboard — 3 no mobile, 6 no desktop.
  static const int _mobileTaskLimit = 3;
  static const int _desktopTaskLimit = 6;

  // ── Dados brutos vindos dos streams ─────────────────────────────
  List<TransactionModel> _transactions = [];
  List<AccountModel> _accounts = [];
  List<AssetModel> _assets = [];
  List<TaskModel> _standaloneTasks = [];
  List<GoalModel> _goals = [];

  // ── Valores derivados (recalculados a cada novo snapshot) ───────
  double _totalWealth = 0;
  double _progressToGoal = 0;

  // ── Flags: já chegou o primeiro snapshot de cada fonte? ──────────
  bool _txnLoaded = false;
  bool _acctLoaded = false;
  bool _assetLoaded = false;
  bool _tasksLoaded = false;
  bool _goalsLoaded = false;

  bool get _loading =>
      !_txnLoaded || !_acctLoaded || !_assetLoaded || !_tasksLoaded || !_goalsLoaded;

  int _unreadCount = 0;
  ReflectionModel? _activeReflection;

  StreamSubscription? _notificationSub;
  StreamSubscription<List<TransactionModel>>? _txnSub;
  StreamSubscription<List<AccountModel>>? _acctSub;
  StreamSubscription<List<AssetModel>>? _assetSub;
  StreamSubscription<QuerySnapshot>? _taskSub;
  StreamSubscription<QuerySnapshot>? _goalSub;

  @override
  void initState() {
    super.initState();
    _subscribeToData();
    _loadReflection();
    _notificationSub = _notificationRepo.getUnreadCountStream().listen((count) {
      if (mounted) setState(() => _unreadCount = count);
    });
  }

  @override
  void dispose() {
    _notificationSub?.cancel();
    _txnSub?.cancel();
    _acctSub?.cancel();
    _assetSub?.cancel();
    _taskSub?.cancel();
    _goalSub?.cancel();
    super.dispose();
  }

  void _subscribeToData() {
    if (FirebaseAuth.instance.currentUser == null) return;

    _txnSub = _financeService.getTransactionsListStream().listen((data) {
      _transactions = data;
      _txnLoaded = true;
      _recomputeFinance();
    });

    _acctSub = _financeService.getAccountsListStream().listen((data) {
      _accounts = data;
      _acctLoaded = true;
      _recomputeFinance();
    });

    _assetSub = _financeService.getAssetsListStream().listen((data) {
      _assets = data;
      _assetLoaded = true;
      _recomputeFinance();
    });

    _taskSub = _taskService.getTasksStream().listen((snapshot) {
      final standalone = snapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return TaskModel(
              id: doc.id,
              title: data['title'] ?? '',
              subtitle: data['subtitle'],
              tag: data['tag'],
              dueLabel: data['dueLabel'],
              priority: data['priority'] != null
                  ? TaskPriority.values.firstWhere(
                      (p) => p.name == data['priority'],
                      orElse: () => TaskPriority.baixa,
                    )
                  : null,
              isDone: data['isDone'] ?? false,
              goalId: data['goalId'],
              completedAt: data['completedAt'] != null
                  ? (data['completedAt'] as Timestamp).toDate()
                  : null,
              description: data['description'],
              dueDate: data['dueDate'] != null
                  ? (data['dueDate'] as Timestamp).toDate()
                  : null,
              createdAt: data['createdAt'] != null
                  ? (data['createdAt'] as Timestamp).toDate()
                  : null,
              status: data['status'] != null
                  ? TaskStatus.values.firstWhere(
                      (s) => s.name == data['status'],
                      orElse: () => TaskStatus.pendente,
                    )
                  : null,
            );
          })
          // Só tarefas avulsas (sem meta) e ainda não concluídas.
          .where((t) => t.goalId == null && !t.isDone)
          .toList();

      if (mounted) {
        setState(() {
          _standaloneTasks = standalone;
          _tasksLoaded = true;
        });
      }
    });

    _goalSub = _goalService.getGoalsStream().listen((snapshot) {
      final goals = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return GoalModel(
          id: doc.id,
          title: data['title'] ?? '',
          category: data['category'] ?? 'Pessoal',
          term: data['term'] != null
              ? GoalTerm.values.firstWhere(
                  (t) => t.name == data['term'],
                  orElse: () => GoalTerm.curtoPrazo,
                )
              : GoalTerm.curtoPrazo,
          progressMode: data['progressMode'] != null
              ? GoalProgressMode.values.firstWhere(
                  (m) => m.name == data['progressMode'],
                  orElse: () => GoalProgressMode.manualValue,
                )
              : GoalProgressMode.manualValue,
          current: (data['current'] as num?)?.toDouble(),
          target: (data['target'] as num?)?.toDouble(),
          imageAsset: data['imageAsset'],
          description: data['description'],
          targetDate: data['targetDate'] != null
              ? (data['targetDate'] as Timestamp).toDate()
              : null,
          progressColor: data['progressColor'] != null
              ? Color(int.parse(data['progressColor']))
              : Colors.blue,
          remainingLabel: data['remainingLabel'],
        );
      }).toList();

      if (mounted) {
        setState(() {
          _goals = goals;
          _goalsLoaded = true;
        });
      }
    });
  }

  void _recomputeFinance() {
    final accountsBalance = AccountBalance.totalOf(_accounts, _transactions);
    final assetsValue = _assets.fold<double>(0.0, (sum, a) => sum + a.currentValue);
    final totalWealth = accountsBalance + assetsValue;

    final monthlyIncome = FinanceSummary.monthlyIncome(_transactions);
    final monthlyExpense = FinanceSummary.monthlyExpense(_transactions);
    final progress = monthlyIncome > 0
        ? (monthlyExpense / monthlyIncome).clamp(0.0, 1.0)
        : 0.0;

    if (mounted) {
      setState(() {
        _totalWealth = totalWealth;
        _progressToGoal = progress;
      });
    }
  }

  Future<void> _loadReflection() async {
    try {
      final reflections = await _reflectionService.getAllActiveReflections();
      if (mounted) {
        if (reflections.isNotEmpty) {
          final randomIndex = Random().nextInt(reflections.length);
          setState(() => _activeReflection = reflections[randomIndex]);
        } else {
          setState(() => _activeReflection = null);
        }
      }
    } catch (e) {
      debugPrint('Dashboard - Erro ao carregar reflexões: $e');
    }
  }

  void _toggleTask(int index) {
    if (index >= _standaloneTasks.length) return;
    final task = _standaloneTasks[index];
    final updated = task.copyWith(isDone: !task.isDone);
    _taskService.updateTask(updated);
    // Remoção otimista — o stream de tarefas também vai confirmar isto
    // no próximo snapshot, mas isto evita esperar o round-trip.
    setState(() {
      _standaloneTasks.removeAt(index);
    });
  }

  Future<void> _openNotifications() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
    );
  }

  void _openNewItemSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      backgroundColor: context.loahColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const NewItemModalSheet(),
    );
  }

  // Troca para a tab de Tarefas dentro do shell (não usa Navigator.push
  // — TasksScreen é uma tab do shell, não uma rota secundária).
  void _openAllTasks() {
    LoahNavigationController.of(context).navigateTo(2); // ajusta o índice se "Tarefas" não for a tab 2
  }

  // Os streams já mantêm os dados sincronizados sozinhos; o "pull to
  // refresh" aqui é só feedback visual — não há nada para buscar
  // manualmente.
  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 400));
  }

  Widget _buildGreeting(BuildContext context, AppLocales loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.translate('dashboard_ola').replaceAll(
            '%s',
            AuthService().currentUser?.displayName?.split(' ').first ??
                loc.translate('dashboard_utilizador'),
          ),
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          loc.translate('dashboard_subtitulo'),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildPendingTasksSection(int limit) {
    final visibleTasks = _standaloneTasks.take(limit).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PendingTasksCard(
          tasks: visibleTasks,
          onToggle: (i) => _toggleTask(i),
        ),
        if (_standaloneTasks.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _openAllTasks,
              child: Text(AppLocales.of(context).translate('goals_summary_ver_todas')),
            ),
          ),
        ],
      ],
    );
  }

  /// Layout mobile original — coluna única, sem alterações de comportamento.
  Widget _buildMobileBody(AppLocales loc) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _buildGreeting(context, loc),
          const SizedBox(height: AppSpacing.xl),
          BalanceCard(
            available: _totalWealth,
            progressToGoal: _progressToGoal,
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildPendingTasksSection(_mobileTaskLimit),
          const SizedBox(height: AppSpacing.lg),
          NewItemCard(onCreate: _openNewItemSheet),
          const SizedBox(height: AppSpacing.lg),
          GoalsSummaryCard(
            goals: _goals.take(3).toList(),
            allTasks: _standaloneTasks,
            onSeeAll: () => LoahNavigationController.of(context).navigateTo(1),
          ),
          const SizedBox(height: AppSpacing.lg),
          DailyReflectionCard(
            quote: _activeReflection?.localizedText(loc.languageCode) ??
                loc.translate('reflection_fallback_quote'),
            imageUrl: _activeReflection?.imageUrl.isNotEmpty == true
                ? _activeReflection!.imageUrl
                : 'https://images.unsplash.com/photo-1483728642387-6c3bdd6c93e5?w=800',
          ),
          const SizedBox(height: AppSpacing.xxxl * 2),
        ],
      ),
    );
  }

  /// Layout desktop — largura máxima centralizada, grid de 2 colunas.
  Widget _buildDesktopBody(AppLocales loc) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGreeting(context, loc),
                const SizedBox(height: AppSpacing.xxxl),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            BalanceCard(
                              available: _totalWealth,
                              progressToGoal: _progressToGoal,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            _buildPendingTasksSection(_desktopTaskLimit),
                            const SizedBox(height: AppSpacing.lg),
                            NewItemCard(onCreate: _openNewItemSheet),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GoalsSummaryCard(
                              goals: _goals.take(3).toList(),
                              allTasks: _standaloneTasks,
                              onSeeAll: () =>
                                  LoahNavigationController.of(context).navigateTo(1),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            DailyReflectionCard(
                              quote: _activeReflection
                                      ?.localizedText(loc.languageCode) ??
                                  loc.translate('reflection_fallback_quote'),
                              imageUrl: _activeReflection?.imageUrl.isNotEmpty ==
                                      true
                                  ? _activeReflection!.imageUrl
                                  : 'https://images.unsplash.com/photo-1483728642387-6c3bdd6c93e5?w=800',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xxxl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocales.of(context);
    final notificationCount = _unreadCount;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= AppBreakpoints.desktop;
        final nav = LoahNavigationController.of(context);

        return Scaffold(
          drawer: LoahDrawer(
            currentIndex: nav.currentIndex,
            onNavigate: nav.navigateTo,
          ),
          appBar: LoahAppBar(
            actions: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    tooltip: loc.translate('common_notificacoes'),
                    onPressed: _openNotifications,
                    icon: const Icon(Icons.notifications_none_rounded),
                  ),
                  if (notificationCount > 0)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$notificationCount',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          body: SafeArea(
            child: _loading
                ? (isDesktop ? const _DashboardDesktopSkeleton() : const _DashboardMobileSkeleton())
                : (isDesktop ? _buildDesktopBody(loc) : _buildMobileBody(loc)),
          ),
          floatingActionButton: isDesktop
              ? null
              : FloatingActionButton(
                  backgroundColor: AppColors.primary,
                  heroTag: 'dashboard_fab',
                  onPressed: _openNewItemSheet,
                  child: const Icon(Icons.add),
                ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// SKELETON DE CARREGAMENTO
// ═══════════════════════════════════════════════════════════════════

/// Bloco cinza com uma animação de "respiração" (opacidade sobe e desce
/// em loop), usado como placeholder enquanto os dados reais não chegam.
class _ShimmerBox extends StatefulWidget {
  final double height;
  final double? width;
  final BorderRadius borderRadius;

  const _ShimmerBox({
    required this.height,
    this.width,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
  });

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = context.loahColors.cardBackgroundAlt;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            color: base.withValues(alpha: 0.35 + (_controller.value * 0.3)),
            borderRadius: widget.borderRadius,
          ),
        );
      },
    );
  }
}

/// Skeleton do layout mobile — mesma ordem visual do conteúdo real.
class _DashboardMobileSkeleton extends StatelessWidget {
  const _DashboardMobileSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: const [
        _ShimmerBox(height: 22, width: 180),
        SizedBox(height: 8),
        _ShimmerBox(height: 14, width: 240),
        SizedBox(height: AppSpacing.xl),
        _ShimmerBox(height: 140),
        SizedBox(height: AppSpacing.lg),
        _ShimmerBox(height: 200),
        SizedBox(height: AppSpacing.lg),
        _ShimmerBox(height: 70),
        SizedBox(height: AppSpacing.lg),
        _ShimmerBox(height: 170),
        SizedBox(height: AppSpacing.lg),
        _ShimmerBox(height: 120),
      ],
    );
  }
}

/// Skeleton do layout desktop — 2 colunas, mesma proporção do real.
class _DashboardDesktopSkeleton extends StatelessWidget {
  const _DashboardDesktopSkeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xxxl),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ShimmerBox(height: 22, width: 180),
              SizedBox(height: 8),
              _ShimmerBox(height: 14, width: 240),
              SizedBox(height: AppSpacing.xxxl),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          _ShimmerBox(height: 140),
                          SizedBox(height: AppSpacing.lg),
                          _ShimmerBox(height: 220),
                          SizedBox(height: AppSpacing.lg),
                          _ShimmerBox(height: 70),
                        ],
                      ),
                    ),
                    SizedBox(width: AppSpacing.lg),
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          _ShimmerBox(height: 170),
                          SizedBox(height: AppSpacing.lg),
                          _ShimmerBox(height: 120),
                        ],
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