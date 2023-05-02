import 'dart:collection';

import 'package:aoc/aoc.dart';

void main(List<String> args) async {
  Solver<Grid<int>, int>(
    part1: part1,
    part2: part2,
    inputTransformer: transformInput,
    testInput: transformInput([
      '2199943210',
      '3987894921',
      '9856789892',
      '8767896789',
      '9899965678',
    ]),
    testOutput1: 15,
    testOutput2: 1134,
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

Iterable<GridItem<int>> getLowestPoints(Grid<int> grid) {
  return grid.entries.where((GridItem<int> tile) {
    Iterable<int> neighborValues = grid
        .neighbors(tile.key)
        .map((GridItem<int> neighbor) => neighbor.value);
    return tile.value < neighborValues.min();
  });
}

int part1(Grid<int> input) {
  return getLowestPoints(input)
      .map((GridItem<int> lowestPoint) => lowestPoint.value + 1)
      .sum();
}

int bfs(
  Grid<int> grid,
  GridItem<int> startingPoint,
) {
  final Set<Point2> visitedPoints = {};
  final Queue<GridItem<int>> queue = Queue();
  queue.add(startingPoint);
  visitedPoints.add(startingPoint.key);

  while (queue.isNotEmpty) {
    final GridItem<int> currentPoint = queue.removeFirst();

    final List<GridItem<int>> basinNeighbors = grid
        .neighbors(currentPoint.key)
        .where((GridItem<int> neighbor) => neighbor.value >= currentPoint.value)
        .where((GridItem<int> neighbor) => neighbor.value < 9)
        .where(
            (GridItem<int> neighbor) => !visitedPoints.contains(neighbor.key))
        .toList();

    visitedPoints
        .addAll(basinNeighbors.map((GridItem<int> neighbor) => neighbor.key));
    queue.addAll(basinNeighbors);
  }

  return visitedPoints.length;
}

int part2(Grid<int> input) {
  final lowestPoints = getLowestPoints(input);
  final List<int> basinSizes = lowestPoints
      .map((GridItem<int> lowestPoint) => bfs(input, lowestPoint))
      .toList()
    ..sort();

  return basinSizes.reversed.take(3).product();
}
