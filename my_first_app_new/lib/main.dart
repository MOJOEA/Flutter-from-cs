import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Modern Counter',
      debugShowCheckedModeBanner: false, // ปิดแถบ Debug มุมขวา
      theme: ThemeData(
        useMaterial3: true,
        // ตั้งค่าโทนสีธีมมืด (Dark Mode) สุดเท่
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212), // สีพื้นหลังชาร์โคล
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepOrange,
          brightness: Brightness.dark,
          primary: Colors.deepOrangeAccent, // สีส้มนีออนเด่นๆ
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _resetCounter() {
    setState(() {
      _counter = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // แถบบาร์ด้านบนสุด
      appBar: AppBar(
        title: const Text(
          'DASHBOARD',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // การ์ดแสดงผลตัวเลขแบบโมเดิร์น
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    // แก้ไขจุดนี้: เปลี่ยนจาก .withOpacity เป็น .withValues
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'TOTAL CLICKS',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[500],
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '$_counter',
                    style: const TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.w800,
                      color: Colors.deepOrangeAccent,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            
            // ปุ่มสไตล์ Text Button สำหรับรีเซ็ตตัวเลข
            TextButton.icon(
              onPressed: _resetCounter,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('RESET COUNTER'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
      
      // ปุ่มกดสไตล์มินิมอลกลมๆ มุมขวาล่าง
      floatingActionButton: FloatingActionButton.large(
        onPressed: _incrementCounter,
        backgroundColor: Colors.deepOrangeAccent,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.add, size: 36),
      ),
    );
  }
}
