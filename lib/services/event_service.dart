import '../core/network/api_client.dart';
import '../models/event_model.dart';

class EventService {
  EventService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<EventModel>> getEvents() async {
    final data = await _apiClient.get('/events') as List<dynamic>;
    return data
        .map((item) => EventModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<EventModel> getEvent(String id) async {
    final data = await _apiClient.get('/events/$id') as Map<String, dynamic>;
    return EventModel.fromJson(data);
  }

  Future<EventModel> createEvent(EventModel event) async {
    final data = await _apiClient.post('/events', event.toJson())
        as Map<String, dynamic>;
    return EventModel.fromJson(data);
  }

  Future<EventModel> updateEvent(EventModel event) async {
    if (event.id == null) {
      throw ArgumentError('O evento precisa de id para ser atualizado.');
    }
    final data = await _apiClient.put('/events/${event.id}', event.toJson())
        as Map<String, dynamic>;
    return EventModel.fromJson(data);
  }

  Future<void> deleteEvent(String eventId) async {
    await _apiClient.delete('/events/$eventId');
  }
}
