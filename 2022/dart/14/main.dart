import 'dart:io';
import 'dart:math';

void main() {
  List<String> input = File('2022/dart/14/input.txt').readAsLinesSync();

  int answer1 = part1(input);
  print(answer1);

  int answer2 = part2(input);
  print(answer2);
}

class Point {
  const Point(this.x, this.y);
  final int x;
  final int y;

  @override
  String toString() {
    return '$x $y';
  }

  @override
  bool operator ==(Object other) {
    return other is Point && other.x == x && other.y == y;
  }

  @override
  int get hashCode => x << 32 + y;

  static List<Point> getPointsOnLine(Point pointA, Point pointB) {
    List<Point> points = [];
    int dx = (pointB.x - pointA.x).abs();
    int dy = (pointB.y - pointA.y).abs();
    int sx = min(pointA.x, pointB.x);
    int sy = min(pointA.y, pointB.y);

    for (int x = 0; x <= dx; x++) {
      for (int y = 0; y <= dy; y++) {
        points.add(Point(sx + x, sy + y));
      }
    }

    return points;
  }

  Point up() => Point(x, y - 1);
  Point right() => Point(x + 1, y);
  Point down() => Point(x, y + 1);
  Point left() => Point(x - 1, y);
}

abstract class Cave {
  const Cave({
    required this.dimensions,
    required this.filledSpots,
  });

  final List<int> dimensions;
  final List<List<bool>> filledSpots;

  bool trickle(Point sand);

  @override
  String toString() {
    return filledSpots
        .rotate()
        .map((row) => row.map((column) => column ? '#' : '.').join(' '))
        .join('\n');
  }
}

/// Cave without a floor.
///
/// Used by part 1.
class BottomlessCave extends Cave {
  const BottomlessCave({
    required super.dimensions,
    required super.filledSpots,
  });

  factory BottomlessCave.fromInput(List<String> input) {
    List<List<Point>> pointGroups = input
        .map(
          (line) => line
              .split(' -> ')
              .map(
                (coordinateString) => coordinateString
                    .split(',')
                    .map((e) => int.parse(e))
                    .toList(),
              )
              .map((coordinate) => Point(coordinate[0], coordinate[1]))
              .toList(),
        )
        .toList();

    List<List<Point>> pointPairs = [];
    for (int groupIndex = 0; groupIndex < pointGroups.length; groupIndex++) {
      for (int pairIndex = 0;
          pairIndex < pointGroups[groupIndex].length - 1;
          pairIndex++) {
        pointPairs.add([
          pointGroups[groupIndex][pairIndex],
          pointGroups[groupIndex][pairIndex + 1],
        ]);
      }
    }

    List<Point> points = pointPairs
        .map((pointPair) => Point.getPointsOnLine(pointPair[0], pointPair[1]))
        .fold([], (allPoints, pointsOnLine) => allPoints + pointsOnLine);

    Iterable<int> xs = points.map((e) => e.x);
    Iterable<int> ys = points.map((e) => e.y);

    int minX = xs.reduce((a, b) => a < b ? a : b);
    int maxX = xs.reduce((a, b) => a > b ? a : b);
    int minY = 0;
    int maxY = ys.reduce((a, b) => a > b ? a : b);

    List<List<bool>> filledSpots = List.generate(
      maxX - minX + 1,
      (x) => List.generate(
        maxY - minY + 1,
        (y) => false,
        growable: false,
      ),
      growable: false,
    );

    // Add rocks.
    points
        .forEach((point) => filledSpots[point.x - minX][point.y - minY] = true);

    return BottomlessCave(
      dimensions: [minX, minY, maxX, maxY],
      filledSpots: filledSpots,
    );
  }

  @override
  bool trickle(Point sand) {
    int xIndex = sand.x - dimensions[0];

    // End of the cave.
    if (sand.y == dimensions[3]) {
      return false;
    }

    // Fall down.
    if (!filledSpots[xIndex][sand.y + 1]) {
      return trickle(sand.down());
    }

    // Fall into the abyss on the left.
    if (sand.x == dimensions[0]) {
      return false;
    }

    // Fall left.
    if (!filledSpots[xIndex - 1][sand.y + 1]) {
      return trickle(sand.down().left());
    }

    // Fall into the abyss on the right.
    if (sand.x == dimensions[2]) {
      return false;
    }

    // Fall right.
    if (!filledSpots[xIndex + 1][sand.y + 1]) {
      return trickle(sand.down().right());
    }

    // Register sand at current location.
    if (sand.y < dimensions[3]) {
      filledSpots[xIndex][sand.y] = true;
      return true;
    }

    return false;
  }
}

/// Cave with a floor.
///
/// Used for part 2.
class FlooredCave extends Cave {
  const FlooredCave({
    required super.dimensions,
    required super.filledSpots,
  });

