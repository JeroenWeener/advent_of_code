import 'package:aoc/aoc.dart';

void main(List<String> args) async {
  final List<int> puzzleInput = await AocApiManager().getPuzzleInputAsInts();

  final int solution1 = part1(puzzleInput);
  print(solution1);
}

int part1(List<int> input) {
  return input.diff().where((int element) => element > 0).length;
}
