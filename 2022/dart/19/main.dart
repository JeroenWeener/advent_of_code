import 'dart:io';

void main() {
  List<String> input = File('2022/dart/19/input.txt').readAsLinesSync();

  int answer1 = part1(input);
  print(answer1);

  int answer2 = part2(input);
  print(answer2);
}

class Minerals {
  const Minerals({
    required this.ore,
    required this.clay,
    required this.obsidian,
    required this.geode,
  });

  Minerals.empty()
      : ore = 0,
        clay = 0,
        obsidian = 0,
        geode = 0;

  final int ore;
  final int clay;
  final int obsidian;
  final int geode;

  int get score => ore + clay + obsidian + geode;

  Minerals operator -(Minerals other) {
    return Minerals(
      ore: ore - other.ore,
      clay: clay - other.clay,
      obsidian: obsidian - other.obsidian,
      geode: geode - other.geode,
    );
  }

  bool operator >=(Minerals other) {
    return ore >= other.ore &&
        clay >= other.clay &&
        obsidian >= other.obsidian &&
        geode >= other.geode;
  }

  @override
  String toString() {
    return '$ore ore, $clay clay, $obsidian obsidian, $geode geode';
  }
}

class Inventory {
  const Inventory({
    required this.oreRobots,
    required this.clayRobots,
    required this.obsidianRobots,
    required this.geodeRobots,
    required this.minerals,
  });

  Inventory.initial()
      : oreRobots = 1,
        clayRobots = 0,
        obsidianRobots = 0,
        geodeRobots = 0,
        minerals = Minerals.empty();

  final int oreRobots;
  final int clayRobots;
  final int obsidianRobots;
  final int geodeRobots;
  final Minerals minerals;

  int get score =>
      oreRobots + clayRobots + obsidianRobots + geodeRobots + minerals.score;

  Inventory mine() {
    return copyWith(
      minerals: Minerals(
        ore: minerals.ore + oreRobots,
        clay: minerals.clay + clayRobots,
        obsidian: minerals.obsidian + obsidianRobots,
        geode: minerals.geode + geodeRobots,
      ),
    );
  }

  Inventory buildOreRobot(BluePrint bluePrint) {
    return copyWith(
      oreRobots: oreRobots + 1,
      minerals: minerals - bluePrint.oreRobotCost,
    );
  }

  Inventory buildClayRobot(BluePrint bluePrint) {
    return copyWith(
      clayRobots: clayRobots + 1,
      minerals: minerals - bluePrint.clayRobotCost,
    );
  }

  Inventory buildObsidianRobot(BluePrint bluePrint) {
    return copyWith(
      obsidianRobots: obsidianRobots + 1,
      minerals: minerals - bluePrint.obsidianRobotCost,
    );
  }

  Inventory buildGeodeRobot(BluePrint bluePrint) {
    return copyWith(
      geodeRobots: geodeRobots + 1,
      minerals: minerals - bluePrint.geodeRobotCost,
    );
  }

  Inventory copyWith({
    oreRobots,
    clayRobots,
    obsidianRobots,
    geodeRobots,
    minerals,
  }) {
    return Inventory(
      oreRobots: oreRobots ?? this.oreRobots,
      clayRobots: clayRobots ?? this.clayRobots,
      obsidianRobots: obsidianRobots ?? this.obsidianRobots,
      geodeRobots: geodeRobots ?? this.geodeRobots,
      minerals: minerals ?? this.minerals,
    );
  }

  bool operator >=(Inventory other) {
    return oreRobots >= other.oreRobots &&
        clayRobots >= other.clayRobots &&
        obsidianRobots >= other.obsidianRobots &&
        geodeRobots >= other.geodeRobots &&
        minerals >= other.minerals;
  }

  @override
  String toString() {
    return 'Ore robots: $oreRobots, Clay robots: $clayRobots, Obsidian robots: $obsidianRobots, Geode robots: $geodeRobots, Minerals: $minerals';
  }
}

class BluePrint {
  const BluePrint({
    required this.oreRobotCost,
    required this.clayRobotCost,
    required this.obsidianRobotCost,
    required this.geodeRobotCost,
  });

