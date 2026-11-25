// lib/services/connectivity_service.dart
//
// Monitora conectividade de rede para decidir entre Firebase e cache local.
// Implementado em: 24/11/2026 — Relatório Semanal #08

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityService extends ChangeNotifier {
  ConnectivityService() {
    init();
  }

  bool _isOnline = false;
  bool _initialized = false;

  bool get isOnline => _isOnline;
  bool get initialized => _initialized;

  StreamSubscription<List<ConnectivityResult>>? _sub;

  Future<void> init() async {
    try {
      final results = await Connectivity().checkConnectivity();
      _isOnline = _hasConnection(results);
    } catch (e) {
      _isOnline = false;
    }
    _initialized = true;
    notifyListeners();

    _sub?.cancel();
    _sub = Connectivity().onConnectivityChanged.listen((results) {
      final online = _hasConnection(results);
      if (online != _isOnline) {
        _isOnline = online;
        debugPrint('Conectividade mudou → online: $_isOnline');
        notifyListeners();
      }
    });
  }

  bool _hasConnection(List<ConnectivityResult> results) {
    return results.any((r) =>
        r == ConnectivityResult.mobile ||
        r == ConnectivityResult.wifi ||
        r == ConnectivityResult.ethernet ||
        r == ConnectivityResult.vpn);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
