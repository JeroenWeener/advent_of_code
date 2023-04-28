import 'package:aoc/aoc.dart';

void main(List<String> args) async {
  final List<String> puzzleInput = await AocApiManager().getPuzzleInput();

  final int solution1 = part1(puzzleInput);
  print(solution1);

  final int solution2 = part2(puzzleInput);
  print(solution2);
}

int x(String s) {
  final String command = s.split(' ').first;
  final int value = int.parse(s.split(' ').last);

  return (command == 'forward').i01 * value;
}

int y(String s) {
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

int part1(List<String> input) {
  int totalX = input.map((String s) => x(s)).sum();
  int totalY = input.map((String s) => y(s)).sum();
  return totalX * totalY;
}

int part2(List<String> input) {
  return input
      .map((String line) => Pair<String, int>.fromList(line.split(' ')))
      .fold(
        Pair<int, Point>(0, Point.origin()),
        (Pair<int, Point> properties, Pair<String, int> instruction) {
          bool isHorizontal = instruction.l == 'forward';
          bool isUp = instruction.l == 'up';
          int speed = isHorizontal ? instruction.r : 0;
          int aim =
              properties.l + (isHorizontal ? 0 : instruction.r * isUp.not.i11);
          Point pos = properties.r.add(x: speed, y: aim * speed);
          return Pair(aim, pos);
        },
      )
      .r
      .product;
}
