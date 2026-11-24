// lib/core/providers/task_provider.dart
//
// Provider de tarefas — ciente do modo offline.
// Relatório Semanal #08 — 24/11/2026

import 'package:flutter/material.dart';
import '../../models/task_model.dart';
import '../../services/task_service.dart';
import '../../services/connectivity_service.dart';

class TaskProvider extends ChangeNotifier {
  TaskProvider(this._taskService, this._connectivity) {
    _connectivity.addListener(_onConnectivityChanged);
    loadTasks();
  }

  final TaskService _taskService;
  final ConnectivityService _connectivity;

  List<TaskModel> _tasks = [];
  bool _loading = false;

  List<TaskModel> get tasks => _tasks;
  bool get loading => _loading;
  bool get isOffline => !_connectivity.isOnline;

  List<TaskModel> get pendingTasks => _tasks.where((t) => !t.isCompleted).toList();
  List<TaskModel> get completedTasks => _tasks.where((t) => t.isCompleted).toList();

  void _onConnectivityChanged() {
    if (_connectivity.isOnline) loadTasks();
    notifyListeners();
  }

  Future<void> loadTasks() async {
    _loading = true;
    notifyListeners();
    _tasks = await _taskService.getTasks();
    _loading = false;
    notifyListeners();
  }

  Future<void> addTask(TaskModel task) async {
    await _taskService.createTask(task);
    _tasks = [task, ..._tasks];
    notifyListeners();
  }

  Future<void> updateTask(TaskModel task) async {
    await _taskService.updateTask(task);
    _tasks = _tasks.map((t) => t.id == task.id ? task : t).toList();
    notifyListeners();
  }

  Future<void> deleteTask(String taskId) async {
    await _taskService.deleteTask(taskId);
    _tasks = _tasks.where((t) => t.id != taskId).toList();
    notifyListeners();
  }

  Future<void> toggleTaskCompletion(TaskModel task) async {
    await updateTask(task.copyWith(isCompleted: !task.isCompleted));
  }

  @override
  void dispose() {
    _connectivity.removeListener(_onConnectivityChanged);
    super.dispose();
  }
}
