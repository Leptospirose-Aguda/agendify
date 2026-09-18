import 'package:flutter/material.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/section_title.dart';
import '../../../models/event_model.dart';
import '../../../models/task_model.dart';
import '../../../services/event_service.dart';
import '../../../services/task_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _eventService = EventService();
  final _taskService = TaskService();
  late Future<List<EventModel>> _events;
  late Future<List<TaskModel>> _tasks;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _events = _eventService.getEvents();
    _tasks = _taskService.getTasks();
  }

  Future<void> _newEvent() async {
    final changed = await Navigator.of(context).pushNamed(AppRoutes.newEvent);
    if (changed == true && mounted) setState(_reload);
  }

  Future<void> _details(EventModel event) async {
    final changed = await Navigator.of(context).pushNamed(AppRoutes.eventDetails, arguments: event);
    if (changed == true && mounted) setState(_reload);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agendify'),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_outlined), tooltip: 'Notificações')],
      ),
      floatingActionButton: FloatingActionButton.extended(onPressed: _newEvent, icon: const Icon(Icons.add), label: const Text('Novo evento')),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(_reload);
          await Future.wait([_events, _tasks]);
        },
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('Resumo da agenda', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text('Dados carregados do backend persistente.'),
            const SizedBox(height: 24),
            const SectionTitle('Próximos eventos'),
            const SizedBox(height: 12),
            FutureBuilder<List<EventModel>>(
              future: _events,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const LinearProgressIndicator();
                if (snapshot.hasError) return const Text('Backend indisponível. Inicie o servidor em backend/.');
                final events = snapshot.data ?? [];
                if (events.isEmpty) return const Text('Nenhum evento cadastrado.');
                return Column(children: events.take(5).map((event) => Card(
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.event)),
                    title: Text(event.title),
                    subtitle: Text(event.location ?? 'Sem localização'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _details(event),
                  ),
                )).toList());
              },
            ),
            const SizedBox(height: 28),
            const SectionTitle('Tarefas'),
            const SizedBox(height: 12),
            FutureBuilder<List<TaskModel>>(
              future: _tasks,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const LinearProgressIndicator();
                if (snapshot.hasError) return const Text('Não foi possível carregar as tarefas.');
                final tasks = snapshot.data ?? [];
                if (tasks.isEmpty) return const Text('Nenhuma tarefa cadastrada.');
                return Column(children: tasks.take(5).map((task) => CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: task.isCompleted,
                  onChanged: null,
                  title: Text(task.title),
                  controlAffinity: ListTileControlAffinity.leading,
                )).toList());
              },
            ),
          ],
        ),
      ),
    );
  }
}
