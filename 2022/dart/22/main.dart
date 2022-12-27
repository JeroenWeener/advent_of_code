import 'dart:io';

void main() {
  List<String> input = File('2022/dart/22/input.txt').readAsLinesSync();

  int answer1 = part1(input);
  print(answer1);

  int answer2 = part2(input);
  print(answer2);
}

enum Tile {
  ground,
  wall,
  empty,
}

/// An instruction.
///
/// Instructions should be interpreted as: walk for [distance] steps, then turn
/// [direction].
class Instruction {
  const Instruction(this.direction, this.distance);

  /// The relative direction.
  ///
  /// -1 for turning right,
  ///  1 for turning left,
  ///  0 for going straight.
  final int direction;

  final int distance;

  @override
  String toString() {
    return '$direction, $distance';
  }
}

List<List<Tile>> parseTiles(List<String> input) {
  int width = input
      .take(input.length - 2)
      .map((e) => e.length)
      .reduce((a, b) => a > b ? a : b);

  return input
      .take(input.length - 2)
      .map(
        (String line) => List.generate(
          width,
          (index) {
            if (index >= line.length) {
              return Tile.empty;
            }
            int c = line.codeUnitAt(index);
            if (c == ' '.codeUnits.first) {
              return Tile.empty;
            } else if (c == '.'.codeUnits.first) {
              return Tile.ground;
            } else if (c == '#'.codeUnits.first) {
              return Tile.wall;
            } else {
              throw Exception('Unexpected tile character $c');
            }
          },
        ),
      )
      .toList();
}

List<Instruction> parseInstructions(List<String> input) {
  String instructionsString = input[input.length - 1];
  int direction = 0;
  List<Instruction> parsedInstructions = [];

  String numberString = '';
  for (int characterIndex = 0;
      characterIndex < instructionsString.length;
      characterIndex++) {
    int c = instructionsString.codeUnitAt(characterIndex);

    if (c == 'R'.codeUnits.first) {
      parsedInstructions.add(Instruction(1, int.parse(numberString)));
      direction = (direction + 1) % 4;
      numberString = '';
    } else if (c == 'L'.codeUnits.first) {
      parsedInstructions.add(Instruction(-1, int.parse(numberString)));
      direction = (direction - 1) % 4;
      numberString = '';
    } else {
      numberString += String.fromCharCode(c);
    }
  }

  // Do not turn after the last instruction.
  parsedInstructions.add(Instruction(0, int.parse(numberString)));

  return parsedInstructions;
}

/// Calculate the next position based on a list of [Tile]s, the current [pos]
/// and the [distance] that needs to be traversed.
///
/// If [distance] is negative, traverse through the list in reversed order.
int nextPosInLine(int pos, int distance, List<Tile> tiles) {
  // If we do not need to cover any extra distance, return current pos.
  if (distance == 0) {
    return pos;
  }

  // Calculate the neighbor position we are interested in.
  int neighbor = (pos + (distance > 0 ? 1 : -1)) % tiles.length;
  Tile neighborTile;
  // Check for neighbor tiles until we find a non-[Tile.empty] tile.
  while (true) {
    neighborTile = tiles[neighbor];

    if (neighborTile == Tile.ground) {
      // If the next non-empty tile is ground, repeat this process with the
      // distance 1 closer to 0.
      return nextPosInLine(neighbor, distance - (distance > 0 ? 1 : -1), tiles);
    }

    if (neighborTile == Tile.wall) {
      // If the next non-empty tile is a wall, return the current position.
      return pos;
    }

    // [Tile.empty], find next neighbor.
    neighbor = (neighbor + (distance > 0 ? 1 : -1)) % tiles.length;
  }
}