  factory FlooredCave.fromInput(List<String> input) {
    List<List<Point>> pointGroups = input
        .map(
          (line) => line
              .split(' -> ')
              .map(
                (coordinateString) => coordinateString
                    .split(',')
                    .map((e) => int.parse(e))
                    .toList(),
              )
              .map((coordinate) => Point(coordinate[0], coordinate[1]))
              .toList(),
        )
        .toList();

    List<List<Point>> pointPairs = [];
    for (int groupIndex = 0; groupIndex < pointGroups.length; groupIndex++) {
      for (int pairIndex = 0;
          pairIndex < pointGroups[groupIndex].length - 1;
          pairIndex++) {
        pointPairs.add([
          pointGroups[groupIndex][pairIndex],
          pointGroups[groupIndex][pairIndex + 1],
        ]);
      }
    }

    List<Point> points = pointPairs
        .map((pointPair) => Point.getPointsOnLine(pointPair[0], pointPair[1]))
        .fold([], (allPoints, pointsOnLine) => allPoints + pointsOnLine);

    Iterable<int> xs = points.map((e) => e.x);
    Iterable<int> ys = points.map((e) => e.y);

    // Add a floor two rows below the cave described by [input]. To make sure
    // sand will never fall into the abyss, extend x axis by [maxY] to both
    // sides.
    int minY = 0;
    int maxY = ys.reduce((a, b) => a > b ? a : b) + 2;
    int minX = xs.reduce((a, b) => a < b ? a : b) - maxY;
    int maxX = xs.reduce((a, b) => a > b ? a : b) + maxY;

    points = [
      ...points,
      ...Point.getPointsOnLine(Point(minX, maxY), Point(maxX, maxY))
    ];

    List<List<bool>> filledSpots = List.generate(
      maxX - minX + 1,
      (x) => List.generate(
        maxY - minY + 1,
        (y) => false,
        growable: false,
      ),
      growable: false,
    );

    // Add rocks.
    points
        .forEach((point) => filledSpots[point.x - minX][point.y - minY] = true);

    return FlooredCave(
      dimensions: [minX, minY, maxX, maxY],
      filledSpots: filledSpots,
    );
  }

  @override
  bool trickle(Point sand) {
    int xIndex = sand.x - dimensions[0];

    // Fall down.
    if (!filledSpots[xIndex][sand.y + 1]) {
      return trickle(sand.down());
    }

    // Fall left.
    if (!filledSpots[xIndex - 1][sand.y + 1]) {
      return trickle(sand.down().left());
    }

    // Fall right.
    if (!filledSpots[xIndex + 1][sand.y + 1]) {
      return trickle(sand.down().right());
    }

    // Sand hasn't fallen since its inception.
    if (sand.y == 0) {
      return false;
    }

    // Register sand at current location.
    if (sand.y < dimensions[3]) {
      filledSpots[xIndex][sand.y] = true;
      return true;
    }

    return false;
  }
}

extension ListOfListsExtensions<T> on List<List<T>> {
  /// Rotate a [List] of [List]s by flipping (x,y) coordinatess to (y,x)
  /// coordinates.
  List<List<T>> rotate() {
    return List.generate(
      this[0].length,
      (x) => List.generate(
        this.length,
        (y) => this[y][x],
        growable: false,
      ),
      growable: false,
    );
  }
}

