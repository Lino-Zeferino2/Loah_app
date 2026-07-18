import 'package:flutter/material.dart';
import 'package:loah_app/core/theme/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/mock/mock_data.dart';
import '../../core/navigation/navigation_controller.dart';
import '../../models/goal_model.dart';
import '../../widgets/loah_app_bar.dart';
import '../../widgets/loah_avatar_action.dart';
import '../../widgets/loah_card.dart';
import '../../widgets/loah_drawer.dart';
import 'add_goal_screen.dart';
import 'goal_detail_screen.dart';
import 'widgets/goal_term_section.dart';

/// "Loah - Metas": overall goal completion summary plus goals grouped
/// by time horizon (curto / médio / longo prazo).
class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  List<GoalModel> _byTerm(GoalTerm term) =>
      MockData.goals.where((g) => g.term == term).toList();

  Future<void> _openGoal(GoalModel goal) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => GoalDetailScreen(goal: goal)),
    );
    setState(() {});
  }

  Future<void> _createGoal() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AddGoalScreen()),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final nav = LoahNavigationController.of(context);
    return Scaffold(
      drawer: LoahDrawer(currentIndex: nav.currentIndex, onNavigate: nav.navigateTo),
      appBar: const LoahAppBar(actions: [LoahAvatarAction()]),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            LoahCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Metas',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Você completou 65% do seu planejamento trimestral.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            GoalTermSection(
              term: GoalTerm.curtoPrazo,
              goals: _byTerm(GoalTerm.curtoPrazo),
              allTasks: MockData.tasks,
              onGoalTap: _openGoal,
              cardIcon: Icons.savings_outlined,
            ),
            const SizedBox(height: AppSpacing.lg),
            GoalTermSection(
              term: GoalTerm.medioPrazo,
              goals: _byTerm(GoalTerm.medioPrazo),
              allTasks: MockData.tasks,
              onGoalTap: _openGoal,
              cardIcon: Icons.flight_takeoff_rounded,
            ),
            const SizedBox(height: AppSpacing.lg),
            GoalTermSection(
              term: GoalTerm.longoPrazo,
              goals: _byTerm(GoalTerm.longoPrazo),
              allTasks: MockData.tasks,
              onGoalTap: _openGoal,
              cardIcon: Icons.home_outlined,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary ,
        heroTag: 'goals_fab',
        onPressed: _createGoal,
        child: const Icon(Icons.add),
      ),
    );
  }
}