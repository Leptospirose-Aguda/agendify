import 'package:flutter/material.dart';

import '../../../core/routes/app_routes.dart';
import '../../../models/event_model.dart';
import '../../../services/event_service.dart';

enum CalendarViewMode { day, week, month }

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final _service = EventService();
  CalendarViewMode _mode = CalendarViewMode.month;
  DateTime _selectedDate = DateTime.now();
  late Future<List<EventModel>> _eventsFuture;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() => _eventsFuture = _service.getEvents();

  Future<void> _openForm() async {
    final changed = await Navigator.of(context).pushNamed(AppRoutes.newEvent);
    if (changed == true && mounted) setState(_reload);
  }

  Future<void> _openDetails(EventModel event) async {
    final changed = await Navigator.of(context).pushNamed(
      AppRoutes.eventDetails,
      arguments: event,
    );
    if (changed == true && mounted) setState(_reload);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agenda')),
      floatingActionButton: FloatingActionButton(onPressed: _openForm, child: const Icon(Icons.add)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SegmentedButton<CalendarViewMode>(
            segments: const [
              ButtonSegment(value: CalendarViewMode.day, label: Text('Dia')),
              ButtonSegment(value: CalendarViewMode.week, label: Text('Semana')),
              ButtonSegment(value: CalendarViewMode.month, label: Text('Mês')),
            ],
            selected: {_mode},
            onSelectionChanged: (selection) => setState(() => _mode = selection.first),
          ),
          const SizedBox(height: 18),
          Card(
            child: CalendarDatePicker(
              initialDate: _selectedDate,
              firstDate: DateTime(2020),
              lastDate: DateTime(2035),
              onDateChanged: (date) => setState(() => _selectedDate = date),
            ),
          ),
          const SizedBox(height: 20),
          Text('Compromissos', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          FutureBuilder<List<EventModel>>(
            future: _eventsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()));
              }
              if (snapshot.hasError) {
                return _ErrorCard(onRetry: () => setState(_reload));
              }
              final events = snapshot.data ?? [];
              if (events.isEmpty) return const Text('Nenhum evento cadastrado.');
              return Column(
                children: events.map((event) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.schedule),
                    title: Text(event.title),
                    subtitle: Text(event.category ?? 'Sem categoria'),
                    onTap: () => _openDetails(event),
                  ),
                )).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text('Não foi possível carregar os eventos. Verifique se o backend está ligado.'),
          const SizedBox(height: 8),
          TextButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: const Text('Tentar novamente')),
        ],
      ),
    ),
  );
}
