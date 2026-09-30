import 'dart:io';

import 'package:sqlite3/sqlite3.dart';

class AppDatabase {
  AppDatabase._(this.db);

  final Database db;

  static AppDatabase open({String? path}) {
    final databasePath = path ?? Platform.environment['AGENDIFY_DB_PATH'] ?? 'data/agendify.db';
    final file = File(databasePath);
    file.parent.createSync(recursive: true);
    final db = sqlite3.open(file.path);
    final instance = AppDatabase._(db);
    instance._configure();
    instance._migrate();
    return instance;
  }

  void _configure() {
    db.execute('PRAGMA foreign_keys = ON;');
    db.execute('PRAGMA journal_mode = WAL;');
  }

  void _migrate() {
    db.execute("""
      CREATE TABLE IF NOT EXISTS events (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        start_at TEXT NOT NULL,
        end_at TEXT NOT NULL,
        location TEXT,
        category TEXT,
        notes TEXT,
        is_recurring INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      );
    """);

    db.execute("""
      CREATE TABLE IF NOT EXISTS tasks (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        deadline TEXT,
        is_completed INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      );
    """);

    db.execute('CREATE INDEX IF NOT EXISTS idx_events_start_at ON events(start_at);');
    db.execute('CREATE INDEX IF NOT EXISTS idx_tasks_deadline ON tasks(deadline);');
  }

  void close() => db.dispose();
}
