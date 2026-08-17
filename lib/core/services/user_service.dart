import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

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

      // ── Subscrição (preparado para planos pagos futuros) ──
      'subscriptionTier': 'free',        // 'free' | 'premium' — string para suportar múltiplos tiers no futuro (ex: tier de IA)
      'subscriptionExpiresAt': null,     // preenchido quando houver subscrição ativa
      'revenueCatUserId': null,          // preenchido quando o RevenueCat for integrado

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

  // ─── Exclusão de conta (GDPR/LGPD) ────────────────────────────

  /// Apaga todos os documentos das subcoleções do utilizador e o próprio
  /// documento em `/users/{uid}`. Subcoleções apagadas: metas, tarefas,
  /// transações, contas, ativos, orçamentos, recorrentes, contatos,
  /// notificações e tokens FCM.
  Future<void> deleteUserData(String uid) async {
    final userRef = _firestore.collection('users').doc(uid);

    const subcollections = [
      'goals',
      'tasks',
      'transactions',
      'accounts',
      'assets',
      'budgets',
      'recurringTransactions',
      'contacts',
      'notifications',
      'fcmTokens',
    ];

    for (final sub in subcollections) {
      try {
        final snap = await userRef.collection(sub).get();
        if (snap.docs.isEmpty) continue;
        final batch = _firestore.batch();
        for (final doc in snap.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      } catch (e) {
        debugPrint('[UserService] Erro ao apagar coleção "$sub": $e');
      }
    }

    // Apaga o documento do utilizador.
    await userRef.delete();
  }

  /// Apaga as fotos de perfil do utilizador no Firebase Storage.
  Future<void> _deleteProfilePhotos(String uid) async {
    try {
      final storageRef = FirebaseStorage.instance.ref('profilePhotos/$uid');
      final result = await storageRef.listAll();
      for (final item in result.items) {
        await item.delete();
      }
      for (final prefix in result.prefixes) {
        final nested = await prefix.listAll();
        for (final item in nested.items) {
          await item.delete();
        }
      }
    } catch (e) {
      debugPrint('[UserService] Erro ao apagar fotos de perfil: $e');
    }
  }

  /// Apaga todo o conteúdo do utilizador (fotos no Storage + dados no
  /// Firestore), mantendo a sessão do Firebase Auth ainda ativa.
  ///
  /// A conta do Firebase Auth deve ser apagada depois, via
  /// `AuthService().deleteAccount()`.
  Future<void> deleteUserContent() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Nenhum utilizador autenticado');
    }
    await _deleteProfilePhotos(user.uid);
    await deleteUserData(user.uid);
  }
}
