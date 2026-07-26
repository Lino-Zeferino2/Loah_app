import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a FAQ category (e.g., "Metas", "Tarefas", "Finanças").
class FaqCategory {
  final String id;
  final String name;
  final String iconName;
  final int order;
  final bool active;
  final DateTime? createdAt;

  const FaqCategory({
    required this.id,
    required this.name,
    this.iconName = 'help_outline',
    this.order = 0,
    this.active = true,
    this.createdAt,
  });

  factory FaqCategory.fromMap(String id, Map<String, dynamic> data) {
    return FaqCategory(
      id: id,
      name: data['name'] as String? ?? '',
      iconName: data['iconName'] as String? ?? 'help_outline',
      order: data['order'] as int? ?? 0,
      active: data['active'] as bool? ?? true,
      createdAt: (data['createdAt'] as dynamic)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'iconName': iconName,
      'order': order,
      'active': active,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  FaqCategory copyWith({
    String? id,
    String? name,
    String? iconName,
    int? order,
    bool? active,
    DateTime? createdAt,
  }) {
    return FaqCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      order: order ?? this.order,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Represents a FAQ article (question + answer).
class FaqArticle {
  final String id;
  final String categoryId;
  final String question;
  final String answer;
  final bool popular;
  final int views;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const FaqArticle({
    required this.id,
    required this.categoryId,
    required this.question,
    required this.answer,
    this.popular = false,
    this.views = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory FaqArticle.fromMap(String id, Map<String, dynamic> data) {
    return FaqArticle(
      id: id,
      categoryId: data['categoryId'] as String? ?? '',
      question: data['question'] as String? ?? '',
      answer: data['answer'] as String? ?? '',
      popular: data['popular'] as bool? ?? false,
      views: data['views'] as int? ?? 0,
      createdAt: (data['createdAt'] as dynamic)?.toDate(),
      updatedAt: (data['updatedAt'] as dynamic)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'categoryId': categoryId,
      'question': question,
      'answer': answer,
      'popular': popular,
      'views': views,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': updatedAt ?? FieldValue.serverTimestamp(),
    };
  }

  FaqArticle copyWith({
    String? id,
    String? categoryId,
    String? question,
    String? answer,
    bool? popular,
    int? views,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FaqArticle(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      popular: popular ?? this.popular,
      views: views ?? this.views,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Status of a help message from a user.
enum HelpMessageStatus { pendente, emAndamento, resolvido }

/// Represents a message sent by a user asking for help.
class HelpMessage {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String subject;
  final String message;
  final String category;
  final HelpMessageStatus status;
  final bool read;
  final String? adminReply;
  final DateTime? adminReplyAt;
  final DateTime? createdAt;

  const HelpMessage({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.subject,
    required this.message,
    this.category = 'geral',
    this.status = HelpMessageStatus.pendente,
    this.read = false,
    this.adminReply,
    this.adminReplyAt,
    this.createdAt,
  });

  factory HelpMessage.fromMap(String id, Map<String, dynamic> data) {
    return HelpMessage(
      id: id,
      userId: data['userId'] as String? ?? '',
      userName: data['userName'] as String? ?? '',
      userEmail: data['userEmail'] as String? ?? '',
      subject: data['subject'] as String? ?? '',
      message: data['message'] as String? ?? '',
      category: data['category'] as String? ?? 'geral',
      status: HelpMessageStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => HelpMessageStatus.pendente,
      ),
      read: data['read'] as bool? ?? false,
      adminReply: data['adminReply'] as String?,
      adminReplyAt: (data['adminReplyAt'] as dynamic)?.toDate(),
      createdAt: (data['createdAt'] as dynamic)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'subject': subject,
      'message': message,
      'category': category,
      'status': status.name,
      'read': read,
      'adminReply': adminReply,
      'adminReplyAt': adminReplyAt ?? FieldValue.serverTimestamp(),
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  HelpMessage copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userEmail,
    String? subject,
    String? message,
    String? category,
    HelpMessageStatus? status,
    bool? read,
    String? adminReply,
    DateTime? adminReplyAt,
    DateTime? createdAt,
  }) {
    return HelpMessage(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      subject: subject ?? this.subject,
      message: message ?? this.message,
      category: category ?? this.category,
      status: status ?? this.status,
      read: read ?? this.read,
      adminReply: adminReply ?? this.adminReply,
      adminReplyAt: adminReplyAt ?? this.adminReplyAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

