import 'package:flutter/material.dart';

import 'db.page/db_diary_page.dart';
import 'api.page/api_diary_list_page.dart';
import 'about.page/about_page.dart';
import 'package:my_first_app/firestore_diary.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DiaryListPage(),
    const ApiDiaryPage(),
    const FirestoreDiaryPage(),
    const AboutPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // แนะนำให้ใช้ IndexedStack เพื่อรักษาสถานะของแต่ละหน้าไว้เมื่อกดสลับไปมา
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed, // กำหนดประเภทเมื่อมี 4 ไอเทมขึ้นไป
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'บันทึก'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'ออนไลน์'),
          BottomNavigationBarItem(icon: Icon(Icons.cloud), label: 'Cloud'),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'เกี่ยวกับ'),
        ],
      ),
    );
  }
}
