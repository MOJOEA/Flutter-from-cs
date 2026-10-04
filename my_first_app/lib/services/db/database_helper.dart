import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../../models/diary.dart';

class DatabaseHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;

    _db = await openDatabase(
      join(
        await getDatabasesPath(),
        'mydiary.db',
      ),
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE diaries('
          'id INTEGER PRIMARY KEY AUTOINCREMENT, '
          'title TEXT NOT NULL, '
          'content TEXT NOT NULL, '
          'date TEXT NOT NULL, '
          'mood TEXT NOT NULL, '
          'author TEXT NOT NULL DEFAULT "ไม่ระบุชื่อ")',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 1) {
          await db.execute(
            'ALTER TABLE diaries ADD COLUMN author TEXT NOT NULL DEFAULT "ไม่ระบุชื่อ"',
          );
        }
      },
    );

    return _db!;
  }

  static Future<void> insert(Diary diary) async {
    final db = await database;

    await db.insert(
      'diaries',
      diary.toMap(),
    );
  }

  static Future<List<Diary>> getAll() async {
    final db = await database;

    final maps = await db.query(
      'diaries',
      orderBy: 'id DESC',
    );

    return maps.map((map) => Diary.fromMap(map)).toList();
  }

  static Future<List<Diary>> searchByTitle(String keyword) async {
    final db = await database;

    final maps = await db.query(
      'diaries',
      where: 'title LIKE ?',
      whereArgs: ['%$keyword%'],
      orderBy: 'id DESC',
    );

    return maps.map((map) => Diary.fromMap(map)).toList();
  }

  static Future<void> delete(int id) async {
    final db = await database;

    await db.delete(
      'diaries',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> update(Diary diary) async {
    final db = await database;

    await db.update(
      'diaries',
      diary.toMap(),
      where: 'id = ?',
      whereArgs: [diary.id],
    );
  }
}