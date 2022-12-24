import 'dart:io';

void main() {
  List<String> input = File('2022/dart/23/input.txt').readAsLinesSync();

  int answer1 = part1(input);
  print(answer1);

  int answer2 = part2(input);
  print(answer2);
}

class Elf {
  const Elf(this.x, this.y);

  final int x;
  final int y;

  bool isTouching(Elf other) {
    return (other.x - x).abs() <= 1 && (other.y - y).abs() <= 1;
  }

  bool isTouchingNorth(Elf other) {
    return (other.x - x).abs() <= 1 && other.y == y - 1;
  }

  bool isTouchingSouth(Elf other) {
    return (other.x - x).abs() <= 1 && other.y == y + 1;
  }

  bool isTouchingWest(Elf other) {
    return other.x == x - 1 && (other.y - y).abs() <= 1;
  }

  bool isTouchingEast(Elf other) {
    return other.x == x + 1 && (other.y - y).abs() <= 1;
  }

  Elf copyWith({
    int? x,
    int? y,
  }) {
    return Elf(
      x ?? this.x,
      y ?? this.y,
    );
  }

  Elf proposeMove(Iterable<Elf> otherElves, int startDirection) {
    if (otherElves.every((elf) => !isTouching(elf))) {
      return this;
    }

    List<Elf? Function()> movingFunctions = [
      () {
        if (otherElves.every((elf) => !isTouchingNorth(elf))) {
          return copyWith(y: y - 1);
        }
        return null;
      },
      () {
        if (otherElves.every((elf) => !isTouchingSouth(elf))) {
          return copyWith(y: y + 1);
        }
        return null;
      },
      () {
        if (otherElves.every((elf) => !isTouchingWest(elf))) {
          return copyWith(x: x - 1);
        }
        return null;
      },
      () {
        if (otherElves.every((elf) => !isTouchingEast(elf))) {
          return copyWith(x: x + 1);
        }
        return null;
      },
    ];

    for (int directionOffset = 0; directionOffset < 4; directionOffset++) {
      int direction = (startDirection + directionOffset) % 4;
      Elf? elf = movingFunctions[direction]();
      if (elf != null) {
        return elf;
      }
    }

    return this;
  }

  bool sharesLocation(Elf other) {
    return other.x == x && other.y == y;
  }

  bool isAt(int x, int y) {
    return x == this.x && y == this.y;
  }

  @override
  bool operator ==(Object other) {
    return other is Elf && other.x == x && other.y == y;
  }

  @override
  int get hashCode => x << 31 + y;

  @override
  String toString() {
    return '($x, $y)';
  }
}

List<Elf> parseElves(List<String> input) {
  List<Elf> elves = [];

  for (int y = 0; y < input.length; y++) {
    for (int x = 0; x < input[0].length; x++) {
      if (input[y][x] == '#') {
        elves.add(Elf(x, y));
      }
    }
  }

  return elves;
}

void printElves(List<Elf> elves) {
  List<int> dimensions = calculateDimensions(elves);
  String s = '';

  for (int y = dimensions[1]; y <= dimensions[3]; y++) {
    for (int x = dimensions[0]; x <= dimensions[2]; x++) {
      s += elves.any((elf) => elf.isAt(x, y)) ? '#' : '.';
    }
    s += '\n';
  }

  print(s);
}

List<Elf> moveElves(List<Elf> currentElves, int startDirection) {
  // First round.
  List<Elf> proposedElves = [];
  for (Elf elf in currentElves) {
    Elf proposedElf =
        elf.proposeMove(currentElves.where((e) => e != elf), startDirection);
    proposedElves.add(proposedElf);
  }

  // print('propoElves: $proposedElves');

  // Second round.
  for (int currentElfIndex = 0;
      currentElfIndex < currentElves.length;
      currentElfIndex++) {
    // If there is another elf with the same proposed position,
    if (proposedElves
            .where((elf) => elf.sharesLocation(proposedElves[currentElfIndex]))
            .length >
        1) {
      // Replace all elves with the same proposed position with their original
      // position.
      int pX = proposedElves[currentElfIndex].x;
      int pY = proposedElves[currentElfIndex].y;
      for (int proposedElfIndex = 0;
          proposedElfIndex < proposedElves.length;
          proposedElfIndex++) {
        if (proposedElves[proposedElfIndex].isAt(pX, pY)) {
          proposedElves[proposedElfIndex] = currentElves[proposedElfIndex];
        }
      }
    }
  }

  return proposedElves;
}

/// Calculate [minX, minY, maxX, maxY] dimensions based on [elves].
List<int> calculateDimensions(List<Elf> elves) {
  return [
    elves.map((e) => e.x).reduce((a, b) => a < b ? a : b),
    elves.map((e) => e.y).reduce((a, b) => a < b ? a : b),
    elves.map((e) => e.x).reduce((a, b) => a > b ? a : b),
    elves.map((e) => e.y).reduce((a, b) => a > b ? a : b),
  ];
}