  final Minerals oreRobotCost;
  final Minerals clayRobotCost;
  final Minerals obsidianRobotCost;
  final Minerals geodeRobotCost;

  @override
  String toString() {
    return 'Ore robot costs: $oreRobotCost. Clay robot costs: $clayRobotCost. Obsidian robot costs: $obsidianRobotCost. Geode robot costs: $geodeRobotCost.';
  }
}

/// Keep track of the maximum number of geodes we have mined in any path for a
/// specific blueprint.
///
/// Should we ever come at an iteration where we can no longer achieve more than
/// this number of geodes, we prune that branch.
late int geodeRecord;

/// Keep track of the maximum number of robots we would ever need. As we can
/// only build one robot per minute, there is a maximum of every resource we can
/// spend per minute. We do not require more robots than that amount as we would
/// never be able to consume their mined minerals.
late int maxOreRobots;
late int maxClayRobots;
late int maxObsidianRobots;

late Map<int, Inventory> inventoryPerMinutesLeft;

/// Returns the number of geodes that can be mined at most, following the
/// provided [bluePrint].
int iterate(
  int minutesLeft,
  BluePrint bluePrint,
  Inventory currentInventory,
) {
  if (minutesLeft == 0) {
    int geode = currentInventory.minerals.geode;
    if (geode > geodeRecord) {
      geodeRecord = geode;
    }
    return geode;
  }

  // Check if upperbound estimate of geode can be higher than the record. If
  // not, just return the record.
  //
  // The upperbound is very generous; it assumes we will spend every minute
  // building another geode robot.
  if (currentInventory.minerals.geode +
          minutesLeft * (currentInventory.geodeRobots + (minutesLeft - 1) / 2) <
      geodeRecord) {
    return geodeRecord;
  }

  // Check if we have already achieved a strictly better inventory at this point
  // in time. Prune this branch if we have.
  if (inventoryPerMinutesLeft.containsKey(minutesLeft) &&
      inventoryPerMinutesLeft[minutesLeft]! >= currentInventory) {
    return geodeRecord;
  } else {
    Inventory other =
        inventoryPerMinutesLeft[minutesLeft] ?? Inventory.initial();
    // Update the stored inventory if its score is higher.
    //
    // Score is determined as the sum of the inventory's objects.
    if (currentInventory.score > other.score) {
      inventoryPerMinutesLeft[minutesLeft] = currentInventory;
    }
  }

  List<int> geodes = [0];

  // Build a geode robot if we can afford one.
  if (currentInventory.minerals >= bluePrint.geodeRobotCost) {
    int geode = iterate(minutesLeft - 1, bluePrint,
        currentInventory.mine().buildGeodeRobot(bluePrint));
    geodes.add(geode);
  }

  // Build an obsidian robot if we can afford one and we do not have enough
  // already.
  if (currentInventory.minerals >= bluePrint.obsidianRobotCost &&
      currentInventory.obsidianRobots < maxObsidianRobots) {
    int geode = iterate(
      minutesLeft - 1,
      bluePrint,
      currentInventory.mine().buildObsidianRobot(bluePrint),
    );
    geodes.add(geode);
  }

  // Build an ore robot if we can afford one and we do not have enough already.
  if (currentInventory.minerals >= bluePrint.oreRobotCost &&
      currentInventory.oreRobots < maxOreRobots) {
    int geode = iterate(
      minutesLeft - 1,
      bluePrint,
      currentInventory.mine().buildOreRobot(bluePrint),
    );
    geodes.add(geode);
  }

  // Build a clay robot if we can afford one and we do not have enough already.
  if (currentInventory.minerals >= bluePrint.clayRobotCost &&
      currentInventory.clayRobots < maxClayRobots) {
    int geode = iterate(
      minutesLeft - 1,
      bluePrint,
      currentInventory.mine().buildClayRobot(bluePrint),
    );
    geodes.add(geode);
  }

  // Do nothing, maybe we can do something next iteration when we have more
  // resources.
  int geode = iterate(
    minutesLeft - 1,
    bluePrint,
    currentInventory.mine(),
  );
  geodes.add(geode);

  return geodes.reduce((a, b) => a > b ? a : b);
}

