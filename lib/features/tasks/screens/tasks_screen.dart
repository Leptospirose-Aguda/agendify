import 'package:flutter/material.dart';

import '../../../data/mock_data.dart';
import '../../../models/task_model.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  late List<TaskModel> _tasks;

  @override
  void initState() {
    super.initState();
    _tasks = List.of(MockData.tasks);
  }

  void _toggleTask(int index, bool? value) {
    setState(() {
      _tasks[index] = _tasks[index].copyWith(
        isCompleted: value ?? false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tarefas'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _tasks.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final task = _tasks[index];

          return Card(
            child: CheckboxListTile(
              value: task.isCompleted,
              onChanged: (value) => _toggleTask(index, value),
              title: Text(
                task.title,
                style: TextStyle(
                  decoration:
                      task.isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
              subtitle: task.deadline == null
                  ? const Text('Sem prazo')
                  : Text(
                      'Prazo: '
                      '${task.deadline!.day.toString().padLeft(2, '0')}/'
                      '${task.deadline!.month.toString().padLeft(2, '0')}/'
                      '${task.deadline!.year}',
                    ),
            ),
          );
        },
      ),
    );
  }
}
