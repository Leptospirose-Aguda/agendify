// lib/services/offline_cache_service.dart
//
// Cache local com sqflite — garante funcionamento offline do Agendify.
// Implementado em: 24/11/2026 — Relatório Semanal #08

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

class OfflineCacheService {
  static const _dbName = 'agendify_offline.db';
  static const _version = 1;

  Database? _db;
  bool _useInMemoryFallback = false;
  final Map<String, Map<String, dynamic>> _inMemoryEvents = {};
  final Map<String, Map<String, dynamic>> _inMemoryTasks = {};

  Future<Database?> get db async {
    if (_useInMemoryFallback) return null;
    if (_db != null) return _db;
    try {
      _db = await _openDatabase();
      return _db;
    } catch (e) {
      debugPrint('OfflineCacheService SQLite initialization fallback: $e');
      _useInMemoryFallback = true;
      return null;
    }
  }

  Future<Database> _openDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = '$dbPath/$_dbName';
    return openDatabase(
      path,
      version: _version,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE events (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        start TEXT NOT NULL,
        end TEXT NOT NULL,
        description TEXT,
        location TEXT,
        category TEXT,
        notes TEXT,
        isRecurring INTEGER NOT NULL DEFAULT 0,
        synced INTEGER NOT NULL DEFAULT 0,
        deletedAt TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        deadline TEXT,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL,
        synced INTEGER NOT NULL DEFAULT 0,
        deletedAt TEXT
      )
    ''');
  }

  // ─── EVENTS ───────────────────────────────────────────────────────────────

  Future<void> upsertEvent(Map<String, dynamic> event, {bool synced = false}) async {
    final row = Map<String, dynamic>.from(event);
    row['synced'] = synced ? 1 : 0;
    if (row['isRecurring'] is bool) {
      row['isRecurring'] = (row['isRecurring'] as bool) ? 1 : 0;
    }
    row.remove('deletedAt');

    final d = await db;
    if (d == null) {
      _inMemoryEvents[row['id'] as String] = row;
      return;
    }
    await d.insert(
      'events',
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getPendingEvents() async {
    final d = await db;
    if (d == null) {
      return _inMemoryEvents.values
          .where((e) => e['synced'] == 0 && e['deletedAt'] == null)
          .toList();
    }
    return d.query('events', where: 'synced = 0 AND deletedAt IS NULL');
  }

  Future<List<Map<String, dynamic>>> getAllLocalEvents() async {
    final d = await db;
    if (d == null) {
      final list = _inMemoryEvents.values
          .where((e) => e['deletedAt'] == null)
          .toList();
      list.sort((a, b) => ((a['start'] as String?) ?? '').compareTo((b['start'] as String?) ?? ''));
      return list;
    }
    return d.query('events', where: 'deletedAt IS NULL', orderBy: 'start ASC');
  }

  Future<void> markEventSynced(String id) async {
    final d = await db;
    if (d == null) {
      if (_inMemoryEvents.containsKey(id)) {
        _inMemoryEvents[id]!['synced'] = 1;
      }
      return;
    }
    await d.update('events', {'synced': 1}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteEventLocally(String id, {bool synced = false}) async {
    final d = await db;
    if (d == null) {
      if (_inMemoryEvents.containsKey(id)) {
        _inMemoryEvents[id]!['deletedAt'] = DateTime.now().toIso8601String();
        _inMemoryEvents[id]!['synced'] = synced ? 1 : 0;
      }
      return;
    }
    await d.update(
      'events',
      {
        'deletedAt': DateTime.now().toIso8601String(),
        'synced': synced ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getPendingDeletedEvents() async {
    final d = await db;
    if (d == null) {
      return _inMemoryEvents.values
          .where((e) => e['synced'] == 0 && e['deletedAt'] != null)
          .toList();
    }
    return d.query(
      'events',
      where: 'synced = 0 AND deletedAt IS NOT NULL',
    );
  }

  // ─── TASKS ────────────────────────────────────────────────────────────────

  Future<void> upsertTask(Map<String, dynamic> task, {bool synced = false}) async {
    final row = Map<String, dynamic>.from(task);
    row['synced'] = synced ? 1 : 0;
    if (row['isCompleted'] is bool) {
      row['isCompleted'] = (row['isCompleted'] as bool) ? 1 : 0;
    }
    row.remove('deletedAt');

    final d = await db;
    if (d == null) {
      _inMemoryTasks[row['id'] as String] = row;
      return;
    }
    await d.insert(
      'tasks',
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getPendingTasks() async {
    final d = await db;
    if (d == null) {
      return _inMemoryTasks.values
          .where((e) => e['synced'] == 0 && e['deletedAt'] == null)
          .toList();
    }
    return d.query('tasks', where: 'synced = 0 AND deletedAt IS NULL');
  }

  Future<List<Map<String, dynamic>>> getAllLocalTasks() async {
    final d = await db;
    if (d == null) {
      final list = _inMemoryTasks.values
          .where((e) => e['deletedAt'] == null)
          .toList();
      list.sort((a, b) => ((b['createdAt'] as String?) ?? '').compareTo((a['createdAt'] as String?) ?? ''));
      return list;
    }
    return d.query('tasks', where: 'deletedAt IS NULL', orderBy: 'createdAt DESC');
  }

  Future<void> markTaskSynced(String id) async {
    final d = await db;
    if (d == null) {
      if (_inMemoryTasks.containsKey(id)) {
        _inMemoryTasks[id]!['synced'] = 1;
      }
      return;
    }
    await d.update('tasks', {'synced': 1}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteTaskLocally(String id, {bool synced = false}) async {
    final d = await db;
    if (d == null) {
      if (_inMemoryTasks.containsKey(id)) {
        _inMemoryTasks[id]!['deletedAt'] = DateTime.now().toIso8601String();
        _inMemoryTasks[id]!['synced'] = synced ? 1 : 0;
      }
      return;
    }
    await d.update(
      'tasks',
      {
        'deletedAt': DateTime.now().toIso8601String(),
        'synced': synced ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getPendingDeletedTasks() async {
    final d = await db;
    if (d == null) {
      return _inMemoryTasks.values
          .where((e) => e['synced'] == 0 && e['deletedAt'] != null)
          .toList();
    }
    return d.query(
      'tasks',
      where: 'synced = 0 AND deletedAt IS NOT NULL',
    );
  }

  // ─── UTILS ────────────────────────────────────────────────────────────────

  Future<void> seedFromFirebase({
    required List<Map<String, dynamic>> events,
    required List<Map<String, dynamic>> tasks,
  }) async {
    final d = await db;
    if (d == null) {
      for (final e in events) {
        final row = Map<String, dynamic>.from(e)..['synced'] = 1;
        if (row['isRecurring'] is bool) {
          row['isRecurring'] = (row['isRecurring'] as bool) ? 1 : 0;
        }
        _inMemoryEvents[row['id'] as String] = row;
      }
      for (final t in tasks) {
        final row = Map<String, dynamic>.from(t)..['synced'] = 1;
        if (row['isCompleted'] is bool) {
          row['isCompleted'] = (row['isCompleted'] as bool) ? 1 : 0;
        }
        _inMemoryTasks[row['id'] as String] = row;
      }
      debugPrint('OfflineCacheService: cache in-memory populado do Firebase.');
      return;
    }

    final batch = d.batch();
    for (final e in events) {
      final row = Map<String, dynamic>.from(e)..['synced'] = 1;
      if (row['isRecurring'] is bool) {
        row['isRecurring'] = (row['isRecurring'] as bool) ? 1 : 0;
      }
      batch.insert('events', row, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    for (final t in tasks) {
      final row = Map<String, dynamic>.from(t)..['synced'] = 1;
      if (row['isCompleted'] is bool) {
        row['isCompleted'] = (row['isCompleted'] as bool) ? 1 : 0;
      }
      batch.insert('tasks', row, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
    debugPrint('OfflineCacheService: cache populado do Firebase.');
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
