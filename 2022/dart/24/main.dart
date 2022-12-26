import 'dart:io';

void main() {
  int answer1 = part1(input);
  print(answer1);

  int answer2 = part2(input);
  print(answer2);
}

class Blizzard {
  const Blizzard(this.x, this.y, this.direction);

  final int x;
  final int y;
  final int direction;

  bool isAt(int x, int y) {
    return x == this.x && y == this.y;
  }

  Blizzard move() {
    int dx = direction == 1
        ? 1
        : direction == 3
            ? -1
            : 0;
    int dy = direction == 0
        ? -1
        : direction == 2
            ? 1
            : 0;
    return Blizzard((x + dx) % maxX, (y + dy) % maxY, direction);
  }
}

/// Updates the entries of the global variable [forwardCosts].
void updateForwardCosts(int minutes, int x, int y) {
  // Terminate if we can no longer reach the destination quick enough.
  //
  // We need at least one minute per distance we need to travel.
  int distance = (maxX - 1 - x) + (maxY - 1 - y);
  if (minutes + distance >= bestScore) {
    return;
  }

  // Terminate if we are already past the minute mark at which we have achieved
  // the target in a previous iteration.
  if (x == maxX - 1 && y == maxY - 1) {
    bestScore = minutes;
  }

  // Calculate the relative minute. The relative minute is the current minute
  // modulo the lcm of the blizzard grid dimensions. We are interested in the
  // relative minutes as the blizzard configuration wraps every lcm iterations.
  int relativeMinutes = minutes % lcm;

  // Terminate if we have been at this exact location before during this
  // relative minute. Otherwise, store the current minute mark for this location
  // at this relative minute.
  if (minutes >= forwardCosts[relativeMinutes][x][y]) {
    return;
  } else {
    forwardCosts[relativeMinutes][x][y] = minutes;
  }

  // Right.
  if (x < maxX - 1 && !blizzardConfigurations[relativeMinutes][x + 1][y]) {
    updateForwardCosts(minutes + 1, x + 1, y);
  }

  // Down.
  if (y < maxY - 1 && !blizzardConfigurations[relativeMinutes][x][y + 1]) {
    updateForwardCosts(minutes + 1, x, y + 1);
  }

  // Wait.
  if (!blizzardConfigurations[relativeMinutes][x][y]) {
    updateForwardCosts(minutes + 1, x, y);
  }

  // Left.
  if (x > 0 && !blizzardConfigurations[relativeMinutes][x - 1][y]) {
    updateForwardCosts(minutes + 1, x - 1, y);
  }

  // Up.
  if (y > 0 && !blizzardConfigurations[relativeMinutes][x][y - 1]) {
    updateForwardCosts(minutes + 1, x, y - 1);
  }
}

/// Updates the entries of the global variable [backwardCosts].
void updateBackwardCosts(int minutes, int x, int y) {
  // Terminate if we can no longer reach the destination quick enough.
  //
  // We need at least one minute per distance we need to travel.
  int distance = x + y;
  if (minutes + distance >= bestScore) {
    // print('minutes + distance >= bestScore, $minutes $distance $bestScore');
    return;
  }

  // Terminate if we are already past the minute mark at which we have achieved
  // the target in a previous iteration.
  if (x == 0 && y == 0) {
    bestScore = minutes;
  }

  // Calculate the relative minute. The relative minute is the current minute
  // modulo the lcm of the blizzard grid dimensions. We are interested in the
  // relative minutes as the blizzard configuration wraps every lcm iterations.
  int relativeMinutes = minutes % lcm;

  // Terminate if we have been at this exact location before during this
  // relative minute. Otherwise, store the current minute mark for this location
  // at this relative minute.
  if (minutes >= backwardCosts[relativeMinutes][x][y]) {
    return;
  } else {
    backwardCosts[relativeMinutes][x][y] = minutes;
  }

  // Left.
  if (x > 0 && !blizzardConfigurations[relativeMinutes][x - 1][y]) {
    updateBackwardCosts(minutes + 1, x - 1, y);
  }

  // Up.
  if (y > 0 && !blizzardConfigurations[relativeMinutes][x][y - 1]) {
    updateBackwardCosts(minutes + 1, x, y - 1);
  }

  // Wait.
  if (!blizzardConfigurations[relativeMinutes][x][y]) {
    updateBackwardCosts(minutes + 1, x, y);
  }

  // Right.
  if (x < maxX - 1 && !blizzardConfigurations[relativeMinutes][x + 1][y]) {
    updateBackwardCosts(minutes + 1, x + 1, y);
  }

  // Down.
  if (y < maxY - 1 && !blizzardConfigurations[relativeMinutes][x][y + 1]) {
    updateBackwardCosts(minutes + 1, x, y + 1);
  }
}

