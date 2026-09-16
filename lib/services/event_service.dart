import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/event_model.dart';

class EventService {
  static const String _key = 'events_v1';

  Future<List<EventModel>> getEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_key);
    if (data == null) return [];
    
    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((e) => EventModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveEvents(List<EventModel> events) async {
    final prefs = await SharedPreferences.getInstance();
    final String data = jsonEncode(events.map((e) => e.toJson()).toList());
    await prefs.setString(_key, data);
  }

  Future<void> createEvent(EventModel event) async {
    final events = await getEvents();
    events.add(event);
    await saveEvents(events);
  }

  Future<void> updateEvent(EventModel event) async {
    final events = await getEvents();
    final index = events.indexWhere((e) => e.id == event.id);
    if (index != -1) {
      events[index] = event;
      await saveEvents(events);
    }
  }

  Future<void> deleteEvent(String eventId) async {
    final events = await getEvents();
    events.removeWhere((e) => e.id == eventId);
    await saveEvents(events);
  }
}
