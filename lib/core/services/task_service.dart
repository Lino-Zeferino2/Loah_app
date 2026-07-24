import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/task_model.dart';

/// Serviço para gerenciar tarefas no Firestore.
/// Cada tarefa fica em /users/{userId}/tasks/{taskId}.
class TaskService {
  static final TaskService _instance = TaskService._internal();
  factory TaskService() => _instance;
  TaskService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  CollectionReference get _tasksCollection =>
      _firestore.collection('users').doc(_userId).collection('tasks');

  /// Retorna um [Stream] de [QuerySnapshot] para ser usado com
  /// [StreamBuilder] nas telas de tarefas.
  Stream<QuerySnapshot> getTasksStream() {
    return _tasksCollection.orderBy('createdAt', descending: false).snapshots();
  }

  /// Converte um [DocumentSnapshot] para [TaskModel].
  TaskModel _fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TaskModel(
      id: doc.id,
      title: data['title'] ?? '',
      subtitle: data['subtitle'],
      tag: data['tag'],
      dueLabel: data['dueLabel'],
      priority: data['priority'] != null
          ? TaskPriority.values.firstWhere(
              (p) => p.name == data['priority'],
              orElse: () => TaskPriority.baixa,
            )
          : null,
      isDone: data['isDone'] ?? false,
      goalId: data['goalId'],
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
      description: data['description'],
      dueDate: data['dueDate'] != null
          ? (data['dueDate'] as Timestamp).toDate()
          : null,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      status: data['status'] != null
          ? TaskStatus.values.firstWhere(
              (s) => s.name == data['status'],
              orElse: () => TaskStatus.pendente,
            )
          : null,
    );
  }

  Map<String, dynamic> _taskToMap(TaskModel task) {
    return {
      'title': task.title,
      'subtitle': task.subtitle,
      'tag': task.tag,
      'dueLabel': task.dueLabel,
      'priority': task.priority?.name,
      'isDone': task.isDone,
      'goalId': task.goalId,
      'completedAt': task.completedAt != null
          ? Timestamp.fromDate(task.completedAt!)
          : null,
      'description': task.description,
      'dueDate': task.dueDate != null
          ? Timestamp.fromDate(task.dueDate!)
          : null,
      'createdAt': task.createdAt != null
          ? Timestamp.fromDate(task.createdAt!)
          : FieldValue.serverTimestamp(),
      'status': task.status?.name,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Adiciona uma nova tarefa ao Firestore.
  Future<void> addTask(TaskModel task) async {
    final data = _taskToMap(task);
    await _tasksCollection.doc(task.id).set(data);
  }

  /// Atualiza uma tarefa existente.
  Future<void> updateTask(TaskModel task) async {
    await _tasksCollection.doc(task.id).update(_taskToMap(task));
  }

  /// Apaga uma tarefa.
  Future<void> deleteTask(String taskId) async {
    await _tasksCollection.doc(taskId).delete();
  }

  /// Busca uma única tarefa pelo ID.
  Future<TaskModel?> getTask(String taskId) async {
    final doc = await _tasksCollection.doc(taskId).get();
    if (!doc.exists) return null;
    return _fromDocument(doc);
  }

  /// Busca todas as tarefas vinculadas a uma meta específica.
  Future<List<TaskModel>> getTasksByGoalId(String goalId) async {
    final querySnapshot = await _tasksCollection
        .where('goalId', isEqualTo: goalId)
        .get();
    return querySnapshot.docs.map((doc) => _fromDocument(doc)).toList();
  }
}
