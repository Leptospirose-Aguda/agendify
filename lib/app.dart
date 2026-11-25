// lib/app.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/providers/auth_provider.dart';
import 'core/providers/task_provider.dart';
import 'core/providers/event_provider.dart';
import 'core/providers/category_provider.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/home/screens/home_screen.dart';

class AgendifyApp extends StatefulWidget {
  const AgendifyApp({super.key});

  @override
  State<AgendifyApp> createState() => _AgendifyAppState();
}

class _AgendifyAppState extends State<AgendifyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void setThemeMode(ThemeMode mode) {
    setState(() => _themeMode = mode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agendify',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _themeMode,
      home: AuthGate(
        setThemeMode: setThemeMode,
        currentThemeMode: _themeMode,
      ),
      onGenerateRoute: (settings) => AppRoutes.onGenerateRoute(
        settings,
        setThemeMode: setThemeMode,
        currentThemeMode: _themeMode,
      ),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({
    super.key,
    required this.setThemeMode,
    required this.currentThemeMode,
  });

  final ValueChanged<ThemeMode> setThemeMode;
  final ThemeMode currentThemeMode;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _dataLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = Provider.of<AuthProvider>(context);
    if (auth.isLoggedIn && !_dataLoaded) {
      _dataLoaded = true;
      Provider.of<TaskProvider>(context, listen: false).loadTasks();
      Provider.of<EventProvider>(context, listen: false).loadEvents();
      Provider.of<CategoryProvider>(context, listen: false).loadCategories();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    // Aguarda checagem de sessão salva localmente
    if (!auth.initialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Se já estiver logado (online ou sessão offline restaurada), entra direto na Home!
    if (auth.isLoggedIn) {
      return HomeScreen(
        onThemeChanged: widget.setThemeMode,
        currentThemeMode: widget.currentThemeMode,
      );
    }

    return const LoginScreen();
  }
}