BluePrint parseBluePrint(String bluePrintString) {
  List<Minerals> robotCosts =
      bluePrintString.split(' ').skip(2).join(' ').split('.').map((sentence) {
    List<int> minerals = ['ore', 'clay', 'obsidian', 'geode'].map((mineral) {
      Iterable<String> mineralStrings = sentence
          .split(' and ')
          .map((description) => description.split(' '))
          .where((description) => description.last == mineral)
          .map((description) => description[description.length - 2]);
      return mineralStrings.length > 0 ? int.parse(mineralStrings.first) : 0;
    }).toList();

    return Minerals(
      ore: minerals[0],
      clay: minerals[1],
      obsidian: minerals[2],
      geode: minerals[3],
    );
  }).toList();

  return BluePrint(
    oreRobotCost: robotCosts[0],
    clayRobotCost: robotCosts[1],
    obsidianRobotCost: robotCosts[2],
    geodeRobotCost: robotCosts[3],
  );
}

/// --- Day 19: Not Enough Minerals ---
///
/// Your scans show that the lava did indeed form obsidian!
///
/// The wind has changed direction enough to stop sending lava droplets toward
/// you, so you and the elephants exit the cave. As you do, you notice a
/// collection of geodes around the pond. Perhaps you could use the obsidian to
/// create some geode-cracking robots and break them open?
///
/// To collect the obsidian from the bottom of the pond, you'll need waterproof
/// obsidian-collecting robots. Fortunately, there is an abundant amount of clay
/// nearby that you can use to make them waterproof.
///
/// In order to harvest the clay, you'll need special-purpose clay-collecting
/// robots. To make any type of robot, you'll need ore, which is also plentiful
/// but in the opposite direction from the clay.
///
/// Collecting ore requires ore-collecting robots with big drills. Fortunately,
/// you have exactly one ore-collecting robot in your pack that you can use to
/// kickstart the whole operation.
///
/// Each robot can collect 1 of its resource type per minute. It also takes one
/// minute for the robot factory (also conveniently from your pack) to construct
/// any type of robot, although it consumes the necessary resources available
/// when construction begins.
///
/// The robot factory has many blueprints (your puzzle input) you can choose
/// from, but once you've configured it with a blueprint, you can't change it.
/// You'll need to work out which blueprint is best.
///
/// For example:
///
///   Blueprint 1:
///     Each ore robot costs 4 ore.
///     Each clay robot costs 2 ore.
///     Each obsidian robot costs 3 ore and 14 clay.
///     Each geode robot costs 2 ore and 7 obsidian.
///
///   Blueprint 2:
///     Each ore robot costs 2 ore.
///     Each clay robot costs 3 ore.
///     Each obsidian robot costs 3 ore and 8 clay.
///     Each geode robot costs 3 ore and 12 obsidian.
///
///
/// (Blueprints have been line-wrapped here for legibility. The robot factory's
/// actual assortment of blueprints are provided one blueprint per line.)
///
/// The elephants are starting to look hungry, so you shouldn't take too long;
/// you need to figure out which blueprint would maximize the number of opened
/// geodes after 24 minutes by figuring out which robots to build and when to
/// build them.
///
/// Using blueprint 1 in the example above, the largest number of geodes you
/// could open in 24 minutes is 9. One way to achieve that is:
///
///   == Minute 1 ==
///   1 ore-collecting robot collects 1 ore; you now have 1 ore.
///
///   == Minute 2 ==
///   1 ore-collecting robot collects 1 ore; you now have 2 ore.
///
///   == Minute 3 ==
///   Spend 2 ore to start building a clay-collecting robot.
///   1 ore-collecting robot collects 1 ore; you now have 1 ore.
///   The new clay-collecting robot is ready; you now have 1 of them.
///
///   == Minute 4 ==
///   1 ore-collecting robot collects 1 ore; you now have 2 ore.
///   1 clay-collecting robot collects 1 clay; you now have 1 clay.
///
///   == Minute 5 ==
///   Spend 2 ore to start building a clay-collecting robot.
///   1 ore-collecting robot collects 1 ore; you now have 1 ore.
///   1 clay-collecting robot collects 1 clay; you now have 2 clay.
///   The new clay-collecting robot is ready; you now have 2 of them.
///
///   == Minute 6 ==
///   1 ore-collecting robot collects 1 ore; you now have 2 ore.
///   2 clay-collecting robots collect 2 clay; you now have 4 clay.
///
///   == Minute 7 ==
///   Spend 2 ore to start building a clay-collecting robot.
///   1 ore-collecting robot collects 1 ore; you now have 1 ore.
///   2 clay-collecting robots collect 2 clay; you now have 6 clay.
///   The new clay-collecting robot is ready; you now have 3 of them.
///
///   == Minute 8 ==
///   1 ore-collecting robot collects 1 ore; you now have 2 ore.
///   3 clay-collecting robots collect 3 clay; you now have 9 clay.
///
///   == Minute 9 ==
///   1 ore-collecting robot collects 1 ore; you now have 3 ore.
///   3 clay-collecting robots collect 3 clay; you now have 12 clay.
///
///   == Minute 10 ==
///   1 ore-collecting robot collects 1 ore; you now have 4 ore.
///   3 clay-collecting robots collect 3 clay; you now have 15 clay.
///
///   == Minute 11 ==
///   Spend 3 ore and 14 clay to start building an obsidian-collecting robot.
///   1 ore-collecting robot collects 1 ore; you now have 2 ore.
///   3 clay-collecting robots collect 3 clay; you now have 4 clay.
///   The new obsidian-collecting robot is ready; you now have 1 of them.
///
///   == Minute 12 ==
///   Spend 2 ore to start building a clay-collecting robot.
///   1 ore-collecting robot collects 1 ore; you now have 1 ore.
///   3 clay-collecting robots collect 3 clay; you now have 7 clay.
///   1 obsidian-collecting robot collects 1 obsidian; you now have 1 obsidian.
///   The new clay-collecting robot is ready; you now have 4 of them.
///
///   == Minute 13 ==
///   1 ore-collecting robot collects 1 ore; you now have 2 ore.
///   4 clay-collecting robots collect 4 clay; you now have 11 clay.
///   1 obsidian-collecting robot collects 1 obsidian; you now have 2 obsidian.
///
///   == Minute 14 ==
///   1 ore-collecting robot collects 1 ore; you now have 3 ore.
///   4 clay-collecting robots collect 4 clay; you now have 15 clay.
///   1 obsidian-collecting robot collects 1 obsidian; you now have 3 obsidian.
///
///   == Minute 15 ==
///   Spend 3 ore and 14 clay to start building an obsidian-collecting robot.
///   1 ore-collecting robot collects 1 ore; you now have 1 ore.
///   4 clay-collecting robots collect 4 clay; you now have 5 clay.
///   1 obsidian-collecting robot collects 1 obsidian; you now have 4 obsidian.
///   The new obsidian-collecting robot is ready; you now have 2 of them.
///
///   == Minute 16 ==
///   1 ore-collecting robot collects 1 ore; you now have 2 ore.
///   4 clay-collecting robots collect 4 clay; you now have 9 clay.
///   2 obsidian-collecting robots collect 2 obsidian; you now have 6 obsidian.
///
///   == Minute 17 ==
///   1 ore-collecting robot collects 1 ore; you now have 3 ore.
///   4 clay-collecting robots collect 4 clay; you now have 13 clay.
///   2 obsidian-collecting robots collect 2 obsidian; you now have 8 obsidian.
///
///   == Minute 18 ==
///   Spend 2 ore and 7 obsidian to start building a geode-cracking robot.
///   1 ore-collecting robot collects 1 ore; you now have 2 ore.
///   4 clay-collecting robots collect 4 clay; you now have 17 clay.
///   2 obsidian-collecting robots collect 2 obsidian; you now have 3 obsidian.
///   The new geode-cracking robot is ready; you now have 1 of them.
///
///   == Minute 19 ==
///   1 ore-collecting robot collects 1 ore; you now have 3 ore.
///   4 clay-collecting robots collect 4 clay; you now have 21 clay.
///   2 obsidian-collecting robots collect 2 obsidian; you now have 5 obsidian.
///   1 geode-cracking robot cracks 1 geode; you now have 1 open geode.
///
///   == Minute 20 ==
///   1 ore-collecting robot collects 1 ore; you now have 4 ore.
///   4 clay-collecting robots collect 4 clay; you now have 25 clay.
///   2 obsidian-collecting robots collect 2 obsidian; you now have 7 obsidian.
///   1 geode-cracking robot cracks 1 geode; you now have 2 open geodes.
///
///   == Minute 21 ==
///   Spend 2 ore and 7 obsidian to start building a geode-cracking robot.
///   1 ore-collecting robot collects 1 ore; you now have 3 ore.
///   4 clay-collecting robots collect 4 clay; you now have 29 clay.
///   2 obsidian-collecting robots collect 2 obsidian; you now have 2 obsidian.
///   1 geode-cracking robot cracks 1 geode; you now have 3 open geodes.
///   The new geode-cracking robot is ready; you now have 2 of them.
///
///   == Minute 22 ==
///   1 ore-collecting robot collects 1 ore; you now have 4 ore.
///   4 clay-collecting robots collect 4 clay; you now have 33 clay.
///   2 obsidian-collecting robots collect 2 obsidian; you now have 4 obsidian.
///   2 geode-cracking robots crack 2 geodes; you now have 5 open geodes.
///
///   == Minute 23 ==
///   1 ore-collecting robot collects 1 ore; you now have 5 ore.
///   4 clay-collecting robots collect 4 clay; you now have 37 clay.
///   2 obsidian-collecting robots collect 2 obsidian; you now have 6 obsidian.
///   2 geode-cracking robots crack 2 geodes; you now have 7 open geodes.
///
///   == Minute 24 ==
///   1 ore-collecting robot collects 1 ore; you now have 6 ore.
///   4 clay-collecting robots collect 4 clay; you now have 41 clay.
///   2 obsidian-collecting robots collect 2 obsidian; you now have 8 obsidian.
///   2 geode-cracking robots crack 2 geodes; you now have 9 open geodes.
///
///
/// However, by using blueprint 2 in the example above, you could do even
/// better: the largest number of geodes you could open in 24 minutes is 12.
///
/// Determine the quality level of each blueprint by multiplying that
/// blueprint's ID number with the largest number of geodes that can be opened
/// in 24 minutes using that blueprint. In this example, the first blueprint has
/// ID 1 and can open 9 geodes, so its quality level is 9. The second blueprint
/// has ID 2 and can open 12 geodes, so its quality level is 24. Finally, if you
/// add up the quality levels of all of the blueprints in the list, you get 33.
///
/// Determine the quality level of each blueprint using the largest number of
/// geodes it could produce in 24 minutes. What do you get if you add up the
/// quality level of all of the blueprints in your list?
int part1(List<String> input) {
  List<BluePrint> bluePrints = input.map((e) => parseBluePrint(e)).toList();

  List<int> qualityLevels = [];
  for (int bluePrintIndex = 0;
      bluePrintIndex < bluePrints.length;
      bluePrintIndex++) {
    geodeRecord = 0;
    inventoryPerMinutesLeft = {};
    BluePrint bp = bluePrints[bluePrintIndex];
    List<Minerals> costs = [
      bp.oreRobotCost,
      bp.clayRobotCost,
      bp.obsidianRobotCost,
      bp.geodeRobotCost
    ];
    maxOreRobots = costs.map((e) => e.ore).reduce((a, b) => a > b ? a : b);
    maxClayRobots = costs.map((e) => e.clay).reduce((a, b) => a > b ? a : b);
    maxObsidianRobots =
        costs.map((e) => e.obsidian).reduce((a, b) => a > b ? a : b);

    int geode = iterate(24, bluePrints[bluePrintIndex], Inventory.initial());
    int qualityLevel = (bluePrintIndex + 1) * geode;
    qualityLevels.add(qualityLevel);
  }
  return qualityLevels.reduce((a, b) => a + b);
}

