import '../models/event_model.dart';
import '../models/task_model.dart';

abstract final class MockData {
  static final events = <EventModel>[
    EventModel(
      id: '1',
      title: 'Reunião do projeto',
      start: DateTime.now().add(const Duration(hours: 2)),
      end: DateTime.now().add(const Duration(hours: 3)),
      location: 'Sala 04',
      category: 'Faculdade',
      description: 'Revisar tarefas e próximas entregas.',
    ),
    EventModel(
      id: '2',
      title: 'Treino',
      start: DateTime.now().add(const Duration(days: 1, hours: 1)),
      end: DateTime.now().add(const Duration(days: 1, hours: 2)),
      category: 'Pessoal',
    ),
  ];

  static final tasks = <TaskModel>[
    TaskModel(
      id: '1',
      title: 'Finalizar protótipo do Agendify',
      deadline: DateTime.now().add(const Duration(days: 2)),
    ),
    const TaskModel(
      id: '2',
      title: 'Revisar requisitos do projeto',
    ),
  ];
}
