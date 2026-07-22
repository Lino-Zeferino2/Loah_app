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

  CollectionReference get _contactsCollection =>
      _firestore.collection('users').doc(_userId).collection('contacts');

  /// Retorna um [Stream] de [QuerySnapshot] para ser usado com
  /// [StreamBuilder] na tela de contactos.
  Stream<QuerySnapshot> getContactsStream() {
    return _contactsCollection.orderBy('name').snapshots();
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
    final data = _contactToMap(contact);
    data['createdAt'] = FieldValue.serverTimestamp();
    await _contactsCollection.doc(contact.id).set(data);
  }

  /// Atualiza um contacto existente.
  Future<void> updateContact(ContactModel contact) async {
    await _contactsCollection.doc(contact.id).update(_contactToMap(contact));
  }

  /// Apaga um contacto.
  Future<void> deleteContact(String contactId) async {
    await _contactsCollection.doc(contactId).delete();
  }

  /// Busca um único contacto pelo ID.
  Future<ContactModel?> getContact(String contactId) async {
    final doc = await _contactsCollection.doc(contactId).get();
    if (!doc.exists) return null;
    return _fromDocument(doc);
  }
}

