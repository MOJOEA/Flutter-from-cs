import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:my_first_app/database_helper.dart'; // << แก้ไข: เพิ่มบรรทัดนี้ด้านบนสุดของไฟล์เพื่อเรียกใช้งาน DatabaseHelper
import 'dart:convert'; // สำหรับ jsonDecode
import 'package:my_first_app/api_service.dart'; // << เพิ่มบรรทัดนี้เพื่อเรียกใช้งาน ApiService

void main() => runApp(const MyApp());

// แม่พิมพ์บันทึก
// -------------------------------------------------------------------------------------------------------------------------------------------
class Diary {
  final int? id;
  final String title;
  final String content;
  final String date;
  final String mood;
  final String author;

  Diary({
    this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.mood,
    required this.author,
  });

  // 1. สำหรับแปลงจาก Diary ไปลงฐานข้อมูล
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'content': content,
      'date': date,
      'mood': mood,
      'author': author,
    };
  }

  // 2. สำหรับดึงจากฐานข้อมูล Local มาเป็นวัตถุ Diary
  factory Diary.fromMap(Map<String, dynamic> map) {
    return Diary(
      id: map['id'],
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      date: map['date'] ?? '',
      mood: map['mood'] ?? 'เฉยๆ',
      author: map['author'] ?? 'ไม่ระบุชื่อ',
    );
  }

  // 3. สำหรับแปลงข้อมูลจาก API Mock Data (JSON) มาเป็นวัตถุ Diary
  factory Diary.fromJson(Map<String, dynamic> json) {
    return Diary(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(
              json['id']?.toString() ?? '',
            ), // รองรับทั้ง id ที่เป็นเลขและข้อความ
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      date: json['date'] ?? '',
      mood: json['mood'] ?? '',
      author: json['author'] ?? '',
    );
  }
}

class Pokemon {
  final int? id;
  final String name;
  final int height;
  final int weight;

  Pokemon({
    this.id,
    required this.name,
    required this.height,
    required this.weight,
  });

  // 3. สำหรับแปลงข้อมูลจาก API Mock Data (JSON) มาเป็นวัตถุ Pokemon
  factory Pokemon.fromJson(Map<String, dynamic> json) {
    return Pokemon(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(
              json['id']?.toString() ?? '',
            ), // รองรับทั้ง id ที่เป็นเลขและข้อความ
      name: json['name'] ?? '' as String,
      height: json['height'] ?? '' as int,
      weight: json['weight'] ?? '' as int,
    );
  }
}

class Types {
  final Type type;

  Types({
    required this.type
  });

  factory Types.fromJson(Map<String, dynamic> json) {
    return Types(
      type: Type.fromJson(json['type'])
      );
  }
}

class Type {
  final String name;
  Type({
    required this.name, 
  });

  factory Type.fromJson(Map<String, dynamic> json) {
    return Type(
      name: json['name'] as String, 
    );
  }
}

class Quote {
  final String text;
  final String author;
  Quote({required this.text, required this.author});

  // แปลง JSON (Map) → Quote — เหมือน fromMap ของ SQLite!
  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      text: json['quote'] ?? '', // dummyjson ใช้ field ชื่อ 'quote'
      author: json['author'] ?? 'ไม่ทราบ',
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyDiary',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home:
          const MainPage(), // แก้ไข: เปลี่ยนมาเริ่มต้นที่หน้า MainPage ที่มีแถบเมนูด้านล่าง
    );
  }
}

// หน้ารายการบันทึก DiaryListPage
// -------------------------------------------------------------------------------------------------------------------------------------------
class DiaryListPage extends StatefulWidget {
  const DiaryListPage({super.key});
  @override
  State<DiaryListPage> createState() => _DiaryListPageState();
}

class _DiaryListPageState extends State<DiaryListPage> {
  List<Diary> diaries = []; // เริ่มจากว่าง (จะโหลดจาก DB)
  late Future<Quote> _quoteFuture;

  @override
  void initState() {
    super.initState();
    _quoteFuture = ApiService.fetchQuote();
    _loadDiaries();
  }

  // โหลดจาก DB
  Future<void> _loadDiaries() async {
    final data = await DatabaseHelper.getAll();
    setState(() {
      diaries = data;
    });
  }

