import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'main.dart'; // เพื่อใช้ class Diary และ Pokemon (ถ้ามี)

class DatabaseHelper {
  static Database? _db;

  // เปิดฐานข้อมูล
  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await openDatabase(
      join(await getDatabasesPath(), 'mydiary.db'),
      version: 2, 
      onCreate: (db, version) async {
        // สร้างตาราง diaries
        await db.execute(
          'CREATE TABLE diaries('
          'id INTEGER PRIMARY KEY AUTOINCREMENT,'
          'title TEXT NOT NULL, '
          'content TEXT NOT NULL, '
          'date TEXT NOT NULL, '
          'mood TEXT NOT NULL, '
          'author TEXT NOT NULL DEFAULT "ไม่ระบุชื่อ")'
        );
        // แก้ไข: เพิ่มวงเล็บปิด และนำคอมมาตัวสุดท้ายออก
        await db.execute(
          'CREATE TABLE pokemons('
          'id INTEGER PRIMARY KEY AUTOINCREMENT, '
          'number INT NOT NULL, '
          'name TEXT NOT NULL, '
          'ranmark TEXT NOT NULL, '
          'date TEXT NOT NULL)' 
        );
      },
    );
    return _db!;
  }

  // ==================== ฟังก์ชันสำหรับ DIARIES ====================

  // เพิ่มบันทึก
  static Future<void> insert(Diary diary) async {
    final db = await database;
    await db.insert('diaries', diary.toMap());
  }

  // อ่านบันทึกทั้งหมด
  static Future<List<Diary>> getAll() async {
    final db = await database;
    final maps = await db.query('diaries', orderBy: 'id DESC');
    return maps.map((map) => Diary.fromMap(map)).toList();
  }

  // อ่านจากบางส่วนของชื่อ
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

  // ลบบันทึก
  static Future<void> delete(int id) async {
    final db = await database;
    await db.delete('diaries', where: 'id = ?', whereArgs: [id]);
  }

  // อัปเดตบันทึก
  static Future<void> update(Diary diary) async {
    final db = await database;
    await db.update(
      'diaries',
      diary.toMap(),
      where: 'id = ?',
      whereArgs: [diary.id],
    );
  }

  // ==================== ฟังก์ชันสำหรับ POKEMONS ====================
  // (หมายเหตุ: หากคุณมีคลาส Pokemon ให้เปลี่ยนจาก List<Diary> เป็น List<Pokemon> นะครับ)

  // อ่านบันทึกทั้งหมด (แก้ไข: เปลี่ยนชื่อตารางเป็น 'pokemons')
  static Future<List<Diary>> getAllPokemon() async {
    final db = await database;
    final maps = await db.query('pokemons', orderBy: 'id DESC');
    return maps.map((map) => Diary.fromMap(map)).toList();
  }

  // อ่านจากบางส่วนของชื่อ (แก้ไข: เปลี่ยนชื่อตารางเป็น 'pokemons')
  static Future<List<Diary>> searchByname(String keyword) async {
    final db = await database;
    final maps = await db.query(
      'pokemons',
      where: 'name LIKE ?',
      whereArgs: ['%$keyword%'],
      orderBy: 'id DESC',
    );
    return maps.map((map) => Diary.fromMap(map)).toList();
  }

  // ลบบันทึก (แก้ไข: เปลี่ยนชื่อตารางเป็น 'pokemons')
  static Future<void> deletepokemon(int id) async {
    final db = await database;
    await db.delete('pokemons', where: 'id = ?', whereArgs: [id]);
  }
}
