void main() {
  for (int mul = 2; mul <= 12; mul++) {
    print("Multiplication Table of $mul");
    for (int i = 1; i <= 12; i++) {
      print("$mul x $i = ${mul * i}");
    }
  }
}
