import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'app.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/event_provider.dart';
import 'core/providers/task_provider.dart';
import 'services/event_service.dart';
import 'services/task_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init error: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider(EventService())),
        ChangeNotifierProvider(create: (_) => TaskProvider(TaskService())),
      ],
      child: const AgendifyApp(),
    ),
  );
}

