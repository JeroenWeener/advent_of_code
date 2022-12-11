import 'dart:io';

void main() {
  String input = File('2015/dart/12/input.txt').readAsStringSync();

  int answer1 = part1(input);
  print(answer1);

  int answer2 = part2(input);
  print(answer2);
}

int part1(String input) {
  return input
      .split(RegExp(r'[\[\]{},:]'))
      .map((word) => int.tryParse(word))
      .where((possibleValue) => possibleValue != null)
      .map((value) => value!)
      .reduce((total, value) => total + value);
}

int part2(String input) {
  return -1;
}
