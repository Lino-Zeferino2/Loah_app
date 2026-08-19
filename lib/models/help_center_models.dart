import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a FAQ category (e.g., "Metas", "Tarefas", "Finanças").
///
/// CORRIGIDO: `name` era um único campo (só português). Agora existem
/// `namePt` e `nameEn`, com `name(locale)` a devolver o correto — e um
/// fallback para PT caso o EN ainda não tenha sido preenchido pelo
/// admin, para nunca mostrar um campo vazio.
class FaqCategory {
  final String id;
  final String namePt;
  final String nameEn;
  final String iconName;
  final int order;
  final bool active;
  final DateTime? createdAt;

  const FaqCategory({
    required this.id,
    required this.namePt,
    this.nameEn = '',
    this.iconName = 'help_outline',
    this.order = 0,
    this.active = true,
    this.createdAt,
  });

  /// Devolve o nome no idioma pedido. Se o EN ainda não foi
  /// preenchido pelo admin, cai de volta para o PT em vez de mostrar
  /// vazio.
  String name(String languageCode) {
    if (languageCode == 'en' && nameEn.trim().isNotEmpty) return nameEn;
    return namePt;
  }

  factory FaqCategory.fromMap(String id, Map<String, dynamic> data) {
    return FaqCategory(
      id: id,
      // Compatibilidade: categorias antigas só têm 'name' (sem sufixo).
      // Se 'namePt' não existir ainda, usa 'name' como valor inicial.
      namePt: data['namePt'] as String? ?? data['name'] as String? ?? '',
      nameEn: data['nameEn'] as String? ?? '',
      iconName: data['iconName'] as String? ?? 'help_outline',
      order: data['order'] as int? ?? 0,
      active: data['active'] as bool? ?? true,
      createdAt: (data['createdAt'] as dynamic)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'namePt': namePt,
      'nameEn': nameEn,
      'iconName': iconName,
      'order': order,
      'active': active,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  FaqCategory copyWith({
    String? id,
    String? namePt,
    String? nameEn,
    String? iconName,
    int? order,
    bool? active,
    DateTime? createdAt,
  }) {
    return FaqCategory(
      id: id ?? this.id,
      namePt: namePt ?? this.namePt,
      nameEn: nameEn ?? this.nameEn,
      iconName: iconName ?? this.iconName,
      order: order ?? this.order,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Represents a FAQ article (question + answer).
///
/// CORRIGIDO: `question`/`answer` eram campos únicos (só português).
/// Agora existem versões `Pt`/`En` de cada, com `question(locale)` e
/// `answer(locale)` a devolver o texto certo — com fallback para PT se
/// o EN ainda não tiver sido preenchido.
class FaqArticle {
  final String id;
  final String categoryId;
  final String questionPt;
  final String questionEn;
  final String answerPt;
  final String answerEn;
  final bool popular;
  final int views;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const FaqArticle({
    required this.id,
    required this.categoryId,
    required this.questionPt,
    this.questionEn = '',
    required this.answerPt,
    this.answerEn = '',
    this.popular = false,
    this.views = 0,
    this.createdAt,
    this.updatedAt,
  });

  String question(String languageCode) {
    if (languageCode == 'en' && questionEn.trim().isNotEmpty) return questionEn;
    return questionPt;
  }

  String answer(String languageCode) {
    if (languageCode == 'en' && answerEn.trim().isNotEmpty) return answerEn;
    return answerPt;
  }

  factory FaqArticle.fromMap(String id, Map<String, dynamic> data) {
    return FaqArticle(
      id: id,
      categoryId: data['categoryId'] as String? ?? '',
      // Compatibilidade: artigos antigos só têm 'question'/'answer'
      // (sem sufixo) — usados como valor inicial de *Pt se *Pt ainda
      // não existir.
      questionPt: data['questionPt'] as String? ?? data['question'] as String? ?? '',
      questionEn: data['questionEn'] as String? ?? '',
      answerPt: data['answerPt'] as String? ?? data['answer'] as String? ?? '',
      answerEn: data['answerEn'] as String? ?? '',
      popular: data['popular'] as bool? ?? false,
      views: data['views'] as int? ?? 0,
      createdAt: (data['createdAt'] as dynamic)?.toDate(),
      updatedAt: (data['updatedAt'] as dynamic)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'categoryId': categoryId,
      'questionPt': questionPt,
      'questionEn': questionEn,
      'answerPt': answerPt,
      'answerEn': answerEn,
      'popular': popular,
      'views': views,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': updatedAt ?? FieldValue.serverTimestamp(),
    };
  }

  FaqArticle copyWith({
    String? id,
    String? categoryId,
    String? questionPt,
    String? questionEn,
    String? answerPt,
    String? answerEn,
    bool? popular,
    int? views,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FaqArticle(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      questionPt: questionPt ?? this.questionPt,
      questionEn: questionEn ?? this.questionEn,
      answerPt: answerPt ?? this.answerPt,
      answerEn: answerEn ?? this.answerEn,
      popular: popular ?? this.popular,
      views: views ?? this.views,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Status of a help message from a user.
enum HelpMessageStatus { pendente, emAndamento, resolvido }

/// Represents the app's "About Loah" content stored in Firestore
/// under a single document: appContent/aboutLoah.
///
/// Fields:
///   - terms:        Termos de Uso
///   - privacyPolicy:Política de Privacidade
///   - aboutUs:      Texto "Sobre Nós" exibido na tela AboutLoahScreen
///   - lastUpdatedBy:UID do admin que fez a última atualização
///   - updatedAt:    Timestamp da última atualização
/// Represents the app's "About Loah" content stored in Firestore
/// under a single document: appContent/aboutLoah.
///
/// CORRIGIDO: terms/privacyPolicy/aboutUs eram campos únicos (só
/// português). Agora existem versões Pt/En de cada, com
/// terms(locale)/privacyPolicy(locale)/aboutUs(locale) a devolver o
/// texto certo — com fallback para PT se o EN ainda não tiver sido
/// preenchido pelo admin, tal como em FaqCategory/FaqArticle.
class AboutLoahContent {
  final String termsPt;
  final String termsEn;
  final String privacyPolicyPt;
  final String privacyPolicyEn;
  final String aboutUsPt;
  final String aboutUsEn;
  final String lastUpdatedBy;
  final DateTime? updatedAt;

  const AboutLoahContent({
    this.termsPt = '',
    this.termsEn = '',
    this.privacyPolicyPt = '',
    this.privacyPolicyEn = '',
    this.aboutUsPt = '',
    this.aboutUsEn = '',
    this.lastUpdatedBy = '',
    this.updatedAt,
  });

  /// Devolve os Termos no idioma pedido. Se o EN ainda não foi
  /// preenchido pelo admin, cai de volta para o PT em vez de mostrar
  /// vazio.
  String terms(String languageCode) {
    if (languageCode == 'en' && termsEn.trim().isNotEmpty) return termsEn;
    return termsPt;
  }

  /// Devolve a Política de Privacidade no idioma pedido, com o mesmo
  /// fallback para PT.
  String privacyPolicy(String languageCode) {
    if (languageCode == 'en' && privacyPolicyEn.trim().isNotEmpty) {
      return privacyPolicyEn;
    }
    return privacyPolicyPt;
  }

  /// Devolve o texto "Sobre Nós" no idioma pedido, com o mesmo
  /// fallback para PT.
  String aboutUs(String languageCode) {
    if (languageCode == 'en' && aboutUsEn.trim().isNotEmpty) return aboutUsEn;
    return aboutUsPt;
  }

  factory AboutLoahContent.fromMap(Map<String, dynamic> data) {
    return AboutLoahContent(
      // Compatibilidade: documentos antigos só têm 'terms'/'privacyPolicy'/
      // 'aboutUs' (sem sufixo) — usados como valor inicial de *Pt se
      // *Pt ainda não existir.
      termsPt: data['termsPt'] as String? ?? data['terms'] as String? ?? '',
      termsEn: data['termsEn'] as String? ?? '',
      privacyPolicyPt: data['privacyPolicyPt'] as String? ??
          data['privacyPolicy'] as String? ??
          '',
      privacyPolicyEn: data['privacyPolicyEn'] as String? ?? '',
      aboutUsPt:
          data['aboutUsPt'] as String? ?? data['aboutUs'] as String? ?? '',
      aboutUsEn: data['aboutUsEn'] as String? ?? '',
      lastUpdatedBy: data['lastUpdatedBy'] as String? ?? '',
      updatedAt: (data['updatedAt'] as dynamic)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'termsPt': termsPt,
      'termsEn': termsEn,
      'privacyPolicyPt': privacyPolicyPt,
      'privacyPolicyEn': privacyPolicyEn,
      'aboutUsPt': aboutUsPt,
      'aboutUsEn': aboutUsEn,
      'lastUpdatedBy': lastUpdatedBy,
      'updatedAt': updatedAt ?? FieldValue.serverTimestamp(),
    };
  }

  AboutLoahContent copyWith({
    String? termsPt,
    String? termsEn,
    String? privacyPolicyPt,
    String? privacyPolicyEn,
    String? aboutUsPt,
    String? aboutUsEn,
    String? lastUpdatedBy,
    DateTime? updatedAt,
  }) {
    return AboutLoahContent(
      termsPt: termsPt ?? this.termsPt,
      termsEn: termsEn ?? this.termsEn,
      privacyPolicyPt: privacyPolicyPt ?? this.privacyPolicyPt,
      privacyPolicyEn: privacyPolicyEn ?? this.privacyPolicyEn,
      aboutUsPt: aboutUsPt ?? this.aboutUsPt,
      aboutUsEn: aboutUsEn ?? this.aboutUsEn,
      lastUpdatedBy: lastUpdatedBy ?? this.lastUpdatedBy,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
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
  final String? userFollowUp;
  final DateTime? userFollowUpAt;
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
    this.userFollowUp,
    this.userFollowUpAt,
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
      userFollowUp: data['userFollowUp'] as String?,
      userFollowUpAt: (data['userFollowUpAt'] as dynamic)?.toDate(),
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
      'userFollowUp': userFollowUp,
      'userFollowUpAt': userFollowUpAt ?? FieldValue.serverTimestamp(),
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
    String? userFollowUp,
    DateTime? userFollowUpAt,
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
      userFollowUp: userFollowUp ?? this.userFollowUp,
      userFollowUpAt: userFollowUpAt ?? this.userFollowUpAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}