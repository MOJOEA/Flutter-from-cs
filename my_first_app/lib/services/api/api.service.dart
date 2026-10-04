import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/quote.dart';

class ApiService {
  static Future<Quote> fetchQuote() async {
    final url = Uri.parse(
      'https://dummyjson.com/quotes/random',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Quote.fromJson(data);
    }

    throw Exception(
      'โหลดคำคมไม่สำเร็จ (${response.statusCode})',
    );
  }
}