/// Returns the new position [newX, newY, newDirection] on the cube, based on
/// the current position [posX],[posY],[direction], the [distance] that needs to
/// be traveled (always positive), and the [tiles].
///
/// The cube wrapping logic has been hardcoded for the specific puzzle input in
/// `input.txt`.
///
/// Wrapping sides in the input have been labeled 1 through 14.
///
///             1     2
///          +-----+-----+
///          |     |     |
///       14 |     |     | 3
///          |     |     |
///          +-----+-----+
///          |     |  4
///       13 |     | 5
///      12  |     |
///    +-----+-----+
///    |     |     |
/// 11 |     |     | 6
///    |     |     |
///    +-----+-----+
///    |     |  7
/// 10 |     | 8
///    |     |
///    +-----+
///       9
List<int> nextTileInCube(
  int posX,
  int posY,
  int direction,
  int distance,
  List<List<Tile>> tiles,
) {
  // If we do not need to cover any extra distance, return current position.
  if (distance == 0) {
    return [posX, posY, direction];
  }

  int neighborX = posX;
  int neighborY = posY;
  int newDirection = direction;

  // Walking north from side 1 to side 10.
  if (newDirection == 3 &&
      neighborY == 0 &&
      neighborX >= 50 &&
      neighborX < 100) {
    neighborY = neighborX + 100;
    neighborX = 0;
    newDirection = 0;
  }

  // Walking north from side 2 to side 9.
  else if (newDirection == 3 &&
      neighborY == 0 &&
      neighborX >= 100 &&
      neighborX < 150) {
    neighborX = neighborX - 100;
    neighborY = 199;
  }

  // Walking east from side 3 to side 6.
  else if (newDirection == 0 && neighborY < 50 && neighborX == 149) {
    neighborY = 149 - neighborY;
    neighborX = 99;
    newDirection = 2;
  }

  // Walking south from side 4 to side 5.
  else if (newDirection == 1 &&
      neighborY == 49 &&
      neighborX >= 100 &&
      neighborX < 150) {
    neighborY = neighborX - 50;
    neighborX = 99;
    newDirection = 2;
  }

  // Walking east from side 5 to side 4.
  else if (newDirection == 0 &&
      neighborY >= 50 &&
      neighborY < 100 &&
      neighborX == 99) {
    neighborX = 50 + neighborY;
    neighborY = 49;
    newDirection = 3;
  }

  // Walking east from side 6 to side 3.
  else if (newDirection == 0 &&
      neighborY >= 100 &&
      neighborY < 150 &&
      neighborX == 99) {
    neighborY = 149 - neighborY;
    neighborX = 149;
    newDirection = 2;
  }

  // Walking south from side 7 to side 8.
  else if (newDirection == 1 &&
      neighborY == 149 &&
      neighborX >= 50 &&
      neighborX < 100) {
    neighborY = 100 + neighborX;
    neighborX = 49;
    newDirection = 2;
  }

  // Walking east from side 8 to side 7.
  else if (newDirection == 0 && neighborY >= 150 && neighborX == 49) {
    neighborX = neighborY - 100;
    neighborY = 149;
    newDirection = 3;
  }

  // Walking south from side 9 to side 2.
  else if (newDirection == 1 && neighborY == 199 && neighborX < 50) {
    neighborX = neighborX + 100;
    neighborY = 0;
  }

  // Walking west from side 10 to side 1.
  else if (newDirection == 2 && neighborY >= 150 && neighborX == 0) {
    neighborX = neighborY - 100;
    neighborY = 0;
    newDirection = 1;
  }

  // Walking west from side 11 to side 14.
  else if (newDirection == 2 &&
      neighborY >= 100 &&
      neighborY < 150 &&
      neighborX == 0) {
    neighborY = 149 - neighborY;
    neighborX = 50;
    newDirection = 0;
  }

  // Walking north from side 12 to side 13.
  else if (newDirection == 3 && neighborY == 100 && neighborX < 50) {
    neighborY = 50 + neighborX;
    neighborX = 50;
    newDirection = 0;
  }

  // Walking west from side 13 to side 12.
  else if (newDirection == 2 &&
      neighborY >= 50 &&
      neighborY < 100 &&
      neighborX == 50) {
    neighborX = neighborY - 50;
    neighborY = 100;
    newDirection = 1;
  }

  // Walking west from side 14 to side 11.
  else if (newDirection == 2 && neighborY < 50 && neighborX == 50) {
    neighborY = 149 - neighborY;
    neighborX = 0;
    newDirection = 0;
  }

  // Walk normally.
  else {
    neighborX = (neighborX +
        (newDirection == 0
            ? 1
            : newDirection == 2
                ? -1
                : 0));
    neighborY = (neighborY +
        (newDirection == 1
            ? 1
            : newDirection == 3
                ? -1
                : 0));
  }

  Tile neighborTile = tiles[neighborY][neighborX];

  if (neighborTile == Tile.ground) {
    return nextTileInCube(
        neighborX, neighborY, newDirection, distance - 1, tiles);
  }

  if (neighborTile == Tile.wall) {
    return [posX, posY, direction];
  }

  throw Exception('Encountered tile $neighborTile');
}

