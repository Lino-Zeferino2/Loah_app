import 'package:cloud_firestore/cloud_firestore.dart';
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

  CollectionReference get _goalsCollection =>
      _firestore.collection('users').doc(_userId).collection('goals');

  /// Retorna um [Stream] de [QuerySnapshot] para ser usado com
  /// [StreamBuilder] na tela de metas.
  Stream<QuerySnapshot> getGoalsStream() {
    return _goalsCollection.orderBy('createdAt', descending: true).snapshots();
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
    final data = _goalToMap(goal);
    data['createdAt'] = FieldValue.serverTimestamp();
    await _goalsCollection.doc(goal.id).set(data);
  }

  /// Atualiza uma meta existente.
  Future<void> updateGoal(GoalModel goal) async {
    await _goalsCollection.doc(goal.id).update(_goalToMap(goal));
  }

  /// Apaga uma meta.
  Future<void> deleteGoal(String goalId) async {
    await _goalsCollection.doc(goalId).delete();
  }

  /// Busca uma única meta pelo ID.
  Future<GoalModel?> getGoal(String goalId) async {
    final doc = await _goalsCollection.doc(goalId).get();
    if (!doc.exists) return null;
    return _fromDocument(doc);
  }
}
