import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/task_model.dart';

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Retorna a subcoleção do usuário logado: users/{uid}/tasks
  CollectionReference<Map<String, dynamic>> _userTasks() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('Usuário não autenticado');
    return _firestore.collection('users').doc(uid).collection('tasks');
  }

  Future<List<TaskModel>> getTasks() async {
    try {
      final snapshot = await _userTasks().orderBy('createdAt', descending: true).get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return TaskModel.fromJson(data);
      }).toList();
    } catch (e) {
      debugPrint('TaskService.getTasks error: $e');
      return [];
    }
  }

  Future<void> createTask(TaskModel task) async {
    try {
      await _userTasks().doc(task.id).set(task.toJson());
    } catch (e) {
      debugPrint('TaskService.createTask error: $e');
      rethrow;
    }
  }

  Future<void> updateTask(TaskModel task) async {
    try {
      await _userTasks().doc(task.id).set(task.toJson(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('TaskService.updateTask error: $e');
      rethrow;
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _userTasks().doc(taskId).delete();
    } catch (e) {
      debugPrint('TaskService.deleteTask error: $e');
      rethrow;
    }
  }
}
