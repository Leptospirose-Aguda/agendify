import 'package:flutter/material.dart';

import '../../features/auth/screens/login_screen.dart';
import '../../features/events/screens/event_details_screen.dart';
import '../../features/events/screens/event_form_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../models/event_model.dart';

abstract final class AppRoutes {
  static const login = '/';
  static const home = '/home';
  static const newEvent = '/events/new';
  static const eventDetails = '/events/details';

  static Route<dynamic> onGenerateRoute(
    RouteSettings settings, {
    required ValueChanged<ThemeMode> setThemeMode,
    required ThemeMode currentThemeMode,
  }) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );

      case home:
        return MaterialPageRoute(
          builder: (_) => HomeScreen(
            onThemeChanged: setThemeMode,
            currentThemeMode: currentThemeMode,
          ),
          settings: settings,
        );

      case newEvent:
        return MaterialPageRoute(
          builder: (_) => const EventFormScreen(),
          settings: settings,
        );

      case eventDetails:
        final event = settings.arguments as EventModel?;
        return MaterialPageRoute(
          builder: (_) => EventDetailsScreen(event: event),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Página não encontrada'),
            ),
          ),
        );
    }
  }
}
