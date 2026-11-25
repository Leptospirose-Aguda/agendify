import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agendify/app.dart';
import 'package:agendify/core/providers/auth_provider.dart';
import 'package:agendify/core/providers/event_provider.dart';
import 'package:agendify/core/providers/task_provider.dart';
import 'package:agendify/core/providers/category_provider.dart';
import 'package:agendify/services/connectivity_service.dart';
import 'package:agendify/services/event_service.dart';
import 'package:agendify/services/task_service.dart';
import 'package:agendify/services/category_service.dart';
import 'package:agendify/services/offline_cache_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({'isLoggedIn': false});
  });

  testWidgets('Agendify abre na tela de login quando não há sessão salva', (tester) async {
    final connectivity = ConnectivityService();
    final cache = OfflineCacheService();
    final eventService = EventService(connectivity: connectivity, cache: cache);
    final taskService = TaskService(connectivity: connectivity, cache: cache);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: connectivity),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => EventProvider(eventService, connectivity)),
          ChangeNotifierProvider(create: (_) => TaskProvider(taskService, connectivity)),
          ChangeNotifierProvider(create: (_) => CategoryProvider(CategoryService())),
        ],
        child: const AgendifyApp(),
      ),
    );

    // Aguarda término da animação/renderização
    await tester.pumpAndSettle();

    // Deve exibir o título de login e a opção offline
    expect(find.text('Entre na sua conta'), findsOneWidget);
    expect(find.text('Acessar agenda offline'), findsOneWidget);
  });
}
