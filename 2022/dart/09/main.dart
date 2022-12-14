import 'dart:io';

void main() {
  final List<String> input = File('2022/dart/09/input.txt').readAsLinesSync();

  final int answer1 = part1(input);
  print(answer1);

  final int answer2 = part2(input);
  print(answer2);
}

/// Direction enum.
///
/// Contains 4 main directions, 4 combined directions and none.
enum Direction {
  none,
  up,
  right,
  down,
  left,
  topRight,
  bottomRight,
  bottomLeft,
  topLeft,
}

/// Transform [char] to [Direction].
///
/// - U: [Direction.up]
/// - R: [Direction.right]
/// - D: [Direction.down]
/// - L: [Direction.left]
Direction dirFromChar(String char) {
  assert(char == 'U' || char == 'R' || char == 'D' || char == 'L');

  switch (char) {
    case 'U':
      return Direction.up;
    case 'R':
      return Direction.right;
    case 'D':
      return Direction.down;
    case 'L':
      return Direction.left;
    default:
      throw Exception('Invalid char: $char');
  }
}

/// Combine x- and y direction into a combined direction.
///
/// For example:
///
///   [Direction.left] + [Direction.up] = [Direction.topLeft]
///   [Direction.right] + [Direction.down] = [Direction.bottomRight]
///   [Direction.none] + [Direction.up] = [Direction.up].
Direction combineDirections(
  Direction xDirection,
  Direction yDirection,
) {
  assert(xDirection == Direction.left ||
      xDirection == Direction.right ||
      xDirection == Direction.none);
  assert(yDirection == Direction.down ||
      yDirection == Direction.up ||
      yDirection == Direction.none);

  if (xDirection == Direction.left) {
    if (yDirection == Direction.down) {
      return Direction.bottomLeft;
    } else if (yDirection == Direction.up) {
      return Direction.topLeft;
    } else {
      return Direction.left;
    }
  } else if (xDirection == Direction.right) {
    if (yDirection == Direction.down) {
      return Direction.bottomRight;
    } else if (yDirection == Direction.up) {
      return Direction.topRight;
    } else {
      return Direction.right;
    }
  } else if (xDirection == Direction.none) {
    return yDirection;
  } else {
    return Direction.none;
  }
}

/// Calculate the direction from [a] to [b].
///
/// For example:
///
/// . . . . .
/// . . . . .
/// . . b . . -> [Direction.up]
/// . . a . .
/// . . . . .
///
/// . . . . .
/// . . . . .
/// . . b . . -> [Direction.topRight]
/// . a . . .
/// . . . . .
Direction getDirectionFromAToB(Knot a, Knot b) {
  final int deltaX = a.x - b.x;
  final int deltaY = a.y - b.y;

  final Direction xDirection = deltaX > 0
      ? Direction.left
      : deltaX < 0
          ? Direction.right
          : Direction.none;
  final Direction yDirection = deltaY > 0
      ? Direction.down
      : deltaY < 0
          ? Direction.up
          : Direction.none;

  return combineDirections(xDirection, yDirection);
}

/// Knot model.
///
/// Keeps track of ([x], [y]) coordinates and provides methods to move it
/// around.
class Knot {
  Knot()
      : x = 0,
        y = 0;

  int x;
  int y;

  /// Move this [Knot] one step along [direction].
  void move(Direction direction) {
    switch (direction) {
      case Direction.up:
        y++;
        break;
      case Direction.right:
        x++;
        break;
      case Direction.down:
        y--;
        break;
      case Direction.left:
        x--;
        break;
      case Direction.topRight:
        x++;
        y++;
        break;
      case Direction.bottomRight:
        x++;
        y--;
        break;
      case Direction.bottomLeft:
        x--;
        y--;
        break;
      case Direction.topLeft:
        x--;
        y++;
        break;
      case Direction.none:
        break;
    }
  }

  /// Check if [this] is touching [other].
  ///
  /// [Knots] are touching if they are next to each other (also diagonally) or
  /// on top of each other.
  ///
  /// For example:
  ///
  /// . . . . .
  /// . . . . .
  /// . . b . . -> [true]
  /// . . a . .
  /// . . . . .
  ///
  /// . . . . .
  /// . . . . .
  /// . . b . . -> [true]
  /// . a . . .
  /// . . . . .
  ///
  /// . . . . .
  /// . . . . .
  /// . . b . . -> [false]
  /// a . . . .
  /// . . . . .
  bool isTouching(Knot other) {
    return (x - other.x).abs() <= 1 && (y - other.y).abs() <= 1;
  }

