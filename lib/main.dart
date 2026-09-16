import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/event_provider.dart';
import 'core/providers/task_provider.dart';
import 'services/event_service.dart';
import 'services/task_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
