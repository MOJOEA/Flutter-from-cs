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

  factory Diary.fromJson(Map<String, dynamic> json) {
    return Diary(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      date: json['date'] ?? '',
      mood: json['mood'] ?? '',
      author: json['author'] ?? '',
    );
  }
}