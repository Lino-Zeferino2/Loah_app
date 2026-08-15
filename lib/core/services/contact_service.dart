import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../models/contact_model.dart';

/// Serviço para gerenciar contactos no Firestore.
/// Cada contacto fica em /users/{userId}/contacts/{contactId}.
class ContactService {
  static final ContactService _instance = ContactService._internal();
  factory ContactService() => _instance;
  ContactService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  /// Retorna a referência à coleção de contactos, ou null se o
  /// utilizador não estiver autenticado.
  CollectionReference? _getContactsCollection() {
    final uid = _userId;
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid).collection('contacts');
  }

  /// Retorna um [Stream] de [QuerySnapshot] para ser usado com
  /// [StreamBuilder] na tela de contactos.
  /// Devolve um stream vazio se não houver sessão autenticada.
  Stream<QuerySnapshot> getContactsStream() {
    final col = _getContactsCollection();
    if (col == null) return const Stream.empty();
    return col.orderBy('name').snapshots();
  }

  /// Converte um [DocumentSnapshot] para [ContactModel].
  ContactModel _fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ContactModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'],
      phone: data['phone'],
      relationshipTag: data['relationshipTag'] ?? 'Amigo',
      avatarUrl: data['avatarUrl'],
      isFavorite: data['isFavorite'] ?? false,
      desiredContactFrequencyDays: data['desiredContactFrequencyDays'],
      interactions: _parseInteractions(data['interactions']),
    );
  }

  List<ContactInteraction> _parseInteractions(dynamic raw) {
    if (raw == null || raw is! List) return [];
    return raw.map((e) {
      final map = e as Map<String, dynamic>;
      return ContactInteraction(
        date: (map['date'] as Timestamp).toDate(),
        type: InteractionType.values.firstWhere(
          (t) => t.name == map['type'],
          orElse: () => InteractionType.other,
        ),
        note: map['note'],
      );
    }).toList();
  }

  Map<String, dynamic> _interactionToMap(ContactInteraction interaction) {
    return {
      'date': Timestamp.fromDate(interaction.date),
      'type': interaction.type.name,
      'note': interaction.note,
    };
  }

  Map<String, dynamic> _contactToMap(ContactModel contact) {
    return {
      'name': contact.name,
      'email': contact.email,
      'phone': contact.phone,
      'relationshipTag': contact.relationshipTag,
      'avatarUrl': contact.avatarUrl,
      'isFavorite': contact.isFavorite,
      'desiredContactFrequencyDays': contact.desiredContactFrequencyDays,
      'interactions': contact.interactions.map(_interactionToMap).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Adiciona um novo contacto ao Firestore.
  /// Se [contactId] for fornecido, usa esse ID; caso contrário, gera um
  /// automaticamente.
  Future<void> addContact(ContactModel contact) async {
    final col = _getContactsCollection();
    if (col == null) return;
    final data = _contactToMap(contact);
    data['createdAt'] = FieldValue.serverTimestamp();
    await col.doc(contact.id).set(data);
  }

  /// Atualiza um contacto existente.
  Future<void> updateContact(ContactModel contact) async {
    final col = _getContactsCollection();
    if (col == null) return;
    await col.doc(contact.id).update(_contactToMap(contact));
  }

  /// Apaga um contacto.
  Future<void> deleteContact(String contactId) async {
    final col = _getContactsCollection();
    if (col == null) return;
    await col.doc(contactId).delete();
  }

/// Busca um único contacto pelo ID.
  Future<ContactModel?> getContact(String contactId) async {
    final col = _getContactsCollection();
    if (col == null) return null;
    final doc = await col.doc(contactId).get();
    if (!doc.exists) return null;
    return _fromDocument(doc);
  }

  // ────────────────────────────────────────────────────────────────
  //  Avatar / Foto de perfil (Firebase Storage)
  // ────────────────────────────────────────────────────────────────

/// Faz o upload de uma foto de perfil para Firebase Storage e
  /// devolve a URL de download.
  ///
  /// O ficheiro fica em `profilePhotos/{userId}/{contactId}_{timestamp}.jpg` —
  /// um caminho plano (2 segmentos) que respeita a storage rule
  /// `profilePhotos/{userId}/{fileName}`, e inclui o contactId no nome
  /// para não colidir com a foto de perfil do utilizador. Devolve `null`
  /// se [file] for `null`.
  Future<String?> uploadAvatar(File? file, {required String contactId}) async {
    final uid = _userId;
    if (file == null || uid == null) return null;

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final ref = FirebaseStorage.instance
        .ref('profilePhotos/$uid/${contactId}_$timestamp.jpg');
    final uploadTask = ref.putFile(file);
    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  /// Apaga uma foto de perfil do Firebase Storage a partir da URL.
  /// Ignora erros silenciosamente (o ficheiro pode já não existir).
  Future<void> deleteAvatar(String? avatarUrl) async {
    if (avatarUrl == null || avatarUrl.isEmpty) return;
    try {
      final ref = FirebaseStorage.instance.refFromURL(avatarUrl);
      await ref.delete();
    } catch (_) {
      // Ficheiro pode já ter sido removido — ignora.
    }
  }

/// Gera um ID único de documento sem gravar nada ainda — usar antes
  /// de importar vários contactos de uma vez, para evitar colisão de
  /// IDs (mesmo raciocínio do padrão antigo em outros serviços).
  String newContactId() {
    final col = _getContactsCollection();
    return col?.doc().id ?? 'contact_${DateTime.now().microsecondsSinceEpoch}';
  }

  /// Cria vários contactos de uma vez, de forma atômica: se algum
  /// falhar, nenhum é gravado. Usado na importação de contactos do
  /// telemóvel.
  Future<void> addContactsBatch(List<ContactModel> contacts) async {
    final col = _getContactsCollection();
    if (col == null || contacts.isEmpty) return;
    final batch = _firestore.batch();
    for (final contact in contacts) {
      final data = _contactToMap(contact);
      data['createdAt'] = FieldValue.serverTimestamp();
      batch.set(col.doc(contact.id), data);
    }
    await batch.commit();
  }


}

