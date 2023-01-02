import 'dart:io';

void main() {
  String input = File('2022/dart/17/input.txt').readAsStringSync();

  int answer1 = part1(input);
  print(answer1);

  int answer2 = part2(input);
  print(answer2);
}

void printGrid(List<List<bool>> grid) {
  print(
      '+${'-' * gridWidth}+\n|${grid.reversed.map((row) => row.map((position) => position ? '#' : '.').join()).join('|\n|')}|\n+${'-' * gridWidth}+');
}

void printShape(List<List<bool>> grid, List<Position> shape) {
  String s = '+-------+\n';
  for (int y = grid.length - 1; y >= 0; y--) {
    s += '|';
    for (int x = 0; x < grid[0].length; x++) {
      s += grid[y][x]
          ? '#'
          : shape.any((e) => e.x == x && e.y == y)
              ? '@'
              : '.';
    }
    s += '|\n';
  }
  s += '+-------+';
  print(s);
}

class Position {
  const Position(this.x, this.y);

  final int x;
  final int y;

  Position down() {
    return Position(x, y - 1);
  }

  Position left() {
    return Position(x - 1, y);
  }

  Position right() {
    return Position(x + 1, y);
  }

  @override
  String toString() {
    return '$x $y';
  }
}

extension BoolListExtensions on List<bool> {
  bool isEqual(List<bool> other) {
    if (length != other.length) {
      return false;
    }
    for (int i = 0; i < length; i++) {
      if (this[i] != other[i]) {
        return false;
      }
    }
    return true;
  }
}

extension BoolListListExtensions on List<List<bool>> {
  bool isEqual(List<List<bool>> other) {
    if (length != other.length) {
      return false;
    }
    for (int i = 0; i < length; i++) {
      if (!this[i].isEqual(other[i])) {
        return false;
      }
    }
    return true;
  }
}

extension PositionListExtensions on List<Position> {
  List<Position> down() {
    return map((e) => e.down()).toList();
  }

  List<Position> left() {
    return map((e) => e.left()).toList();
  }

  List<Position> right() {
    return map((e) => e.right()).toList();
  }

  bool canDown(List<List<bool>> grid) {
    return every(
        (position) => position.y > 0 && !grid[position.y - 1][position.x]);
  }

  bool canLeft(List<List<bool>> grid) {
    return every(
        (position) => position.x > 0 && !grid[position.y][position.x - 1]);
  }

  bool canRight(List<List<bool>> grid) {
    return every((position) =>
        position.x < grid[0].length - 1 && !grid[position.y][position.x + 1]);
  }

  int get height {
    Iterable<int> ys = map((e) => e.y);
    int topY = ys.reduce((maxY, y) => maxY > y ? maxY : y);
    int bottomY = ys.reduce((minY, y) => minY < y ? minY : y);
    return topY - bottomY + 1;
  }
}

void addShape(
  List<List<bool>> grid,
  List<Position> shape,
  List<bool> jets,
) {
  int targetEmptyRows = 3;
  int currentEmptyRows = grid.reversed
      .takeWhile((row) => row.every((position) => !position))
      .length;

  // Add extra empty rows if we do not have [targetEmptyRows] already.
  for (int i = 0; i < targetEmptyRows + shape.height - currentEmptyRows; i++) {
    grid.add(List.filled(gridWidth, false));
  }

  // Remove empty rows if we have a number of rows exceeding [targetEmptyRows].
  for (int i = 0; i < currentEmptyRows - shape.height - targetEmptyRows; i++) {
    grid.removeLast();
  }

  // Shapes start at the top of the grid with 2 empty spaces on their left.
  List<Position> updatedShape =
      shape.map((e) => Position(e.x + 2, grid.length - 1 - e.y)).toList();

  while (true) {
    // Whether the jet is moving right.
    //
    // True: right
    // False: left
    bool jet = jets[jetIndex++ % jets.length];

    if (jet && updatedShape.canRight(grid)) {
      updatedShape = updatedShape.right();
    }
    if (!jet && updatedShape.canLeft(grid)) {
      updatedShape = updatedShape.left();
    }

    if (updatedShape.canDown(grid)) {
      updatedShape = updatedShape.down();
    } else {
      break;
    }
  }

  updatedShape.forEach((position) => grid[position.y][position.x] = true);
}

List<List<Position>> shapes = [
  // ####
  [
    Position(0, 0),
    Position(1, 0),
    Position(2, 0),
    Position(3, 0),
  ],
  // .#.
  // ###
  // .#.
  [
    Position(1, 0),
    Position(0, 1),
    Position(1, 1),
    Position(2, 1),
    Position(1, 2),
  ],

  // ..#
  // ..#
  // ###
  [
    Position(2, 0),
    Position(2, 1),
    Position(0, 2),
    Position(1, 2),
    Position(2, 2),
  ],

  // #
  // #
  // #
  // #
  [
    Position(0, 0),
    Position(0, 1),
    Position(0, 2),
    Position(0, 3),
  ],

  // ##
  // ##
  [
    Position(0, 0),
    Position(1, 0),
    Position(0, 1),
    Position(1, 1),
  ],
];
int gridWidth = 7;
late int jetIndex;

/// --- Day 17: Pyroclastic Flow ---
///
/// Your handheld device has located an alternative exit from the cave for you
/// and the elephants. The ground is rumbling almost continuously now, but the
/// strange valves bought you some time. It's definitely getting warmer in here,
/// though.
///
/// The tunnels eventually open into a very tall, narrow chamber. Large,
/// oddly-shaped rocks are falling into the chamber from above, presumably due
/// to all the rumbling. If you can't work out where the rocks will fall next,
/// you might be crushed!
///
/// The five types of rocks have the following peculiar shapes, where # is rock
/// and . is empty space:
///
///   ####
///
///   .#.
///   ###
///   .#.
///
///   ..#
///   ..#
///   ###
///
///   #
///   #
///   #
///   #
///
///   ##
///   ##
///
///
/// The rocks fall in the order shown above: first the - shape, then the +
/// shape, and so on. Once the end of the list is reached, the same order
/// repeats: the - shape falls first, sixth, 11th, 16th, etc.
///
/// The rocks don't spin, but they do get pushed around by jets of hot gas
/// coming out of the walls themselves. A quick scan reveals the effect the jets
/// of hot gas will have on the rocks as they fall (your puzzle input).
///
/// For example, suppose this was the jet pattern in your cave:
///
///   >>><<><>><<<>><>>><<<>>><<<><<<>><>><<>>
///
///
/// In jet patterns, < means a push to the left, while > means a push to the
/// right. The pattern above means that the jets will push a falling rock right,
/// then right, then right, then left, then left, then right, and so on. If the
/// end of the list is reached, it repeats.
///
/// The tall, vertical chamber is exactly seven units wide. Each rock appears so
/// that its left edge is two units away from the left wall and its bottom edge
/// is three units above the highest rock in the room (or the floor, if there
/// isn't one).
///
/// After a rock appears, it alternates between being pushed by a jet of hot gas
/// one unit (in the direction indicated by the next symbol in the jet pattern)
/// and then falling one unit down. If any movement would cause any part of the
/// rock to move into the walls, floor, or a stopped rock, the movement instead
/// does not occur. If a downward movement would have caused a falling rock to
/// move into the floor or an already-fallen rock, the falling rock stops where
/// it is (having landed on something) and a new rock immediately begins
/// falling.
///
/// Drawing falling rocks with @ and stopped rocks with #, the jet pattern in
/// the example above manifests as follows:
///
///   The first rock begins falling:
///   |..@@@@.|
///   |.......|
///   |.......|
///   |.......|
///   +-------+
///
///   Jet of gas pushes rock right:
///   |...@@@@|
///   |.......|
///   |.......|
///   |.......|
///   +-------+
///
///   Rock falls 1 unit:
///   |...@@@@|
///   |.......|
///   |.......|
///   +-------+
///
///   Jet of gas pushes rock right, but nothing happens:
///   |...@@@@|
///   |.......|
///   |.......|
///   +-------+
///
///   Rock falls 1 unit:
///   |...@@@@|
///   |.......|
///   +-------+
///
///   Jet of gas pushes rock right, but nothing happens:
///   |...@@@@|
///   |.......|
///   +-------+
///
///   Rock falls 1 unit:
///   |...@@@@|
///   +-------+
///
///   Jet of gas pushes rock left:
///   |..@@@@.|
///   +-------+
///
///   Rock falls 1 unit, causing it to come to rest:
///   |..####.|
///   +-------+
///
///   A new rock begins falling:
///   |...@...|
///   |..@@@..|
///   |...@...|
///   |.......|
///   |.......|
///   |.......|
///   |..####.|
///   +-------+
///
///   Jet of gas pushes rock left:
///   |..@....|
///   |.@@@...|
///   |..@....|
///   |.......|
///   |.......|
///   |.......|
///   |..####.|
///   +-------+
///
///   Rock falls 1 unit:
///   |..@....|
///   |.@@@...|
///   |..@....|
///   |.......|
///   |.......|
///   |..####.|
///   +-------+
///
///   Jet of gas pushes rock right:
///   |...@...|
///   |..@@@..|
///   |...@...|
///   |.......|
///   |.......|
///   |..####.|
///   +-------+
///
///   Rock falls 1 unit:
///   |...@...|
///   |..@@@..|
///   |...@...|
///   |.......|
///   |..####.|
///   +-------+
///
///   Jet of gas pushes rock left:
///   |..@....|
///   |.@@@...|
///   |..@....|
///   |.......|
///   |..####.|
///   +-------+
///
///   Rock falls 1 unit:
///   |..@....|
///   |.@@@...|
///   |..@....|
///   |..####.|
///   +-------+
///
///   Jet of gas pushes rock right:
///   |...@...|
///   |..@@@..|
///   |...@...|
///   |..####.|
///   +-------+
///
///   Rock falls 1 unit, causing it to come to rest:
///   |...#...|
///   |..###..|
///   |...#...|
///   |..####.|
///   +-------+
///
///   A new rock begins falling:
///   |....@..|
///   |....@..|
///   |..@@@..|
///   |.......|
///   |.......|
///   |.......|
///   |...#...|
///   |..###..|
///   |...#...|
///   |..####.|
///   +-------+
///
///
/// The moment each of the next few rocks begins falling, you would see this:
///
///   |..@....|
///   |..@....|
///   |..@....|
///   |..@....|
///   |.......|
///   |.......|
///   |.......|
///   |..#....|
///   |..#....|
///   |####...|
///   |..###..|
///   |...#...|
///   |..####.|
///   +-------+
///
///   |..@@...|
///   |..@@...|
///   |.......|
///   |.......|
///   |.......|
///   |....#..|
///   |..#.#..|
///   |..#.#..|
///   |#####..|
///   |..###..|
///   |...#...|
///   |..####.|
///   +-------+
///
///   |..@@@@.|
///   |.......|
///   |.......|
///   |.......|
///   |....##.|
///   |....##.|
///   |....#..|
///   |..#.#..|
///   |..#.#..|
///   |#####..|
///   |..###..|
///   |...#...|
///   |..####.|
///   +-------+
///
///   |...@...|
///   |..@@@..|
///   |...@...|
///   |.......|
///   |.......|
///   |.......|
///   |.####..|
///   |....##.|
///   |....##.|
///   |....#..|
///   |..#.#..|
///   |..#.#..|
///   |#####..|
///   |..###..|
///   |...#...|
///   |..####.|
///   +-------+
///
///   |....@..|
///   |....@..|
///   |..@@@..|
///   |.......|
///   |.......|
///   |.......|
///   |..#....|
///   |.###...|
///   |..#....|
///   |.####..|
///   |....##.|
///   |....##.|
///   |....#..|
///   |..#.#..|
///   |..#.#..|
///   |#####..|
///   |..###..|
///   |...#...|
///   |..####.|
///   +-------+
///
///   |..@....|
///   |..@....|
///   |..@....|
///   |..@....|
///   |.......|
///   |.......|
///   |.......|
///   |.....#.|
///   |.....#.|
///   |..####.|
///   |.###...|
///   |..#....|
///   |.####..|
///   |....##.|
///   |....##.|
///   |....#..|
///   |..#.#..|
///   |..#.#..|
///   |#####..|
///   |..###..|
///   |...#...|
///   |..####.|
///   +-------+
///
///   |..@@...|
///   |..@@...|
///   |.......|
///   |.......|
///   |.......|
///   |....#..|
///   |....#..|
///   |....##.|
///   |....##.|
///   |..####.|
///   |.###...|
///   |..#....|
///   |.####..|
///   |....##.|
///   |....##.|
///   |....#..|
///   |..#.#..|
///   |..#.#..|
///   |#####..|
///   |..###..|
///   |...#...|
///   |..####.|
///   +-------+
///
///   |..@@@@.|
///   |.......|
///   |.......|
///   |.......|
///   |....#..|
///   |....#..|
///   |....##.|
///   |##..##.|
///   |######.|
///   |.###...|
///   |..#....|
///   |.####..|
///   |....##.|
///   |....##.|
///   |....#..|
///   |..#.#..|
///   |..#.#..|
///   |#####..|
///   |..###..|
///   |...#...|
///   |..####.|
///   +-------+
///
///
/// To prove to the elephants your simulation is accurate, they want to know how
/// tall the tower will get after 2022 rocks have stopped (but before the 2023rd
/// rock begins falling). In this example, the tower of rocks will be 3068 units
/// tall.
///
/// How many units tall will the tower of rocks be after 2022 rocks have stopped
/// falling?
int part1(String input) {
  jetIndex = 0;
  List<List<bool>> grid = [];
  List<bool> jets = input.split('').map((e) => e == '>').toList();

  for (int dropIndex = 0; dropIndex < 2022; dropIndex++) {
    addShape(grid, shapes[dropIndex % shapes.length], jets);
  }

  return grid.takeWhile((row) => row.any((position) => position)).length;
}

/// --- Part Two ---
///
/// The elephants are not impressed by your simulation. They demand to know how
/// tall the tower will be after 1000000000000 rocks have stopped! Only then
/// will they feel confident enough to proceed through the cave.
///
/// In the example above, the tower would be 1514285714288 units tall!
///
/// How tall will the tower be after 1000000000000 rocks have stopped?
int part2(String input) {
  jetIndex = 0;
  List<List<bool>> grid = [];
  List<bool> jets = input.split('').map((e) => e == '>').toList();

  int totalDrops = 1000000000000;
  int initialDrops = 10000;

  // Calculate the start height; the height after dropping [initialDrops]
  // shapes.
  for (int initialDropIndex = 0;
      initialDropIndex < initialDrops;
      initialDropIndex++) {
    addShape(grid, shapes[initialDropIndex % shapes.length], jets);
  }

  int heightStart = grid.reversed
      .skipWhile((row) => row.every((position) => !position))
      .length;

  // Store top 100 rows so we can check for repetition.
  List<List<bool>> top =
      List.generate(100, (index) => List.from(grid[grid.length - 1 - index]));

  // Drop shapes until we repeated the top 100 rows.
  int middleDrops = 0;
  while (true) {
    for (List<Position> shape in shapes) {
      addShape(grid, shape, jets);
    }
    middleDrops += shapes.length;

    List<List<bool>> gridTop =
        List.generate(100, (index) => List.from(grid[grid.length - 1 - index]));

    if (gridTop.isEqual(top)) {
      break;
    }
  }

  // Calculate the height that [middleDrops] drops will add.
  int height = grid.reversed
      .skipWhile((row) => row.every((position) => !position))
      .length;
  int difference = height - heightStart;

  // Calculate the number of [middleDrops] that are needed before we are almost
  // at [totalDrops].
  int batches = (totalDrops - initialDrops) ~/ middleDrops;

  // Compute the height we are at without actually dropping more shapes.
  int heightMiddle = difference * batches;

  // Compute remaining number of drops until we reached [totalDrops] drops.
  int remainingDrops = totalDrops - initialDrops - batches * middleDrops;

  // Add [remainingDrops] number of shapes.
  for (int dropIndex = 0; dropIndex < remainingDrops; dropIndex++) {
    addShape(grid, shapes[dropIndex % shapes.length], jets);
  }

  // Compute the height that was added by dropping [remainingDrops] drops.
  int heightEnd = grid.reversed
          .skipWhile((row) => row.every((position) => !position))
          .length -
      height;

  // Compute total height by adding the initial height, the height by repeating
  // the batches and the height we got by dropping shapes at the end.
  int totalHeight = heightStart + heightMiddle + heightEnd;

  return totalHeight;
}
