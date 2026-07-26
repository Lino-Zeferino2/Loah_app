import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
}

