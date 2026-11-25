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
      initialRoute: AppRoutes.root,
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

  void _triggerInitialDataLoad() {
    if (!_dataLoaded) {
      _dataLoaded = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Provider.of<TaskProvider>(context, listen: false).loadTasks();
        Provider.of<EventProvider>(context, listen: false).loadEvents();
        Provider.of<CategoryProvider>(context, listen: false).loadCategories();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    // Enquanto carrega a verificação da sessão local
    if (!auth.initialized) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/agendify_logo.png',
                height: 80,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.calendar_month,
                  size: 80,
                  color: Color(0xFF185286),
                ),
              ),
              const SizedBox(height: 24),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      );
    }

    // Se já está logado (sessão online ou offline restaurada), entra direto na Home!
    if (auth.isLoggedIn) {
      _triggerInitialDataLoad();
      return HomeScreen(
        onThemeChanged: widget.setThemeMode,
        currentThemeMode: widget.currentThemeMode,
      );
    }

    // Se deslogado, vai para a tela de login
    return const LoginScreen();
  }
}
