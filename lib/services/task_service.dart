// lib/services/task_service.dart
//
// Serviço de tarefas com suporte offline (mesma estratégia do EventService).
// Relatório Semanal #08 — 24/11/2026

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/task_model.dart';
import 'offline_cache_service.dart';
import 'connectivity_service.dart';

class TaskService {
  TaskService({
    required ConnectivityService connectivity,
    required OfflineCacheService cache,
  })  : _connectivity = connectivity,
        _cache = cache;

  final ConnectivityService _connectivity;
  final OfflineCacheService _cache;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _userTasks() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('Usuário não autenticado');
    return _firestore.collection('users').doc(uid).collection('tasks');
  }

  Future<List<TaskModel>> getTasks() async {
    if (_connectivity.isOnline) {
      try {
        final snap = await _userTasks().orderBy('createdAt', descending: true).get();
        final tasks = snap.docs.map((doc) {
          final d = doc.data();
          d['id'] = doc.id;
          return d;
        }).toList();

        await _cache.seedFromFirebase(events: [], tasks: tasks);
        return tasks.map(TaskModel.fromJson).toList();
      } catch (e) {
        debugPrint('TaskService.getTasks online error: $e — usando cache');
      }
    }

    final localRows = await _cache.getAllLocalTasks();
    debugPrint('TaskService: retornando ${localRows.length} tarefas do cache offline');
    return localRows.map((row) {
      final m = Map<String, dynamic>.from(row);
      m['isCompleted'] = (m['isCompleted'] as int?) == 1;
      return TaskModel.fromJson(m);
    }).toList();
  }

  Future<void> createTask(TaskModel task) async {
    final json = task.toJson();
    await _cache.upsertTask(json, synced: false);

    if (_connectivity.isOnline) {
      try {
        await _userTasks().doc(task.id).set(json);
        await _cache.markTaskSynced(task.id);
      } catch (e) {
        debugPrint('TaskService.createTask Firebase error: $e');
      }
    }
  }

  Future<void> updateTask(TaskModel task) async {
    final json = task.toJson();
    await _cache.upsertTask(json, synced: false);

    if (_connectivity.isOnline) {
      try {
        await _userTasks().doc(task.id).set(json, SetOptions(merge: true));
        await _cache.markTaskSynced(task.id);
      } catch (e) {
        debugPrint('TaskService.updateTask Firebase error: $e');
      }
    }
  }

  Future<void> deleteTask(String taskId) async {
    await _cache.deleteTaskLocally(taskId, synced: false);

    if (_connectivity.isOnline) {
      try {
        await _userTasks().doc(taskId).delete();
        await _cache.deleteTaskLocally(taskId, synced: true);
      } catch (e) {
        debugPrint('TaskService.deleteTask Firebase error: $e');
      }
    }
  }

  Future<void> syncPendingTasks() async {
    if (!_connectivity.isOnline) return;

    final pending = await _cache.getPendingTasks();
    for (final row in pending) {
      try {
        final m = Map<String, dynamic>.from(row)
          ..remove('synced')
          ..remove('deletedAt');
        m['isCompleted'] = (m['isCompleted'] as int?) == 1;
        await _userTasks().doc(row['id'] as String).set(m, SetOptions(merge: true));
        await _cache.markTaskSynced(row['id'] as String);
      } catch (e) {
        debugPrint('TaskService.sync: erro ${row['id']}: $e');
      }
    }

    final deletions = await _cache.getPendingDeletedTasks();
    for (final row in deletions) {
      try {
        await _userTasks().doc(row['id'] as String).delete();
        await _cache.deleteTaskLocally(row['id'] as String, synced: true);
      } catch (e) {
        debugPrint('TaskService.sync: erro deleção ${row['id']}: $e');
      }
    }
  }
}
