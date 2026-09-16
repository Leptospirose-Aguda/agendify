import 'package:flutter/material.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/section_title.dart';
import '../../../data/mock_data.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final events = MockData.events;
    final tasks = MockData.tasks;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agendify'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined),
            tooltip: 'Notificações',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).pushNamed(AppRoutes.newEvent),
        icon: const Icon(Icons.add),
        label: const Text('Novo evento'),
      ),
      body: ListView(
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
                children: const [
                  _SummaryCard(
                    icon: Icons.event_available,
                    title: 'Eventos hoje',
                    value: '3',
                  ),
                  _SummaryCard(
                    icon: Icons.task_alt,
                    title: 'Tarefas pendentes',
                    value: '2',
                  ),
                  _SummaryCard(
                    icon: Icons.access_time,
                    title: 'Horas planejadas',
                    value: '5h',
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 28),
          const SectionTitle('Próximos eventos'),
          const SizedBox(height: 12),
          ...events.map(
            (event) => Card(
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.event),
                ),
                title: Text(event.title),
                subtitle: Text(
                  event.location ?? 'Sem localização',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).pushNamed(
                  AppRoutes.eventDetails,
                  arguments: event,
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
          const SectionTitle('Tarefas'),
          const SizedBox(height: 12),
          ...tasks.map(
            (task) => CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: task.isCompleted,
              onChanged: (_) {},
              title: Text(task.title),
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ),
        ],
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
