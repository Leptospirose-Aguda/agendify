import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/event_model.dart';

class EventService {
  static const String _key = 'events_v1';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<EventModel>> getEvents() async {
    try {
      final snapshot = await _firestore.collection('events').get();
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.map((doc) => EventModel.fromJson(doc.data())).toList();
      }
    } catch (e) {
      debugPrint('Firestore getEvents info: $e');
    }

    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_key);
    if (data == null) return [];
    
    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((e) => EventModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveEventsLocally(List<EventModel> events) async {
    final prefs = await SharedPreferences.getInstance();
    final String data = jsonEncode(events.map((e) => e.toJson()).toList());
    await prefs.setString(_key, data);
  }

  Future<void> createEvent(EventModel event) async {
    try {
      await _firestore.collection('events').doc(event.id).set(event.toJson());
    } catch (e) {
      debugPrint('Firestore createEvent info: $e');
    }
    final events = await getEvents();
    if (!events.any((e) => e.id == event.id)) {
      events.add(event);
      await saveEventsLocally(events);
    }
  }

  Future<void> updateEvent(EventModel event) async {
    try {
      await _firestore.collection('events').doc(event.id).set(event.toJson(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('Firestore updateEvent info: $e');
    }
    final events = await getEvents();
    final index = events.indexWhere((e) => e.id == event.id);
    if (index != -1) {
      events[index] = event;
      await saveEventsLocally(events);
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      await _firestore.collection('events').doc(eventId).delete();
    } catch (e) {
      debugPrint('Firestore deleteEvent info: $e');
    }
    final events = await getEvents();
    events.removeWhere((e) => e.id == eventId);
    await saveEventsLocally(events);
  }
}
