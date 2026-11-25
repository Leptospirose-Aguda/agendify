import 'package:flutter_test/flutter_test.dart';
import 'package:agendify/models/event_model.dart';
import 'package:agendify/models/task_model.dart';

void main() {
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
}
