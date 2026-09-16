import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/providers/event_provider.dart';
import '../../../models/event_model.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();

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
      body: Consumer<EventProvider>(
        builder: (context, provider, _) {
          final selectedEvents = _selectedDay != null 
              ? provider.getEventsForDay(_selectedDay!) 
              : [];

          return Column(
            children: [
              Card(
                margin: const EdgeInsets.all(16.0),
                child: TableCalendar<EventModel>(
                  firstDay: DateTime.utc(2020, 10, 16),
                  lastDay: DateTime.utc(2035, 3, 14),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    if (!isSameDay(_selectedDay, selectedDay)) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    }
                  },
                  eventLoader: (day) => provider.getEventsForDay(day),
                  calendarFormat: CalendarFormat.month,
                  availableCalendarFormats: const {
                    CalendarFormat.month: 'Mês',
                    CalendarFormat.twoWeeks: '2 Semanas',
                    CalendarFormat.week: 'Semana',
                  },
                  headerStyle: const HeaderStyle(
                    titleCentered: true,
                    formatButtonVisible: true,
                  ),
                ),
              ),
              Expanded(
                child: selectedEvents.isEmpty
                    ? const Center(child: Text('Nenhum evento neste dia.'))
                    : ListView.builder(
                        itemCount: selectedEvents.length,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemBuilder: (context, index) {
                          final event = selectedEvents[index];
                          return Card(
                            child: ListTile(
                              leading: const Icon(Icons.schedule),
                              title: Text(event.title),
                              subtitle: Text(event.category ?? 'Sem categoria'),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () => provider.deleteEvent(event.id),
                              ),
                              onTap: () => Navigator.of(context).pushNamed(
                                AppRoutes.eventDetails,
                                arguments: event,
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