  // อ่าน: จากบางส่วนของชื่อ
  Future<void> _searchByTitle(String keyword) async {
    final data = await DatabaseHelper.searchByTitle(keyword);
    setState(() {
      diaries = data;
    });
  }

  // เพิ่ม: เขียน DB แล้วโหลดใหม่
  Future<void> _addDiary(Diary diary) async {
    await DatabaseHelper.insert(diary);
    _loadDiaries();
  }

  // แก้ไข: เขียน DB แล้วโหลดใหม่
  Future<void> _updateDiary(Diary diary) async {
    await DatabaseHelper.update(diary);
    _loadDiaries();
  }

  // ลบ: เขียน DB แล้วโหลดใหม่
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
          //  เพิ่มส่วนนี้
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _quoteFuture =
                    ApiService.fetchQuote(); // สร้าง Future ใหม่ = โหลดใหม่ (ตั้งใจ)
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ── กล่องคำคมประจำวัน ──
          FutureBuilder<Quote>(
            future: _quoteFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'โหลดคำคมไม่ได้',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              } else {
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
                              id: null,
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
              }
            },
          ),
          Expanded(
            child: diaries.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.book_outlined, size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'ไม่พบบันทึก',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        Text(
                          'ลองเปลี่ยนคำค้นหา หรือกดปุ่ม + เพื่อเพิ่มบันทึกใหม่',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: diaries.length, // มีกี่อัน
                    itemBuilder: (context, i) {
                      // สร้างการ์ดทีละอัน
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.book, color: Colors.indigo),
                          title: Text(
                            diaries[i].title + ' (' + diaries[i].author + ')',
                          ), // แสดงชื่อเรื่อง + ชื่อผู้เขียน
                          subtitle: Text(
                            '${diaries[i].mood} • ${diaries[i].date} • ${diaries[i].content}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Row(
                            mainAxisSize:
                                MainAxisSize.min, // ให้ Row กว้างเท่าที่จำเป็น
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddDiaryPage(
                                        existing: diaries[i],
                                      ), //  ส่งตัวเดิมเข้าไป
                                    ),
                                  );
                                  if (result != null && result is Diary) {
                                    await _updateDiary(
                                      result,
                                    ); //  อัปเดตแทนการเพิ่ม
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('ลบบันทึก?'),
                                      content: Text(
                                        'ต้องการลบ "${diaries[i].title}" ใช่ไหม',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, false),
                                          child: const Text('ยกเลิก'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, true),
                                          child: const Text(
                                            'ลบ',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    _deleteDiary(diaries[i].id!);
                                  }
                                },
                              ),
                            ],
                          ),
                          onTap: () {
                            // เมื่อแตะการ์ด
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DiaryDetailPage(
                                  diary: diaries[i],
                                ), // ส่งบันทึกที่แตะไป
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
          // async เพราะต้องรอค่ากลับ
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddDiaryPage()),
          );
          if (result != null && result is Diary) {
            _addDiary(result); // แทน setState(() => diaries.add(result))
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// หน้ารายการบันทึก PokemonPage
// -------------------------------------------------------------------------------------------------------------------------------------------
class PokemonPage extends StatefulWidget {
  const PokemonPage({super.key});
  
  @override
  State<PokemonPage> createState() => _PokemonPageState();
}

class _PokemonPageState extends State<PokemonPage> {
  List<Pokemon> pokemons = []; // เริ่มจากว่าง (จะโหลดจาก DB)
  late Future<Pokemon> _pokemonFuture;

  @override
  void initState() {
    super.initState();
    _pokemonFuture = ApiService.fetchPokemon();
    print(ApiService.fetchPokemon());
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pokemon(${0})'),
        actions: [
          //  เพิ่มส่วนนี้
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _pokemonFuture = ApiService.fetchPokemon();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ── กล่องหา pokemon ──
          FutureBuilder<Pokemon>(
            future: _pokemonFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'มันไม่โหรต อ้าาาาา',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              } else {
                final pokemon = snapshot.data!;
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
                        '${pokemon.name} height:${pokemon.height} weight:${pokemon.weight}',
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

// หน้าสร้างบันทึกใหม่ AddDiaryPage
// -------------------------------------------------------------------------------------------------------------------------------------------
// เพิ่มคลาสหลักที่หายไปกลับคืนมาตรงนี้
class AddDiaryPage extends StatefulWidget {
  final Diary? existing; // << เพิ่มบรรทัดนี้: เปิดช่องรับข้อมูลเก่าเพื่อแก้ไขS
  const AddDiaryPage({
    super.key,
    this.existing,
  }); // << แก้ไขจุดนี้เพื่อรองรับพารามิเตอร์ existing

  @override
  State<AddDiaryPage> createState() => _AddDiaryPageState();
}

class _AddDiaryPageState extends State<AddDiaryPage> {
  final _formKey = GlobalKey<FormState>(); // กุญแจคุมฟอร์ม
  final _titleController = TextEditingController(); // อ่านค่าช่องชื่อเรื่อง
  final _nameController = TextEditingController(); // อ่านค่าช่องชื่อผู้เขียน
  final _contentController = TextEditingController(); // อ่านค่าช่องเนื้อหา
  String _selectedMood = 'มีความสุข'; // ค่าเริ่มต้น
  final List<String> _moods = [
    'มีความสุข',
    'เฉยๆ',
    'เศร้า',
    'เหนื่อย',
    'ตื่นเต้น',
  ];

  late Future<Quote> _quoteFuture;

  // ขั้น 1 — ประกาศตัวแปรเก็บวันที่ ตามที่คุณส่งมา
  DateTime _selectedDate = DateTime.now(); // เริ่มที่วันนี้
  bool _isImportant = false;
  bool _isPinned = false;
  String _type = 'ส่วนตัว';

  // เพิ่มส่วนนี้: ดึงข้อมูลเก่ามาใส่ในฟอร์ม (ถ้าเป็นการกดปุ่มแก้ไข)
  @override
  void initState() {
    super.initState();

    if (widget.existing != null) {
      _titleController.text = widget.existing!.title;
      _nameController.text = widget.existing!.author;
      _contentController.text = widget.existing!.content;
      _selectedMood = widget.existing!.mood;
      _selectedDate = DateTime.parse(widget.existing!.date);
    } else {
      _quoteFuture = ApiService.fetchQuote();

      _quoteFuture.then((quote) {
        if (mounted) {
          setState(() {
            _nameController.text = quote.author;
            _contentController.text = quote.text;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose(); // คืนทรัพยากรตอนปิดหน้า
    _nameController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existing == null ? 'เขียนบันทึกใหม่' : 'แก้ไขบันทึก',
        ),
      ), // เปลี่ยนหัวข้อตามการใช้งาน
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            // เพิ่มส่วนนี้เพื่อป้องกันหน้าจอเกินเวลาเปิดคีย์บอร์ดหรือปฏิทิน
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'ชื่อเรื่อง',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'กรุณากรอกชื่อเรื่อง';
                    }
                    return null; // null = ผ่าน
                  },
                ),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'ผุู้เขียน',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'กรุณากรอกผุู้เขียน';
                    }
                    return null; // null = ผ่าน
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contentController,
                  maxLines: 5, // ช่องเนื้อหาสูง 5 บรรทัด
                  decoration: const InputDecoration(
                    labelText: 'เนื้อหา',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'กรุณากรอกเนื้อหา';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  // แก้ไขตรงนี้: ถ้าใน _moods ไม่มีค่า _selectedMood ให้ส่ง null ไปก่อน
                  value: _moods.contains(_selectedMood) ? _selectedMood : null,
                  decoration: const InputDecoration(
                    labelText: 'อารมณ์วันนี้',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.mood),
                  ),
                  items: _moods.map((mood) {
                    return DropdownMenuItem(value: mood, child: Text(mood));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      // แก้ไขตรงนี้: เอา ! ออก เพื่อความปลอดภัยเผื่อค่าเป็น null
                      _selectedMood = value ?? '';
                    });
                  },
                ),

                const SizedBox(
                  height: 8,
                ), // เว้นระยะห่างเล็กน้อยก่อนเข้าปุ่มวันที่
                // ขั้น 2 — เพิ่มปุ่มเลือกวันที่ในฟอร์ม ตามที่คุณส่งมา
                Card(
                  // ครอบด้วย Card เพื่อความสวยงามเป็นสัดส่วน
                  child: ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: Text(
                      'วันที่: ${_selectedDate.toString().substring(0, 10)}',
                    ),
                    trailing: const Icon(Icons.edit),
                    onTap: () async {
                      final picked = await showDatePicker(
                        // เปิดปฏิทินให้เลือก
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2020), // เลือกได้ตั้งแต่ปี 2020
                        lastDate: DateTime(2030), // ถึงปี 2030
                      );
                      if (picked != null) {
                        // ถ้าเลือก (ไม่กดยกเลิก)
                        setState(() {
                          _selectedDate = picked;
                        });
                      }
                    },
                  ),
                ),
                CheckboxListTile(
                  title: const Text('ทำเครื่องหมายว่าสำคัญ'),
                  value: _isImportant,
                  onChanged: (value) => setState(() => _isImportant = value!),
                ),
                SwitchListTile(
                  title: const Text('ปักหมุดบันทึก'),
                  value: _isPinned,
                  onChanged: (value) => setState(() => _isPinned = value),
                ),
                Column(
                  children: [
                    RadioListTile<String>(
                      title: const Text('ส่วนตัว'),
                      value: 'ส่วนตัว',
                      groupValue: _type,
                      onChanged: (v) => setState(() => _type = v!),
                    ),
                    RadioListTile<String>(
                      title: const Text('งาน'),
                      value: 'งาน',
                      groupValue: _type,
                      onChanged: (v) => setState(() => _type = v!),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // validate เช็คแค่ TextFormField
                        final newDiary = Diary(
                          id: widget
                              .existing
                              ?.id, // << เพิ่มบรรทัดนี้: ส่ง id เดิมกลับไปกรณีแก้ไขข้อมูล
                          title: _titleController.text.trim(),
                          content: _contentController.text.trim(),
                          date: _selectedDate.toString().substring(
                            0,
                            10,
                          ), // วันที่ที่เลือก
                          mood: _selectedMood, // อารมณ์ที่เลือก
                          author: _nameController.text.trim(), // ชื่อผู้เขียน
                        );
                        Navigator.pop(context, newDiary);
                      }
                    },
                    child: const Text('บันทึก'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// หน้ารายละเอียดบันทึก DiaryDetailPage
// -------------------------------------------------------------------------------------------------------------------------------------------
class DiaryDetailPage extends StatelessWidget {
  final Diary diary; // รับบันทึกที่ถูกแตะเข้ามา
  const DiaryDetailPage({super.key, required this.diary});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('รายละเอียด')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              diary.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              diary.date,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              'อารมณ์: ${diary.mood}',
              style: const TextStyle(fontSize: 14, color: Colors.indigo),
            ), // << เพิ่มบรรทัดนี้ในหน้ารายละเอียด
            const Divider(height: 32),
            Text(
              diary.content,
              style: const TextStyle(fontSize: 16, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}

// หน้าเกี่ยวกับ (ง่ายๆ) AboutPage
// -------------------------------------------------------------------------------------------------------------------------------------------
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('เกี่ยวกับ')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                // << รูปวงกลม (ใช้ไอคอนแทนรูปก่อน)
                radius: 50,
                backgroundColor: Colors.indigo,
                child: Icon(Icons.book, size: 50, color: Colors.white),
              ),
              const SizedBox(height: 20),
              const Text(
                'MyDiary',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('แอปสมุดบันทึกส่วนตัว'),
              const SizedBox(height: 4),
              const Text('สร้างโดย นายธาดา ทองอ่อน'), // << ใส่ชื่อตัวเอง
              const Text('รหัสนักศึกษา 67011212035'), // << ใส่รหัส
              const SizedBox(height: 16),
              const Text('เวอร์ชัน 1.0', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}

// หน้า MainPage ที่มีแถบเมนูด้านล่าง
// -------------------------------------------------------------------------------------------------------------------------------------------
class MainPage extends StatefulWidget {
  const MainPage({super.key});
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0; // หน้าที่เลือกอยู่ (0=บันทึก, 1=เกี่ยวกับ)

  // รายการหน้า
  final List<Widget> _pages = [
    const DiaryListPage(),
    const PokemonPage(),
    const AboutPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // แสดงหน้าที่เลือก
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            // เปลี่ยนหน้า + วาดจอใหม่
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'บันทึก'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Pokemon'),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'เกี่ยวกับ'),
        ],
      ),
    );
  }
}
