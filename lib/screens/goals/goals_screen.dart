// ignore_for_file: avoid_types_as_parameter_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loah_app/core/theme/app_colors.dart';
import '../../core/constants/app_breakpoints.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/navigation/navigation_controller.dart';
import '../../core/services/goal_service.dart';
import '../../core/utils/goal_progress.dart';
import '../../models/goal_model.dart';
import '../../widgets/loah_app_bar.dart';
import '../../widgets/loah_card.dart';
import '../../widgets/loah_drawer.dart';
import 'add_goal_screen.dart';
import 'goal_detail_screen.dart';
import 'widgets/goal_term_section.dart';

/// "Loah - Metas": overall goal completion summary plus goals grouped
/// by time horizon (curto / médio / longo prazo).
///
/// Lê metas do Firestore via [GoalService].
///
/// Layout: mobile mantém as 3 secções empilhadas verticalmente (original).
/// Desktop coloca as 3 secções lado a lado — são categorias paralelas
/// (mesmo prazo diferente), mais fácil comparar de relance do que rolar
/// a página três vezes. O card de resumo fica em largura total no topo
/// nos dois casos.
class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final GoalService _goalService = GoalService();
  List<GoalModel> _goals = [];

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    final snapshot = await _goalService.getGoalsStream().first;
    final goals = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return GoalModel(
        id: doc.id,
        title: data['title'] ?? '',
        category: data['category'] ?? 'Pessoal',
        term: data['term'] != null
            ? GoalTerm.values.firstWhere((t) => t.name == data['term'], orElse: () => GoalTerm.curtoPrazo)
            : GoalTerm.curtoPrazo,
        progressMode: data['progressMode'] != null
            ? GoalProgressMode.values.firstWhere((m) => m.name == data['progressMode'], orElse: () => GoalProgressMode.manualValue)
            : GoalProgressMode.manualValue,
        current: (data['current'] as num?)?.toDouble(),
        target: (data['target'] as num?)?.toDouble(),
        imageAsset: data['imageAsset'],
        description: data['description'],
        targetDate: data['targetDate'] != null ? (data['targetDate'] as Timestamp).toDate() : null,
        progressColor: data['progressColor'] != null ? Color(int.parse(data['progressColor'])) : Colors.blue,
        remainingLabel: data['remainingLabel'],
      );
    }).toList();
    if (mounted) setState(() => _goals = goals);
  }

  List<GoalModel> _byTerm(GoalTerm term) => _goals.where((g) => g.term == term).toList();

  String _buildCompletionSummary(BuildContext context) {
    if (_goals.isEmpty) return '';
    final totalProgress = _goals.fold<double>(
      0,
      (sum, g) => sum + GoalProgress.of(g, []),
    );
    final avgPercent = ((totalProgress / _goals.length) * 100).round();
    final loc = AppLocales.of(context);
    return loc.translate('goals_summary_completion').replaceAll('%s', '$avgPercent');
  }

  Future<void> _openGoal(GoalModel goal) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => GoalDetailScreen(goal: goal)),
    );
    _loadGoals();
  }

  Future<void> _createGoal() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AddGoalScreen()),
    );
    _loadGoals();
  }

  Widget _buildSummaryCard(AppLocales loc) {
    if (_goals.isEmpty) return const SizedBox.shrink();
    return LoahCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(loc.translate('goals_summary_title'),
              style: Theme.of(context)
                  .textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(
            _buildCompletionSummary(context),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  /// Mobile — 3 secções empilhadas, comportamento original intocado.
  Widget _buildMobileBody(AppLocales loc) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        _buildSummaryCard(loc),
        const SizedBox(height: AppSpacing.xl),
        GoalTermSection(
          term: GoalTerm.curtoPrazo,
          goals: _byTerm(GoalTerm.curtoPrazo),
          allTasks: const [],
          onGoalTap: _openGoal,
          cardIcon: Icons.savings_outlined,
        ),
        const SizedBox(height: AppSpacing.lg),
        GoalTermSection(
          term: GoalTerm.medioPrazo,
          goals: _byTerm(GoalTerm.medioPrazo),
          allTasks: const [],
          onGoalTap: _openGoal,
          cardIcon: Icons.flight_takeoff_rounded,
        ),
        const SizedBox(height: AppSpacing.lg),
        GoalTermSection(
          term: GoalTerm.longoPrazo,
          goals: _byTerm(GoalTerm.longoPrazo),
          allTasks: const [],
          onGoalTap: _openGoal,
          cardIcon: Icons.home_outlined,
        ),
      ],
    );
  }

  /// Desktop — largura máxima centralizada; resumo em largura total no
  /// topo; as 3 secções de prazo lado a lado.
  Widget _buildDesktopBody(AppLocales loc) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xxxl),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryCard(loc),
              const SizedBox(height: AppSpacing.xxxl),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: GoalTermSection(
                      term: GoalTerm.curtoPrazo,
                      goals: _byTerm(GoalTerm.curtoPrazo),
                      allTasks: const [],
                      onGoalTap: _openGoal,
                      cardIcon: Icons.savings_outlined,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: GoalTermSection(
                      term: GoalTerm.medioPrazo,
                      goals: _byTerm(GoalTerm.medioPrazo),
                      allTasks: const [],
                      onGoalTap: _openGoal,
                      cardIcon: Icons.flight_takeoff_rounded,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: GoalTermSection(
                      term: GoalTerm.longoPrazo,
                      goals: _byTerm(GoalTerm.longoPrazo),
                      allTasks: const [],
                      onGoalTap: _openGoal,
                      cardIcon: Icons.home_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxxl),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nav = LoahNavigationController.of(context);
    final loc = AppLocales.of(context);
    return Scaffold(
      drawer: LoahDrawer(currentIndex: nav.currentIndex, onNavigate: nav.navigateTo),
      appBar: LoahAppBar(title: loc.translate('goals_minhas_metas')),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadGoals,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= AppBreakpoints.desktop;
              return isDesktop ? _buildDesktopBody(loc) : _buildMobileBody(loc);
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        heroTag: 'goals_fab',
        onPressed: _createGoal,
        child: const Icon(Icons.add),
      ),
    );
  }
}