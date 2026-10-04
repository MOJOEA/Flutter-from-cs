import 'package:flutter/material.dart';

import '../../services/api/api_diary.service.dart';
import 'add_diary_page.dart';

class ApiDiaryPage extends StatefulWidget {
  const ApiDiaryPage({super.key});
  @override
  State<ApiDiaryPage> createState() => _ApiDiaryPageState();
}

class _ApiDiaryPageState extends State<ApiDiaryPage> {
  late Future<List<dynamic>> _diariesFuture;   // รหัสอยู่ใน ApiService.baseUrl แล้ว

  @override
  void initState() {
    super.initState();
    _loadDiaries();
  }

  void _loadDiaries() {
    setState(() {
      _diariesFuture = ApiService.getDiaries();   // โหลดใหม่ (ได้เฉพาะของเรา)
    });
  }

  // เพิ่มแล้วโหลดใหม่ (แพตเทิร์นเดียวกับ SQLite สัปดาห์ 2!)
  Future<void> _addDiary(String title, String content, String mood, String date) async {
    await ApiService.createDiary(title, content, mood, date);
    _loadDiaries();
  }

  Future<void> _deleteDiary(String id) async {
    await ApiService.deleteDiary(id);
    _loadDiaries();
  }

  // แก้ไขแล้วโหลดใหม่
  Future<void> _updateDiary(String id, String title, String content, String mood, String date) async {
    await ApiService.updateDiary(id, title, content, mood, date);
    _loadDiaries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('บันทึกบน Cloud (REST API)')),
      body: FutureBuilder<List<dynamic>>(
        future: _diariesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('ผิดพลาด: ${snapshot.error}'));
          }
          final diaries = snapshot.data!;
          if (diaries.isEmpty) {
            return const Center(child: Text('ยังไม่มีบันทึก กดปุ่ม +'));
          }
          return ListView.builder(
            itemCount: diaries.length,
            itemBuilder: (context, i) {
              final obj = diaries[i];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(obj['title'] ?? ''),
                  subtitle: Text('${obj['mood'] ?? ''} • ${obj['date'] ?? ''} • ${obj['content'] ?? ''}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,       // ให้ Row กว้างเท่าที่จำเป็น
                    children: [
                      // ── ปุ่มแก้ไข: เปิดฟอร์มโหมดแก้ (ส่ง obj เดิมไป) ──
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ApiFormPage(existing: obj),   // โหมดแก้
                            ),
                          );
                          if (result is Map) {
                            await _updateDiary(obj['id'], result['title'],
                                result['content'], result['mood'], result['date']);
                          }
                        },
                      ),
                      // ── ปุ่มลบ ──
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteDiary(obj['id']),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      // ── ปุ่มเพิ่ม: เปิดฟอร์มโหมดเพิ่ม แล้วรับค่ากลับมา createDiary ──
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ApiFormPage()),   // โหมดเพิ่ม
          );
          if (result is Map) {
            await _addDiary(result['title'], result['content'],
                result['mood'], result['date']);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}