import 'lab1.dart';

class GraduateStudent extends Student {
  String thesisTopic;

  GraduateStudent({required super.id, required super.name, super.gpa = 0.0, 
    required this.thesisTopic,
  });

  @override
  void introduce() {
    super.introduce();
    print("กำลังทำวิทยานิพนธ์เรื่อง $thesisTopic");
  }
}

void main(List<String> args) {
  GraduateStudent graduateStudent1 = GraduateStudent(
    id: "65999", name: "สมปอง เพียรเรียน", gpa: 3.6, 
    thesisTopic: "การพัฒนาแอปด้วย Flutter",
  );
  
  graduateStudent1.introduce();
}