/// --- Day 14: Regolith Reservoir ---
///
/// The distress signal leads you to a giant waterfall! Actually, hang on - the
/// signal seems like it's coming from the waterfall itself, and that doesn't
/// make any sense. However, you do notice a little path that leads behind the
/// waterfall.
///
/// Correction: the distress signal leads you behind a giant waterfall! There
/// seems to be a large cave system here, and the signal definitely leads
/// further inside.
///
/// As you begin to make your way deeper underground, you feel the ground rumble
/// for a moment. Sand begins pouring into the cave! If you don't quickly figure
/// out where the sand is going, you could quickly become trapped!
///
/// Fortunately, your familiarity with analyzing the path of falling material
/// will come in handy here. You scan a two-dimensional vertical slice of the
/// cave above you (your puzzle input) and discover that it is mostly air with
/// structures made of rock.
///
/// Your scan traces the path of each solid rock structure and reports the x,y
/// coordinates that form the shape of the path, where x represents distance to
/// the right and y represents distance down. Each path appears as a single line
/// of text in your scan. After the first point of each path, each point
/// indicates the end of a straight horizontal or vertical line to be drawn from
/// the previous point. For example:
///
///   498,4 -> 498,6 -> 496,6
///   503,4 -> 502,4 -> 502,9 -> 494,9
///
///
/// This scan means that there are two paths of rock; the first path consists of
/// two straight lines, and the second path consists of three straight lines.
/// (Specifically, the first path consists of a line of rock from 498,4 through
/// 498,6 and another line of rock from 498,6 through 496,6.)
///
/// The sand is pouring into the cave from point 500,0.
///
/// Drawing rock as #, air as ., and the source of the sand as +, this becomes:
///
///     4     5  5
///     9     0  0
///     4     0  3
///   0 ......+...
///   1 ..........
///   2 ..........
///   3 ..........
///   4 ....#...##
///   5 ....#...#.
///   6 ..###...#.
///   7 ........#.
///   8 ........#.
///   9 #########.
///
///
/// Sand is produced one unit at a time, and the next unit of sand is not
/// produced until the previous unit of sand comes to rest. A unit of sand is
/// large enough to fill one tile of air in your scan.
///
/// A unit of sand always falls down one step if possible. If the tile
/// immediately below is blocked (by rock or sand), the unit of sand attempts to
/// instead move diagonally one step down and to the left. If that tile is
/// blocked, the unit of sand attempts to instead move diagonally one step down
/// and to the right. Sand keeps moving as long as it is able to do so, at each
/// step trying to move down, then down-left, then down-right. If all three
/// possible destinations are blocked, the unit of sand comes to rest and no
/// longer moves, at which point the next unit of sand is created back at the
/// source.
///
/// So, drawing sand that has come to rest as o, the first unit of sand simply
/// falls straight down and then stops:
///
///   ......+...
///   ..........
///   ..........
///   ..........
///   ....#...##
///   ....#...#.
///   ..###...#.
///   ........#.
///   ......o.#.
///   #########.
///
///
/// The second unit of sand then falls straight down, lands on the first one,
/// and then comes to rest to its left:
///
///   ......+...
///   ..........
///   ..........
///   ..........
///   ....#...##
///   ....#...#.
///   ..###...#.
///   ........#.
///   .....oo.#.
///   #########.
///
///
/// After a total of five units of sand have come to rest, they form this
/// pattern:
///
///   ......+...
///   ..........
///   ..........
///   ..........
///   ....#...##
///   ....#...#.
///   ..###...#.
///   ......o.#.
///   ....oooo#.
///   #########.
///
///
/// After a total of 22 units of sand:
///
///   ......+...
///   ..........
///   ......o...
///   .....ooo..
///   ....#ooo##
///   ....#ooo#.
///   ..###ooo#.
///   ....oooo#.
///   ...ooooo#.
///   #########.
///
///
/// Finally, only two more units of sand can possibly come to rest:
///
///   ......+...
///   ..........
///   ......o...
///   .....ooo..
///   ....#ooo##
///   ...o#ooo#.
///   ..###ooo#.
///   ....oooo#.
///   .o.ooooo#.
///   #########.
///
///
/// Once all 24 units of sand shown above have come to rest, all further sand
/// flows out the bottom, falling into the endless void. Just for fun, the path
/// any new sand takes before falling forever is shown here with ~:
///
///   .......+...
///   .......~...
///   ......~o...
///   .....~ooo..
///   ....~#ooo##
///   ...~o#ooo#.
///   ..~###ooo#.
///   ..~..oooo#.
///   .~o.ooooo#.
///   ~#########.
///   ~..........
///   ~..........
///   ~..........
///
///
/// Using your scan, simulate the falling sand. How many units of sand come to
/// rest before sand starts flowing into the abyss below?
int part1(List<String> input) {
  BottomlessCave cave = BottomlessCave.fromInput(input);

  int sandCounter = 0;
  while (cave.trickle(Point(500, 0))) {
    sandCounter++;
  }
  return sandCounter;
}

/// --- Part Two ---
///
/// You realize you misread the scan. There isn't an endless void at the bottom
/// of the scan - there's floor, and you're standing on it!
///
/// You don't have time to scan the floor, so assume the floor is an infinite
/// horizontal line with a y coordinate equal to two plus the highest y
/// coordinate of any point in your scan.
///
/// In the example above, the highest y coordinate of any point is 9, and so the
/// floor is at y=11. (This is as if your scan contained one extra rock path
/// like -infinity,11 -> infinity,11.) With the added floor, the example above
/// now looks like this:
///
///           ...........+........
///           ....................
///           ....................
///           ....................
///           .........#...##.....
///           .........#...#......
///           .......###...#......
///           .............#......
///           .............#......
///           .....#########......
///           ....................
///   <-- etc #################### etc -->
///
///
/// To find somewhere safe to stand, you'll need to simulate falling sand until
/// a unit of sand comes to rest at 500,0, blocking the source entirely and
/// stopping the flow of sand into the cave. In the example above, the situation
/// finally looks like this after 93 units of sand come to rest:
///
///   ............o............
///   ...........ooo...........
///   ..........ooooo..........
///   .........ooooooo.........
///   ........oo#ooo##o........
///   .......ooo#ooo#ooo.......
///   ......oo###ooo#oooo......
///   .....oooo.oooo#ooooo.....
///   ....oooooooooo#oooooo....
///   ...ooo#########ooooooo...
///   ..ooooo.......ooooooooo..
///   #########################
///
///
/// Using your scan, simulate the falling sand until the source of the sand
/// becomes blocked. How many units of sand come to rest?
int part2(List<String> input) {
  FlooredCave cave = FlooredCave.fromInput(input);

  int sandCounter = 0;
  while (cave.trickle(Point(500, 0))) {
    sandCounter++;
  }
  return sandCounter + 1;
}
