import 'package:aoc/aoc.dart';

void main(List<String> args) async {
  final List<String> puzzleInput = await AocApiManager().getPuzzleInput();

  final List<int> fish = puzzleInput.first.extractInts();

  final int solution1 = part1(fish);
  print(solution1);

  final int solution2 = part2(fish);
  print(solution2);
}

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
