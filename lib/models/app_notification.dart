import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationCategory { contacts, tasks, goals, finance, system }

/// One notification card stored in Firestore under
/// /users/{userId}/notifications/{notificationId}.
///
/// Notifications are generated server-side (Cloud Functions) or
/// client-side (NotificationScheduler) and written to Firestore,
/// then delivered to the device via FCM push.
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

  /// Whether the user has already seen/read this notification.
  final bool isRead;

  const AppNotification({
    required this.id,
    required this.category,
    required this.title,
    required this.message,
    required this.timestamp,
    this.relatedId,
    this.progress,
    this.isRead = false,
  });

  /// Create a copy with updated fields.
  AppNotification copyWith({
    String? id,
    NotificationCategory? category,
    String? title,
    String? message,
    DateTime? timestamp,
    String? relatedId,
    double? progress,
    bool? isRead,
  }) {
    return AppNotification(
      id: id ?? this.id,
      category: category ?? this.category,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      relatedId: relatedId ?? this.relatedId,
      progress: progress ?? this.progress,
      isRead: isRead ?? this.isRead,
    );
  }

  /// Converts a Firestore [DocumentSnapshot] into an [AppNotification].
  factory AppNotification.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppNotification(
      id: doc.id,
      category: NotificationCategory.values.firstWhere(
        (c) => c.name == data['category'],
        orElse: () => NotificationCategory.system,
      ),
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      timestamp: data['timestamp'] != null
          ? (data['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
      relatedId: data['relatedId'],
      progress: (data['progress'] as num?)?.toDouble(),
      isRead: data['isRead'] ?? false,
    );
  }

  /// Serializes this notification to a map for Firestore.
  Map<String, dynamic> toFirestore() {
    return {
      'category': category.name,
      'title': title,
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
      'relatedId': relatedId,
      'progress': progress,
      'isRead': isRead,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