int countEmptyTiles(List<Elf> elves) {
  List<int> dimensions = calculateDimensions(elves);
  int count = 0;

  for (int y = dimensions[1]; y <= dimensions[3]; y++) {
    for (int x = dimensions[0]; x <= dimensions[2]; x++) {
      if (!elves.any((elf) => elf.isAt(x, y))) {
        count++;
      }
    }
  }
  return count;
}

bool areListsEqual<T>(List<T> a, List<T> b) {
  return a.length == b.length && a.every((element) => b.contains(element));
}

/// --- Day 23: Unstable Diffusion ---
///
/// You enter a large crater of gray dirt where the grove is supposed to be. All
/// around you, plants you imagine were expected to be full of fruit are instead
/// withered and broken. A large group of Elves has formed in the middle of the
/// grove.
///
/// "...but this volcano has been dormant for months. Without ash, the fruit
/// can't grow!"
///
/// You look up to see a massive, snow-capped mountain towering above you.
///
/// "It's not like there are other active volcanoes here; we've looked
/// everywhere."
///
/// "But our scanners show active magma flows; clearly it's going somewhere."
///
/// They finally notice you at the edge of the grove, your pack almost
/// overflowing from the random star fruit you've been collecting. Behind you,
/// elephants and monkeys explore the grove, looking concerned. Then, the Elves
/// recognize the ash cloud slowly spreading above your recent detour.
///
/// "Why do you--" "How is--" "Did you just--"
///
/// Before any of them can form a complete question, another Elf speaks up:
/// "Okay, new plan. We have almost enough fruit already, and ash from the plume
/// should spread here eventually. If we quickly plant new seedlings now, we can
/// still make it to the extraction point. Spread out!"
///
/// The Elves each reach into their pack and pull out a tiny plant. The plants
/// rely on important nutrients from the ash, so they can't be planted too close
/// together.
///
/// There isn't enough time to let the Elves figure out where to plant the
/// seedlings themselves; you quickly scan the grove (your puzzle input) and
/// note their positions.
///
/// For example:
///
///   ....#..
///   ..###.#
///   #...#.#
///   .#...##
///   #.###..
///   ##.#.##
///   .#..#..
///
///
/// The scan shows Elves # and empty ground .; outside your scan, more empty
/// ground extends a long way in every direction. The scan is oriented so that
/// north is up; orthogonal directions are written N (north), S (south), W
/// (west), and E (east), while diagonal directions are written NE, NW, SE, SW.
///
/// The Elves follow a time-consuming process to figure out where they should
/// each go; you can speed up this process considerably. The process consists of
/// some number of rounds during which Elves alternate between considering where
/// to move and actually moving.
///
/// During the first half of each round, each Elf considers the eight positions
/// adjacent to themself. If no other Elves are in one of those eight positions,
/// the Elf does not do anything during this round. Otherwise, the Elf looks in
/// each of four directions in the following order and proposes moving one step
/// in the first valid direction:
///
///   If there is no Elf in the N, NE, or NW adjacent positions, the Elf
///     proposes moving north one step.
///   If there is no Elf in the S, SE, or SW adjacent positions, the Elf
///     proposes moving south one step.
///   If there is no Elf in the W, NW, or SW adjacent positions, the Elf
///     proposes moving west one step.
///   If there is no Elf in the E, NE, or SE adjacent positions, the Elf
///     proposes moving east one step.
///
///
/// After each Elf has had a chance to propose a move, the second half of the
/// round can begin. Simultaneously, each Elf moves to their proposed
/// destination tile if they were the only Elf to propose moving to that
/// position. If two or more Elves propose moving to the same position, none of
/// those Elves move.
///
/// Finally, at the end of the round, the first direction the Elves considered
/// is moved to the end of the list of directions. For example, during the
/// second round, the Elves would try proposing a move to the south first, then
/// west, then east, then north. On the third round, the Elves would first
/// consider west, then east, then north, then south.
///
/// As a smaller example, consider just these five Elves:
///
///   .....
///   ..##.
///   ..#..
///   .....
///   ..##.
///   .....
///
///
/// The northernmost two Elves and southernmost two Elves all propose moving
/// north, while the middle Elf cannot move north and proposes moving south. The
/// middle Elf proposes the same destination as the southwest Elf, so neither of
/// them move, but the other three do:
///
///   ..##.
///   .....
///   ..#..
///   ...#.
///   ..#..
///   .....
///
///
/// Next, the northernmost two Elves and the southernmost Elf all propose moving
/// south. Of the remaining middle two Elves, the west one cannot move south and
/// proposes moving west, while the east one cannot move south or west and
/// proposes moving east. All five Elves succeed in moving to their proposed
/// positions:
///
///   .....
///   ..##.
///   .#...
///   ....#
///   .....
///   ..#..
///
///
/// Finally, the southernmost two Elves choose not to move at all. Of the
/// remaining three Elves, the west one proposes moving west, the east one
/// proposes moving east, and the middle one proposes moving north; all three
/// succeed in moving:
///
///   ..#..
///   ....#
///   #....
///   ....#
///   .....
///   ..#..
///
///
/// At this point, no Elves need to move, and so the process ends.
///
/// The larger example above proceeds as follows:
///
///   == Initial State ==
///   ..............
///   ..............
///   .......#......
///   .....###.#....
///   ...#...#.#....
///   ....#...##....
///   ...#.###......
///   ...##.#.##....
///   ....#..#......
///   ..............
///   ..............
///   ..............
///
///   == End of Round 1 ==
///   ..............
///   .......#......
///   .....#...#....
///   ...#..#.#.....
///   .......#..#...
///   ....#.#.##....
///   ..#..#.#......
///   ..#.#.#.##....
///   ..............
///   ....#..#......
///   ..............
///   ..............
///
///   == End of Round 2 ==
///   ..............
///   .......#......
///   ....#.....#...
///   ...#..#.#.....
///   .......#...#..
///   ...#..#.#.....
///   .#...#.#.#....
///   ..............
///   ..#.#.#.##....
///   ....#..#......
///   ..............
///   ..............
///
///   == End of Round 3 ==
///   ..............
///   .......#......
///   .....#....#...
///   ..#..#...#....
///   .......#...#..
///   ...#..#.#.....
///   .#..#.....#...
///   .......##.....
///   ..##.#....#...
///   ...#..........
///   .......#......
///   ..............
///
///   == End of Round 4 ==
///   ..............
///   .......#......
///   ......#....#..
///   ..#...##......
///   ...#.....#.#..
///   .........#....
///   .#...###..#...
///   ..#......#....
///   ....##....#...
///   ....#.........
///   .......#......
///   ..............
///
///   == End of Round 5 ==
///   .......#......
///   ..............
///   ..#..#.....#..
///   .........#....
///   ......##...#..
///   .#.#.####.....
///   ...........#..
///   ....##..#.....
///   ..#...........
///   ..........#...
///   ....#..#......
///   ..............
///
///   After a few more rounds...
///
///   == End of Round 10 ==
///   .......#......
///   ...........#..
///   ..#.#..#......
///   ......#.......
///   ...#.....#..#.
///   .#......##....
///   .....##.......
///   ..#........#..
///   ....#.#..#....
///   ..............
///   ....#..#..#...
///   ..............
///
///
/// To make sure they're on the right track, the Elves like to check after round
/// 10 that they're making good progress toward covering enough ground. To do
/// this, count the number of empty ground tiles contained by the smallest
/// rectangle that contains every Elf. (The edges of the rectangle should be
/// aligned to the N/S/E/W directions; the Elves do not have the patience to
/// calculate arbitrary rectangles.) In the above example, that rectangle is:
///
///   ......#.....
///   ..........#.
///   .#.#..#.....
///   .....#......
///   ..#.....#..#
///   #......##...
///   ....##......
///   .#........#.
///   ...#.#..#...
///   ............
///   ...#..#..#..
///
///
/// In this region, the number of empty ground tiles is 110.
///
/// Simulate the Elves' process and find the smallest rectangle that contains
/// the Elves after 10 rounds. How many empty ground tiles does that rectangle
/// contain?
int part1(List<String> input) {
  List<Elf> elves = parseElves(input);
  int startDirection = 0;

  for (int iteration = 0; iteration < 10; iteration++) {
    elves = moveElves(elves, startDirection++);
  }

  return countEmptyTiles(elves);
}

/// --- Part Two ---
///
/// It seems you're on the right track. Finish simulating the process and figure
/// out where the Elves need to go. How many rounds did you save them?
///
/// In the example above, the first round where no Elf moved was round 20:
///
///   .......#......
///   ....#......#..
///   ..#.....#.....
///   ......#.......
///   ...#....#.#..#
///   #.............
///   ....#.....#...
///   ..#.....#.....
///   ....#.#....#..
///   .........#....
///   ....#......#..
///   .......#......
///
///
/// Figure out where the Elves need to go. What is the number of the first round
/// where no Elf moves?
int part2(List<String> input) {
  List<Elf> elves = parseElves(input);
  int startDirection = 0;

  while (true) {
    List<Elf> newElves = moveElves(elves, startDirection++);
    if (areListsEqual<Elf>(newElves, elves)) {
      return startDirection;
    }
    elves = newElves;
  }
}
