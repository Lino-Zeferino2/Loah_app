import 'package:flutter/material.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/mock/mock_data.dart';
import '../../core/mock/notification_generator.dart';
import '../../core/navigation/navigation_controller.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_theme.dart';
import '../notifications/notifications_screen.dart';

import '../../widgets/loah_app_bar.dart';
import '../../widgets/loah_drawer.dart';
import 'widgets/new_item_modal_sheet.dart';

import '../../models/task_model.dart';

import 'widgets/balance_card.dart';
import 'widgets/daily_reflection_card.dart';
import 'widgets/goals_summary_card.dart';
import 'widgets/new_item_card.dart';
import 'widgets/pending_tasks_card.dart';

/// "Loah - Dashboard": the home screen with a greeting, balance summary,
/// pending tasks, a quick-add card, goal progress and a daily reflection.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  /// Pairs each non-goal-linked [TaskModel] with its real index inside
  /// [MockData.tasks], so toggling from this filtered view still mutates
  /// the correct item in the shared source (not a disconnected copy).
  List<_IndexedTask> get _standaloneTasks => MockData.tasks
      .asMap()
      .entries
      .where((e) => e.value.goalId == null)
      .map((e) => _IndexedTask(e.key, e.value))
      .toList();

  void _toggleTask(int taskIndexInMockData) {
    setState(() {
      MockData.tasks[taskIndexInMockData] =
          MockData.tasks[taskIndexInMockData].copyWith(
        isDone: !MockData.tasks[taskIndexInMockData].isDone,
      );
    });
  }

  Future<void> _openNotifications() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final nav = LoahNavigationController.of(context);
    final standalone = _standaloneTasks;
    final notificationCount = NotificationGenerator.generate().length;

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
                tooltip: 'Notificações',
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
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text(
              'Olá, ${AuthService().currentUser?.displayName?.split(' ').first ?? 'Utilizador'}',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'Seu cérebro auxiliar está pronto. Aqui está o resumo de hoje.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xl),
            const BalanceCard(available: 4820.50, progressToGoal: 0.75),
            const SizedBox(height: AppSpacing.lg),
            PendingTasksCard(
              tasks: standalone.map((p) => p.task).toList(),
              onToggle: (i) => _toggleTask(standalone[i].mockDataIndex),
            ),
            const SizedBox(height: AppSpacing.lg),
            NewItemCard(
              onCreate: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: false,
                  backgroundColor: context.loahColors.cardBackground,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (_) => const NewItemModalSheet(),
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            GoalsSummaryCard(
              goals: MockData.goals.take(3).toList(),
              allTasks: MockData.tasks,
              onSeeAll: () => nav.navigateTo(1), // tab 1 = Metas
            ),
            const SizedBox(height: AppSpacing.lg),
            DailyReflectionCard(
              quote: 'O que é medido, é gerenciado.',
              imageUrl:
                  'https://images.unsplash.com/photo-1483728642387-6c3bdd6c93e5?w=800',
              onEdit: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _IndexedTask {
  final int mockDataIndex;
  final TaskModel task;
  const _IndexedTask(this.mockDataIndex, this.task);
}