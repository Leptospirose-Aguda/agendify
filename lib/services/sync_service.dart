// lib/services/sync_service.dart
//
// Escuta mudanças de conectividade e envia dados pendentes ao Firebase
// assim que a conexão é restabelecida.
// Relatório Semanal #08 — 24/11/2026

import 'package:flutter/foundation.dart';
import 'connectivity_service.dart';
import 'event_service.dart';
import 'task_service.dart';

class SyncService {
  SyncService({
    required ConnectivityService connectivity,
    required EventService eventService,
    required TaskService taskService,
  })  : _connectivity = connectivity,
        _eventService = eventService,
        _taskService = taskService {
    _connectivity.addListener(_onConnectivityChanged);
  }

  final ConnectivityService _connectivity;
  final EventService _eventService;
  final TaskService _taskService;

  void _onConnectivityChanged() {
    if (_connectivity.isOnline) {
      debugPrint('SyncService: voltou online — iniciando sincronização...');
      _syncAll();
    }
  }

  Future<void> _syncAll() async {
    try {
      await _eventService.syncPendingEvents();
      await _taskService.syncPendingTasks();
      debugPrint('SyncService: sincronização concluída ✓');
    } catch (e) {
      debugPrint('SyncService: erro durante sincronização: $e');
    }
  }

  void dispose() {
    _connectivity.removeListener(_onConnectivityChanged);
  }
}
