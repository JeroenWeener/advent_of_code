import 'dart:io';

void main() {
  List<String> input = File('2022/dart/18/input.txt').readAsLinesSync();

  int answer1 = part1(input);
  print(answer1);

  int answer2 = part2(input);
  print(answer2);
}

Iterable<String> adjacentBlocks(String block) {
  List<int> coordinates = block.split(',').map((e) => int.parse(e)).toList();
  return [
    [coordinates[0], coordinates[1], coordinates[2] - 1],
    [coordinates[0], coordinates[1], coordinates[2] + 1],
    [coordinates[0], coordinates[1] - 1, coordinates[2]],
    [coordinates[0], coordinates[1] + 1, coordinates[2]],
    [coordinates[0] - 1, coordinates[1], coordinates[2]],
    [coordinates[0] + 1, coordinates[1], coordinates[2]],
  ].map((coordinates) => coordinates.join(','));
}

int part1(List<String> input) {
  return input
      .map((block) =>
          6 -
          adjacentBlocks(block)
              .where((adjacent) => input.contains(adjacent))
              .length)
      .reduce((total, faces) => total + faces);
}

int part2(List<String> input) {
  return -1;
}
