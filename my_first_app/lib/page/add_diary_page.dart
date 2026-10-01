import 'package:flutter/material.dart';
import 'package:my_first_app/services/api_service.dart';

import '../models/diary.dart';
import '../models/quote.dart';

class AddDiaryPage extends StatefulWidget {
  final Diary? existing;

  const AddDiaryPage({
    super.key,
    this.existing,
  });

  @override
  State<AddDiaryPage> createState() => _AddDiaryPageState();
}

class _AddDiaryPageState extends State<AddDiaryPage> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _nameController = TextEditingController();
  final _contentController = TextEditingController();

  final List<String> _moods = [
    'มีความสุข',
    'เฉยๆ',
    'เศร้า',
    'เหนื่อย',
    'ตื่นเต้น',
  ];

  late Future<Quote> _quoteFuture;

  String _selectedMood = 'มีความสุข';
  DateTime _selectedDate = DateTime.now();

  bool _isImportant = false;
  bool _isPinned = false;

  String _type = 'ส่วนตัว';

  @override
  void initState() {
    super.initState();

    if (widget.existing != null) {
      final diary = widget.existing!;

      _titleController.text = diary.title;
      _nameController.text = diary.author;
      _contentController.text = diary.content;
      _selectedMood = diary.mood;
      _selectedDate = DateTime.parse(diary.date);
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
    _titleController.dispose();
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
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
                    return null;
                  },
                ),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'ผู้เขียน',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'กรุณากรอกผู้เขียน';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contentController,
                  maxLines: 5,
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
                  value: _moods.contains(_selectedMood)
                      ? _selectedMood
                      : null,
                  decoration: const InputDecoration(
                    labelText: 'อารมณ์วันนี้',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.mood),
                  ),
                  items: _moods.map((mood) {
                    return DropdownMenuItem(
                      value: mood,
                      child: Text(mood),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedMood = value ?? '';
                    });
                  },
                ),
                const SizedBox(height: 8),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: Text(
                      'วันที่: ${_selectedDate.toString().substring(0, 10)}',
                    ),
                    trailing: const Icon(Icons.edit),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );

                      if (picked != null) {
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
                  onChanged: (value) {
                    setState(() {
                      _isImportant = value!;
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text('ปักหมุดบันทึก'),
                  value: _isPinned,
                  onChanged: (value) {
                    setState(() {
                      _isPinned = value;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: const Text('ส่วนตัว'),
                  value: 'ส่วนตัว',
                  groupValue: _type,
                  onChanged: (value) {
                    setState(() {
                      _type = value!;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: const Text('งาน'),
                  value: 'งาน',
                  groupValue: _type,
                  onChanged: (value) {
                    setState(() {
                      _type = value!;
                    });
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final diary = Diary(
                          id: widget.existing?.id,
                          title: _titleController.text.trim(),
                          content: _contentController.text.trim(),
                          date: _selectedDate.toString().substring(0, 10),
                          mood: _selectedMood,
                          author: _nameController.text.trim(),
                        );

                        Navigator.pop(context, diary);
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