import 'dart:io';

void main() {
  List<String> input = File('2022/dart/12/input.txt').readAsLinesSync();

  int answer1 = part1(input);
  print(answer1);

  int answer2 = part2(input);
  print(answer2);
}

final int MAX_INT = ~(1 << 63);

late List<List<int>> mountains;
late List<List<int>> costs;

class Position {
  const Position(this.x, this.y);

  final int x;
  final int y;

  Position? up() => y < mountains[0].length - 1 ? Position(x, y + 1) : null;
  Position? right() => x < mountains.length - 1 ? Position(x + 1, y) : null;
  Position? down() => y > 0 ? Position(x, y - 1) : null;
  Position? left() => x > 0 ? Position(x - 1, y) : null;

  int get height => mountains[x][y];
  int get lowestPathCost => costs[x][y];
  void set lowestPathCost(int cost) => costs[x][y] = cost;

  @override
  String toString() {
    return '$x $y';
  }

  /// Return an [Iterable] of neighbors that can be reached by this position.
  Iterable<Position> getReachableNeighbors() {
    return [up(), right(), down(), left()]
        .whereType<Position>()
        .where((neighbor) => neighbor.height - height <= 1);
  }

  /// Return an [Iterable] of neighbors that can reach this position.
  Iterable<Position> getReachingNeighbors() {
    return [up(), right(), down(), left()]
        .whereType<Position>()
        .where((neighbor) => height - neighbor.height <= 1);
  }
}

List<List<int>> generateHeightMap(List<String> input) {
  return List.generate(
    input.length,
    (lineIndex) => input[lineIndex].codeUnits.map(
      (codeUnit) {
        if (codeUnit == 'S'.codeUnits.first) {
          return 0;
        } else if (codeUnit == 'E'.codeUnits.first) {
          return 25;
        } else {
          return codeUnit - 'a'.codeUnits.first;
        }
      },
    ).toList(),
  );
}

Position getStartingPosition(List<String> input) {
  int totalPosition = input.join('').indexOf('S');
  return Position(
      totalPosition ~/ input[0].length, totalPosition % input[0].length);
}

Position getDestinationPosition(List<String> input) {
  int totalPosition = input.join('').indexOf('E');
  return Position(
      totalPosition ~/ input[0].length, totalPosition % input[0].length);
}

void discoverPathForward(Position currentPosition) {
  currentPosition
      .getReachableNeighbors()
      .where((neighbor) =>
          neighbor.lowestPathCost > currentPosition.lowestPathCost + 1)
      .forEach((improvableNeighbors) {
    improvableNeighbors.lowestPathCost = currentPosition.lowestPathCost + 1;
    discoverPathForward(improvableNeighbors);
  });
}

void discoverPathBackward(Position currentPosition) {
  currentPosition
      .getReachingNeighbors()
      .where((neighbor) =>
          neighbor.lowestPathCost > currentPosition.lowestPathCost + 1)
      .forEach((improvableNeighbors) {
    improvableNeighbors.lowestPathCost = currentPosition.lowestPathCost + 1;
    discoverPathBackward(improvableNeighbors);
  });
}

/// --- Day 12: Hill Climbing Algorithm ---
///
/// You try contacting the Elves using your handheld device, but the river
/// you're following must be too low to get a decent signal.
///
/// You ask the device for a heightmap of the surrounding area (your puzzle
/// input). The heightmap shows the local area from above broken into a grid;
/// the elevation of each square of the grid is given by a single lowercase
/// letter, where a is the lowest elevation, b is the next-lowest, and so on up
/// to the highest elevation, z.
///
/// Also included on the heightmap are marks for your current position (S) and
/// the location that should get the best signal (E). Your current position (S)
/// has elevation a, and the location that should get the best signal (E) has
/// elevation z.
///
/// You'd like to reach E, but to save energy, you should do it in as few steps
/// as possible. During each step, you can move exactly one square up, down,
/// left, or right. To avoid needing to get out your climbing gear, the
/// elevation of the destination square can be at most one higher than the
/// elevation of your current square; that is, if your current elevation is m,
/// you could step to elevation n, but not to elevation o. (This also means that
/// the elevation of the destination square can be much lower than the elevation
/// of your current square.)
///
/// For example:
///
///   Sabqponm
///   abcryxxl
///   accszExk
///   acctuvwj
///   abdefghi
///
///
/// Here, you start in the top-left corner; your goal is near the middle. You
/// could start by moving down or right, but eventually you'll need to head
/// toward the e at the bottom. From there, you can spiral around to the goal:
///
///   v..v<<<<
///   >v.vv<<^
///   .>vv>E^^
///   ..v>>>^^
///   ..>>>>>^
///
///
/// In the above diagram, the symbols indicate whether the path exits each
/// square moving up (^), down (v), left (<), or right (>). The location that
/// should get the best signal is still E, and . marks unvisited squares.
///
/// This path reaches the goal in 31 steps, the fewest possible.
///
/// What is the fewest steps required to move from your current position to the
/// location that should get the best signal?
int part1(List<String> input) {
  mountains = generateHeightMap(input);
  costs = List.generate(
    mountains.length,
    (x) => List.generate(
      mountains[0].length,
      (y) => MAX_INT,
      growable: false,
    ),
    growable: false,
  );

  Position startingPosition = getStartingPosition(input);
  Position destinationPosition = getDestinationPosition(input);

  startingPosition.lowestPathCost = 0;

  discoverPathForward(startingPosition);

  return destinationPosition.lowestPathCost;
}

/// --- Part Two ---
///
/// As you walk up the hill, you suspect that the Elves will want to turn this
/// into a hiking trail. The beginning isn't very scenic, though; perhaps you
/// can find a better starting point.
///
/// To maximize exercise while hiking, the trail should start as low as
/// possible: elevation a. The goal is still the square marked E. However, the
/// trail should still be direct, taking the fewest steps to reach its goal. So,
/// you'll need to find the shortest path from any square at elevation a to the
/// square marked E.
///
/// Again consider the example from above:
///
///   Sabqponm
///   abcryxxl
///   accszExk
///   acctuvwj
///   abdefghi
///
///
/// Now, there are six choices for starting position (five marked a, plus the
/// square marked S that counts as being at elevation a). If you start at the
/// bottom-left square, you can reach the goal most quickly:
///
///   ...v<<<<
///   ...vv<<^
///   ...v>E^^
///   .>v>>>^^
///   >^>>>>>^
///
///
/// This path reaches the goal in only 29 steps, the fewest possible.
///
/// What is the fewest steps required to move starting from any square with
/// elevation a to the location that should get the best signal?
int part2(List<String> input) {
  mountains = generateHeightMap(input);
  costs = List.generate(
    mountains.length,
    (x) => List.generate(
      mountains[0].length,
      (y) => MAX_INT,
      growable: false,
    ),
    growable: false,
  );

  Position destinationPosition = getDestinationPosition(input);

  destinationPosition.lowestPathCost = 0;

  discoverPathBackward(destinationPosition);

  List<Position> potentialStartingPositions = [];
  for (int x = 0; x < mountains.length; x++) {
    for (int y = 0; y < mountains[0].length; y++) {
      if (mountains[x][y] == 0) {
        potentialStartingPositions.add(Position(x, y));
      }
    }
  }

  return potentialStartingPositions
      .map((potentialStartingPosition) =>
          potentialStartingPosition.lowestPathCost)
      .reduce((a, b) => b < a ? b : a);
}