/// Parses the puzzle [input] to a [List] of [Blizzards].
List<Blizzard> parseBlizzards(List<String> input) {
  List<Blizzard> blizzards = [];

  for (int y = 0; y < input.length - 2; y++) {
    for (int x = 0; x < input[0].length - 2; x++) {
      String c = input[y + 1][x + 1];
      if (c == '^') {
        blizzards.add(Blizzard(x, y, 0));
      } else if (c == '>') {
        blizzards.add(Blizzard(x, y, 1));
      } else if (c == 'v') {
        blizzards.add(Blizzard(x, y, 2));
      } else if (c == '<') {
        blizzards.add(Blizzard(x, y, 3));
      }
    }
  }

  return blizzards;
}

/// Global variables accessed by the different methods in this file.

// Read the puzzle input.
List<String> input = File('2022/dart/24/input.txt').readAsLinesSync();

// Set value for a cost that we consider to be strictly higher than calculated
// costs. We do not set it to ~(1 << 63) to prevent integer overflows when
// performing additions.
int infiniteCost = 1 << 62;

// Initialize a grid of bools indicating empty spots for every blizzard
// configuration.
List<List<List<bool>>> blizzardConfigurations = () {
  blizzardConfigurations = List.generate(
    lcm,
    (relativeMinute) => List.generate(
      maxX,
      (x) => List.generate(
        maxY,
        (y) => false,
        growable: false,
      ),
      growable: false,
    ),
    growable: false,
  );

  Iterable<Blizzard> blizzards = parseBlizzards(input);
  for (int relativeMinute = 0; relativeMinute < lcm; relativeMinute++) {
    for (Blizzard blizzard in blizzards) {
      blizzardConfigurations[relativeMinute][blizzard.x][blizzard.y] = true;
    }
    blizzards = blizzards.map((blizzard) => blizzard.move());
  }

  return blizzardConfigurations;
}();

// Initialize the cost of reaching [x], [y] in blizzard configuration [z] to
// [infiniteCost].
List<List<List<int>>> forwardCosts = List.generate(
  lcm,
  (a) => List.generate(
    maxX,
    (b) => List.generate(
      maxY,
      (c) => infiniteCost,
      growable: false,
    ),
    growable: false,
  ),
  growable: false,
);

// Initialize the cost of reaching [x], [y] in blizzard configuration [z] to
// [infiniteCost].
List<List<List<int>>> backwardCosts = List.generate(
  lcm,
  (a) => List.generate(
    maxX,
    (b) => List.generate(
      maxY,
      (c) => infiniteCost,
      growable: false,
    ),
    growable: false,
  ),
  growable: false,
);

int maxX = input[0].length - 2;
int maxY = input.length - 2;

// Blizzard configurations will repeat every lcm(maxX, maxY) iterations.
int lcm = maxX * maxY ~/ maxX.gcd(maxY);

int bestScore = infiniteCost;

