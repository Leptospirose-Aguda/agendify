// lib/services/offline_cache_service.dart
//
// Cache local com sqflite — garante funcionamento offline do Agendify.
// Implementado em: 24/11/2026 — Relatório Semanal #08
//
// Estratégia:
//   • Eventos e tarefas são gravados no SQLite local imediatamente.
//   • Uma coluna `synced` (0/1) rastreia o que ainda não foi para o Firebase.
//   • Ao recuperar conexão, o EventSyncService envia os itens pendentes.

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

class OfflineCacheService {
  static const _dbName = 'agendify_offline.db';
  static const _version = 1;

  Database? _db;

  Future<Database> get db async {
    _db ??= await _openDatabase();
    return _db!;
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

  /// Insere ou atualiza um evento localmente.
  /// [synced] = false quando criado offline; = true quando vindo do Firebase.
  Future<void> upsertEvent(Map<String, dynamic> event, {bool synced = false}) async {
    final d = await db;
    final row = Map<String, dynamic>.from(event);
    row['synced'] = synced ? 1 : 0;
    row.remove('deletedAt');
    await d.insert(
      'events',
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Retorna todos os eventos locais que ainda não foram sincronizados.
  Future<List<Map<String, dynamic>>> getPendingEvents() async {
    final d = await db;
    return d.query('events', where: 'synced = 0 AND deletedAt IS NULL');
  }

  /// Retorna todos os eventos do banco local (incluindo os já sincronizados).
  Future<List<Map<String, dynamic>>> getAllLocalEvents() async {
    final d = await db;
    return d.query('events', where: 'deletedAt IS NULL', orderBy: 'start ASC');
  }

  /// Marca um evento como sincronizado.
  Future<void> markEventSynced(String id) async {
    final d = await db;
    await d.update('events', {'synced': 1}, where: 'id = ?', whereArgs: [id]);
  }

  /// Remove logicamente um evento (soft-delete) para sincronização posterior.
  Future<void> deleteEventLocally(String id, {bool synced = false}) async {
    final d = await db;
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

  /// Retorna deleções pendentes de sincronização.
  Future<List<Map<String, dynamic>>> getPendingDeletedEvents() async {
    final d = await db;
    return d.query(
      'events',
      where: 'synced = 0 AND deletedAt IS NOT NULL',
    );
  }

  // ─── TASKS ────────────────────────────────────────────────────────────────

  Future<void> upsertTask(Map<String, dynamic> task, {bool synced = false}) async {
    final d = await db;
    final row = Map<String, dynamic>.from(task);
    row['synced'] = synced ? 1 : 0;
    row.remove('deletedAt');
    await d.insert(
      'tasks',
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getPendingTasks() async {
    final d = await db;
    return d.query('tasks', where: 'synced = 0 AND deletedAt IS NULL');
  }

  Future<List<Map<String, dynamic>>> getAllLocalTasks() async {
    final d = await db;
    return d.query('tasks', where: 'deletedAt IS NULL', orderBy: 'createdAt DESC');
  }

  Future<void> markTaskSynced(String id) async {
    final d = await db;
    await d.update('tasks', {'synced': 1}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteTaskLocally(String id, {bool synced = false}) async {
    final d = await db;
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
    return d.query(
      'tasks',
      where: 'synced = 0 AND deletedAt IS NOT NULL',
    );
  }

  // ─── UTILS ────────────────────────────────────────────────────────────────

  /// Popula o cache com dados vindos do Firebase (marcando como synced).
  Future<void> seedFromFirebase({
    required List<Map<String, dynamic>> events,
    required List<Map<String, dynamic>> tasks,
  }) async {
    final d = await db;
    final batch = d.batch();
    for (final e in events) {
      final row = Map<String, dynamic>.from(e)..['synced'] = 1;
      batch.insert('events', row, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    for (final t in tasks) {
      final row = Map<String, dynamic>.from(t)..['synced'] = 1;
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
