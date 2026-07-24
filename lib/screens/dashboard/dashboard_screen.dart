import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/mock/notification_generator.dart';
import '../../core/navigation/navigation_controller.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/task_service.dart';
import '../../core/services/goal_service.dart';
import '../../core/theme/app_theme.dart';
import '../notifications/notifications_screen.dart';
import '../../widgets/loah_app_bar.dart';
import '../../widgets/loah_drawer.dart';
import 'widgets/new_item_modal_sheet.dart';
import '../../models/task_model.dart';
import '../../models/goal_model.dart';
import 'widgets/balance_card.dart';
import 'widgets/daily_reflection_card.dart';
import 'widgets/goals_summary_card.dart';
import 'widgets/new_item_card.dart';
import 'widgets/pending_tasks_card.dart';

/// "Loah - Dashboard": the home screen with a greeting, balance summary,
/// pending tasks, a quick-add card, goal progress and a daily reflection.
///
/// Lê tarefas e metas do Firestore via services.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TaskService _taskService = TaskService();
  final GoalService _goalService = GoalService();

  List<TaskModel> _standaloneTasks = [];
  List<GoalModel> _goals = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final tasksSnapshot = await _taskService.getTasksStream().first;
      final standalone = tasksSnapshot.docs
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
          .where((t) => t.goalId == null)
          .toList();

      final goalsSnapshot = await _goalService.getGoalsStream().first;
      final goals = goalsSnapshot.docs.map((doc) {
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
          _standaloneTasks = standalone;
          _goals = goals;
        });
      }
    } catch (_) {}
  }

  void _toggleTask(int index) {
    if (index >= _standaloneTasks.length) return;
    final task = _standaloneTasks[index];
    final updated = task.copyWith(isDone: !task.isDone);
    _taskService.updateTask(updated);
    setState(() {
      _standaloneTasks[index] = updated;
    });
  }

  Future<void> _openNotifications() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nav = LoahNavigationController.of(context);
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
        child: RefreshIndicator(
          onRefresh: _loadData,
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
                tasks: _standaloneTasks,
                onToggle: (i) => _toggleTask(i),
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
                goals: _goals.take(3).toList(),
                allTasks: _standaloneTasks,
                onSeeAll: () => nav.navigateTo(1),
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
      ),
    );
  }
}
