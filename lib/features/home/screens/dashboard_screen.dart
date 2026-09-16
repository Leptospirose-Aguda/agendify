import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/section_title.dart';
import '../../../core/providers/event_provider.dart';
import '../../../core/providers/task_provider.dart';
import '../../../core/providers/auth_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<AuthProvider>(
          builder: (context, auth, _) => Text('Olá, ${auth.username ?? 'Agendify'}'),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.of(context).pushReplacementNamed(AppRoutes.login);
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).pushNamed(AppRoutes.newEvent),
        icon: const Icon(Icons.add),
        label: const Text('Novo evento'),
      ),
      body: Consumer2<EventProvider, TaskProvider>(
        builder: (context, eventProvider, taskProvider, child) {
          final events = eventProvider.events;
          final tasks = taskProvider.pendingTasks;
          final todayEvents = eventProvider.getEventsForDay(DateTime.now());

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Resumo da agenda',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'Veja seus próximos compromissos e tarefas.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final columns = width >= 900 ? 3 : width >= 600 ? 2 : 1;
                  return GridView.count(
                    crossAxisCount: columns,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: columns == 1 ? 3.4 : 2.2,
                    children: [
                      _SummaryCard(
                        icon: Icons.event_available,
                        title: 'Eventos hoje',
                        value: '${todayEvents.length}',
                      ),
                      _SummaryCard(
                        icon: Icons.task_alt,
                        title: 'Tarefas pendentes',
                        value: '${tasks.length}',
                      ),
                      _SummaryCard(
                        icon: Icons.access_time,
                        title: 'Total de eventos',
                        value: '${events.length}',
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 28),
              const SectionTitle('Próximos eventos'),
              const SizedBox(height: 12),
              if (events.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Nenhum evento agendado.'),
                ),
              ...events.take(3).map(
                (event) => Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.event),
                    ),
                    title: Text(event.title),
                    subtitle: Text(
                      event.location ?? 'Sem localização',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => eventProvider.deleteEvent(event.id),
                    ),
                    onTap: () => Navigator.of(context).pushNamed(
                      AppRoutes.eventDetails,
                      arguments: event,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              const SectionTitle('Tarefas recentes'),
              const SizedBox(height: 12),
              if (tasks.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Nenhuma tarefa pendente.'),
                ),
              ...tasks.take(3).map(
                (task) => CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: task.isCompleted,
                  onChanged: (_) => taskProvider.toggleTaskCompletion(task),
                  title: Text(task.title),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(child: Icon(icon)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
