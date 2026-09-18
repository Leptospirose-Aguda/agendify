import '../core/network/api_client.dart';
import '../models/task_model.dart';

class TaskService {
  TaskService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<TaskModel>> getTasks() async {
    final data = await _apiClient.get('/tasks') as List<dynamic>;
    return data
        .map((item) => TaskModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<TaskModel> createTask(TaskModel task) async {
    final data = await _apiClient.post('/tasks', task.toJson())
        as Map<String, dynamic>;
    return TaskModel.fromJson(data);
  }

  Future<TaskModel> updateTask(TaskModel task) async {
    if (task.id == null) {
      throw ArgumentError('A tarefa precisa de id para ser atualizada.');
    }
    final data = await _apiClient.put('/tasks/${task.id}', task.toJson())
        as Map<String, dynamic>;
    return TaskModel.fromJson(data);
  }

  Future<void> deleteTask(String id) async {
    await _apiClient.delete('/tasks/$id');
  }
}
