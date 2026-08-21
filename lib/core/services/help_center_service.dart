import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loah_app/models/help_center_models.dart';

/// Service to manage Help Center content (FAQ categories, articles,
/// and user support messages) in Firestore.
class HelpCenterService {
  static final HelpCenterService _instance = HelpCenterService._internal();
  factory HelpCenterService() => _instance;
  HelpCenterService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ────────────────────────────────────────────────────────────────
  //  Collections
  // ────────────────────────────────────────────────────────────────

  CollectionReference get _categories =>
      _firestore.collection('helpCenterCategories');

  CollectionReference get _articles =>
      _firestore.collection('helpCenterArticles');

  CollectionReference get _messages =>
      _firestore.collection('helpCenterMessages');

  // ════════════════════════════════════════════════════════════════
  //  APP CONTENT – About Loah (terms, privacy, about us)
  // ════════════════════════════════════════════════════════════════

  DocumentReference get _appContentDoc =>
      _firestore.collection('appContent').doc('aboutLoah');

  /// Fetch the AboutLoahContent document from Firestore.
  Future<AboutLoahContent> getAboutLoahContent() async {
    final snap = await _appContentDoc.get();
    if (snap.exists) {
      return AboutLoahContent.fromMap(snap.data() as Map<String, dynamic>);
    }
    return const AboutLoahContent();
  }

  /// Save (create or update) the AboutLoahContent document.
  Future<void> updateAboutLoahContent(AboutLoahContent content) async {
    await _appContentDoc.set(content.toMap(), SetOptions(merge: true));
  }

  // ════════════════════════════════════════════════════════════════
  //  CATEGORIES
  // ════════════════════════════════════════════════════════════════

  /// Stream all categories ordered by [order] field.
  Stream<QuerySnapshot> getCategoriesStream() {
    return _categories.orderBy('order').snapshots();
  }

  /// Fetch all active categories once.
  Future<List<FaqCategory>> getActiveCategories() async {
    final snap = await _categories
        .where('active', isEqualTo: true)
        .orderBy('order')
        .get();
    return snap.docs.map((doc) {
      return FaqCategory.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    }).toList();
  }

  /// Add a new category.
  Future<void> addCategory(FaqCategory category) async {
    await _categories.add(category.toMap());
  }

  /// Update an existing category.
  Future<void> updateCategory(FaqCategory category) async {
    await _categories.doc(category.id).update(category.toMap());
  }

  /// Delete a category.
  Future<void> deleteCategory(String categoryId) async {
    await _categories.doc(categoryId).delete();
  }

  // ════════════════════════════════════════════════════════════════
  //  ARTICLES (FAQs)
  // ════════════════════════════════════════════════════════════════

  /// Stream all articles, newest first.
  Stream<QuerySnapshot> getArticlesStream() {
    return _articles.orderBy('createdAt', descending: true).snapshots();
  }

  /// Stream articles filtered by category.
  Stream<QuerySnapshot> getArticlesByCategoryStream(String categoryId) {
    return _articles
        .where('categoryId', isEqualTo: categoryId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Get all popular articles (for the user-facing Help Center).
  Future<List<FaqArticle>> getPopularArticles() async {
    final snap = await _articles
        .where('popular', isEqualTo: true)
        .orderBy('views', descending: true)
        .limit(10)
        .get();
    return snap.docs.map((doc) {
      return FaqArticle.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    }).toList();
  }

  /// Search articles by question or answer text, in both languages.
  Future<List<FaqArticle>> searchArticles(String query) async {
    if (query.trim().isEmpty) return [];

    final lowerQuery = query.toLowerCase();
    final snap = await _articles.get();
    final results = snap.docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final questionPt = (data['questionPt'] as String? ?? data['question'] as String? ?? '').toLowerCase();
      final questionEn = (data['questionEn'] as String? ?? '').toLowerCase();
      final answerPt = (data['answerPt'] as String? ?? data['answer'] as String? ?? '').toLowerCase();
      final answerEn = (data['answerEn'] as String? ?? '').toLowerCase();
      return questionPt.contains(lowerQuery) ||
          questionEn.contains(lowerQuery) ||
          answerPt.contains(lowerQuery) ||
          answerEn.contains(lowerQuery);
    }).toList();

    return results.map((doc) {
      return FaqArticle.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    }).toList();
  }