/// --- Day 24: Blizzard Basin ---
///
/// With everything replanted for next year (and with elephants and monkeys to
/// tend the grove), you and the Elves leave for the extraction point.
///
/// Partway up the mountain that shields the grove is a flat, open area that
/// serves as the extraction point. It's a bit of a climb, but nothing the
/// expedition can't handle.
///
/// At least, that would normally be true; now that the mountain is covered in
/// snow, things have become more difficult than the Elves are used to.
///
/// As the expedition reaches a valley that must be traversed to reach the
/// extraction site, you find that strong, turbulent winds are pushing small
/// blizzards of snow and sharp ice around the valley. It's a good thing
/// everyone packed warm clothes! To make it across safely, you'll need to find
/// a way to avoid them.
///
/// Fortunately, it's easy to see all of this from the entrance to the valley,
/// so you make a map of the valley and the blizzards (your puzzle input). For
/// example:
///
///   #.#####
///   #.....#
///   #>....#
///   #.....#
///   #...v.#
///   #.....#
///   #####.#
///
///
/// The walls of the valley are drawn as #; everything else is ground. Clear
/// ground - where there is currently no blizzard - is drawn as .. Otherwise,
/// blizzards are drawn with an arrow indicating their direction of motion: up
/// (^), down (v), left (<), or right (>).
///
/// The above map includes two blizzards, one moving right (>) and one moving
/// down (v). In one minute, each blizzard moves one position in the direction
///it is pointing:
///
///   #.#####
///   #.....#
///   #.>...#
///   #.....#
///   #.....#
///   #...v.#
///   #####.#
///
///
/// Due to conservation of blizzard energy, as a blizzard reaches the wall of
/// the valley, a new blizzard forms on the opposite side of the valley moving
/// in the same direction. After another minute, the bottom downward-moving
/// blizzard has been replaced with a new downward-moving blizzard at the top of
/// the valley instead:
///
///   #.#####
///   #...v.#
///   #..>..#
///   #.....#
///   #.....#
///   #.....#
///   #####.#
///
///
/// Because blizzards are made of tiny snowflakes, they pass right through each
/// other. After another minute, both blizzards temporarily occupy the same
/// position, marked 2:
///
///   #.#####
///   #.....#
///   #...2.#
///   #.....#
///   #.....#
///   #.....#
///   #####.#
///
///
/// After another minute, the situation resolves itself, giving each blizzard
/// back its personal space:
///
///   #.#####
///   #.....#
///   #....>#
///   #...v.#
///   #.....#
///   #.....#
///   #####.#
///
///
/// Finally, after yet another minute, the rightward-facing blizzard on the
/// right is replaced with a new one on the left facing the same direction:
///
///   #.#####
///   #.....#
///   #>....#
///   #.....#
///   #...v.#
///   #.....#
///   #####.#
///
///
/// This process repeats at least as long as you are observing it, but probably
/// forever.
///
/// Here is a more complex example:
///
///   #.######
///   #>>.<^<#
///   #.<..<<#
///   #>v.><>#
///   #<^v^^>#
///   ######.#
///
///
/// Your expedition begins in the only non-wall position in the top row and
/// needs to reach the only non-wall position in the bottom row. On each minute,
/// you can move up, down, left, or right, or you can wait in place. You and the
/// blizzards act simultaneously, and you cannot share a position with a
/// blizzard.
///
/// In the above example, the fastest way to reach your goal requires 18 steps.
/// Drawing the position of the expedition as E, one way to achieve this is:
///
///   Initial state:
///   #E######
///   #>>.<^<#
///   #.<..<<#
///   #>v.><>#
///   #<^v^^>#
///   ######.#
///
///   Minute 1, move down:
///   #.######
///   #E>3.<.#
///   #<..<<.#
///   #>2.22.#
///   #>v..^<#
///   ######.#
///
///   Minute 2, move down:
///   #.######
///   #.2>2..#
///   #E^22^<#
///   #.>2.^>#
///   #.>..<.#
///   ######.#
///
///   Minute 3, wait:
///   #.######
///   #<^<22.#
///   #E2<.2.#
///   #><2>..#
///   #..><..#
///   ######.#
///
///   Minute 4, move up:
///   #.######
///   #E<..22#
///   #<<.<..#
///   #<2.>>.#
///   #.^22^.#
///   ######.#
///
///   Minute 5, move right:
///   #.######
///   #2Ev.<>#
///   #<.<..<#
///   #.^>^22#
///   #.2..2.#
///   ######.#
///
///   Minute 6, move right:
///   #.######
///   #>2E<.<#
///   #.2v^2<#
///   #>..>2>#
///   #<....>#
///   ######.#
///
///   Minute 7, move down:
///   #.######
///   #.22^2.#
///   #<vE<2.#
///   #>>v<>.#
///   #>....<#
///   ######.#
///
///   Minute 8, move left:
///   #.######
///   #.<>2^.#
///   #.E<<.<#
///   #.22..>#
///   #.2v^2.#
///   ######.#
///
///   Minute 9, move up:
///   #.######
///   #<E2>>.#
///   #.<<.<.#
///   #>2>2^.#
///   #.v><^.#
///   ######.#
///
///   Minute 10, move right:
///   #.######
///   #.2E.>2#
///   #<2v2^.#
///   #<>.>2.#
///   #..<>..#
///   ######.#
///
///   Minute 11, wait:
///   #.######
///   #2^E^2>#
///   #<v<.^<#
///   #..2.>2#
///   #.<..>.#
///   ######.#
///
///   Minute 12, move down:
///   #.######
///   #>>.<^<#
///   #.<E.<<#
///   #>v.><>#
///   #<^v^^>#
///   ######.#
///
///   Minute 13, move down:
///   #.######
///   #.>3.<.#
///   #<..<<.#
///   #>2E22.#
///   #>v..^<#
///   ######.#
///
///   Minute 14, move right:
///   #.######
///   #.2>2..#
///   #.^22^<#
///   #.>2E^>#
///   #.>..<.#
///   ######.#
///
///   Minute 15, move right:
///   #.######
///   #<^<22.#
///   #.2<.2.#
///   #><2>E.#
///   #..><..#
///   ######.#
///
///   Minute 16, move right:
///   #.######
///   #.<..22#
///   #<<.<..#
///   #<2.>>E#
///   #.^22^.#
///   ######.#
///
///   Minute 17, move down:
///   #.######
///   #2.v.<>#
///   #<.<..<#
///   #.^>^22#
///   #.2..2E#
///   ######.#
///
///   Minute 18, move down:
///   #.######
///   #>2.<.<#
///   #.2v^2<#
///   #>..>2>#
///   #<....>#
///   ######E#
///
///
/// What is the fewest number of minutes required to avoid the blizzards and
/// reach the goal?
int part1(List<String> input) {
  updateForwardCosts(1, 0, 0);
  return bestScore;
}

