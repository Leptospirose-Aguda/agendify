import '../models/event_model.dart';

class EventService {
  Future<List<EventModel>> getEvents() async {
    // TODO: buscar eventos no backend ou banco local.
    return [];
  }

  Future<void> createEvent(EventModel event) async {
    // TODO: persistir evento.
  }

  Future<void> updateEvent(EventModel event) async {
    // TODO: atualizar evento.
  }

  Future<void> deleteEvent(String eventId) async {
    // TODO: excluir evento.
  }
}
