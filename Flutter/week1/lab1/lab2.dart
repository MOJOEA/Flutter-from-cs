void main() {
  for (int score = 1; score <= 100; score++) {
    if (score % 3 == 0 && score % 5 == 0) {
      print("$score FizzBuzz");
    } else if (score % 3 == 0) {
      print("$score Fizz");
    } else if (score % 5 == 0) {
      print("$score Buzz");
    } else {
      print("$score");
    }
  }
}
