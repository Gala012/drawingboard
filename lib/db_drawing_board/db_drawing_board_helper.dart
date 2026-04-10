import 'dart:convert';

import 'package:drawing_board/db_drawing_board/data.dart';
import 'package:drawing_board/drawing/document_model.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class ProjectTableAggregate {
  const ProjectTableAggregate({
    required this.projectCount,
    required this.maxCanvasW,
    required this.maxCanvasH,
    required this.latestUpdatedAtMs,
  });

  final int projectCount;
  final int maxCanvasW;
  final int maxCanvasH;
  final int latestUpdatedAtMs;
}

class DocumentAggregateStats {
  const DocumentAggregateStats({
    required this.totalLayerCount,
    required this.traceProjectCount,
  });

  final int totalLayerCount;
  final int traceProjectCount;
}

class ProjectRow {
  ProjectRow({
    required this.id,
    required this.title,
    this.thumbPath,
    required this.updatedAt,
    required this.canvasW,
    required this.canvasH,
    required this.docJson,
  });

  final int id;
  final String title;
  final String? thumbPath;
  final int updatedAt;
  final int canvasW;
  final int canvasH;
  final String docJson;

  DrawingDocument parseDoc() {
    return DrawingDocument.fromJson(
      jsonDecode(docJson) as Map<String, dynamic>,
    );
  }
}

