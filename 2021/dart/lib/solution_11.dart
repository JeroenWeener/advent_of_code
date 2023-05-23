import 'package:aoc/aoc.dart';

void main(List<String> args) {
  Solver<List<List<int>>, int>(
    inputTransformer: transformInput,
    part1: part1,
    part2: part2,
    testOutput1: 1656,
    testOutput2: 195,
  ).execute();
}

List<List<int>> transformInput(List<String> input) =>
    input.map((e) => e.toIterable().map((c) => int.parse(c)).toList()).toList();

int part1(List<List<int>> grid) {
  List<List<int>> localGrid = [...grid];
  int flashes = 0;

  void increase() {
    localGrid = localGrid
        .map((List<int> row) => row.map((int octopus) => ++octopus).toList())
        .toList();
  }

  void set0() {
    localGrid = localGrid
        .map((List<int> row) =>
            row.map((int octopus) => octopus > 9 ? 0 : octopus).toList())
        .toList();
  }

  void update() {
    bool checkChainReaction = false;

    List<List<bool>> exploded = List.generate(
      localGrid.length,
      (_) => List.filled(localGrid.first.length, false),
    );

    do {
      checkChainReaction = false;
      for (int y = 0; y < localGrid.length; y++) {
        for (int x = 0; x < localGrid.first.length; x++) {
          if (localGrid[y][x] > 9 && !exploded[y][x]) {
            flashes++;
            exploded[y][x] = true;
            checkChainReaction = true;

            List<int> validY = range(
              [0, y - 1].max(),
              [localGrid.length, y + 1 + 1].min(),
            ).toList();
            List<int> validX = range(
              [0, x - 1].max(),
              [localGrid.first.length, x + 1 + 1].min(),
            ).toList();

            for (int r in validY) {
              for (int c in validX) {
                localGrid[r][c]++;
              }
            }
          }
        }
      }
    } while (checkChainReaction);
  }

  void iteration() {
    increase();
    update();
    set0();
  }

  100.times(iteration);

  return flashes;
}

int part2(List<List<int>> grid) {
  List<List<int>> localGrid = [...grid];
  int flashes = 0;

  void increase() {
    localGrid = localGrid
        .map((List<int> row) => row.map((int octopus) => ++octopus).toList())
        .toList();
  }

  void set0() {
    localGrid = localGrid
        .map((List<int> row) =>
            row.map((int octopus) => octopus > 9 ? 0 : octopus).toList())
        .toList();
  }

  void update() {
    bool checkChainReaction = false;

    List<List<bool>> exploded = List.generate(
      localGrid.length,
      (_) => List.filled(localGrid.first.length, false),
    );

    do {
      checkChainReaction = false;
      for (int y = 0; y < localGrid.length; y++) {
        for (int x = 0; x < localGrid.first.length; x++) {
          if (localGrid[y][x] > 9 && !exploded[y][x]) {
            flashes++;
            exploded[y][x] = true;
            checkChainReaction = true;
            List<int> validY = range(
              [0, y - 1].max(),
              [localGrid.length, y + 1 + 1].min(),
            ).toList();
            List<int> validX = range(
              [0, x - 1].max(),
              [localGrid.first.length, x + 1 + 1].min(),
            ).toList();

            for (int r in validY) {
              for (int c in validX) {
                localGrid[r][c]++;
              }
            }
          }
        }
      }
    } while (checkChainReaction);
  }

  void iteration() {
    increase();
    update();
    set0();
  }

  int iterations = 0;

  while (flashes != grid.length * grid.first.length) {
    flashes = 0;
    iteration();
    iterations++;
  }

  return iterations;
}
