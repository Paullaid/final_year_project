import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

/// Offline-first SQLite cache for question metadata from Firebase RTDB.
class LocalDatabase {
  LocalDatabase._();

  static final LocalDatabase instance = LocalDatabase._();

  static const String _dbName = 'past_questions.db';
  static const int _dbVersion = 1;

  Database? _db;

  Future<Database> get database async {
    _db ??= await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
CREATE TABLE questions (
  id TEXT PRIMARY KEY,
  title TEXT,
  courseCode TEXT,
  courseTitle TEXT,
  year INTEGER,
  semester INTEGER,
  department TEXT,
  faculty TEXT,
  r2Path TEXT,
  downloads INTEGER,
  updatedAt INTEGER
)
''');
        await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_questions_courseCode ON questions(courseCode)',
        );
        await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_questions_year ON questions(year)',
        );
      },
    );
  }

  /// Batch upsert rows keyed by [id].
  Future<void> insertOrUpdateQuestions(List<Map<String, dynamic>> questions) async {
    if (questions.isEmpty) return;
    final db = await database;
    final batch = db.batch();
    for (final q in questions) {
      final id = q['id']?.toString();
      if (id == null || id.isEmpty) continue;
      batch.insert(
        'questions',
        _normalizeRow(id, q),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Map<String, dynamic> _normalizeRow(String id, Map<String, dynamic> q) {
    return {
      'id': id,
      'title': q['title']?.toString(),
      'courseCode': q['courseCode']?.toString(),
      'courseTitle': q['courseTitle']?.toString(),
      'year': _asInt(q['year']),
      'semester': _asInt(q['semester']),
      'department': q['department']?.toString(),
      'faculty': q['faculty']?.toString(),
      'r2Path': q['r2Path']?.toString(),
      'downloads': _asInt(q['downloads']),
      'updatedAt': _asInt(q['updatedAt']),
    };
  }

  int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is double) return v.round();
    return int.tryParse(v.toString());
  }

  /// LIKE search on courseCode, title, courseTitle (case-insensitive).
  /// Wildcards in user input are stripped so `%` / `_` are treated literally.
  Future<List<Map<String, dynamic>>> searchQuestions(String query) async {
    final db = await database;
    final q = query.trim();
    if (q.isEmpty) {
      final rows = await db.query(
        'questions',
        orderBy: 'courseCode COLLATE NOCASE ASC, year DESC',
      );
      return rows;
    }
    final safe = q.replaceAll('%', '').replaceAll('_', '').toLowerCase();
    if (safe.isEmpty) {
      return db.query(
        'questions',
        orderBy: 'courseCode COLLATE NOCASE ASC, year DESC',
      );
    }
    final pattern = '%$safe%';
    final rows = await db.query(
      'questions',
      where:
          "(LOWER(courseCode) LIKE ? OR LOWER(COALESCE(title, '')) LIKE ? OR LOWER(COALESCE(courseTitle, '')) LIKE ?)",
      whereArgs: [pattern, pattern, pattern],
      orderBy: 'courseCode COLLATE NOCASE ASC, year DESC',
    );
    return rows;
  }

  Future<int> questionCount() async {
    final db = await database;
    final res = await db.rawQuery('SELECT COUNT(*) AS c FROM questions');
    final raw = res.first['c'];
    if (raw is int) return raw;
    return int.parse(raw.toString());
  }

  Future<void> clearAll() async {
    final db = await database;
    await db.delete('questions');
  }

  /// Closes the DB handle (useful for tests).
  Future<void> close() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
  }
}
