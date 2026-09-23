import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_model.dart';

class TaskService {
  static const String _key = 'tasks_v1';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<TaskModel>> getTasks() async {
    try {
      final snapshot = await _firestore.collection('tasks').get();
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.map((doc) => TaskModel.fromJson(doc.data())).toList();
      }
    } catch (e) {
      debugPrint('Firestore getTasks info: $e');
    }

    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_key);
    if (data == null) return [];
    
    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((e) => TaskModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveTasksLocally(List<TaskModel> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final String data = jsonEncode(tasks.map((e) => e.toJson()).toList());
    await prefs.setString(_key, data);
  }

  Future<void> createTask(TaskModel task) async {
    try {
      await _firestore.collection('tasks').doc(task.id).set(task.toJson());
    } catch (e) {
      debugPrint('Firestore createTask info: $e');
    }
    final tasks = await getTasks();
    if (!tasks.any((t) => t.id == task.id)) {
      tasks.add(task);
      await saveTasksLocally(tasks);
    }
  }

  Future<void> updateTask(TaskModel task) async {
    try {
      await _firestore.collection('tasks').doc(task.id).set(task.toJson(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('Firestore updateTask info: $e');
    }
    final tasks = await getTasks();
    final index = tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      tasks[index] = task;
      await saveTasksLocally(tasks);
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _firestore.collection('tasks').doc(taskId).delete();
    } catch (e) {
      debugPrint('Firestore deleteTask info: $e');
    }
    final tasks = await getTasks();
    tasks.removeWhere((t) => t.id == taskId);
    await saveTasksLocally(tasks);
  }
}
