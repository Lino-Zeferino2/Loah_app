import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../models/app_notification.dart';
import 'notification_repository.dart';

/// Central service for Firebase Cloud Messaging (FCM).
///
/// Responsibilities:
/// 1. Request notification permissions
/// 2. Register/refresh the FCM device token in Firestore
/// 3. Handle foreground messages (show local notification)
/// 4. Handle background/terminated messages (via onMessageOpenedApp)
/// 5. Navigate to the correct screen when a notification is tapped
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final NotificationRepository _repository = NotificationRepository();

  /// Local notifications plugin for displaying push payloads while
  /// the app is in the foreground.
  late final FlutterLocalNotificationsPlugin _localNotifications;

  /// The current FCM token.
  String? _currentToken;

  /// Whether the service has been initialized.
  bool _initialized = false;

  /// Callback for navigation — set by [NotificationService.setNavigator].
  /// Receives the [AppNotification] from the tapped push.
  void Function(AppNotification notification)? _onNotificationTap;

  /// Provide a navigation callback so the service can open the
  /// correct screen when a push notification is tapped.
  void setNavigator(void Function(AppNotification notification) onTap) {
    _onNotificationTap = onTap;
  }

  /// Initialize FCM: request permissions, get token, set up handlers.
  ///
  /// Call this once in [main] after [Firebase.initializeApp].
  Future<void> initialize() async {
    if (_initialized) return;

    // ── 1. Local notifications setup ──────────────────────────────
    _localNotifications = FlutterLocalNotificationsPlugin();
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );

    // ── 2. Request permissions (iOS) ──────────────────────────────
    final messagingSettings = await _messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );
    debugPrint(
      '[NotificationService] Permission: ${messagingSettings.authorizationStatus}',
    );

    // ── 3. Get & register the FCM token ──────────────────────────
    // No iOS, o token FCM depende do APNS token, que só chega depois
    // de o sistema registar o device para push. Em simuladores esse
    // APNS token pode nunca chegar — sem esta checagem, getToken()
    // lança exceção e derruba o app inteiro (main() faz await nisto).
    // No Android este bloco continua a funcionar exatamente igual.
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final apnsToken = await _messaging.getAPNSToken();
      if (apnsToken == null) {
        debugPrint(
          '[NotificationService] APNS token ainda não disponível '
          '(normal em simulador). A saltar registo de FCM token.',
        );
      } else {
        try {
          _currentToken = await _messaging.getToken();
          debugPrint('[NotificationService] FCM Token: $_currentToken');
          await _saveTokenToFirestore(_currentToken);
        } catch (e) {
          debugPrint('[NotificationService] Erro ao obter FCM token: $e');
        }
      }
    } else {
      try {
        _currentToken = await _messaging.getToken();
        debugPrint('[NotificationService] FCM Token: $_currentToken');
        await _saveTokenToFirestore(_currentToken);
      } catch (e) {
        debugPrint('[NotificationService] Erro ao obter FCM token: $e');
      }
    }

    // Listen for token refresh
    _messaging.onTokenRefresh.listen((newToken) {
      debugPrint('[NotificationService] Token refreshed: $newToken');
      _currentToken = newToken;
      _saveTokenToFirestore(newToken);
    });

    // ── 4. Foreground messages ────────────────────────────────────
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // ── 5. Background/terminated tap handling ─────────────────────
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Check if the app was opened from a terminated notification
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }

    _initialized = true;
    debugPrint('[NotificationService] Initialized successfully.');
  }

  /// Saves the current FCM token to the user's Firestore document
  /// under /users/{userId}/fcmTokens/{tokenId}.
  Future<void> _saveTokenToFirestore(String? token) async {
    if (token == null || FirebaseAuth.instance.currentUser == null) return;

    try {
      final firestore = FirebaseFirestore.instance;
      final uid = FirebaseAuth.instance.currentUser!.uid;

      await firestore
          .collection('users')
          .doc(uid)
          .collection('fcmTokens')
          .doc(token)
          .set({
        'token': token,
        'platform': 
          // ignore: undefined_prefixed_name
          defaultTargetPlatform == TargetPlatform.android
              ? 'android'
              : 'ios',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('[NotificationService] Error saving FCM token: $e');
    }
  }

  /// Called when a push notification arrives while the app is in the
  /// foreground. Shows a local notification instead of the system one.
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('[NotificationService] Foreground message: ${message.messageId}');

    final notification = message.notification;
    final data = message.data;

    if (notification == null) return;

    // Save the notification to Firestore
    final appNotification = _parseRemoteMessage(message);
    if (appNotification != null) {
      await _repository.addNotification(appNotification);
    }

    // Show local notification
    await _showLocalNotification(
      id: message.messageId?.hashCode ?? DateTime.now().millisecondsSinceEpoch,
      title: notification.title ?? '',
      body: notification.body ?? '',
      payload: jsonEncode(data),
    );
  }

  /// Shows a local notification (used for foreground messages).
  Future<void> _showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'loah_notifications',
      'Loah Notificações',
      channelDescription: 'Notificações do app Loah',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(id, title, body, details, payload: payload);
  }


  /// Called when the user taps a push notification while the app is
  /// in background or has been opened from terminated state.
  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('[NotificationService] Notification tapped: ${message.messageId}');
    _navigateFromData(message.data);
  }

  void _onLocalNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;

    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      _navigateFromData(data);
    } catch (e) {
      debugPrint('[NotificationService] Error parsing local notification tap: $e');
    }
  }

  /// Parses the remote message and navigates to the appropriate screen
  /// based on the [category] and [relatedId] in the data payload.
  void _navigateFromData(Map<String, dynamic> data) {
    final category = data['category'] as String?;
    final relatedId = data['relatedId'] as String?;
    final title = data['title'] as String? ?? '';
    final message = data['message'] as String? ?? '';

    final notification = AppNotification(
      id: data['id'] as String? ?? '',
      category: category != null
          ? NotificationCategory.values.firstWhere(
              (c) => c.name == category,
              orElse: () => NotificationCategory.system,
            )
          : NotificationCategory.system,
      title: title,
      message: message,
      timestamp: DateTime.now(),
      relatedId: relatedId,
    );

    _onNotificationTap?.call(notification);
  }

  /// Converts a [RemoteMessage] to an [AppNotification].
  AppNotification? _parseRemoteMessage(RemoteMessage message) {
    final data = message.data;
    final notification = message.notification;
    if (notification == null) return null;

    final category = data['category'] as String?;

    return AppNotification(
      id: data['id'] as String? ?? message.messageId ?? '',
      category: category != null
          ? NotificationCategory.values.firstWhere(
              (c) => c.name == category,
              orElse: () => NotificationCategory.system,
            )
          : NotificationCategory.system,
      title: notification.title ?? data['title'] as String? ?? '',
      message: notification.body ?? data['message'] as String? ?? '',
      timestamp: DateTime.now(),
      relatedId: data['relatedId'] as String?,
      // FCM data payloads are always strings; parse safely.
      progress: _parseProgress(data['progress']),
    );
  }

  /// Safely parses progress from FCM data (can be String or num).
  double? _parseProgress(dynamic raw) {
    if (raw == null) return null;
    if (raw is num) return raw.toDouble();
    if (raw is String) return double.tryParse(raw);
    return null;
  }

  /// Returns the current FCM token.
  String? get currentToken => _currentToken;
}