import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/event_model.dart';

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Retorna a subcoleção do usuário logado: users/{uid}/events
  CollectionReference<Map<String, dynamic>> _userEvents() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('Usuário não autenticado');
    return _firestore.collection('users').doc(uid).collection('events');
  }

  Future<List<EventModel>> getEvents() async {
    try {
      final snapshot = await _userEvents().orderBy('start').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return EventModel.fromJson(data);
      }).toList();
    } catch (e) {
      debugPrint('EventService.getEvents error: $e');
      return [];
    }
  }

  Future<void> createEvent(EventModel event) async {
    try {
      await _userEvents().doc(event.id).set(event.toJson());
    } catch (e) {
      debugPrint('EventService.createEvent error: $e');
      rethrow;
    }
  }

  Future<void> updateEvent(EventModel event) async {
    try {
      await _userEvents().doc(event.id).set(event.toJson(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('EventService.updateEvent error: $e');
      rethrow;
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      await _userEvents().doc(eventId).delete();
    } catch (e) {
      debugPrint('EventService.deleteEvent error: $e');
      rethrow;
    }
  }
}
