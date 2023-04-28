import 'package:aoc/aoc.dart';

void main(List<String> args) async {
  final List<int> puzzleInput = await AocApiManager().getPuzzleInputAsInts();

  final int solution1 = part1(puzzleInput);
  print(solution1);

  final int solution2 = part2(puzzleInput);
  print(solution2);
}

int part1(List<int> input) {
  return input.diff().where((int diff) => diff > 0).length;
}

int part2(List<int> input) {
  return input
      .sw(3)
      .map((List<int> w) => w.sum())
      .diff()
      .where((int diff) => diff > 0)
      .length;
}
