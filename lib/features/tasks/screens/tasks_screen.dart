import 'package:flutter/material.dart';

import '../../../models/task_model.dart';
import '../../../services/task_service.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final _service = TaskService();
  late Future<List<TaskModel>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() => _future = _service.getTasks();

  Future<void> _toggleTask(TaskModel task, bool? value) async {
    await _service.updateTask(task.copyWith(isCompleted: value ?? false));
    if (mounted) setState(_reload);
  }

  Future<void> _addTask() async {
    final controller = TextEditingController();
    final title = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nova tarefa'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Título'),
          onSubmitted: (value) => Navigator.pop(context, value.trim()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Adicionar')),
        ],
      ),
    );
    controller.dispose();
    if (title == null || title.isEmpty) return;
    await _service.createTask(TaskModel(title: title));
    if (mounted) setState(_reload);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tarefas')),
      floatingActionButton: FloatingActionButton(onPressed: _addTask, child: const Icon(Icons.add)),
      body: FutureBuilder<List<TaskModel>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: FilledButton.icon(
                onPressed: () => setState(_reload),
                icon: const Icon(Icons.refresh),
                label: const Text('Backend indisponível — tentar novamente'),
              ),
            );
          }
          final tasks = snapshot.data ?? [];
          if (tasks.isEmpty) return const Center(child: Text('Nenhuma tarefa cadastrada.'));
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: tasks.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final task = tasks[index];
              return Card(
                child: CheckboxListTile(
                  value: task.isCompleted,
                  onChanged: (value) => _toggleTask(task, value),
                  title: Text(task.title, style: TextStyle(decoration: task.isCompleted ? TextDecoration.lineThrough : null)),
                  subtitle: task.deadline == null
                      ? const Text('Sem prazo')
                      : Text('Prazo: ${task.deadline!.day.toString().padLeft(2, '0')}/${task.deadline!.month.toString().padLeft(2, '0')}/${task.deadline!.year}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
