import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../core/providers/task_provider.dart';
import '../../../models/task_model.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final _taskController = TextEditingController();

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  void _addTask() {
    final title = _taskController.text.trim();
    if (title.isEmpty) return;

    final newTask = TaskModel(
      id: const Uuid().v4(),
      title: title,
    );

    Provider.of<TaskProvider>(context, listen: false).addTask(newTask);
    _taskController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tarefas'),
      ),
      body: Consumer<TaskProvider>(
        builder: (context, provider, child) {
          final pendingTasks = provider.pendingTasks;
          final completedTasks = provider.completedTasks;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _taskController,
                        decoration: const InputDecoration(
                          hintText: 'Adicionar nova tarefa...',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        onSubmitted: (_) => _addTask(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: _addTask,
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  children: [
                    if (pendingTasks.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text('Pendentes', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                      ),
                      ...pendingTasks.map((task) => _buildTaskTile(task, provider)),
                    ],
                    if (completedTasks.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text('Concluídas', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                      ),
                      ...completedTasks.map((task) => _buildTaskTile(task, provider)),
                    ],
                    if (pendingTasks.isEmpty && completedTasks.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Center(
                          child: Text('Nenhuma tarefa ainda.', style: TextStyle(color: Colors.grey)),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTaskTile(TaskModel task, TaskProvider provider) {
    return ListTile(
      leading: Checkbox(
        value: task.isCompleted,
        onChanged: (_) => provider.toggleTaskCompletion(task),
      ),
      title: Text(
        task.title,
        style: TextStyle(
          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
          color: task.isCompleted ? Colors.grey : null,
        ),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, color: Colors.red),
        onPressed: () => provider.deleteTask(task.id),
      ),
    );
  }
}