/// --- Part Two ---
///
/// As the expedition reaches the far side of the valley, one of the Elves looks
/// especially dismayed:
///
/// He forgot his snacks at the entrance to the valley!
///
/// Since you're so good at dodging blizzards, the Elves humbly request that you
/// go back for his snacks. From the same initial conditions, how quickly can
/// you make it from the start to the goal, then back to the start, then back to
/// the goal?
///
/// In the above example, the first trip to the goal takes 18 minutes, the trip
/// back to the start takes 23 minutes, and the trip back to the goal again
/// takes 13 minutes, for a total time of 54 minutes.
///
/// What is the fewest number of minutes required to reach the goal, go back to
/// the start, then reach the goal again?
int part2(List<String> input) {
  // Fetch duration for the first forward travel from global variable that has
  // been set in part 1.
  int travelCost = bestScore;

  // Reset best score as we are now interested in the score for reaching 0,0
  // from (maxX - 1),(maxY - 1).
  bestScore = infiniteCost;

  // Try to enter the hailstorm. The case can arise where you cannot be at
  // (maxX - 1),(max - 1) immediately, as this does not result in the optimal
  // path. We might need to wait for some turns.
  List<int> scores = [];
  for (int iterationIndex = 0; iterationIndex < lcm; iterationIndex++) {
    if (!blizzardConfigurations[(travelCost + 1 + iterationIndex) % lcm]
        [maxX - 1][maxY - 1]) {
      updateBackwardCosts(travelCost + 1 + iterationIndex, maxX - 1, maxY - 1);
      scores.add(bestScore);
    }
  }

  // Get new total travel cost.
  travelCost = scores.reduce((a, b) => a < b ? a : b);

  // Reset best score as we are now interested in the score for reaching
  //(maxX - 1),(maxY - 1) again.
  bestScore = infiniteCost;

  // Reset forward costs.
  forwardCosts = List.generate(
    lcm,
    (a) => List.generate(
      maxX,
      (b) => List.generate(
        maxY,
        (c) => infiniteCost,
        growable: false,
      ),
      growable: false,
    ),
    growable: false,
  );

  // Try to enter the hailstorm. The case can arise where you cannot be at
  // (maxX - 1),(max - 1) immediately, as this does not result in the optimal
  // path. We might need to wait for some turns.
  scores = [];
  for (int iterationIndex = 0; iterationIndex < lcm; iterationIndex++) {
    if (!blizzardConfigurations[(travelCost + 1 + iterationIndex) % lcm]
        [maxX - 1][maxY - 1]) {
      updateForwardCosts(travelCost + 1 + iterationIndex, 0, 0);
      scores.add(bestScore);
    }
  }

  return scores.reduce((a, b) => a < b ? a : b);
}