/// --- Part Two ---
///
/// While you were choosing the best blueprint, the elephants found some food on
/// their own, so you're not in as much of a hurry; you figure you probably have
/// 32 minutes before the wind changes direction again and you'll need to get
/// out of range of the erupting volcano.
///
/// Unfortunately, one of the elephants ate most of your blueprint list! Now,
/// only the first three blueprints in your list are intact.
///
/// In 32 minutes, the largest number of geodes blueprint 1 (from the example
/// above) can open is 56. One way to achieve that is:
///
///   == Minute 1 ==
///   1 ore-collecting robot collects 1 ore; you now have 1 ore.
///
///   == Minute 2 ==
///   1 ore-collecting robot collects 1 ore; you now have 2 ore.
///
///   == Minute 3 ==
///   1 ore-collecting robot collects 1 ore; you now have 3 ore.
///
///   == Minute 4 ==
///   1 ore-collecting robot collects 1 ore; you now have 4 ore.
///
///   == Minute 5 ==
///   Spend 4 ore to start building an ore-collecting robot.
///   1 ore-collecting robot collects 1 ore; you now have 1 ore.
///   The new ore-collecting robot is ready; you now have 2 of them.
///
///   == Minute 6 ==
///   2 ore-collecting robots collect 2 ore; you now have 3 ore.
///
///   == Minute 7 ==
///   Spend 2 ore to start building a clay-collecting robot.
///   2 ore-collecting robots collect 2 ore; you now have 3 ore.
///   The new clay-collecting robot is ready; you now have 1 of them.
///
///   == Minute 8 ==
///   Spend 2 ore to start building a clay-collecting robot.
///   2 ore-collecting robots collect 2 ore; you now have 3 ore.
///   1 clay-collecting robot collects 1 clay; you now have 1 clay.
///   The new clay-collecting robot is ready; you now have 2 of them.
///
///   == Minute 9 ==
///   Spend 2 ore to start building a clay-collecting robot.
///   2 ore-collecting robots collect 2 ore; you now have 3 ore.
///   2 clay-collecting robots collect 2 clay; you now have 3 clay.
///   The new clay-collecting robot is ready; you now have 3 of them.
///
///   == Minute 10 ==
///   Spend 2 ore to start building a clay-collecting robot.
///   2 ore-collecting robots collect 2 ore; you now have 3 ore.
///   3 clay-collecting robots collect 3 clay; you now have 6 clay.
///   The new clay-collecting robot is ready; you now have 4 of them.
///
///   == Minute 11 ==
///   Spend 2 ore to start building a clay-collecting robot.
///   2 ore-collecting robots collect 2 ore; you now have 3 ore.
///   4 clay-collecting robots collect 4 clay; you now have 10 clay.
///   The new clay-collecting robot is ready; you now have 5 of them.
///
///   == Minute 12 ==
///   Spend 2 ore to start building a clay-collecting robot.
///   2 ore-collecting robots collect 2 ore; you now have 3 ore.
///   5 clay-collecting robots collect 5 clay; you now have 15 clay.
///   The new clay-collecting robot is ready; you now have 6 of them.
///
///   == Minute 13 ==
///   Spend 2 ore to start building a clay-collecting robot.
///   2 ore-collecting robots collect 2 ore; you now have 3 ore.
///   6 clay-collecting robots collect 6 clay; you now have 21 clay.
///   The new clay-collecting robot is ready; you now have 7 of them.
///
///   == Minute 14 ==
///   Spend 3 ore and 14 clay to start building an obsidian-collecting robot.
///   2 ore-collecting robots collect 2 ore; you now have 2 ore.
///   7 clay-collecting robots collect 7 clay; you now have 14 clay.
///   The new obsidian-collecting robot is ready; you now have 1 of them.
///
///   == Minute 15 ==
///   2 ore-collecting robots collect 2 ore; you now have 4 ore.
///   7 clay-collecting robots collect 7 clay; you now have 21 clay.
///   1 obsidian-collecting robot collects 1 obsidian; you now have 1 obsidian.
///
///   == Minute 16 ==
///   Spend 3 ore and 14 clay to start building an obsidian-collecting robot.
///   2 ore-collecting robots collect 2 ore; you now have 3 ore.
///   7 clay-collecting robots collect 7 clay; you now have 14 clay.
///   1 obsidian-collecting robot collects 1 obsidian; you now have 2 obsidian.
///   The new obsidian-collecting robot is ready; you now have 2 of them.
///
///   == Minute 17 ==
///   Spend 3 ore and 14 clay to start building an obsidian-collecting robot.
///   2 ore-collecting robots collect 2 ore; you now have 2 ore.
///   7 clay-collecting robots collect 7 clay; you now have 7 clay.
///   2 obsidian-collecting robots collect 2 obsidian; you now have 4 obsidian.
///   The new obsidian-collecting robot is ready; you now have 3 of them.
///
///   == Minute 18 ==
///   2 ore-collecting robots collect 2 ore; you now have 4 ore.
///   7 clay-collecting robots collect 7 clay; you now have 14 clay.
///   3 obsidian-collecting robots collect 3 obsidian; you now have 7 obsidian.
///
///   == Minute 19 ==
///   Spend 3 ore and 14 clay to start building an obsidian-collecting robot.
///   2 ore-collecting robots collect 2 ore; you now have 3 ore.
///   7 clay-collecting robots collect 7 clay; you now have 7 clay.
///   3 obsidian-collecting robots collect 3 obsidian; you now have 10 obsidian.
///   The new obsidian-collecting robot is ready; you now have 4 of them.
///
///   == Minute 20 ==
///   Spend 2 ore and 7 obsidian to start building a geode-cracking robot.
///   2 ore-collecting robots collect 2 ore; you now have 3 ore.
///   7 clay-collecting robots collect 7 clay; you now have 14 clay.
///   4 obsidian-collecting robots collect 4 obsidian; you now have 7 obsidian.
///   The new geode-cracking robot is ready; you now have 1 of them.
///
///   == Minute 21 ==
///   Spend 3 ore and 14 clay to start building an obsidian-collecting robot.
///   2 ore-collecting robots collect 2 ore; you now have 2 ore.
///   7 clay-collecting robots collect 7 clay; you now have 7 clay.
///   4 obsidian-collecting robots collect 4 obsidian; you now have 11 obsidian.
///   1 geode-cracking robot cracks 1 geode; you now have 1 open geode.
///   The new obsidian-collecting robot is ready; you now have 5 of them.
///
///   == Minute 22 ==
///   Spend 2 ore and 7 obsidian to start building a geode-cracking robot.
///   2 ore-collecting robots collect 2 ore; you now have 2 ore.
///   7 clay-collecting robots collect 7 clay; you now have 14 clay.
///   5 obsidian-collecting robots collect 5 obsidian; you now have 9 obsidian.
///   1 geode-cracking robot cracks 1 geode; you now have 2 open geodes.
///   The new geode-cracking robot is ready; you now have 2 of them.
///
///   == Minute 23 ==
///   Spend 2 ore and 7 obsidian to start building a geode-cracking robot.
///   2 ore-collecting robots collect 2 ore; you now have 2 ore.
///   7 clay-collecting robots collect 7 clay; you now have 21 clay.
///   5 obsidian-collecting robots collect 5 obsidian; you now have 7 obsidian.
///   2 geode-cracking robots crack 2 geodes; you now have 4 open geodes.
///   The new geode-cracking robot is ready; you now have 3 of them.
///
///   == Minute 24 ==
///   Spend 2 ore and 7 obsidian to start building a geode-cracking robot.
///   2 ore-collecting robots collect 2 ore; you now have 2 ore.
///   7 clay-collecting robots collect 7 clay; you now have 28 clay.
///   5 obsidian-collecting robots collect 5 obsidian; you now have 5 obsidian.
///   3 geode-cracking robots crack 3 geodes; you now have 7 open geodes.
///   The new geode-cracking robot is ready; you now have 4 of them.
///
///   == Minute 25 ==
///   2 ore-collecting robots collect 2 ore; you now have 4 ore.
///   7 clay-collecting robots collect 7 clay; you now have 35 clay.
///   5 obsidian-collecting robots collect 5 obsidian; you now have 10 obsidian.
///   4 geode-cracking robots crack 4 geodes; you now have 11 open geodes.
///
///   == Minute 26 ==
///   Spend 2 ore and 7 obsidian to start building a geode-cracking robot.
///   2 ore-collecting robots collect 2 ore; you now have 4 ore.
///   7 clay-collecting robots collect 7 clay; you now have 42 clay.
///   5 obsidian-collecting robots collect 5 obsidian; you now have 8 obsidian.
///   4 geode-cracking robots crack 4 geodes; you now have 15 open geodes.
///   The new geode-cracking robot is ready; you now have 5 of them.
///
///   == Minute 27 ==
///   Spend 2 ore and 7 obsidian to start building a geode-cracking robot.
///   2 ore-collecting robots collect 2 ore; you now have 4 ore.
///   7 clay-collecting robots collect 7 clay; you now have 49 clay.
///   5 obsidian-collecting robots collect 5 obsidian; you now have 6 obsidian.
///   5 geode-cracking robots crack 5 geodes; you now have 20 open geodes.
///   The new geode-cracking robot is ready; you now have 6 of them.
///
///   == Minute 28 ==
///   2 ore-collecting robots collect 2 ore; you now have 6 ore.
///   7 clay-collecting robots collect 7 clay; you now have 56 clay.
///   5 obsidian-collecting robots collect 5 obsidian; you now have 11 obsidian.
///   6 geode-cracking robots crack 6 geodes; you now have 26 open geodes.
///
///   == Minute 29 ==
///   Spend 2 ore and 7 obsidian to start building a geode-cracking robot.
///   2 ore-collecting robots collect 2 ore; you now have 6 ore.
///   7 clay-collecting robots collect 7 clay; you now have 63 clay.
///   5 obsidian-collecting robots collect 5 obsidian; you now have 9 obsidian.
///   6 geode-cracking robots crack 6 geodes; you now have 32 open geodes.
///   The new geode-cracking robot is ready; you now have 7 of them.
///
///   == Minute 30 ==
///   Spend 2 ore and 7 obsidian to start building a geode-cracking robot.
///   2 ore-collecting robots collect 2 ore; you now have 6 ore.
///   7 clay-collecting robots collect 7 clay; you now have 70 clay.
///   5 obsidian-collecting robots collect 5 obsidian; you now have 7 obsidian.
///   7 geode-cracking robots crack 7 geodes; you now have 39 open geodes.
///   The new geode-cracking robot is ready; you now have 8 of them.
///
///   == Minute 31 ==
///   Spend 2 ore and 7 obsidian to start building a geode-cracking robot.
///   2 ore-collecting robots collect 2 ore; you now have 6 ore.
///   7 clay-collecting robots collect 7 clay; you now have 77 clay.
///   5 obsidian-collecting robots collect 5 obsidian; you now have 5 obsidian.
///   8 geode-cracking robots crack 8 geodes; you now have 47 open geodes.
///   The new geode-cracking robot is ready; you now have 9 of them.
///
///   == Minute 32 ==
///   2 ore-collecting robots collect 2 ore; you now have 8 ore.
///   7 clay-collecting robots collect 7 clay; you now have 84 clay.
///   5 obsidian-collecting robots collect 5 obsidian; you now have 10 obsidian.
///   9 geode-cracking robots crack 9 geodes; you now have 56 open geodes.
///
///
/// However, blueprint 2 from the example above is still better; using it, the
/// largest number of geodes you could open in 32 minutes is 62.
///
/// You no longer have enough blueprints to worry about quality levels. Instead,
/// for each of the first three blueprints, determine the largest number of
/// geodes you could open; then, multiply these three values together.
///
/// Don't worry about quality levels; instead, just determine the largest number
/// of geodes you could open using each of the first three blueprints. What do
/// you get if you multiply these numbers together?
int part2(List<String> input) {
  return input.take(3).map((e) => parseBluePrint(e)).map((bp) {
    geodeRecord = 0;
    inventoryPerMinutesLeft = {};
    List<Minerals> costs = [
      bp.oreRobotCost,
      bp.clayRobotCost,
      bp.obsidianRobotCost,
      bp.geodeRobotCost
    ];
    maxOreRobots = costs.map((e) => e.ore).reduce((a, b) => a > b ? a : b);
    maxClayRobots = costs.map((e) => e.clay).reduce((a, b) => a > b ? a : b);
    maxObsidianRobots =
        costs.map((e) => e.obsidian).reduce((a, b) => a > b ? a : b);

    return iterate(32, bp, Inventory.initial());
  }).reduce((a, b) => a * b);
}
