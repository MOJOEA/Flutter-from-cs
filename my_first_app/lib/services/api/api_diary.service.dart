import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // เปลี่ยนแค่ studentId เป็นรหัสของคุณ (โดเมนตั้งให้แล้ว)
  static const String studentId = '67011212035'; // << ใส่รหัสของคุณ
  static const String baseUrl = 'https://thipwimon.comsciproject.net/mydiary/api.php/$studentId'; // << กล่องข้อมูลของเราโดยเฉพาะ

  // CREATE — เพิ่มบันทึก (POST)
  static Future<void> createDiary(
    String title,
    String content,
    String mood,
    String date,
  ) async {
    final url = Uri.parse(baseUrl);
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'}, // บอกว่าส่ง JSON
      body: jsonEncode({
        // แปลง Map → JSON string
        'title': title,
        'content': content,
        'mood': mood,
        'date': date,
      }),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('เพิ่มไม่สำเร็จ (${response.statusCode})');
    }
  }

  static Future<List<dynamic>> getDiaries() async {
    final url = Uri.parse(baseUrl);
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> all = jsonDecode(response.body);
      return all; // ได้เฉพาะกล่องของเรา ไม่ต้องกรอง
    }
    throw Exception('โหลดไม่สำเร็จ');
  }

  static Future<void> updateDiary(
    String id,
    String title,
    String content,
    String mood,
    String date,
  ) async {
    final url = Uri.parse('$baseUrl/$id'); // ระบุ id ที่จะแก้
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title,
        'content': content,
        'mood': mood,
        'date': date,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('แก้ไขไม่สำเร็จ');
    }
  }

  static Future<void> deleteDiary(String id) async {
    final url = Uri.parse('$baseUrl/$id');
    final response = await http.delete(url);
    if (response.statusCode != 200) {
      throw Exception('ลบไม่สำเร็จ');
    }
  }
}
