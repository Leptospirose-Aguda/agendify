import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'repositories/event_repository.dart';
import 'repositories/task_repository.dart';

class AgendifyApi {
  AgendifyApi({required EventRepository events, required TaskRepository tasks})
      : _events = events,
        _tasks = tasks;

  final EventRepository _events;
  final TaskRepository _tasks;

  Router get router {
    final router = Router();
    router.get('/health', (Request request) => _json({'status': 'ok'}));

    router.get('/api/events', (Request request) => _json(_events.findAll()));
    router.get('/api/events/<id>', (Request request, String id) {
      final event = _events.findById(id);
      return event == null ? _error('Evento não encontrado.', 404) : _json(event);
    });
    router.post('/api/events', (Request request) => _createEvent(request));
    router.put('/api/events/<id>', (Request request, String id) => _updateEvent(request, id));
    router.delete('/api/events/<id>', (Request request, String id) {
      return _events.delete(id)
          ? _json({'deleted': true})
          : _error('Evento não encontrado.', 404);
    });

    router.get('/api/tasks', (Request request) => _json(_tasks.findAll()));
    router.get('/api/tasks/<id>', (Request request, String id) {
      final task = _tasks.findById(id);
      return task == null ? _error('Tarefa não encontrada.', 404) : _json(task);
    });
    router.post('/api/tasks', (Request request) => _createTask(request));
    router.put('/api/tasks/<id>', (Request request, String id) => _updateTask(request, id));
    router.delete('/api/tasks/<id>', (Request request, String id) {
      return _tasks.delete(id)
          ? _json({'deleted': true})
          : _error('Tarefa não encontrada.', 404);
    });

    return router;
  }

  Future<Response> _createEvent(Request request) async {
    try {
      final input = await _body(request);
      return _json(_events.create(input), statusCode: 201);
    } on FormatException catch (error) {
      return _error(error.message, 400);
    }
  }

  Future<Response> _updateEvent(Request request, String id) async {
    try {
      final input = await _body(request);
      final event = _events.update(id, input);
      return event == null ? _error('Evento não encontrado.', 404) : _json(event);
    } on FormatException catch (error) {
      return _error(error.message, 400);
    }
  }

  Future<Response> _createTask(Request request) async {
    try {
      final input = await _body(request);
      return _json(_tasks.create(input), statusCode: 201);
    } on FormatException catch (error) {
      return _error(error.message, 400);
    }
  }

  Future<Response> _updateTask(Request request, String id) async {
    try {
      final input = await _body(request);
      final task = _tasks.update(id, input);
      return task == null ? _error('Tarefa não encontrada.', 404) : _json(task);
    } on FormatException catch (error) {
      return _error(error.message, 400);
    }
  }

  Future<Map<String, dynamic>> _body(Request request) async {
    final text = await request.readAsString();
    if (text.isEmpty) throw const FormatException('Corpo da requisição vazio.');
    final decoded = jsonDecode(text);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('JSON inválido.');
    }
    return decoded;
  }

  Response _json(Object value, {int statusCode = 200}) => Response(
        statusCode,
        body: jsonEncode(value),
        headers: _headers,
      );

  Response _error(String message, int statusCode) =>
      _json({'error': message}, statusCode: statusCode);

  static const _headers = {
    'Content-Type': 'application/json; charset=utf-8',
    'Access-Control-Allow-Origin': '*',
  };
}

Middleware corsMiddleware() {
  return (innerHandler) {
    return (request) async {
      if (request.method == 'OPTIONS') {
        return Response.ok('', headers: const {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
          'Access-Control-Allow-Headers': 'Origin, Content-Type, Accept',
        });
      }
      final response = await innerHandler(request);
      return response.change(headers: {
        ...response.headers,
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': 'Origin, Content-Type, Accept',
      });
    };
  };
}
