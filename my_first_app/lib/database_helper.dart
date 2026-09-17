import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'main.dart';       // เพื่อใช้ class Diary

class DatabaseHelper {
  static Database? _db;

  // เปิดฐานข้อมูล (เปิดครั้งเดียว ใช้ซ้ำ)
    // เปลี่ยนชื่อฐานข้อมูลเพื่อบังคับระบบสร้างตารางใหม่ที่มีคอลัมน์ครบถ้วน
    // ปรับขยับเวอร์ชัน และล้างตารางเก่าสร้างใหม่เมื่อพบโครงสร้างเปลี่ยน
  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await openDatabase(
      join(await getDatabasesPath(), 'mydiary.db'), // กลับมาใช้ชื่อเดิมได้
      version: 2, // << แก้ไขจุดนี้: ขยับเวอร์ชันขึ้นจาก 1 เป็น 2 เพื่อสั่งให้ฐานข้อมูลอัปเกรดตาราง
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE diaries('
          'id INTEGER PRIMARY KEY AUTOINCREMENT, '
          'title TEXT NOT NULL, '
          'content TEXT NOT NULL, '
          'date TEXT NOT NULL, '
          'mood TEXT NOT NULL)',
        );
      },
    );
    return _db!;
  }


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
}