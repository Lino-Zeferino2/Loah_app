enum NotificationCategory { contacts, tasks, goals, finance, system }

/// One notification card. These are never stored directly — see
/// `NotificationGenerator`, which derives a fresh list every time the
/// Notifications screen opens, scanning contacts/tasks/goals/
/// finances for anything worth surfacing. [relatedId] lets the screen
/// build the right tap/action behavior (open the source item, log a
/// call, mark a bill paid...) without the model needing to hold
/// callbacks itself.
class AppNotification {
  final String id;
  final NotificationCategory category;
  final String title;
  final String message;
  final DateTime timestamp;
  final String? relatedId;

  /// Optional 0..1 progress shown as a thin bar (used for goal
  /// milestone notifications).
  final double? progress;

  const AppNotification({
    required this.id,
    required this.category,
    required this.title,
    required this.message,
    required this.timestamp,
    this.relatedId,
    this.progress,
  });
}