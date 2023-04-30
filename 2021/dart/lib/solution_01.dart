import 'package:aoc/aoc.dart';

void main(List<String> args) async {
  Solver<List<int>, int>(
    part1: part1,
    part2: part2,
    testInput: [
      199,
      200,
      208,
      210,
      200,
      207,
      240,
      269,
      260,
      263,
    ],
    testOutput1: 7,
    testOutput2: 5,
  ).execute();
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
