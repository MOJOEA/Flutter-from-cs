import 'package:flutter/material.dart';
import 'package:my_first_app/database_helper.dart';

void main() => runApp(const MyApp());

// แม่พิมพ์บันทึก
// -------------------------------------------------------------------------------------------------------------------------------------------
class Song {
  final int? id;
  final String song;
  final String artist;
  final String content;
  final String date;
  final String type;
  Song({
    this.id,
    required this.song,
    required this.artist,
    required this.content,
    required this.date,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'song': song,
      'artist': artist,
      'content': content,
      'date': date,
      'type': type,
    };
  }

  factory Song.fromMap(Map<String, dynamic> map) {
    return Song(
      id: map['id'],
      song: map['song'] ?? '',
      artist: map['artist'] ?? '',
      content: map['content'] ?? '',
      date: map['date'] ?? '',
      type: map['type'] ?? 'Pop',
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

// SongListPage
// -------------------------------------------------------------------------------------------------------------------------------------------
class SongListPage extends StatefulWidget {
  const SongListPage({super.key});
  @override
  State<SongListPage> createState() => _SongListPageState();
}

class _SongListPageState extends State<SongListPage> {
  List<Song> diaries = [];
  int? _selectedSongId;

  @override
  void initState() {
    super.initState();
    _loadDiaries();
  }

  Future<void> _loadDiaries() async {
    final data = await DatabaseHelper.getAll();
    if (!mounted) return;
    setState(() {
      diaries = data;
    });
  }

  Future<void> _addDiary(Song diary) async {
    await DatabaseHelper.insert(diary);
    await _loadDiaries();
  }

  Future<void> _updateDiary(Song diary) async {
    await DatabaseHelper.update(diary);
    await _loadDiaries();
  }

  Future<void> _deleteDiary(int id) async {
    await DatabaseHelper.delete(id);
    await _loadDiaries();
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'Pop':
        return Colors.blue;
      case 'Rock':
        return Colors.orange;
      case 'Metal':
        return Colors.red;
      case 'Indie':
        return Colors.cyan;
      case 'R&B Soul':
        return Colors.purple;
      case 'EDM':
        return Colors.grey;
      case 'Jazz':
        return Colors.amber;
      case 'Acoustic / Folk':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedSong = diaries
        .where((song) => song.id == _selectedSongId)
        .firstOrNull;
    final themeColor = selectedSong != null
        ? _getTypeColor(selectedSong.type)
        : const Color(0xFF1E1E1E);

    return Scaffold(
      backgroundColor: const Color(0xFF080808),
      appBar: AppBar(
        title: Text(
          'บันทึกของฉัน (${diaries.length})',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF101010),
        elevation: 8,
        shadowColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              themeColor.withValues(alpha: 0.85),
              themeColor.withValues(alpha: 0.40),
              const Color(0xFF080808),
              Colors.black,
            ],
            stops: const [0.0, 0.28, 0.68, 1.0],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: diaries.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.library_music_outlined,
                            size: 70,
                            color: Colors.white38,
                          ),
                          SizedBox(height: 14),
                          Text(
                            'ยังไม่มีบันทึก',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'กดปุ่มด้านล่างเพื่อเขียนบันทึกแรก',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 12, bottom: 4),
                      itemCount: diaries.length,
                      itemBuilder: (context, i) {
                        final songItem = diaries[i];
                        final typeColor = _getTypeColor(songItem.type);
                        final isSelected = _selectedSongId == songItem.id;

                        return AnimatedScale(
                          scale: isSelected ? 1.025 : 1.0,
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOutBack,
                          child: Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 6.0,
                            ),
                            color: const Color(0xFF202020),
                            elevation: isSelected ? 10 : 4,
                            shadowColor: isSelected
                                ? typeColor.withValues(alpha: 0.45)
                                : Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                              side: BorderSide(
                                color: isSelected
                                    ? typeColor.withValues(alpha: 0.9)
                                    : Colors.white.withValues(alpha: 0.05),
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 5,
                              ),
                              leading: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                width: isSelected ? 52 : 46,
                                height: isSelected ? 52 : 46,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: typeColor.withValues(
                                    alpha: isSelected ? 0.30 : 0.18,
                                  ),
                                  border: Border.all(
                                    color: typeColor.withValues(alpha: 0.65),
                                  ),
                                ),
                                child: Icon(
                                  Icons.music_note,
                                  color: typeColor,
                                  size: isSelected ? 27 : 23,
                                ),
                              ),
                              title: Text(
                                songItem.song,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: isSelected ? 16 : 15,
                                ),
                              ),
                              subtitle: Text(
                                '(${songItem.artist})\n${songItem.type} Song • ${songItem.date} • ${songItem.content}',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white60,
                                  fontSize: 12,
                                  height: 1.35,
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.change_circle,
                                      color: Colors.blue,
                                    ),
                                    onPressed: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              AddSongPage(existing: diaries[i]),
                                        ),
                                      );
                                      if (result != null && result is Song) {
                                        await _updateDiary(result);
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.remove_circle,
                                      color: Colors.red,
                                    ),
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          backgroundColor: const Color(
                                            0xFF202020,
                                          ),
                                          title: const Text(
                                            'ลบบันทึก?',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                          content: Text(
                                            'ต้องการลบ "${diaries[i].song}" ใช่ไหม',
                                            style: const TextStyle(
                                              color: Colors.white70,
                                            ),
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
                                                style: TextStyle(
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm == true) {
                                        await _deleteDiary(diaries[i].id!);
                                      }
                                    },
                                  ),
                                ],
                              ),
                              onTap: () {
                                if (_selectedSongId == songItem.id) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          SongDetailPage(diary: diaries[i]),
                                    ),
                                  );
                                } else {
                                  setState(() {
                                    _selectedSongId = songItem.id;
                                  });
                                }
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
              decoration: BoxDecoration(
                color: const Color(0xFF101010),
                border: Border(
                  top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black54,
                    blurRadius: 15,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF292929),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddSongPage(),
                      ),
                    );
                    if (result != null && result is Song) {
                      await _addDiary(result);
                    }
                  },
                  child: const Text(
                    'ADD TO THIS PLAYLIST',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// AddSongPage
// -------------------------------------------------------------------------------------------------------------------------------------------
class AddSongPage extends StatefulWidget {
  final Song? existing; // รับข้อมูลเก่ากรณีแก้ไข
  const AddSongPage({super.key, this.existing});

  @override
  State<AddSongPage> createState() => _AddSongPageState();
}

class _AddSongPageState extends State<AddSongPage> {
  final _formKey = GlobalKey<FormState>(); // กุญแจคุมฟอร์ม
  final _songController = TextEditingController(); // อ่านค่าช่องชื่อเพลง
  final _artistController = TextEditingController(); // อ่านค่าช่องเจ้าของเพลง
  final _contentController = TextEditingController(); // อ่านค่าช่องเนื้อหา
  String _selectedType = 'Pop'; // ค่าเริ่มต้น
  final List<String> _moods = [
    'Pop',
    'Rock',
    'Metal',
    'Indie',
    'R&B Soul',
    'EDM',
    'Jazz',
    'Acoustic / Folk',
  ];

  DateTime _selectedDate = DateTime.now(); // เริ่มที่วันนี้
  bool _isImportant = false;
  bool _isPinned = false;
  String _type = 'ส่วนตัว';

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _songController.text = widget.existing!.song;
      _artistController.text = widget.existing!.artist;
      _contentController.text = widget.existing!.content;
      _selectedType = widget.existing!.type;
      _selectedDate = DateTime.parse(widget.existing!.date);
    }
  }

  @override
  void dispose() {
    _songController.dispose(); // คืนทรัพยากรตอนปิดหน้า
    _artistController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF08070D),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text(
          widget.existing == null ? 'เขียนบันทึกใหม่' : 'แก้ไขบันทึก',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF24113D),
              Color(0xFF120D20),
              Color(0xFF08070D),
              Color(0xFF000000),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white.withOpacity(0.06),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.music_note,
                          color: Color(0xFFB084FF),
                          size: 25,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          widget.existing == null
                              ? 'บันทึกเพลงของ'
                              : 'แก้ไขบันทึกเพลง',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _songController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'ชื่อเพลง',
                      labelStyle: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.06),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFF9C6BFF)),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'กรุณากรอกชื่อเพลง';
                      }
                      return null; // null = ผ่าน
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _artistController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'เจ้าของเพลง',
                      labelStyle: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.06),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFF9C6BFF)),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'กรุณากรอกเจ้าของเพลง';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _contentController,
                    maxLines: 4, // ช่องเนื้อหาสูง 4 บรรทัด
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'เนื้อหา',
                      labelStyle: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                      ),
                      alignLabelWithHint: true,
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.06),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFF9C6BFF)),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'กรุณากรอกเนื้อหา';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedType,
                    dropdownColor: const Color(0xFF1B1725),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'แนวเพลงวันนี้',
                      labelStyle: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.06),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFF9C6BFF)),
                      ),
                    ),
                    items: _moods.map((mood) {
                      return DropdownMenuItem(value: mood, child: Text(mood));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        // เลือกค่าเลือกต้อง setState เอง
                        _selectedType = value!;
                      });
                    },
                  ),
                  const SizedBox(
                    height: 8,
                  ), // เว้นระยะห่างเล็กน้อยก่อนเข้าปุ่มวันที่
                  Card(
                    // ครอบด้วย Card เพื่อความสวยงามเป็นสัดส่วน
                    color: Colors.white.withOpacity(0.06),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide.none,
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                      ),
                      leading: const Icon(
                        Icons.calendar_today,
                        color: Color(0xFFB084FF),
                      ),
                      title: Text(
                        'วันที่: ${_selectedDate.toString().substring(0, 10)}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      trailing: const Icon(
                        Icons.edit,
                        color: Color(0xFFB084FF),
                      ),
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
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'ทำเครื่องหมายว่าสำคัญ',
                      style: TextStyle(color: Colors.white),
                    ),
                    value: _isImportant,
                    activeColor: const Color(0xFF9C6BFF),
                    onChanged: (value) => setState(() => _isImportant = value!),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'ปักหมุดบันทึก',
                      style: TextStyle(color: Colors.white),
                    ),
                    value: _isPinned,
                    activeColor: const Color(0xFFEC4899),
                    onChanged: (value) => setState(() => _isPinned = value),
                  ),
                  Column(
                    children: [
                      RadioListTile<String>(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'ส่วนตัว',
                          style: TextStyle(color: Colors.white),
                        ),
                        value: 'ส่วนตัว',
                        groupValue: _type,
                        activeColor: const Color(0xFF9C6BFF),
                        onChanged: (v) => setState(() => _type = v!),
                      ),
                      RadioListTile<String>(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'งาน',
                          style: TextStyle(color: Colors.white),
                        ),
                        value: 'งาน',
                        groupValue: _type,
                        activeColor: const Color(0xFFEC4899),
                        onChanged: (v) => setState(() => _type = v!),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                        ),
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // validate เช็คแค่ TextFormField
                            final newDiary = Song(
                              id: widget.existing?.id,
                              song: _songController.text.trim(),
                              artist: _artistController.text.trim(),
                              content: _contentController.text.trim(),
                              date: _selectedDate.toString().substring(
                                0,
                                10,
                              ), // วันที่ที่เลือก
                              type: _selectedType, // แนวเพลงที่เลือก
                            );
                            Navigator.pop(context, newDiary);
                          }
                        },
                        child: const Text(
                          'บันทึก',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// SongDetailPage
// -------------------------------------------------------------------------------------------------------------------------------------------
class SongDetailPage extends StatelessWidget {
  final Song diary;
  const SongDetailPage({super.key, required this.diary});

  Color _getTypeColor(String type) {
    switch (type) {
      case 'Pop':
        return Colors.blue;
      case 'Rock':
        return Colors.orange;
      case 'Metal':
        return Colors.red;
      case 'Indie':
        return Colors.cyan;
      case 'R&B Soul':
        return Colors.purple;
      case 'EDM':
        return Colors.grey;
      case 'Jazz':
        return Colors.amber;
      case 'Acoustic / Folk':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = _getTypeColor(diary.type);

    return Scaffold(
      backgroundColor: const Color(0xFF080808),
      appBar: AppBar(
        title: const Text('Song Detail'),
        backgroundColor: const Color(0xFF101010),
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              typeColor.withValues(alpha: 0.85),
              typeColor.withValues(alpha: 0.45),
              const Color(0xFF080808),
              Colors.black,
            ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: typeColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.music_note,
                        color: Colors.white,
                        size: 35,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        children: [
                          Slider(
                            value: 0.6,
                            onChanged: (v) {},
                            activeColor: Colors.orange,
                            inactiveColor: Colors.white24,
                          ),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Icon(Icons.repeat, color: Colors.white, size: 20),
                              Icon(
                                Icons.skip_previous,
                                color: Colors.white,
                                size: 24,
                              ),
                              Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                                size: 30,
                              ),
                              Icon(
                                Icons.skip_next,
                                color: Colors.white,
                                size: 24,
                              ),
                              Icon(
                                Icons.shuffle,
                                color: Colors.white,
                                size: 20,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '${diary.song} (${diary.artist})',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${diary.type} Song • ${diary.date}',
                style: const TextStyle(fontSize: 14, color: Colors.white70),
              ),
              const Divider(height: 32, color: Colors.white30),
              Text(
                diary.content,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// AboutPage
// -------------------------------------------------------------------------------------------------------------------------------------------
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF08070D),
      appBar: AppBar(
        title: const Text(
          'เกี่ยวกับ',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF101010),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF24113D),
              Color(0xFF120D20),
              Color(0xFF08070D),
              Colors.black,
            ],
            stops: [0.0, 0.35, 0.7, 1.0],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF9C27B0), Color(0xFFE91E63)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE91E63).withValues(alpha: 0.35),
                        blurRadius: 25,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: const CircleAvatar(
                    radius: 52,
                    backgroundColor: Color(0xFF17131F),
                    child: Icon(
                      Icons.library_music,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'MyPlaylist',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'แอปพลิเคชันจัดเพลย์ลิสต์เพลงส่วนตัว',
                  style: TextStyle(fontSize: 15, color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: const Column(
                    children: [
                      Text(
                        'สร้างโดย นายธาดา ทองอ่อน',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'รหัสนักศึกษา 67011212035',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'เวอร์ชัน 1.0',
                  style: TextStyle(color: Colors.white38, fontSize: 13),
                ),
              ],
            ),
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
  final List<Widget> _pages = [const SongListPage(), const AboutPage()];

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
          BottomNavigationBarItem(
            icon: Icon(Icons.library_music),
            label: 'Playlist',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'About'),
        ],
      ),
    );
  }
}
