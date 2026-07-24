class Student{
  String id;
  String name;
  double gpa = 0.0;

  Student({required this.id, required this.name, required this.gpa});

  introduce() {
    print("สวัสดี ฉันชื่อ ${name} รหัส ${id} เกรดเฉลี่ย ${gpa}");
  }

  isHonor() => gpa >= 3.5;
  getHonor() => "ได้เกียรตตินิยม: ${isHonor()}";

}

void main(List<String> args) {
  Student student1 = Student(id: "66123", name: "สมชาย ใจดี", gpa: 3.75);
  student1.introduce();
  Student student2 = Student(id: "66124", name: "สมหญิง ตั้งใจ", gpa: 0.0);
  student2.introduce();

  print(student1.getHonor());
  print(student2.getHonor());
}