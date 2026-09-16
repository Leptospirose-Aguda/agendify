import 'package:flutter/material.dart';

import '../../../core/routes/app_routes.dart';
import '../../../data/mock_data.dart';

enum CalendarViewMode { day, week, month }

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarViewMode _mode = CalendarViewMode.month;
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed(AppRoutes.newEvent),
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SegmentedButton<CalendarViewMode>(
            segments: const [
              ButtonSegment(
                value: CalendarViewMode.day,
                label: Text('Dia'),
              ),
              ButtonSegment(
                value: CalendarViewMode.week,
                label: Text('Semana'),
              ),
              ButtonSegment(
                value: CalendarViewMode.month,
                label: Text('Mês'),
              ),
            ],
            selected: {_mode},
            onSelectionChanged: (selection) {
              setState(() => _mode = selection.first);
            },
          ),
          const SizedBox(height: 18),
          Card(
            child: CalendarDatePicker(
              initialDate: _selectedDate,
              firstDate: DateTime(2020),
              lastDate: DateTime(2035),
              onDateChanged: (date) {
                setState(() => _selectedDate = date);
              },
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Compromissos',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 10),
          ...MockData.events.map(
            (event) => Card(
              child: ListTile(
                leading: const Icon(Icons.schedule),
                title: Text(event.title),
                subtitle: Text(event.category ?? 'Sem categoria'),
                onTap: () => Navigator.of(context).pushNamed(
                  AppRoutes.eventDetails,
                  arguments: event,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
