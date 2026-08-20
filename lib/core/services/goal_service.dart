import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/goal_model.dart';

/// Serviço para gerenciar metas no Firestore.
/// Cada meta fica em /users/{userId}/goals/{goalId}.
class GoalService {
  static final GoalService _instance = GoalService._internal();
  factory GoalService() => _instance;
  GoalService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  /// Retorna a referência à coleção de metas, ou null se o utilizador
  /// não estiver autenticado.
  CollectionReference? _getGoalsCollection() {
    final uid = _userId;
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid).collection('goals');
  }

  // NOVO: upload da foto da meta para o Firebase Storage — sem isto,
  // o caminho local do image_picker (tmp/...) era gravado direto no
  // Firestore, e deixava de existir entre sessões da app, causando
  // crash toda vez que a Dashboard tentava desenhar a imagem.
  Future<String> uploadGoalImage(File file, {required String goalId}) async {
    final uid = _userId;
    if (uid == null) throw Exception('Utilizador não autenticado');
    final ref = FirebaseStorage.instance
        .ref('users/$uid/goalImages/$goalId.jpg');
    await ref.putFile(file);
    return ref.getDownloadURL();
  }

  // NOVO: apaga a foto antiga do Storage quando a meta troca de foto
  // ou remove a foto — evita acumular ficheiros órfãos.
  Future<void> deleteGoalImage(String? imageUrl) async {
    if (imageUrl == null || !imageUrl.startsWith('http')) return;
    try {
      await FirebaseStorage.instance.refFromURL(imageUrl).delete();
    } catch (_) {
      // Ignora erros de limpeza (ex: já apagado, ou URL inválido) —
      // não deve impedir o resto da operação.
    }
  }

  /// Retorna um [Stream] de [QuerySnapshot] para ser usado com
  /// [StreamBuilder] na tela de metas.
  /// Devolve um stream vazio se não houver sessão autenticada.
  Stream<QuerySnapshot> getGoalsStream() {
    final col = _getGoalsCollection();
    if (col == null) return const Stream.empty();
    return col.orderBy('createdAt', descending: true).snapshots();
  }

  /// Converte um [DocumentSnapshot] para [GoalModel].
  GoalModel _fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GoalModel(
      id: doc.id,
      title: data['title'] ?? '',
      category: data['category'] ?? 'Pessoal',
      term: data['term'] != null
          ? GoalTerm.values.firstWhere(
              (t) => t.name == data['term'],
              orElse: () => GoalTerm.curtoPrazo,
            )
          : GoalTerm.curtoPrazo,
      progressMode: data['progressMode'] != null
          ? GoalProgressMode.values.firstWhere(
              (m) => m.name == data['progressMode'],
              orElse: () => GoalProgressMode.manualValue,
            )
          : GoalProgressMode.manualValue,
      current: (data['current'] as num?)?.toDouble(),
      target: (data['target'] as num?)?.toDouble(),
      imageAsset: data['imageAsset'],
      description: data['description'],
      targetDate: data['targetDate'] != null
          ? (data['targetDate'] as Timestamp).toDate()
          : null,
      progressColor: data['progressColor'] != null
          ? Color(int.parse(data['progressColor']))
          : Colors.blue,
      remainingLabel: data['remainingLabel'],
    );
  }

  Map<String, dynamic> _goalToMap(GoalModel goal) {
    return {
      'title': goal.title,
      'category': goal.category,
      'term': goal.term.name,
      'progressMode': goal.progressMode.name,
      'current': goal.current,
      'target': goal.target,
      'imageAsset': goal.imageAsset,
      'description': goal.description,
      'targetDate': goal.targetDate != null
          ? Timestamp.fromDate(goal.targetDate!)
          : null,
      'progressColor': goal.progressColor.toARGB32().toString(),
      'remainingLabel': goal.remainingLabel,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Adiciona uma nova meta ao Firestore.
  Future<void> addGoal(GoalModel goal) async {
    final col = _getGoalsCollection();
    if (col == null) return;
    final data = _goalToMap(goal);
    data['createdAt'] = FieldValue.serverTimestamp();
    await col.doc(goal.id).set(data);
  }

  /// Atualiza uma meta existente.
  Future<void> updateGoal(GoalModel goal) async {
    final col = _getGoalsCollection();
    if (col == null) return;
    await col.doc(goal.id).update(_goalToMap(goal));
  }

  /// Apaga uma meta.
  Future<void> deleteGoal(String goalId) async {
    final col = _getGoalsCollection();
    if (col == null) return;
    await col.doc(goalId).delete();
  }

  /// Busca uma única meta pelo ID.
  Future<GoalModel?> getGoal(String goalId) async {
    final col = _getGoalsCollection();
    if (col == null) return null;
    final doc = await col.doc(goalId).get();
    if (!doc.exists) return null;
    return _fromDocument(doc);
  }
}