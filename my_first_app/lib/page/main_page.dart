import 'package:flutter/material.dart';

import 'db.page/db_diary_page.dart';
import 'api.page/api_diary_list_page.dart';
import 'about.page/about_page.dart';

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
    const AboutPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'บันทึก',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'ออนไลน์',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'เกี่ยวกับ',
          ),
        ],
      ),
    );
  }
}