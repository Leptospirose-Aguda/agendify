import 'package:flutter/material.dart';

import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';

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
      initialRoute: AppRoutes.login,
      onGenerateRoute: (settings) => AppRoutes.onGenerateRoute(
        settings,
        setThemeMode: setThemeMode,
        currentThemeMode: _themeMode,
      ),
    );
  }
}
