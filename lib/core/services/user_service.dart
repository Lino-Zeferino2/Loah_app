import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Serviço para gerenciar dados do usuário no Firestore.
class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Coleção onde os dados dos usuários são armazenados.
  CollectionReference get _usersCollection => _firestore.collection('users');

  /// Salva os dados básicos do usuário no Firestore após o cadastro.
  Future<void> createUserProfile({
    required String uid,
    required String name,
    required String email,
    String? phoneNumber,
    String dialCode = '+351',
  }) async {
    await _usersCollection.doc(uid).set({
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber ?? '',
      'dialCode': dialCode,
      'role': 'user', // Padrão: usuário normal. Para tornar admin, alterar manualmente no Firestore.
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Atualiza o nome de exibição do usuário no Firebase Auth.
  Future<void> updateDisplayName(String displayName) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.updateDisplayName(displayName);
      await user.reload();
    }
  }

  /// Busca os dados de um usuário pelo UID.
  Future<DocumentSnapshot> getUserProfile(String uid) async {
    return await _usersCollection.doc(uid).get();
  }

  /// Atualiza campos específicos no perfil do usuário.
  Future<void> updateUserProfile({
    required String uid,
    Map<String, dynamic>? data,
  }) async {
    if (data != null && data.isNotEmpty) {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _usersCollection.doc(uid).update(data);
    }
  }
}
