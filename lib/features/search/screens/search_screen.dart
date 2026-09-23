import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/event_provider.dart';
import '../../../core/providers/task_provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final allEvents = context.watch<EventProvider>().events;
    final allTasks = context.watch<TaskProvider>().tasks;

    final filteredEvents = _query.isEmpty
        ? <dynamic>[]
        : allEvents.where((e) {
            final text =
                '${e.title} ${e.description ?? ''} ${e.location ?? ''} ${e.category ?? ''}'
                    .toLowerCase();
            return text.contains(_query.toLowerCase());
          }).toList();

    final filteredTasks = _query.isEmpty
        ? <dynamic>[]
        : allTasks.where((t) {
            return t.title.toLowerCase().contains(_query.toLowerCase());
          }).toList();

    final hasResults = filteredEvents.isNotEmpty || filteredTasks.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Buscar')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: TextField(
              autofocus: true,
              onChanged: (value) => setState(() => _query = value),
              decoration: const InputDecoration(
                labelText: 'Buscar eventos e tarefas...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: _query.isEmpty
                ? const Center(
                    child: Text(
                      'Digite algo para buscar.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : !hasResults
                    ? const Center(
                        child: Text(
                          'Nenhum resultado encontrado.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.all(20),
                        children: [
                          if (filteredEvents.isNotEmpty) ...[
                            const Padding(
                              padding: EdgeInsets.only(bottom: 8),
                              child: Text(
                                'Eventos',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            ...filteredEvents.map(
                              (event) => Card(
                                child: ListTile(
                                  leading: const CircleAvatar(
                                    child: Icon(Icons.event_outlined),
                                  ),
                                  title: Text(event.title),
                                  subtitle: Text(
                                    event.category ?? event.location ?? 'Sem categoria',
                                  ),
                                ),
                              ),
                            ),
                          ],
                          if (filteredTasks.isNotEmpty) ...[
                            Padding(
                              padding: EdgeInsets.only(
                                top: filteredEvents.isNotEmpty ? 16 : 0,
                                bottom: 8,
                              ),
                              child: const Text(
                                'Tarefas',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            ...filteredTasks.map(
                              (task) => Card(
                                child: ListTile(
                                  leading: CircleAvatar(
                                    child: Icon(
                                      task.isCompleted
                                          ? Icons.task_alt
                                          : Icons.radio_button_unchecked,
                                    ),
                                  ),
                                  title: Text(
                                    task.title,
                                    style: TextStyle(
                                      decoration: task.isCompleted
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                                  ),
                                  subtitle: task.deadline != null
                                      ? Text(
                                          'Prazo: ${task.deadline!.day.toString().padLeft(2, '0')}/'
                                          '${task.deadline!.month.toString().padLeft(2, '0')}/'
                                          '${task.deadline!.year}',
                                        )
                                      : null,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}