class DbDrawingBoardHelper {
  DbDrawingBoardHelper._();
  static final DbDrawingBoardHelper instance = DbDrawingBoardHelper._();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) {
      return _db!;
    }
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, DbDrawingBoardData.dbName);
    _db = await openDatabase(
      path,
      version: DbDrawingBoardData.dbVersion,
      onCreate: (db, version) async {
        await db.execute(DbDrawingBoardData.createProjects);
        await db.execute(DbDrawingBoardData.createStrokeStats);
      },
    );
    return _db!;
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }

  Future<int> insertProject({
    required String title,
    required DrawingDocument doc,
    String? thumbPath,
  }) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    return db.insert(DbDrawingBoardData.tableProjects, {
      'title': title,
      'thumb_path': thumbPath,
      'updated_at': now,
      'canvas_w': doc.canvasWidth.round(),
      'canvas_h': doc.canvasHeight.round(),
      'doc_json': jsonEncode(doc.toJson()),
    });
  }

  Future<void> updateProject({
    required int id,
    String? title,
    DrawingDocument? doc,
    String? thumbPath,
  }) async {
    final db = await database;
    final map = <String, Object?>{'updated_at': DateTime.now().millisecondsSinceEpoch};
    if (title != null) {
      map['title'] = title;
    }
    if (doc != null) {
      map['canvas_w'] = doc.canvasWidth.round();
      map['canvas_h'] = doc.canvasHeight.round();
      map['doc_json'] = jsonEncode(doc.toJson());
    }
    if (thumbPath != null) {
      map['thumb_path'] = thumbPath;
    }
    await db.update(
      DbDrawingBoardData.tableProjects,
      map,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteProject(int id) async {
    final db = await database;
    await db.delete(
      DbDrawingBoardData.tableProjects,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<ProjectRow?> getProject(int id) async {
    final db = await database;
    final rows = await db.query(
      DbDrawingBoardData.tableProjects,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return _rowToProject(rows.first);
  }

  Future<List<ProjectRow>> listProjects({int limit = 100}) async {
    final db = await database;
    final rows = await db.query(
      DbDrawingBoardData.tableProjects,
      orderBy: 'updated_at DESC',
      limit: limit,
    );
    return rows.map(_rowToProject).toList();
  }

  Future<int> projectCount() async {
    final db = await database;
    final r = await db.rawQuery(
      'SELECT COUNT(*) AS c FROM ${DbDrawingBoardData.tableProjects}',
    );
    final v = r.first['c'] as int?;
    return v ?? 0;
  }

  ProjectRow _rowToProject(Map<String, Object?> r) {
    return ProjectRow(
      id: r['id']! as int,
      title: r['title']! as String,
      thumbPath: r['thumb_path'] as String?,
      updatedAt: r['updated_at']! as int,
      canvasW: r['canvas_w']! as int,
      canvasH: r['canvas_h']! as int,
      docJson: r['doc_json']! as String,
    );
  }

  Future<void> addStrokeCountForToday(int delta) async {
    if (delta <= 0) {
      return;
    }
    final db = await database;
    final day = _todayKey();
    await db.rawInsert(
      '''
INSERT INTO ${DbDrawingBoardData.tableStrokeStats}(day, stroke_count)
VALUES (?, ?)
ON CONFLICT(day) DO UPDATE SET stroke_count = stroke_count + excluded.stroke_count
''',
      [day, delta],
    );
  }

  Future<int> totalStrokeCount() async {
    final db = await database;
    final r = await db.rawQuery(
      'SELECT SUM(stroke_count) as t FROM ${DbDrawingBoardData.tableStrokeStats}',
    );
    final v = r.first['t'] as int?;
    return v ?? 0;
  }

  Future<int> strokeCountForToday() async {
    final db = await database;
    final rows = await db.query(
      DbDrawingBoardData.tableStrokeStats,
      columns: ['stroke_count'],
      where: 'day = ?',
      whereArgs: [_todayKey()],
      limit: 1,
    );
    if (rows.isEmpty) {
      return 0;
    }
    return rows.first['stroke_count'] as int? ?? 0;
  }

  Future<int> strokeSumForLastDays(int days) async {
    if (days < 1) {
      return 0;
    }
    final map = await strokeCountsLastDays(days);
    var sum = 0;
    for (final n in map.values) {
      sum += n;
    }
    return sum;
  }

  Future<ProjectTableAggregate> loadProjectTableAggregate() async {
    final db = await database;
    final r = await db.rawQuery('''
SELECT COUNT(*) AS c, MAX(canvas_w) AS mw, MAX(canvas_h) AS mh,
       MAX(updated_at) AS lu
FROM ${DbDrawingBoardData.tableProjects}
''');
    final row = r.first;
    return ProjectTableAggregate(
      projectCount: (row['c'] as int?) ?? 0,
      maxCanvasW: (row['mw'] as int?) ?? 0,
      maxCanvasH: (row['mh'] as int?) ?? 0,
      latestUpdatedAtMs: (row['lu'] as int?) ?? 0,
    );
  }

  Future<DocumentAggregateStats> loadDocumentAggregates(
      {int projectLimit = 300}) async {
    final projects = await listProjects(limit: projectLimit);
    var layers = 0;
    var trace = 0;
    for (final p in projects) {
      try {
        final doc = p.parseDoc();
        layers += doc.layers.length;
        final ref = doc.referenceImagePath;
        if (ref != null && ref.isNotEmpty) {
          trace++;
        }
      } catch (_) {}
    }
    return DocumentAggregateStats(
      totalLayerCount: layers,
      traceProjectCount: trace,
    );
  }

  Future<Map<String, int>> strokeCountsLastDays(int days) async {
    final db = await database;
    final end = DateTime.now();
    final start = end.subtract(Duration(days: days - 1));
    final rows = await db.query(
      DbDrawingBoardData.tableStrokeStats,
      where: 'day >= ? AND day <= ?',
      whereArgs: [_dayKey(start), _dayKey(end)],
    );
    final map = <String, int>{};
    for (final r in rows) {
      map[r['day']! as String] = r['stroke_count']! as int;
    }
    return map;
  }

  String _todayKey() => _dayKey(DateTime.now());

  String _dayKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<int> computeStreakDaysAsync() async {
    final db = await database;
    final rows = await db.query(
      DbDrawingBoardData.tableStrokeStats,
      columns: ['day', 'stroke_count'],
      orderBy: 'day DESC',
    );
    final daysWithInk = <String>{};
    for (final r in rows) {
      if ((r['stroke_count'] as int) > 0) {
        daysWithInk.add(r['day']! as String);
      }
    }
    if (daysWithInk.isEmpty) {
      return 0;
    }
    var streak = 0;
    var cursor = DateTime.now();
    for (var i = 0; i < 366; i++) {
      final key =
          '${cursor.year}-${cursor.month.toString().padLeft(2, '0')}-${cursor.day.toString().padLeft(2, '0')}';
      if (daysWithInk.contains(key)) {
        streak++;
        cursor = cursor.subtract(const Duration(days: 1));
      } else if (i == 0) {
        cursor = cursor.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }
}