/// Finds first ground tile at y=0.
int getStartingX(List<List<Tile>> tiles) {
  return tiles[0].indexWhere((tile) => tile == Tile.ground);
}

/// --- Day 22: Monkey Map ---
///
/// The monkeys take you on a surprisingly easy trail through the jungle.
/// They're even going in roughly the right direction according to your handheld
/// device's Grove Positioning System.
///
/// As you walk, the monkeys explain that the grove is protected by a force
/// field. To pass through the force field, you have to enter a password; doing
/// so involves tracing a specific path on a strangely-shaped board.
///
/// At least, you're pretty sure that's what you have to do; the elephants
/// aren't exactly fluent in monkey.
///
/// The monkeys give you notes that they took when they last saw the password
/// entered (your puzzle input).
///
/// For example:
///
///           ...#
///           .#..
///           #...
///           ....
///   ...#.......#
///   ........#...
///   ..#....#....
///   ..........#.
///           ...#....
///           .....#..
///           .#......
///           ......#.
///
///   10R5L5R10L4R5L5
///
///
/// The first half of the monkeys' notes is a map of the board. It is comprised
/// of a set of open tiles (on which you can move, drawn .) and solid walls
/// (tiles which you cannot enter, drawn #).
///
/// The second half is a description of the path you must follow. It consists of
/// alternating numbers and letters:
///
///   - A number indicates the number of tiles to move in the direction you are
///     facing. If you run into a wall, you stop moving forward and continue
///     with the next instruction.
///   - A letter indicates whether to turn 90 degrees clockwise (R) or
///     counterclockwise (L). Turning happens in-place; it does not change your
///     current tile.
///
///
/// So, a path like 10R5 means "go forward 10 tiles, then turn clockwise 90
/// degrees, then go forward 5 tiles".
///
/// You begin the path in the leftmost open tile of the top row of tiles.
/// Initially, you are facing to the right (from the perspective of how the map
/// is drawn).
///
/// If a movement instruction would take you off of the map, you wrap around to
/// the other side of the board. In other words, if your next tile is off of the
/// board, you should instead look in the direction opposite of your current
/// facing as far as you can until you find the opposite edge of the board, then
/// reappear there.
///
/// For example, if you are at A and facing to the right, the tile in front of
/// you is marked B; if you are at C and facing down, the tile in front of you
/// is marked D:
///
///           ...#
///           .#..
///           #...
///           ....
///   ...#.D.....#
///   ........#...
///   B.#....#...A
///   .....C....#.
///           ...#....
///           .....#..
///           .#......
///           ......#.
///
///
/// It is possible for the next tile (after wrapping around) to be a wall; this
/// still counts as there being a wall in front of you, and so movement stops
/// before you actually wrap to the other side of the board.
///
/// By drawing the last facing you had with an arrow on each tile you visit, the
/// full path taken by the above example looks like this:
///
///           >>v#
///           .#v.
///           #.v.
///           ..v.
///   ...#...v..v#
///   >>>v...>#.>>
///   ..#v...#....
///   ...>>>>v..#.
///           ...#....
///           .....#..
///           .#......
///           ......#.
///
///
/// To finish providing the password to this strange input device, you need to
/// determine numbers for your final row, column, and facing as your final
/// position appears from the perspective of the original map. Rows start from 1
/// at the top and count downward; columns start from 1 at the left and count
/// rightward. (In the above example, row 1, column 1 refers to the empty space
/// with no tile on it in the top-left corner.) Facing is 0 for right (>), 1 for
/// down (v), 2 for left (<), and 3 for up (^). The final password is the sum of
/// 1000 times the row, 4 times the column, and the facing.
///
/// In the above example, the final row is 6, the final column is 8, and the
/// final facing is 0. So, the final password is 1000 * 6 + 4 * 8 + 0: 6032.
///
/// Follow the path given in the monkeys' notes. What is the final password?
int part1(List<String> input) {
  List<List<Tile>> tiles = parseTiles(input);
  List<Instruction> instructions = parseInstructions(input);
  int x = getStartingX(tiles);
  int y = 0;
  int absoluteDirection = 0;

  for (Instruction instruction in instructions) {
    if (absoluteDirection % 2 == 0) {
      x = nextPosInLine(
        x,
        instruction.distance * (absoluteDirection == 0 ? 1 : -1),
        tiles[y],
      );
    } else {
      y = nextPosInLine(
        y,
        instruction.distance * (absoluteDirection == 1 ? 1 : -1),
        tiles.map((e) => e[x]).toList(),
      );
    }
    absoluteDirection = (absoluteDirection + instruction.direction) % 4;
  }

  return 1000 * (y + 1) + 4 * (x + 1) + absoluteDirection;
}

