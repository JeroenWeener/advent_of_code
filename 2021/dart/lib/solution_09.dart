import 'package:aoc/aoc.dart';

void main(List<String> args) async {
  Solver<Grid<int>, int>(
    part1: part1,
    inputTransformer: transformInput,
    testInput: transformInput([
      '2199943210',
      '3987894921',
      '9856789892',
      '8767896789',
      '9899965678',
    ]),
    testOutput1: 15,
  ).execute();
}

Grid<int> transformInput(List<String> input) {
  final Grid<int> map = {};
  for (int y = 0; y < input.length; y++) {
    for (int x = 0; x < input.first.length; x++) {
      map[Point2(x, y)] = int.parse(input[y][x]);
    }
  }
  return map;
}

int part1(Grid<int> input) {
  return input.entries
      .where((GridItem<int> tile) {
        Iterable<int> neighborValues = input
            .neighbors(tile.key)
            .map((GridItem<int> neighbor) => neighbor.value);
        return tile.value < neighborValues.min();
      })
      .map((GridItem<int> lowTile) => lowTile.value + 1)
      .sum();
}
