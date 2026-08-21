import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationCategory { contacts, tasks, goals, finance, system }

/// One notification card stored in Firestore under
/// /users/{userId}/notifications/{notificationId}.
///
/// Notifications are generated server-side (Cloud Functions) or
/// client-side (NotificationScheduler) and written to Firestore,
/// then delivered to the device via FCM push.
///
/// CORRIGIDO: title/message eram sempre texto final já traduzido (em
/// português) no momento da criação — por isso nunca mudavam com o
/// idioma da app. Agora existem titleKey/messageKey/params opcionais:
/// quando presentes, a UI (NotificationCard) monta o texto na hora,
/// no idioma atual, usando AppLocales. title/message continuam a
/// existir como fallback — para notificações antigas já gravadas
/// antes desta mudança, e como texto de reserva caso a chave não
/// seja encontrada.
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

  /// NOVO: chave de tradução para o título (ex: 'notif_cat_financas').
  /// Se presente, tem prioridade sobre [title].
  final String? titleKey;

  /// NOVO: chave de tradução para a mensagem (ex:
  /// 'notif_msg_task_upcoming_hours'). Se presente, tem prioridade
  /// sobre [message]. O texto traduzido pode conter placeholders tipo
  /// {name}, {days}, {pct} — substituídos a partir de [params].
  final String? messageKey;

  /// NOVO: parâmetros para preencher os placeholders de [messageKey],
  /// ex: {'name': 'Maria', 'days': '5'}.
  final Map<String, String>? params;

  const AppNotification({
    required this.id,
    required this.category,
    required this.title,
    required this.message,
    required this.timestamp,
    this.relatedId,
    this.progress,
    this.isRead = false,
    this.titleKey,
    this.messageKey,
    this.params,
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
    String? titleKey,
    String? messageKey,
    Map<String, String>? params,
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
      titleKey: titleKey ?? this.titleKey,
      messageKey: messageKey ?? this.messageKey,
      params: params ?? this.params,
    );
  }

  /// Converts a Firestore [DocumentSnapshot] into an [AppNotification].
  factory AppNotification.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // NOVO: params vem do Firestore como Map<String, dynamic> — cada
    // valor é convertido para String, já que é sempre usado como
    // substituição de texto num placeholder.
    Map<String, String>? parsedParams;
    final rawParams = data['params'];
    if (rawParams is Map) {
      parsedParams = rawParams.map(
        (key, value) => MapEntry(key.toString(), value.toString()),
      );
    }

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
      titleKey: data['titleKey'] as String?,
      messageKey: data['messageKey'] as String?,
      params: parsedParams,
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
      'titleKey': titleKey,
      'messageKey': messageKey,
      'params': params,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}