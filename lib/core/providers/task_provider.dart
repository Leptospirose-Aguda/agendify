import 'package:flutter/material.dart';
import '../../models/task_model.dart';
import '../../services/task_service.dart';

class TaskProvider extends ChangeNotifier {
  TaskProvider(this._taskService) {
    loadTasks();
  }

  final TaskService _taskService;
  List<TaskModel> _tasks = [];

  List<TaskModel> get tasks => _tasks;

  List<TaskModel> get pendingTasks => _tasks.where((t) => !t.isCompleted).toList();
  List<TaskModel> get completedTasks => _tasks.where((t) => t.isCompleted).toList();

  Future<void> loadTasks() async {
    _tasks = await _taskService.getTasks();
    notifyListeners();
  }

  Future<void> addTask(TaskModel task) async {
    await _taskService.createTask(task);
    await loadTasks();
  }

  Future<void> updateTask(TaskModel task) async {
    await _taskService.updateTask(task);
    await loadTasks();
  }

  Future<void> deleteTask(String taskId) async {
    await _taskService.deleteTask(taskId);
    await loadTasks();
  }

  Future<void> toggleTaskCompletion(TaskModel task) async {
    final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
    await updateTask(updatedTask);
  }
}
