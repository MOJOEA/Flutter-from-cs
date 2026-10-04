import 'package:flutter/material.dart';

import 'package:my_first_app/services/db/database_helper.dart';
import 'package:my_first_app/services/api/api.service.dart';

import '../../models/diary.dart';
import '../../models/quote.dart';

import 'add_diary_page.dart';
import '../diary_detail_page.dart';

class DiaryListPage extends StatefulWidget {
  const DiaryListPage({super.key});

  @override
  State<DiaryListPage> createState() => _DiaryListPageState();
}

class _DiaryListPageState extends State<DiaryListPage> {
  List<Diary> diaries = [];
  late Future<Quote> _quoteFuture;

  @override
  void initState() {
    super.initState();

    _quoteFuture = ApiService.fetchQuote();
    _loadDiaries();
  }

  Future<void> _loadDiaries() async {
    final data = await DatabaseHelper.getAll();

    setState(() {
      diaries = data;
    });
  }

  Future<void> _searchByTitle(String keyword) async {
    final data = await DatabaseHelper.searchByTitle(keyword);

    setState(() {
      diaries = data;
    });
  }

  Future<void> _addDiary(Diary diary) async {
    await DatabaseHelper.insert(diary);
    _loadDiaries();
  }

  Future<void> _updateDiary(Diary diary) async {
    await DatabaseHelper.update(diary);
    _loadDiaries();
  }

  Future<void> _deleteDiary(int id) async {
    await DatabaseHelper.delete(id);
    _loadDiaries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('บันทึกของฉัน (${diaries.length})'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _quoteFuture = ApiService.fetchQuote();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          FutureBuilder<Quote>(
            future: _quoteFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.hasError) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'โหลดคำคมไม่ได้',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              final quote = snapshot.data!;

              return Container(
                width: double.infinity,
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.indigo[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      '"${quote.text}"',
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '— ${quote.author}',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        _addDiary(
                          Diary(
                            title: 'คำคมที่บันทึก',
                            content: quote.text,
                            date: DateTime.now().toString(),
                            mood: 'ปกติ',
                            author: quote.author,
                          ),
                        );
                      },
                      child: const Text('บันทึกคำคม'),
                    ),
                  ],
                ),
              );
            },
          ),
          Expanded(
            child: diaries.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.book_outlined,
                          size: 80,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'ไม่พบบันทึก',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          'ลองเปลี่ยนคำค้นหา หรือกดปุ่ม + เพื่อเพิ่มบันทึกใหม่',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: diaries.length,
                    itemBuilder: (context, i) {
                      final diary = diaries[i];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: ListTile(
                          leading: const Icon(
                            Icons.book,
                            color: Colors.indigo,
                          ),
                          title: Text(
                            '${diary.title} (${diary.author})',
                          ),
                          subtitle: Text(
                            '${diary.mood} • ${diary.date} • ${diary.content}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DiaryDetailPage(
                                  diary: diary,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddDiaryPage(),
            ),
          );

          if (result != null && result is Diary) {
            _addDiary(result);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}