import 'package:aoc/aoc.dart';

void main(List<String> args) {
  Solver<Pair<List<List<bool>>, List<Pair<String, int>>>, int>(
    inputTransformer: transformInput,
    part1: part1,
    part2: part2,
    testOutput1: 17,
  ).execute();
}

Pair<List<List<bool>>, List<Pair<String, int>>> transformInput(
  List<String> input,
) {
  Iterable<Pair<String, int>> instructions =
      input.skipWhile((String line) => line != '').skip(1).map(
            (String line) => Pair<String, int>(
              line.contains('x') ? 'x' : 'y',
              int.parse(line.split('=')[1]),
            ),
          );

  int y = instructions
      .firstWhere((Pair<String, int> instruction) => instruction.l == 'y')
      .r;
  int x = instructions
      .firstWhere((Pair<String, int> instruction) => instruction.l == 'x')
      .r;

  int rows = 2 * y + 1;
  int cols = 2 * x + 1;

  List<List<bool>> paper = List.generate(rows, (_) => List.filled(cols, false));

  List<Point2> coordinates = input
      .takeWhile((String line) => line != '')
      .map((String line) => line.split(','))
      .map((List<String> coordinateStrings) => coordinateStrings
          .map((String coordinateString) => int.parse(coordinateString)))
      .map((Iterable<int> coordinateValues) =>
          Point2.fromIterable(coordinateValues))
      .toList();

  for (Point2 coordinate in coordinates) {
    paper[coordinate.y][coordinate.x] = true;
  }

  return Pair(paper, instructions.toList());
}

List<List<bool>> foldH(List<List<bool>> paper) {
  return List.generate(
      paper.length,
      (int row) => List.generate(
          paper.first.length ~/ 2,
          (int col) =>
              paper[row][col] | paper[row][paper.first.length - 1 - col]));
}

List<List<bool>> foldV(List<List<bool>> paper) {
  return List.generate(
      paper.length ~/ 2,
      (int row) => List.generate(paper.first.length,
          (int col) => paper[row][col] | paper[paper.length - 1 - row][col]));
}

int part1(Pair<List<List<bool>>, List<Pair<String, int>>> input) {
  List<List<bool>> paper = [...input.l];

  if (input.r.first.l == 'x') {
    paper = foldH(paper);
  } else {
    paper = foldV(paper);
  }

  return paper
      .map((List<bool> row) =>
          row.map((bool coordinate) => coordinate.i01).sum())
      .sum();
}

int part2(Pair<List<List<bool>>, List<Pair<String, int>>> input) {
  List<List<bool>> paper = [...input.l];

  for (Pair<String, int> instruction in input.r) {
    if (instruction.l == 'x') {
      paper = foldH(paper);
    } else {
      paper = foldV(paper);
    }
  }

  for (List<bool> row in paper) {
    print(row.map((bool coordinate) => coordinate ? '#' : ' ').join());
  }

  return -1;
}
