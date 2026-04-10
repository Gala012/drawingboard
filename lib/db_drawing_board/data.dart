class DbDrawingBoardData {
  static const dbName = 'drawing_board.db';
  static const dbVersion = 1;

  static const tableProjects = 'projects';
  static const tableStrokeStats = 'stroke_stats';

  static const createProjects = '''
CREATE TABLE $tableProjects (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  thumb_path TEXT,
  updated_at INTEGER NOT NULL,
  canvas_w INTEGER NOT NULL,
  canvas_h INTEGER NOT NULL,
  doc_json TEXT NOT NULL
);
''';

  static const createStrokeStats = '''
CREATE TABLE $tableStrokeStats (
  day TEXT PRIMARY KEY,
  stroke_count INTEGER NOT NULL DEFAULT 0
);
''';
}