  /// Get articles for a specific category (once, not stream).
  Future<List<FaqArticle>> getArticlesByCategory(String categoryId) async {
    final snap = await _articles
        .where('categoryId', isEqualTo: categoryId)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map((doc) {
      return FaqArticle.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    }).toList();
  }

  /// Fetch all articles (once, not streaming), newest first.
  Future<List<FaqArticle>> getAllArticles() async {
    final snap = await _articles.orderBy('createdAt', descending: true).get();
    return snap.docs.map((doc) {
      return FaqArticle.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    }).toList();
  }

  /// Add a new article.
  Future<void> addArticle(FaqArticle article) async {
    await _articles.add(article.toMap());
  }

  /// Update an existing article.
  Future<void> updateArticle(FaqArticle article) async {
    await _articles.doc(article.id).update(article.toMap());
  }

  /// Delete an article.
  Future<void> deleteArticle(String articleId) async {
    await _articles.doc(articleId).delete();
  }

  /// Increment the view count for an article.
  Future<void> incrementArticleViews(String articleId) async {
    await _articles.doc(articleId).update({
      'views': FieldValue.increment(1),
    });
  }

  // ════════════════════════════════════════════════════════════════
  //  USER MESSAGES
  // ════════════════════════════════════════════════════════════════

  /// Stream all messages, newest first.
  Stream<QuerySnapshot> getMessagesStream() {
    return _messages.orderBy('createdAt', descending: true).snapshots();
  }

  /// Stream messages filtered by status.
  Stream<QuerySnapshot> getMessagesByStatusStream(HelpMessageStatus status) {
    return _messages
        .where('status', isEqualTo: status.name)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Get messages for a specific user (fire-and-forget, newest first).
  Future<List<HelpMessage>> getUserMessages(String userId) async {
    final snap = await _messages
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map((doc) {
      return HelpMessage.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    }).toList();
  }

  /// Add a user follow-up (reply) to an existing message.
  Future<void> addUserFollowUp(String messageId, String followUp) async {
    await _messages.doc(messageId).update({
      'userFollowUp': followUp,
      'userFollowUpAt': FieldValue.serverTimestamp(),
      'read': false,
      'status': HelpMessageStatus.emAndamento.name,
    });
  }

  /// Send a new message (from a user).
  Future<void> sendMessage(HelpMessage message) async {
    await _messages.add(message.toMap());
  }

  /// Update a message (admin: change status, add reply, mark as read).
  Future<void> updateMessage(HelpMessage message) async {
    await _messages.doc(message.id).update(message.toMap());
  }

  /// Mark a message as read.
  Future<void> markMessageAsRead(String messageId) async {
    await _messages.doc(messageId).update({
      'read': true,
    });
  }

  /// Update message status.
  Future<void> updateMessageStatus(
      String messageId, HelpMessageStatus status) async {
    await _messages.doc(messageId).update({
      'status': status.name,
    });
  }

    /// Add admin reply to a message.
  ///
  /// CORRIGIDO: notificação criada com titleKey/messageKey/params em
  /// vez de texto final — o cliente traduz na hora com AppLocales.
  Future<void> replyToMessage(String messageId, String reply) async {
    final snap = await _messages.doc(messageId).get();
    final data = snap.data() as Map<String, dynamic>?;
    final userId = data?['userId'] as String?;
    final subject = data?['subject'] as String? ?? '';

    await _messages.doc(messageId).update({
      'adminReply': reply,
      'adminReplyAt': FieldValue.serverTimestamp(),
      'status': HelpMessageStatus.resolvido.name,
    });

    if (userId == null || userId.isEmpty) return;

    final now = DateTime.now();
    final notificationId =
        'notif_help_reply_${messageId}_${now.millisecondsSinceEpoch}';
    final hasSubject = subject.isNotEmpty;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(notificationId)
        .set({
      'category': 'system',
      'title': 'Central de Ajuda',
      'message': hasSubject
          ? 'A sua mensagem "$subject" foi respondida pelo suporte.'
          : 'A sua mensagem foi respondida pelo suporte.',
      'timestamp': Timestamp.fromDate(now),
      'relatedId': messageId,
      'isRead': false,
      'titleKey': 'notif_title_central_ajuda',
      'messageKey': hasSubject
          ? 'notif_msg_support_replied_subject'
          : 'notif_msg_support_replied_generic',
      'params': hasSubject ? {'subject': subject} : null,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
  /// Delete a message.
  Future<void> deleteMessage(String messageId) async {
    await _messages.doc(messageId).delete();
  }
}