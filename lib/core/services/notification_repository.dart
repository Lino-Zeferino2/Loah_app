import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/app_notification.dart';

/// Service that reads/writes notifications from/to Firestore.
///
/// Each user's notifications live at:
///   /users/{userId}/notifications/{notificationId}
///
/// The data is written either by:
///   - [NotificationScheduler] (client-side periodic checks)
///   - Firebase Cloud Functions (server-side triggers & scheduled jobs)
///   - The FCM notification handler (when a push arrives)
class NotificationRepository {
  static final NotificationRepository _instance = NotificationRepository._internal();
  factory NotificationRepository() => _instance;
  NotificationRepository._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  CollectionReference get _notificationsCollection =>
      _firestore.collection('users').doc(_userId).collection('notifications');

  /// Returns a stream of all notifications for the current user,
  /// ordered by timestamp descending (newest first).
  Stream<QuerySnapshot> getNotificationsStream() {
    return _notificationsCollection
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  /// Returns a stream of only unread notifications.
  Stream<QuerySnapshot> getUnreadNotificationsStream() {
    return _notificationsCollection
        .where('isRead', isEqualTo: false)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  /// Writes a new notification to Firestore.
  ///
  /// Returns the document ID that was created.
  Future<String> addNotification(AppNotification notification) async {
    final data = notification.toFirestore();
    data['createdAt'] = FieldValue.serverTimestamp();

    if (notification.id.isNotEmpty) {
      await _notificationsCollection.doc(notification.id).set(data);
      return notification.id;
    } else {
      final docRef = await _notificationsCollection.add(data);
      return docRef.id;
    }
  }

  /// Marks a single notification as read.
  Future<void> markAsRead(String notificationId) async {
    await _notificationsCollection.doc(notificationId).update({
      'isRead': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Marks all notifications as read.
  Future<void> markAllAsRead() async {
    final batch = _firestore.batch();
    final snapshot = await _notificationsCollection
        .where('isRead', isEqualTo: false)
        .get();

    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {
        'isRead': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  /// Deletes a specific notification.
  Future<void> deleteNotification(String notificationId) async {
    await _notificationsCollection.doc(notificationId).delete();
  }

  /// Clears all notifications for the current user.
  Future<void> clearAll() async {
    final batch = _firestore.batch();
    final snapshot = await _notificationsCollection.get();

    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  /// Returns the count of unread notifications.
  Future<int> getUnreadCount() async {
    final snapshot = await _notificationsCollection
        .where('isRead', isEqualTo: false)
        .get();
    return snapshot.docs.length;
  }

  /// Returns a stream of the unread count (useful for badge indicators).
  Stream<int> getUnreadCountStream() {
    return _notificationsCollection
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}

