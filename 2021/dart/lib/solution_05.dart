import 'package:aoc/aoc.dart';

void main(List<String> args) async {
  final List<String> puzzleInput = await AocApiManager().getPuzzleInput();

  final int solution1 = part1(puzzleInput);
  print(solution1);

  final int solution2 = part2(puzzleInput);
  print(solution2);
}

Iterable<Point> pointsOnHorizontalLine(int x1, int x2, int y) sync* {
  final int minX = x1 < x2 ? x1 : x2;
  final int maxX = x1 < x2 ? x2 : x1;

  for (int x = minX; x <= maxX; x++) {
    yield Point(x, y);
  }
}

Iterable<Point> pointsOnVerticalLine(int x, int y1, int y2) sync* {
  final int minY = y1 < y2 ? y1 : y2;
  final int maxY = y1 < y2 ? y2 : y1;

  for (int y = minY; y <= maxY; y++) {
    yield Point(x, y);
  }
}

Iterable<Point> pointsOnDiagonalLine(int x1, int x2, int y1, int y2) sync* {
  assert((x1 - x2).abs() == (y1 - y2).abs());

  final bool reversedX = x2 < x1;
  final bool reversedY = y2 < y1;

  int x = x1;
  int y = y1;

  for (int i = 0; i < (x1 - x2).abs() + 1; i++) {
    yield Point(x, y);
    x += reversedX.not.i11;
    y += reversedY.not.i11;
  }
}

Iterable<Point> pointsOnLine1(String line) {
  final List<int> coordinates = line.extractInts();

  final int x1 = coordinates[0];
  final int x2 = coordinates[2];
  final int y1 = coordinates[1];
  final int y2 = coordinates[3];

  if (x1 == x2) {
    return pointsOnVerticalLine(x1, y1, y2);
  }

  if (y1 == y2) {
    return pointsOnHorizontalLine(x1, x2, y1);
  }

  return [];
}

Iterable<Point> pointsOnLine2(String line) {
  final List<int> coordinates = line.extractInts();

  final int x1 = coordinates[0];
  final int x2 = coordinates[2];
  final int y1 = coordinates[1];
  final int y2 = coordinates[3];

  if (x1 == x2) {
    return pointsOnVerticalLine(x1, y1, y2);
  }

  if (y1 == y2) {
    return pointsOnHorizontalLine(x1, x2, y1);
  }

  if ((x1 - x2).abs() == (y1 - y2).abs()) {
    return pointsOnDiagonalLine(x1, x2, y1, y2);
  }

  throw Exception('Unexpected line');
}

int part1(Iterable<String> input) {
  return input
      .map((line) => pointsOnLine1(line))
      .flatten()
      .counts()
      .where((element) => element.r >= 2)
      .length;
}

int part2(Iterable<String> input) {
  return input
      .map((line) => pointsOnLine2(line))
      .flatten()
      .counts()
      .where((element) => element.r >= 2)
      .length;
}
