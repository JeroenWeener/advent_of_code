import 'package:aoc/aoc.dart';

void main(List<String> args) async {
  final List<String> puzzleInput = await AocApiManager().getPuzzleInput();

  final int solution1 = part1(puzzleInput);
  print(solution1);

  final int solution2 = part2(puzzleInput);
  print(solution2);
}

int _y(String s) {
  final String command = s.split(' ').first;
  final int value = int.parse(s.split(' ').last);

  switch (command) {
    case 'up':
      return -value;
    case 'down':
      return value;
    default:
      return 0;
  }
}

int _x(String s) {
  final String command = s.split(' ').first;
  final int value = int.parse(s.split(' ').last);

  switch (command) {
    case 'forward':
      return value;
    default:
      return 0;
  }
}

int part1(List<String> input) {
  int totalX = input.map((e) => _x(e)).sum();
  int totalY = input.map((e) => _y(e)).sum();
  return totalX * totalY;
}

int part2(List<String> input) {
  return -1;
}