  /// Move this [Knot] towards [other].
  ///
  /// If the knots are touching, this knot will not move. Otherwise, this knot
  /// will move toward [other] by taking one step in its direction.
  void moveTowards(Knot other) {
    if (!isTouching(other)) {
      final Direction direction = getDirectionFromAToB(this, other);
      move(direction);
    }
  }

  /// Represent this [Knot] as its ([x],[y]) coordinate.
  @override
  String toString() {
    return '($x, $y)';
  }
}

/// --- Day 9: Rope Bridge ---
///
/// This rope bridge creaks as you walk along it. You aren't sure how old it is,
/// or whether it can even support your weight.
///
/// It seems to support the Elves just fine, though. The bridge spans a gorge
/// which was carved out by the massive river far below you.
///
/// You step carefully; as you do, the ropes stretch and twist. You decide to
/// distract yourself by modeling rope physics; maybe you can even figure out
/// where not to step.
///
/// Consider a rope with a knot at each end; these knots mark the head and the
/// tail of the rope. If the head moves far enough away from the tail, the tail
/// is pulled toward the head.
///
/// Due to nebulous reasoning involving Planck lengths, you should be able to
/// model the positions of the knots on a two-dimensional grid. Then, by
/// following a hypothetical series of motions (your puzzle input) for the head,
/// you can determine how the tail will move.
///
/// Due to the aforementioned Planck lengths, the rope must be quite short; in
/// fact, the head (H) and tail (T) must always be touching (diagonally adjacent
/// and even overlapping both count as touching):
///
/// ....
/// .TH.
/// ....
///
/// ....
/// .H..
/// ..T.
/// ....
///
/// ...
/// .H. (H covers T)
/// ...
///
///
/// If the head is ever two steps directly up, down, left, or right from the
/// tail, the tail must also move one step in that direction so it remains close
/// enough:
///
/// .....    .....    .....
/// .TH.. -> .T.H. -> ..TH.
/// .....    .....    .....
///
/// ...    ...    ...
/// .T.    .T.    ...
/// .H. -> ... -> .T.
/// ...    .H.    .H.
/// ...    ...    ...
///
///
/// Otherwise, if the head and tail aren't touching and aren't in the same row
/// or column, the tail always moves one step diagonally to keep up:
///
/// .....    .....    .....
/// .....    ..H..    ..H..
/// ..H.. -> ..... -> ..T..
/// .T...    .T...    .....
/// .....    .....    .....
///
/// .....    .....    .....
/// .....    .....    .....
/// ..H.. -> ...H. -> ..TH.
/// .T...    .T...    .....
/// .....    .....    .....
///
///
/// You just need to work out where the tail goes as the head follows a series
/// of motions. Assume the head and the tail both start at the same position,
/// overlapping.
///
/// For example:
///
/// - R 4
/// - U 4
/// - L 3
/// - D 1
/// - R 4
/// - D 1
/// - L 5
/// - R 2
///
///
/// This series of motions moves the head right four steps, then up four steps,
/// then left three steps, then down one step, and so on. After each step,
/// you'll need to update the position of the tail if the step means the head is
/// no longer adjacent to the tail. Visually, these motions occur as follows (s
/// marks the starting position as a reference point):
///
/// == Initial State ==
///
/// ......
/// ......
/// ......
/// ......
/// H.....  (H covers T, s)
///
/// == R 4 ==
///
/// ......
/// ......
/// ......
/// ......
/// TH....  (T covers s)
///
/// ......
/// ......
/// ......
/// ......
/// sTH...
///
/// ......
/// ......
/// ......
/// ......
/// s.TH..
///
/// ......
/// ......
/// ......
/// ......
/// s..TH.
///
/// == U 4 ==
///
/// ......
/// ......
/// ......
/// ....H.
/// s..T..
///
/// ......
/// ......
/// ....H.
/// ....T.
/// s.....
///
/// ......
/// ....H.
/// ....T.
/// ......
/// s.....
///
/// ....H.
/// ....T.
/// ......
/// ......
/// s.....
///
/// == L 3 ==
///
/// ...H..
/// ....T.
/// ......
/// ......
/// s.....
///
/// ..HT..
/// ......
/// ......
/// ......
/// s.....
///
/// .HT...
/// ......
/// ......
/// ......
/// s.....
///
/// == D 1 ==
///
/// ..T...
/// .H....
/// ......
/// ......
/// s.....
///
/// == R 4 ==
///
/// ..T...
/// ..H...
/// ......
/// ......
/// s.....
///
/// ..T...
/// ...H..
/// ......
/// ......
/// s.....
///
/// ......
/// ...TH.
/// ......
/// ......
/// s.....
///
/// ......
/// ....TH
/// ......
/// ......
/// s.....
///
/// == D 1 ==
///
/// ......
/// ....T.
/// .....H
/// ......
/// s.....
///
/// == L 5 ==
///
/// ......
/// ....T.
/// ....H.
/// ......
/// s.....
///
/// ......
/// ....T.
/// ...H..
/// ......
/// s.....
///
/// ......
/// ......
/// ..HT..
/// ......
/// s.....
///
/// ......
/// ......
/// .HT...
/// ......
/// s.....
///
/// ......
/// ......
/// HT....
/// ......
/// s.....
///
/// == R 2 ==
///
/// ......
/// ......
/// .H....  (H covers T)
/// ......
/// s.....
///
/// ......
/// ......
/// .TH...
/// ......
/// s.....
///
///
/// After simulating the rope, you can count up all of the positions the tail
/// visited at least once. In this diagram, s again marks the starting position
/// (which the tail also visited) and # marks other positions the tail visited:
///
/// ..##..
/// ...##.
/// .####.
/// ....#.
/// s###..
///
///
/// So, there are 13 positions the tail visited at least once.
///
/// Simulate your complete hypothetical series of motions. How many positions
/// does the tail of the rope visit at least once?
int part1(List<String> input) {
  final Knot head = Knot();
  final Knot tail = Knot();

  final Set<String> tailLocations = {tail.toString()};

  input.forEach((line) {
    /// Parse input line.
    final List<String> parts = line.split(' ');
    final Direction direction = dirFromChar(parts[0]);
    final int distance = int.parse(parts[1]);

    /// Move knots.
    for (int iteration = 0; iteration < distance; iteration++) {
      head.move(direction);
      tail.moveTowards(head);

      /// Store tail location.
      tailLocations.add(tail.toString());
    }
  });

  return tailLocations.length;
}

