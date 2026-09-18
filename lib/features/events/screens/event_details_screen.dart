import 'package:flutter/material.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/routes/app_routes.dart';
import '../../../models/event_model.dart';
import '../../../services/event_service.dart';

class EventDetailsScreen extends StatefulWidget {
  const EventDetailsScreen({super.key, required this.event});

  final EventModel? event;

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  final _service = EventService();
  late EventModel? _event = widget.event;
  bool _deleting = false;

  Future<void> _edit() async {
    final event = _event;
    if (event == null) return;
    final changed = await Navigator.of(context).pushNamed(
      AppRoutes.eventForm,
      arguments: event,
    );
    if (changed == true && event.id != null) {
      try {
        final refreshed = await _service.getEvent(event.id!);
        if (mounted) setState(() => _event = refreshed);
      } catch (_) {
        if (mounted) Navigator.of(context).pop(true);
      }
    }
  }

  Future<void> _delete() async {
    final event = _event;
    if (event?.id == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir evento?'),
        content: Text('O evento "${event!.title}" será removido permanentemente.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _deleting = true);
    try {
      await _service.deleteEvent(event!.id!);
      if (mounted) Navigator.of(context).pop(true);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _deleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentEvent = _event;
    if (currentEvent == null) {
      return const Scaffold(body: Center(child: Text('Evento não encontrado.')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do evento'),
        actions: [
          IconButton(onPressed: _deleting ? null : _edit, icon: const Icon(Icons.edit_outlined)),
          IconButton(onPressed: _deleting ? null : _delete, icon: const Icon(Icons.delete_outline)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (_deleting) const LinearProgressIndicator(),
          Text(
            currentEvent.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          _InfoTile(
            icon: Icons.schedule,
            title: 'Horário',
            value:
                '${currentEvent.start.hour.toString().padLeft(2, '0')}:${currentEvent.start.minute.toString().padLeft(2, '0')} - '
                '${currentEvent.end.hour.toString().padLeft(2, '0')}:${currentEvent.end.minute.toString().padLeft(2, '0')}',
          ),
          _InfoTile(icon: Icons.location_on_outlined, title: 'Local', value: currentEvent.location ?? 'Não informado'),
          _InfoTile(icon: Icons.category_outlined, title: 'Categoria', value: currentEvent.category ?? 'Não informada'),
          _InfoTile(icon: Icons.notes, title: 'Descrição', value: currentEvent.description ?? 'Sem descrição'),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.icon, required this.title, required this.value});
  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(leading: Icon(icon), title: Text(title), subtitle: Text(value)),
    );
  }
}