/// --- Part Two ---
///
/// As you reach the force field, you think you hear some Elves in the distance.
/// Perhaps they've already arrived?
///
/// You approach the strange input device, but it isn't quite what the monkeys
/// drew in their notes. Instead, you are met with a large cube; each of its six
/// faces is a square of 50x50 tiles.
///
/// To be fair, the monkeys' map does have six 50x50 regions on it. If you were
/// to carefully fold the map, you should be able to shape it into a cube!
///
/// In the example above, the six (smaller, 4x4) faces of the cube are:
///
///           1111
///           1111
///           1111
///           1111
///   222233334444
///   222233334444
///   222233334444
///   222233334444
///           55556666
///           55556666
///           55556666
///           55556666
///
///
/// You still start in the same position and with the same facing as before, but
/// the wrapping rules are different. Now, if you would walk off the board, you
/// instead proceed around the cube. From the perspective of the map, this can
/// look a little strange. In the above example, if you are at A and move to the
/// right, you would arrive at B facing down; if you are at C and move down, you
/// would arrive at D facing up:
///
///           ...#
///           .#..
///           #...
///           ....
///   ...#.......#
///   ........#..A
///   ..#....#....
///   .D........#.
///           ...#..B.
///           .....#..
///           .#......
///           ..C...#.
///
///
/// Walls still block your path, even if they are on a different face of the
/// cube. If you are at E facing up, your movement is blocked by the wall marked
/// by the arrow:
///
///           ...#
///           .#..
///        -->#...
///           ....
///   ...#..E....#
///   ........#...
///   ..#....#....
///   ..........#.
///           ...#....
///           .....#..
///           .#......
///           ......#.
///
///
/// Using the same method of drawing the last facing you had with an arrow on
/// each tile you visit, the full path taken by the above example now looks like
/// this:
///
///           >>v#
///           .#v.
///           #.v.
///           ..v.
///   ...#..^...v#
///   .>>>>>^.#.>>
///   .^#....#....
///   .^........#.
///           ...#..v.
///           .....#v.
///           .#v<<<<.
///           ..v...#.
///
///
/// The final password is still calculated from your final position and facing
/// from the perspective of the map. In this example, the final row is 5, the
/// final column is 7, and the final facing is 3, so the final password is
/// 1000 * 5 + 4 * 7 + 3 = 5031.
///
/// Fold the map into a cube, then follow the path given in the monkeys' notes.
/// What is the final password?
int part2(List<String> input) {
  List<List<Tile>> tiles = parseTiles(input);
  List<Instruction> instructions = parseInstructions(input);
  int x = getStartingX(tiles);
  int y = 0;
  int absoluteDirection = 0;

  for (Instruction instruction in instructions) {
    List<int> newPos =
        nextTileInCube(x, y, absoluteDirection, instruction.distance, tiles);
    x = newPos[0];
    y = newPos[1];
    absoluteDirection = newPos[2];
    absoluteDirection = (absoluteDirection + instruction.direction) % 4;
  }

  return 1000 * (y + 1) + 4 * (x + 1) + absoluteDirection;
}
