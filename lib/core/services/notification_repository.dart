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

  /// Returns a reference to the user's notifications collection, or null
  /// if the user is not authenticated.
  CollectionReference? get _notificationsCollection {
    final uid = _userId;
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid).collection('notifications');
  }

  CollectionReference _requireCollection() {
    final col = _notificationsCollection;
    if (col == null) throw Exception('User not authenticated');
    return col;
  }

  /// Returns a stream of all notifications for the current user,
  /// ordered by timestamp descending (newest first). Returns an empty
  /// stream if the user is not authenticated.
  Stream<QuerySnapshot> getNotificationsStream() {
    final col = _notificationsCollection;
    if (col == null) return const Stream.empty();
    return col
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  /// Returns a stream of only unread notifications. Returns an empty
  /// stream if the user is not authenticated.
  Stream<QuerySnapshot> getUnreadNotificationsStream() {
    final col = _notificationsCollection;
    if (col == null) return const Stream.empty();
    return col
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
    final col = _requireCollection();

    if (notification.id.isNotEmpty) {
      await col.doc(notification.id).set(data);
      return notification.id;
    } else {
      final docRef = await col.add(data);
      return docRef.id;
    }
  }

  /// Marks a single notification as read.
  Future<void> markAsRead(String notificationId) async {
    await _requireCollection().doc(notificationId).update({
      'isRead': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Marks all notifications as read.
  Future<void> markAllAsRead() async {
    final batch = _firestore.batch();
    final col = _requireCollection();
    final snapshot = await col
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
    await _requireCollection().doc(notificationId).delete();
  }

  /// Clears all notifications for the current user.
  Future<void> clearAll() async {
    final batch = _firestore.batch();
    final col = _requireCollection();
    final snapshot = await col.get();

    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  /// Returns the count of unread notifications.
  Future<int> getUnreadCount() async {
    final col = _requireCollection();
    final snapshot = await col
        .where('isRead', isEqualTo: false)
        .get();
    return snapshot.docs.length;
  }

  /// Returns a stream of the unread count (useful for badge indicators).
  /// Se o utilizador nao estiver autenticado, retorna um stream vazio
  /// (0) para evitar erros PERMISSION_DENIED que podem travar a app.
  Stream<int> getUnreadCountStream() {
    final col = _notificationsCollection;
    if (col == null) {
      return Stream<int>.value(0);
    }
    return col
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}

