import 'package:sqlite3/sqlite3.dart';
import 'package:uuid/uuid.dart';

class EventRepository {
  EventRepository(this._db);

  final Database _db;
  static const _uuid = Uuid();

  List<Map<String, dynamic>> findAll() {
    final rows = _db.select('SELECT * FROM events ORDER BY start_at ASC');
    return rows.map(_toJson).toList();
  }

  Map<String, dynamic>? findById(String id) {
    final rows = _db.select('SELECT * FROM events WHERE id = ?', [id]);
    if (rows.isEmpty) return null;
    return _toJson(rows.first);
  }

  Map<String, dynamic> create(Map<String, dynamic> input) {
    _validate(input);
    final id = _uuid.v4();
    final now = DateTime.now().toUtc().toIso8601String();
    _db.execute(
      """INSERT INTO events (
        id, title, description, start_at, end_at, location, category, notes,
        is_recurring, created_at, updated_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)""",
      [
        id,
        input['title'],
        input['description'],
        input['start'],
        input['end'],
        input['location'],
        input['category'],
        input['notes'],
        input['isRecurring'] == true ? 1 : 0,
        now,
        now,
      ],
    );
    return findById(id)!;
  }

  Map<String, dynamic>? update(String id, Map<String, dynamic> input) {
    if (findById(id) == null) return null;
    _validate(input);
    final now = DateTime.now().toUtc().toIso8601String();
    _db.execute(
      """UPDATE events SET
        title = ?, description = ?, start_at = ?, end_at = ?, location = ?,
        category = ?, notes = ?, is_recurring = ?, updated_at = ?
        WHERE id = ?""",
      [
        input['title'],
        input['description'],
        input['start'],
        input['end'],
        input['location'],
        input['category'],
        input['notes'],
        input['isRecurring'] == true ? 1 : 0,
        now,
        id,
      ],
    );
    return findById(id);
  }

  bool delete(String id) {
    if (findById(id) == null) return false;
    _db.execute('DELETE FROM events WHERE id = ?', [id]);
    return true;
  }

  void _validate(Map<String, dynamic> input) {
    final title = input['title'];
    final start = input['start'];
    final end = input['end'];
    if (title is! String || title.trim().isEmpty) {
      throw const FormatException('O título é obrigatório.');
    }
    if (start is! String || DateTime.tryParse(start) == null) {
      throw const FormatException('Data/hora inicial inválida.');
    }
    if (end is! String || DateTime.tryParse(end) == null) {
      throw const FormatException('Data/hora final inválida.');
    }
    if (!DateTime.parse(end).isAfter(DateTime.parse(start))) {
      throw const FormatException('O término deve ser posterior ao início.');
    }
  }

  Map<String, dynamic> _toJson(Row row) => {
        'id': row['id'],
        'title': row['title'],
        'description': row['description'],
        'start': row['start_at'],
        'end': row['end_at'],
        'location': row['location'],
        'category': row['category'],
        'notes': row['notes'],
        'isRecurring': row['is_recurring'] == 1,
        'createdAt': row['created_at'],
        'updatedAt': row['updated_at'],
      };
}
