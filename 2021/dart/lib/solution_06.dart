import 'package:aoc/aoc.dart';

void main(List<String> args) {
  Solver<List<int>, int>(
    part1: part1,
    part2: part2,
    inputTransformer: transformInput,
    testOutput1: 5934,
    testOutput2: 26984457539,
  ).execute();
}

List<int> transformInput(List<String> input) => input.first.extractInts();

int part1(Iterable<int> fish) {
  Iterable<int> iterate(Iterable<int> fish) {
    final int offspring = fish.where((int f) => f == 0).length;
    fish = fish.map((int f) => f-- == 0 ? 6 : f);
    return [...fish, ...List.filled(offspring, 8)];
  }

  return iterate.applyNTimes(fish, 80).length;
}

int part2(List<int> fish) {
  final List<int> fishPerOffset = List.filled(7, 0);
  final List<int> fishOffspringPerOffset = List.filled(7, 0);
  for (int f in fish) {
    fishPerOffset[f]++;
  }

  256.fori((int i) {
    final int offset = i % 7;
    final int offspringOffset = (i + 2) % 7;
    fishPerOffset[offspringOffset] += fishOffspringPerOffset[offspringOffset];
    fishOffspringPerOffset[offspringOffset] = fishPerOffset[offset];
  });

  return fishPerOffset
      .zip(fishOffspringPerOffset)
      .map((Pair<int, int> p) => p.l + p.r)
      .sum();
}
