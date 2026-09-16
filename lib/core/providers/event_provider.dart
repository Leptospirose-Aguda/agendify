import 'package:flutter/material.dart';
import '../../models/event_model.dart';
import '../../services/event_service.dart';

class EventProvider extends ChangeNotifier {
  EventProvider(this._eventService) {
    loadEvents();
  }

  final EventService _eventService;
  List<EventModel> _events = [];

  List<EventModel> get events => _events;

  Future<void> loadEvents() async {
    _events = await _eventService.getEvents();
    notifyListeners();
  }

  Future<void> addEvent(EventModel event) async {
    await _eventService.createEvent(event);
    await loadEvents();
  }

  Future<void> updateEvent(EventModel event) async {
    await _eventService.updateEvent(event);
    await loadEvents();
  }

  Future<void> deleteEvent(String eventId) async {
    await _eventService.deleteEvent(eventId);
    await loadEvents();
  }

  List<EventModel> getEventsForDay(DateTime day) {
    return _events.where((e) {
      return e.start.year == day.year && 
             e.start.month == day.month && 
             e.start.day == day.day;
    }).toList();
  }
}
