import 'dart:collection';

import 'package:aoc/aoc.dart';

void main(List<String> args) {
  Solver<UnboundGrid<int>, int>(
    part1: part1,
    part2: part2,
    inputTransformer: transformInput,
    testOutput1: 15,
    testOutput2: 1134,
  ).execute();
}

UnboundGrid<int> transformInput(List<String> input) {
  final UnboundGrid<int> map = {};
  for (int y = 0; y < input.length; y++) {
    for (int x = 0; x < input.first.length; x++) {
      map[Point2(x, y)] = int.parse(input[y][x]);
    }
  }
  return map;
}

Iterable<UnboundGridItem<int>> getLowestPoints(UnboundGrid<int> grid) {
  return grid.entries.where((UnboundGridItem<int> tile) {
    Iterable<int> neighborValues = grid
        .neighbors(tile.point2)
        .map((UnboundGridItem<int> neighbor) => neighbor.value);
    return tile.value < neighborValues.min();
  });
}

int part1(UnboundGrid<int> input) {
  return getLowestPoints(input)
      .map((UnboundGridItem<int> lowestPoint) => lowestPoint.value + 1)
      .sum();
}

int bfs(
  UnboundGrid<int> grid,
  UnboundGridItem<int> startingPoint,
) {
  final Set<Point2> visitedPoints = {};
  final Queue<UnboundGridItem<int>> queue = Queue();
  queue.add(startingPoint);
  visitedPoints.add(startingPoint.point2);

  while (queue.isNotEmpty) {
    final UnboundGridItem<int> currentPoint = queue.removeFirst();

    final List<UnboundGridItem<int>> basinNeighbors = grid
        .neighbors(currentPoint.point2)
        .where((UnboundGridItem<int> neighbor) =>
            neighbor.value >= currentPoint.value)
        .where((UnboundGridItem<int> neighbor) => neighbor.value < 9)
        .where((UnboundGridItem<int> neighbor) =>
            !visitedPoints.contains(neighbor.point2))
        .toList();

    visitedPoints.addAll(
        basinNeighbors.map((UnboundGridItem<int> neighbor) => neighbor.point2));
    queue.addAll(basinNeighbors);
  }

  return visitedPoints.length;
}

int part2(UnboundGrid<int> input) {
  final lowestPoints = getLowestPoints(input);
  final List<int> basinSizes = lowestPoints
      .map((UnboundGridItem<int> lowestPoint) => bfs(input, lowestPoint))
      .toList()
    ..sort();

  return basinSizes.reversed.take(3).product();
}
