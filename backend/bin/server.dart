import 'dart:io';

import 'package:agendify_backend/src/api.dart';
import 'package:agendify_backend/src/database/app_database.dart';
import 'package:agendify_backend/src/repositories/event_repository.dart';
import 'package:agendify_backend/src/repositories/task_repository.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

Future<void> main() async {
  final database = AppDatabase.open();
  final api = AgendifyApi(
    events: EventRepository(database.db),
    tasks: TaskRepository(database.db),
  );

  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsMiddleware())
      .addHandler(api.router.call);

  final port = int.tryParse(Platform.environment['PORT'] ?? '') ?? 8080;
  final server = await shelf_io.serve(handler, InternetAddress.anyIPv4, port);

  stdout.writeln('Agendify API executando em http://localhost:${server.port}');
  stdout.writeln('Health check: http://localhost:${server.port}/health');

  ProcessSignal.sigint.watch().listen((_) async {
    await server.close(force: true);
    database.close();
    exit(0);
  });
}
