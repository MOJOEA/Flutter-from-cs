import 'dart:convert';                    // สำหรับ jsonDecode
import 'package:http/http.dart' as http;
import 'main.dart';                        // ใช้ class Quote

class ApiService {
  // ดึงคำคมสุ่ม
  static Future<Quote> fetchQuote() async {
    final url = Uri.parse('https://dummyjson.com/quotes/random');   // API คำคม (ฟรี ไม่ต้อง key)
    final response = await http.get(url);                       // ส่งคำขอ + รอ

    if (response.statusCode == 200) {       // 200 = สำเร็จ
      final data = jsonDecode(response.body);   // แปลง JSON → Map
      return Quote.fromJson(data);
    } else {
      throw Exception('โหลดคำคมไม่สำเร็จ (${response.statusCode})');
    }
  }
}