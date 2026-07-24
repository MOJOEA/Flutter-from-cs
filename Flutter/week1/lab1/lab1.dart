void main() {
  int score = 62;
  int joinclass = 85;
  int allclass = 100;
  double persent = (joinclass / allclass) * 100;
  switch (score) {
    case >= 80:
      print("A");
      break;
    case >= 75:
      print("B+");
      break;
    case >= 70:
      print("B");
      break;
    case >= 65:
      print("C+");
      break;
    case >= 60:
      print("C");
      break;
    case >= 55:
      print("D+");
      break;
    case >= 50:
      print("D");
      break;
    default:
      print("F");
  }
  if (persent >= 80 && score >= 50) {
    print("You can join the class");
  } else {
    print("You cannot join the class");
  }
}
