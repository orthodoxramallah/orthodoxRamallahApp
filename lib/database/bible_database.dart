import 'dart:io' show Directory, File;
import 'package:flutter/services.dart' show rootBundle, ByteData;
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class BibleDatabase {
  static Database? _db;
  static const String _assetDbPath = 'assets/bible_ar.db';
  static const String _dbFileName = 'bible_ar.db';

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final dbDir = await getDatabasesPath();
    await Directory(dbDir).create(recursive: true);
    final dbPath = p.join(dbDir, _dbFileName);

    // Copy DB from assets if not exists
    if (!await File(dbPath).exists()) {
      final ByteData data = await rootBundle.load(_assetDbPath);
      final bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(dbPath).writeAsBytes(bytes, flush: true);
    }

    return openDatabase(dbPath, readOnly: true);
  }

  /// ✅ Get distinct books from verses table
  static Future<List<int>> getBooks() async {
    final db = await database;
    final rows = await db.rawQuery(
      'SELECT DISTINCT book FROM verses ORDER BY book',
    );
    return rows
        .map((r) => (r['book'] as int))
        .toList(growable: false);
  }

  /// ✅ Get chapters for a book
  static Future<List<int>> getChapters(int book) async {
    final db = await database;
    final rows = await db.rawQuery(
      'SELECT DISTINCT chapter FROM verses WHERE book = ? ORDER BY chapter',
      [book],
    );
    return rows
        .map((r) => (r['chapter'] as int))
        .toList(growable: false);
  }

  /// ✅ Get verses for book + chapter
  static Future<List<Map<String, Object?>>> getVerses(
    int book,
    int chapter,
  ) async {
    final db = await database;
    return db.query(
      'verses',
      columns: ['id', 'book', 'chapter', 'verse', 'text'],
      where: 'book = ? AND chapter = ?',
      whereArgs: [book, chapter],
      orderBy: 'verse',
    );
  }
}