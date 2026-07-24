import 'lab1.dart';

void main(List<String> args) {
  List<Student> students = [
    Student(id: "66123", name: "สมชาย ใจดี", gpa: 3.75),
    Student(id: "66124", name: "สมหญิง ตั้งใจ", gpa: 3.1),
    Student(id: "66125", name: "สมศรี ขยันยิ่ง", gpa: 3.9),
    Student(id: "66126", name: "สมพงษ์ พักผ่อน", gpa: 1.85),
    Student(id: "66127", name: "สมคิด พอใช้", gpa: 2.3)
  ];
  printAll(students);
}

void printAll(List<Student> students) {
  print("===== นักศึกษาทั้งหมด =====");
  students.forEach((student) => student.introduce());

  print("===== เกียรตินิยม =====");
  var honors = students.where((student) => student.gpa >= 3.5);
  honors.forEach((student) => print(student.name));

  print("===== รอพินิจ =====");
  var probations = students.where((student) => student.gpa < 2.0);
  probations.forEach((student) => print("${student.name} (gpa ${student.gpa}) โปรดพบอาจารย์ที่ปรึกษา"));

  print("===== สรุป =====");
  var summaryList = students.map((student) => "${student.name} (${student.gpa.toStringAsFixed(2)})").toList();
  print("[$summaryList]".replaceAll("'", ""));

  double totalGpa = students.fold(0.0, (sum, student) => sum + student.gpa);
  double averageGpa = totalGpa / students.length;
  print("GPA เฉลี่ยของกลุ่ม: ${averageGpa.toStringAsFixed(2)}");
}
