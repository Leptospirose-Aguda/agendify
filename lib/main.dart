// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'app.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/event_provider.dart';
import 'core/providers/task_provider.dart';
import 'core/providers/category_provider.dart';
import 'services/event_service.dart';
import 'services/task_service.dart';
import 'services/category_service.dart';
import 'services/connectivity_service.dart';
import 'services/offline_cache_service.dart';
import 'services/sync_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Firebase com tratamento de erro
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init error: $e');
  }

  // Serviços compartilhados
  final connectivity = ConnectivityService();
  await connectivity.init(); // Detecta imediatamente se está offline no início

  final cache = OfflineCacheService();
  final eventService = EventService(connectivity: connectivity, cache: cache);
  final taskService = TaskService(connectivity: connectivity, cache: cache);

  // SyncService: escuta reconexão e sincroniza automaticamente
  final syncService = SyncService(
    connectivity: connectivity,
    eventService: eventService,
    taskService: taskService,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: connectivity),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(
          create: (_) => EventProvider(eventService, connectivity),
        ),
        ChangeNotifierProvider(
          create: (_) => TaskProvider(taskService, connectivity),
        ),
        ChangeNotifierProvider(create: (_) => CategoryProvider(CategoryService())),
        Provider.value(value: syncService),
      ],
      child: const AgendifyApp(),
    ),
  );
}
