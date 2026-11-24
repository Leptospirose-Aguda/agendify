// lib/services/event_service.dart
//
// Serviço de eventos com suporte offline.
// Estratégia:
//   • Escrita: salva SEMPRE no SQLite local (sincrono, sem falha de rede).
//     Se online, envia também ao Firestore e marca como synced.
//   • Leitura: se online → Firestore + atualiza cache.
//               se offline → retorna do SQLite local.
//   • Sincronização: ao voltar online, o SyncService envia os pendentes.
//
// Relatório Semanal #08 — 24/11/2026

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/event_model.dart';
import 'offline_cache_service.dart';
import 'connectivity_service.dart';

class EventService {
  EventService({
    required ConnectivityService connectivity,
    required OfflineCacheService cache,
  })  : _connectivity = connectivity,
        _cache = cache;

  final ConnectivityService _connectivity;
  final OfflineCacheService _cache;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _userEvents() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('Usuário não autenticado');
    return _firestore.collection('users').doc(uid).collection('events');
  }

  Future<List<EventModel>> getEvents() async {
    if (_connectivity.isOnline) {
      try {
        final snap = await _userEvents().orderBy('start').get();
        final events = snap.docs.map((doc) {
          final d = doc.data();
          d['id'] = doc.id;
          return d;
        }).toList();

        // Atualiza cache local com dados do Firebase
        await _cache.seedFromFirebase(events: events, tasks: []);

        return events.map(EventModel.fromJson).toList();
      } catch (e) {
        debugPrint('EventService.getEvents online error: $e — usando cache');
      }
    }

    // Offline: retorna do cache local
    final localRows = await _cache.getAllLocalEvents();
    debugPrint('EventService: retornando ${localRows.length} eventos do cache offline');
    return localRows.map((row) {
      final m = Map<String, dynamic>.from(row);
      m['isRecurring'] = (m['isRecurring'] as int?) == 1;
      return EventModel.fromJson(m);
    }).toList();
  }

  Future<void> createEvent(EventModel event) async {
    final json = event.toJson();

    // 1. Sempre salva no cache local (offline-first)
    await _cache.upsertEvent(json, synced: false);

    // 2. Se online, envia ao Firebase e marca como sincronizado
    if (_connectivity.isOnline) {
      try {
        await _userEvents().doc(event.id).set(json);
        await _cache.markEventSynced(event.id);
      } catch (e) {
        debugPrint('EventService.createEvent Firebase error: $e — ficará pendente');
      }
    } else {
      debugPrint('EventService.createEvent: offline — evento salvo localmente (id: ${event.id})');
    }
  }

  Future<void> updateEvent(EventModel event) async {
    final json = event.toJson();

    await _cache.upsertEvent(json, synced: false);

    if (_connectivity.isOnline) {
      try {
        await _userEvents().doc(event.id).set(json, SetOptions(merge: true));
        await _cache.markEventSynced(event.id);
      } catch (e) {
        debugPrint('EventService.updateEvent Firebase error: $e');
      }
    }
  }

  Future<void> deleteEvent(String eventId) async {
    await _cache.deleteEventLocally(eventId, synced: false);

    if (_connectivity.isOnline) {
      try {
        await _userEvents().doc(eventId).delete();
        // Marca a deleção como sincronizada (atualiza synced=1)
        await _cache.deleteEventLocally(eventId, synced: true);
      } catch (e) {
        debugPrint('EventService.deleteEvent Firebase error: $e');
      }
    }
  }

  /// Sincroniza eventos pendentes com o Firebase.
  /// Chamado pelo SyncService ao recuperar conectividade.
  Future<void> syncPendingEvents() async {
    if (!_connectivity.isOnline) return;

    // Upserts pendentes
    final pending = await _cache.getPendingEvents();
    for (final row in pending) {
      try {
        final m = Map<String, dynamic>.from(row)
          ..remove('synced')
          ..remove('deletedAt');
        m['isRecurring'] = (m['isRecurring'] as int?) == 1;
        await _userEvents().doc(row['id'] as String).set(m, SetOptions(merge: true));
        await _cache.markEventSynced(row['id'] as String);
        debugPrint('EventService.sync: evento ${row['id']} sincronizado ✓');
      } catch (e) {
        debugPrint('EventService.sync: erro ao sincronizar ${row['id']}: $e');
      }
    }

    // Deleções pendentes
    final deletions = await _cache.getPendingDeletedEvents();
    for (final row in deletions) {
      try {
        await _userEvents().doc(row['id'] as String).delete();
        await _cache.deleteEventLocally(row['id'] as String, synced: true);
        debugPrint('EventService.sync: deleção ${row['id']} sincronizada ✓');
      } catch (e) {
        debugPrint('EventService.sync: erro ao deletar ${row['id']}: $e');
      }
    }
  }
}
