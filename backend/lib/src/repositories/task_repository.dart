import 'package:sqlite3/sqlite3.dart';
import 'package:uuid/uuid.dart';

class TaskRepository {
  TaskRepository(this._db);

  final Database _db;
  static const _uuid = Uuid();

  List<Map<String, dynamic>> findAll() {
    final rows = _db.select('SELECT * FROM tasks ORDER BY is_completed ASC, deadline ASC, created_at DESC');
    return rows.map(_toJson).toList();
  }

  Map<String, dynamic>? findById(String id) {
    final rows = _db.select('SELECT * FROM tasks WHERE id = ?', [id]);
    if (rows.isEmpty) return null;
    return _toJson(rows.first);
  }

  Map<String, dynamic> create(Map<String, dynamic> input) {
    _validate(input);
    final id = _uuid.v4();
    final now = DateTime.now().toUtc().toIso8601String();
    _db.execute(
      """INSERT INTO tasks (id, title, deadline, is_completed, created_at, updated_at)
         VALUES (?, ?, ?, ?, ?, ?)""",
      [id, input['title'], input['deadline'], input['isCompleted'] == true ? 1 : 0, now, now],
    );
    return findById(id)!;
  }

  Map<String, dynamic>? update(String id, Map<String, dynamic> input) {
    if (findById(id) == null) return null;
    _validate(input);
    final now = DateTime.now().toUtc().toIso8601String();
    _db.execute(
      'UPDATE tasks SET title = ?, deadline = ?, is_completed = ?, updated_at = ? WHERE id = ?',
      [input['title'], input['deadline'], input['isCompleted'] == true ? 1 : 0, now, id],
    );
    return findById(id);
  }

  bool delete(String id) {
    if (findById(id) == null) return false;
    _db.execute('DELETE FROM tasks WHERE id = ?', [id]);
    return true;
  }

  void _validate(Map<String, dynamic> input) {
    final title = input['title'];
    if (title is! String || title.trim().isEmpty) {
      throw const FormatException('O título da tarefa é obrigatório.');
    }
    final deadline = input['deadline'];
    if (deadline != null && (deadline is! String || DateTime.tryParse(deadline) == null)) {
      throw const FormatException('Prazo inválido.');
    }
  }

  Map<String, dynamic> _toJson(Row row) => {
        'id': row['id'],
        'title': row['title'],
        'deadline': row['deadline'],
        'isCompleted': row['is_completed'] == 1,
        'createdAt': row['created_at'],
        'updatedAt': row['updated_at'],
      };
}
