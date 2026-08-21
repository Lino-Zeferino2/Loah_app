import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/notification_preferences.dart';

/// Service to read/write the current user's notification preferences.
/// Stored at users/{uid}/settings/notificationPreferences.
class NotificationPreferencesService {
  static final NotificationPreferencesService _instance =
      NotificationPreferencesService._internal();
  factory NotificationPreferencesService() => _instance;
  NotificationPreferencesService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  DocumentReference? get _doc {
    final uid = _userId;
    if (uid == null) return null;
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('settings')
        .doc('notificationPreferences');
  }

  /// Fetch current preferences (defaults if none saved yet).
  Future<NotificationPreferences> getPreferences() async {
    final doc = _doc;
    if (doc == null) return const NotificationPreferences();
    try {
      final snap = await doc.get();
      if (!snap.exists) return const NotificationPreferences();
      return NotificationPreferences.fromMap(
          snap.data() as Map<String, dynamic>);
    } catch (_) {
      // Se falhar (ex: sem permissão/offline), usa defaults — nunca
      // deve bloquear as verificações de notificação por causa disto.
      return const NotificationPreferences();
    }
  }

  /// Stream preferences for live UI updates.
  Stream<NotificationPreferences> streamPreferences() {
    final doc = _doc;
    if (doc == null) {
      return Stream.value(const NotificationPreferences());
    }
    return doc.snapshots().map((snap) {
      if (!snap.exists) return const NotificationPreferences();
      return NotificationPreferences.fromMap(
          snap.data() as Map<String, dynamic>);
    });
  }

  Future<void> updatePreferences(NotificationPreferences prefs) async {
    final doc = _doc;
    if (doc == null) return;
    await doc.set(prefs.toMap(), SetOptions(merge: true));
  }
}