import 'package:aoc/aoc.dart';

void main(List<String> args) async {
  Solver<List<int>, int>(
    part1: part1,
    part2: part2,
    inputTransformer: (List<String> input) => input.first.extractInts(),
    testInput: [16, 1, 2, 0, 4, 2, 7, 1, 2, 14],
    testOutput1: 37,
    testOutput2: 168,
  ).execute();
}

int part1(List<int> input) {
  return Pair(input.min(), input.max())
      .range()
      .map((int end) => input.map((int start) => (end - start).abs()).sum())
      .min();
}

int part2(List<int> input) {
  return Pair(input.min(), input.max())
      .range()
      .map((int end) =>
          input.map((int start) => (end - start).abs().triangular()).sum())
      .min();
}