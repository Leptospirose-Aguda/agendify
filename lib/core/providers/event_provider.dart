// lib/core/providers/event_provider.dart
//
// Provider de eventos — ciente do modo offline.
// Relatório Semanal #08 — 24/11/2026

import 'package:flutter/material.dart';
import '../../models/event_model.dart';
import '../../services/event_service.dart';
import '../../services/connectivity_service.dart';

class EventProvider extends ChangeNotifier {
  EventProvider(this._eventService, this._connectivity) {
    _connectivity.addListener(_onConnectivityChanged);
    loadEvents();
  }

  final EventService _eventService;
  final ConnectivityService _connectivity;

  List<EventModel> _events = [];
  bool _loading = false;

  List<EventModel> get events => _events;
  bool get loading => _loading;
  bool get isOffline => !_connectivity.isOnline;

  void _onConnectivityChanged() {
    // Recarrega quando voltar online (os dados do Firebase têm prioridade)
    if (_connectivity.isOnline) {
      loadEvents();
    }
    notifyListeners();
  }

  Future<void> loadEvents() async {
    _loading = true;
    notifyListeners();
    _events = await _eventService.getEvents();
    _loading = false;
    notifyListeners();
  }

  Future<void> addEvent(EventModel event) async {
    await _eventService.createEvent(event);
    // Otimista: adiciona localmente sem esperar reload completo
    if (!_events.any((e) => e.id == event.id)) {
      _events = [..._events, event];
      _events.sort((a, b) => a.start.compareTo(b.start));
    }
    notifyListeners();
  }

  Future<void> updateEvent(EventModel event) async {
    await _eventService.updateEvent(event);
    _events = _events.map((e) => e.id == event.id ? event : e).toList();
    notifyListeners();
  }

  Future<void> deleteEvent(String eventId) async {
    await _eventService.deleteEvent(eventId);
    _events = _events.where((e) => e.id != eventId).toList();
    notifyListeners();
  }

  List<EventModel> getEventsForDay(DateTime day) {
    return _events.where((e) {
      return e.start.year == day.year &&
          e.start.month == day.month &&
          e.start.day == day.day;
    }).toList();
  }

  @override
  void dispose() {
    _connectivity.removeListener(_onConnectivityChanged);
    super.dispose();
  }
}
