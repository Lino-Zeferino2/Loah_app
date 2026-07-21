import 'package:flutter/material.dart';
import '../../core/mock/mock_data.dart';
import '../../core/mock/notification_generator.dart';
import '../../core/theme/app_theme.dart';
import '../../models/app_notification.dart';
import '../../models/contact_model.dart';
import '../../models/goal_model.dart';
import '../../models/task_model.dart';
import '../../widgets/loah_app_bar_simple.dart';
import '../contacts/contact_detail_screen.dart';
import '../finances/add_transaction_screen.dart';
import '../finances/budgets_screen.dart';
import '../goals/goal_detail_screen.dart';
import '../tasks/task_detail_screen.dart';
import 'widgets/notification_card.dart';

/// "Loah - Notificações": a unified feed pulling from every corner of
/// the app — contacts overdue, tasks due soon, goal milestones,
/// recurring bills, budgets over limit. Nothing is stored here twice;
/// see [NotificationGenerator] for how the list is derived fresh each
/// time this screen opens.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  void _dismiss(AppNotification n) {
    setState(() => MockData.dismissedNotificationIds.add(n.id));
  }

  void _clearAll(List<AppNotification> current) {
    setState(() {
      MockData.dismissedNotificationIds.addAll(current.map((n) => n.id));
    });
  }

  ContactModel? _findContact(String id) {
    final matches = MockData.contacts.where((c) => c.id == id);
    return matches.isEmpty ? null : matches.first;
  }

  TaskModel? _findTask(String id) {
    final matches = MockData.tasks.where((t) => t.id == id);
    return matches.isEmpty ? null : matches.first;
  }

  GoalModel? _findGoal(String id) {
    final matches = MockData.goals.where((g) => g.id == id);
    return matches.isEmpty ? null : matches.first;
  }

  void _logCallAndDismiss(AppNotification n, ContactModel contact) {
    setState(() {
      final updated = contact.copyWith(
        interactions: [
          ...contact.interactions,
          ContactInteraction(date: DateTime.now(), type: InteractionType.call),
        ],
      );
      final index = MockData.contacts.indexWhere((c) => c.id == contact.id);
      if (index != -1) MockData.contacts[index] = updated;
      MockData.dismissedNotificationIds.add(n.id);
    });
  }

  Future<void> _openTask(TaskModel task) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TaskDetailScreen(task: task)),
    );
    setState(() {});
  }

  Future<void> _openGoal(GoalModel goal) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => GoalDetailScreen(goal: goal)),
    );
    setState(() {});
  }

  Future<void> _openContact(ContactModel contact) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ContactDetailScreen(contact: contact)),
    );
    setState(() {});
  }

  Future<void> _openBudgets() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const BudgetsScreen()),
    );
    setState(() {});
  }

  /// "Pagar" on a recurring-bill notification: opens the transaction
  /// form pre-filled so the user confirms the amount/account, instead
  /// of silently creating it — safer than a single tap for money.
  Future<void> _payRecurring(AppNotification n) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
    );
    setState(() => MockData.dismissedNotificationIds.add(n.id));
  }

  /// Builds the row of action buttons/tap behavior for one
  /// notification, based on its category — actions need real
  /// callbacks, so they live here rather than on the model itself.
  ({VoidCallback? onTap, List<Widget> actions}) _behaviorFor(AppNotification n) {
    final colors = context.loahColors;

    switch (n.category) {
      case NotificationCategory.contacts:
        final contact = n.relatedId == null ? null : _findContact(n.relatedId!);
        if (contact == null) return (onTap: null, actions: const []);
        return (
          onTap: () => _openContact(contact),
          actions: [
            ElevatedButton(
              onPressed: () => _logCallAndDismiss(n, contact),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.accentBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                minimumSize: Size.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
              ),
              child: const Text('Ligar agora', style: TextStyle(fontSize: 12.5)),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: () => _dismiss(n),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                minimumSize: Size.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
              ),
              child: const Text('Lembrar depois', style: TextStyle(fontSize: 12.5)),
            ),
          ],
        );

      case NotificationCategory.tasks:
        final task = n.relatedId == null ? null : _findTask(n.relatedId!);
        return (onTap: task == null ? null : () => _openTask(task), actions: const []);

      case NotificationCategory.goals:
        final goal = n.relatedId == null ? null : _findGoal(n.relatedId!);
        return (onTap: goal == null ? null : () => _openGoal(goal), actions: const []);

      case NotificationCategory.finance:
        // Two finance sub-cases share the category: a recurring bill
        // due (id starts with a recurring id) gets a "Pagar" button;
        // a budget overrun just navigates to the Orçamento screen.
        final isRecurringBill = n.id.startsWith('notif_recurring_');
        if (isRecurringBill) {
          return (
            onTap: null,
            actions: [
              ElevatedButton(
                onPressed: () => _payRecurring(n),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.negative,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  minimumSize: Size.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                ),
                child: const Text('Pagar', style: TextStyle(fontSize: 12.5)),
              ),
            ],
          );
        }
        return (onTap: _openBudgets, actions: const []);

      case NotificationCategory.system:
        return (onTap: null, actions: const []);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.loahColors;
    final all = NotificationGenerator.generate();
    final recent = all.where((n) => DateTime.now().difference(n.timestamp).inHours < 24).toList();
    final older = all.where((n) => DateTime.now().difference(n.timestamp).inHours >= 24).toList();

    return Scaffold(
      appBar: const LoahAppBarSimple(title: 'Notificações'),
      body: SafeArea(
        child: all.isEmpty
            ? Center(
                child: Text(
                  'Nenhuma notificação por aqui — tudo em dia!',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (recent.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'RECENTES',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                letterSpacing: 0.6,
                                color: context.textSecondary,
                              ),
                        ),
                        TextButton.icon(
                          onPressed: () => _clearAll(all),
                          icon: Icon(Icons.clear_all, size: 16, color: colors.accentBlue),
                          label: Text(
                            'Limpar tudo',
                            style: TextStyle(color: colors.accentBlue, fontSize: 12.5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    for (final n in recent) ...[
                      _buildCard(n),
                      const SizedBox(height: 10),
                    ],
                    const SizedBox(height: 12),
                  ],
                  if (older.isNotEmpty) ...[
                    Text(
                      'ANTERIORES',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            letterSpacing: 0.6,
                            color: context.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    for (final n in older) ...[
                      _buildCard(n),
                      const SizedBox(height: 10),
                    ],
                  ],
                ],
              ),
      ),
    );
  }

  Widget _buildCard(AppNotification n) {
    final behavior = _behaviorFor(n);
    return NotificationCard(notification: n, onTap: behavior.onTap, actions: behavior.actions);
  }
}