/// --- Part Two ---
///
/// A rope snaps! Suddenly, the river is getting a lot closer than you remember.
/// The bridge is still there, but some of the ropes that broke are now whipping
/// toward you as you fall through the air!
///
/// The ropes are moving too quickly to grab; you only have a few seconds to
/// choose how to arch your body to avoid being hit. Fortunately, your
/// simulation can be extended to support longer ropes.
///
/// Rather than two knots, you now must simulate a rope consisting of ten knots.
/// One knot is still the head of the rope and moves according to the series of
/// motions. Each knot further down the rope follows the knot in front of it
/// using the same rules as before.
///
/// Using the same series of motions as the above example, but with the knots
/// marked H, 1, 2, ..., 9, the motions now occur as follows:
///
/// == Initial State ==
///
/// ......
/// ......
/// ......
/// ......
/// H.....  (H covers 1, 2, 3, 4, 5, 6, 7, 8, 9, s)
///
/// == R 4 ==
///
/// ......
/// ......
/// ......
/// ......
/// 1H....  (1 covers 2, 3, 4, 5, 6, 7, 8, 9, s)
///
/// ......
/// ......
/// ......
/// ......
/// 21H...  (2 covers 3, 4, 5, 6, 7, 8, 9, s)
///
/// ......
/// ......
/// ......
/// ......
/// 321H..  (3 covers 4, 5, 6, 7, 8, 9, s)
///
/// ......
/// ......
/// ......
/// ......
/// 4321H.  (4 covers 5, 6, 7, 8, 9, s)
///
/// == U 4 ==
///
/// ......
/// ......
/// ......
/// ....H.
/// 4321..  (4 covers 5, 6, 7, 8, 9, s)
///
/// ......
/// ......
/// ....H.
/// .4321.
/// 5.....  (5 covers 6, 7, 8, 9, s)
///
/// ......
/// ....H.
/// ....1.
/// .432..
/// 5.....  (5 covers 6, 7, 8, 9, s)
///
/// ....H.
/// ....1.
/// ..432.
/// .5....
/// 6.....  (6 covers 7, 8, 9, s)
///
/// == L 3 ==
///
/// ...H..
/// ....1.
/// ..432.
/// .5....
/// 6.....  (6 covers 7, 8, 9, s)
///
/// ..H1..
/// ...2..
/// ..43..
/// .5....
/// 6.....  (6 covers 7, 8, 9, s)
///
/// .H1...
/// ...2..
/// ..43..
/// .5....
/// 6.....  (6 covers 7, 8, 9, s)
///
/// == D 1 ==
///
/// ..1...
/// .H.2..
/// ..43..
/// .5....
/// 6.....  (6 covers 7, 8, 9, s)
///
/// == R 4 ==
///
/// ..1...
/// ..H2..
/// ..43..
/// .5....
/// 6.....  (6 covers 7, 8, 9, s)
///
/// ..1...
/// ...H..  (H covers 2)
/// ..43..
/// .5....
/// 6.....  (6 covers 7, 8, 9, s)
///
/// ......
/// ...1H.  (1 covers 2)
/// ..43..
/// .5....
/// 6.....  (6 covers 7, 8, 9, s)
///
/// ......
/// ...21H
/// ..43..
/// .5....
/// 6.....  (6 covers 7, 8, 9, s)
///
/// == D 1 ==
///
/// ......
/// ...21.
/// ..43.H
/// .5....
/// 6.....  (6 covers 7, 8, 9, s)
///
/// == L 5 ==
///
/// ......
/// ...21.
/// ..43H.
/// .5....
/// 6.....  (6 covers 7, 8, 9, s)
///
/// ......
/// ...21.
/// ..4H..  (H covers 3)
/// .5....
/// 6.....  (6 covers 7, 8, 9, s)
///
/// ......
/// ...2..
/// ..H1..  (H covers 4; 1 covers 3)
/// .5....
/// 6.....  (6 covers 7, 8, 9, s)
///
/// ......
/// ...2..
/// .H13..  (1 covers 4)
/// .5....
/// 6.....  (6 covers 7, 8, 9, s)
///
/// ......
/// ......
/// H123..  (2 covers 4)
/// .5....
/// 6.....  (6 covers 7, 8, 9, s)
///
/// == R 2 ==
///
/// ......
/// ......
/// .H23..  (H covers 1; 2 covers 4)
/// .5....
/// 6.....  (6 covers 7, 8, 9, s)
///
/// ......
/// ......
/// .1H3..  (H covers 2, 4)
/// .5....
/// 6.....  (6 covers 7, 8, 9, s)
///
///
/// Now, you need to keep track of the positions the new tail, 9, visits. In
/// this example, the tail never moves, and so it only visits 1 position.
/// However, be careful: more types of motion are possible than before, so you
/// might want to visually compare your simulated rope to the one above.
///
/// Here's a larger example:
///
/// - R 5
/// - U 8
/// - L 8
/// - D 3
/// - R 17
/// - D 10
/// - L 25
/// - U 20
///
///
/// These motions occur as follows (individual steps are not shown):
///
/// == Initial State ==
///
/// ..........................
/// ..........................
/// ..........................
/// ..........................
/// ..........................
/// ..........................
/// ..........................
/// ..........................
/// ..........................
/// ..........................
/// ..........................
/// ..........................
/// ..........................
/// ..........................
/// ..........................
/// ...........H..............  (H covers 1, 2, 3, 4, 5, 6, 7, 8, 9, s)
/// ..........................
/// ..........................
/// ..........................
/// ..........................
/// ..........................
///
/// == R 5 ==
///
/// ..........................
/// ..........................
/// ..........................
/// ..........................
/// ..........................
/// ..........................
/// ..........................
/// ..........................
/// ..........................
/// ..........................
/// ..........................
/// ..........................
/// ..........................
/// ..........................
/// ..........................
/// ...........54321H.........  (5 covers 6, 7, 8, 9, s)
/// ..........................
/// ..........................
/// ..........................
/// ..........................
/// ..........................
///
/// == U 8 ==
///
/// ..........................
/// ..........................
/// ..........................
/// ..........................
/// ..........................
/// ..........................
/// ..........................
/// ................H.........
/// ................1.........
/// ................2.........
/// ................3.........
/// ...............54.........
/// ..............6...........
/// .............7............
/// ............8.............
/// ...........9..............  (9 covers s)
/// ..........................
/// ..........................
/// ..........................
/// ..........................
/// ..........................
///
/// == L 8 ==
///
/// ..........................
/// ..........................
/// ..........................
/// ..........................
/// ..........................
/// ..........................
/// ..........................
/// ........H1234.............
/// ............5.............
/// ............6.............
/// ............7.............
/// ............8.............
/// ............9.............
/// ..........................
/// ..........................
/// ...........s..............
/// ..........................
/// ..........................
/// ..........................
/// ..........................
/// ..........................
///
/// == D 3 ==
///
/// ..........................
/// ..........................
/// ..........................
/// ..........................
/// ..........................
/// ..........................
/// ..........................
/// ..........................
/// .........2345.............
/// ........1...6.............
/// ........H...7.............
/// ............8.............
/// ............9.............
/// ..........................
/// ..........................
/// ...........s..............
/// ..........................
/// ..........................
/// ..........................
/// ..........................
/// ..........................
///
/// == R 17 ==
///
/// ..........................
/// ..........................
/// ..........................
/// ..........................
/// ..........................
/// ..........................
/// ..........................
/// ..........................
/// ..........................
/// ..........................
/// ................987654321H
/// ..........................
/// ..........................
/// ..........................
/// ..........................
/// ...........s..............
/// ..........................
/// ..........................
/// ..........................
/// ..........................
/// ..........................
///
/// == D 10 ==
///
/// ..........................
/// ..........................
/// ..........................
/// ..........................
/// ..........................
/// ..........................
/// ..........................
/// ..........................
/// ..........................
/// ..........................
/// ..........................
/// ..........................
/// ..........................
/// ..........................
/// ..........................
/// ...........s.........98765
/// .........................4
/// .........................3
/// .........................2
/// .........................1
/// .........................H
///
/// == L 25 ==
///
/// ..........................
/// ..........................
/// ..........................
/// ..........................
/// ..........................
/// ..........................
/// ..........................
/// ..........................
/// ..........................
/// ..........................
/// ..........................
/// ..........................
/// ..........................
/// ..........................
/// ..........................
/// ...........s..............
/// ..........................
/// ..........................
/// ..........................
/// ..........................
/// H123456789................
///
/// == U 20 ==
///
/// H.........................
/// 1.........................
/// 2.........................
/// 3.........................
/// 4.........................
/// 5.........................
/// 6.........................
/// 7.........................
/// 8.........................
/// 9.........................
/// ..........................
/// ..........................
/// ..........................
/// ..........................
/// ..........................
/// ...........s..............
/// ..........................
/// ..........................
/// ..........................
/// ..........................
/// ..........................
///
///
/// Now, the tail (9) visits 36 positions (including s) at least once:
///
/// ..........................
/// ..........................
/// ..........................
/// ..........................
/// ..........................
/// ..........................
/// ..........................
/// ..........................
/// ..........................
/// #.........................
/// #.............###.........
/// #............#...#........
/// .#..........#.....#.......
/// ..#..........#.....#......
/// ...#........#.......#.....
/// ....#......s.........#....
/// .....#..............#.....
/// ......#............#......
/// .......#..........#.......
/// ........#........#........
/// .........########.........
///
///
/// Simulate your complete series of motions on a larger rope with ten knots.
/// How many positions does the tail of the rope visit at least once?
int part2(List<String> input) {
  final int ropeLength = 10;
  final List<Knot> knots = List.generate(ropeLength, (index) => Knot());
  final Set<String> tailLocations = {knots.last.toString()};

  input.forEach((line) {
    final List<String> parts = line.split(' ');
    final Direction direction = dirFromChar(parts[0]);
    final int distance = int.parse(parts[1]);

    for (int iteration = 0; iteration < distance; iteration++) {
      /// Move head.
      knots.first.move(direction);

      /// Propagate movement of head to other knots.
      for (int knotIndex = 1; knotIndex < knots.length; knotIndex++) {
        knots[knotIndex].moveTowards(knots[knotIndex - 1]);
      }

      /// Store tail location.
      tailLocations.add(knots.last.toString());
    }
  });

  return tailLocations.length;
}
