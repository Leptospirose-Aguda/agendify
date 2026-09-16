import 'package:flutter/material.dart';

import '../../../models/event_model.dart';

class EventDetailsScreen extends StatelessWidget {
  const EventDetailsScreen({
    super.key,
    required this.event,
  });

  final EventModel? event;

  @override
  Widget build(BuildContext context) {
    final currentEvent = event;

    if (currentEvent == null) {
      return const Scaffold(
        body: Center(child: Text('Evento não encontrado.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do evento'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            currentEvent.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),
          _InfoTile(
            icon: Icons.schedule,
            title: 'Horário',
            value:
                '${currentEvent.start.hour.toString().padLeft(2, '0')}:'
                '${currentEvent.start.minute.toString().padLeft(2, '0')} - '
                '${currentEvent.end.hour.toString().padLeft(2, '0')}:'
                '${currentEvent.end.minute.toString().padLeft(2, '0')}',
          ),
          _InfoTile(
            icon: Icons.location_on_outlined,
            title: 'Local',
            value: currentEvent.location ?? 'Não informado',
          ),
          _InfoTile(
            icon: Icons.category_outlined,
            title: 'Categoria',
            value: currentEvent.category ?? 'Não informada',
          ),
          _InfoTile(
            icon: Icons.notes,
            title: 'Descrição',
            value: currentEvent.description ?? 'Sem descrição',
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
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
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }
}
