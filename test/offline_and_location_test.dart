import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agendify/app.dart';
import 'package:agendify/models/event_model.dart';
import 'package:agendify/models/task_model.dart';
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

  group('EventModel Testes Unitários', () {
    test('Serialização e deserialização JSON correta', () {
      final now = DateTime.now();
      final end = now.add(const Duration(hours: 2));

      final event = EventModel(
        id: 'evt-123',
        title: 'Reunião de Alinhamento',
        start: now,
        end: end,
        description: 'Discussão sobre arquitetura offline',
        location: 'Av. Sete de Setembro, Curitiba, PR',
        category: 'Trabalho',
        notes: 'Levar anotações do relatório',
        isRecurring: true,
      );

      final json = event.toJson();
      expect(json['id'], 'evt-123');
      expect(json['title'], 'Reunião de Alinhamento');
      expect(json['location'], 'Av. Sete de Setembro, Curitiba, PR');
      expect(json['isRecurring'], true);

      final fromJson = EventModel.fromJson(json);
      expect(fromJson.id, event.id);
      expect(fromJson.title, event.title);
      expect(fromJson.location, event.location);
      expect(fromJson.duration.inHours, 2);
      expect(fromJson.isRecurring, true);
    });

    test('Validação de evento com localização vazia/opcional', () {
      final event = EventModel(
        id: 'evt-456',
        title: 'Estudo Flutter',
        start: DateTime(2026, 11, 24, 14, 0),
        end: DateTime(2026, 11, 24, 16, 0),
      );

      expect(event.location, isNull);
      expect(event.isRecurring, false);
      expect(event.duration.inMinutes, 120);
    });
  });

  group('TaskModel Testes Unitários (Offline & Persistência)', () {
    test('Serialização e deserialização JSON com campos offline', () {
      final deadline = DateTime(2026, 11, 30);
      final task = TaskModel(
        id: 'task-789',
        title: 'Finalizar relatório semanal',
        deadline: deadline,
        isCompleted: false,
      );

      final json = task.toJson();
      expect(json['id'], 'task-789');
      expect(json['title'], 'Finalizar relatório semanal');
      expect(json['isCompleted'], false);
      expect(json['createdAt'], isNotNull);

      final fromJson = TaskModel.fromJson(json);
      expect(fromJson.id, task.id);
      expect(fromJson.title, task.title);
      expect(fromJson.isCompleted, false);

      final completed = fromJson.copyWith(isCompleted: true);
      expect(completed.isCompleted, true);
      expect(completed.id, task.id);
    });
  });

  group('AuthProvider e Auto-Login Offline', () {
    test('loginOffline ativa a sessão local com sucesso', () async {
      SharedPreferences.setMockInitialValues({});
      final auth = AuthProvider();
      await auth.loginOffline();

      expect(auth.isLoggedIn, true);
      expect(auth.isOfflineSession, true);
      expect(auth.email, isNotNull);
    });

    testWidgets('Auto-login: quando há sessão salva, app abre direto na HomeScreen sem pedir login', (tester) async {
      // Simula sessão previamente salva no aparelho antes de desligar a internet e forçar a parada
      SharedPreferences.setMockInitialValues({
        'isLoggedIn': true,
        'uid': 'user_123',
        'email': 'teste@agendify.com',
        'username': 'Bruno',
      });

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

      await tester.pumpAndSettle();

      // NÃO deve exibir tela de login
      expect(find.text('Entre na sua conta'), findsNothing);
      // DEVE estar na HomeScreen (exibe a barra de navegação com Início, Agenda, etc.)
      expect(find.text('Início'), findsOneWidget);
      expect(find.text('Agenda'), findsOneWidget);
      expect(find.text('Tarefas'), findsOneWidget);
    });
  });
}
