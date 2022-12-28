import 'dart:io';

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

  Inventory mine() {
    return copyWith(
        minerals: Minerals(
      ore: minerals.ore + oreRobots,
      clay: minerals.clay + clayRobots,
      obsidian: minerals.obsidian + obsidianRobots,
      geode: minerals.geode + geodeRobots,
    ));
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

late int geodeRecord;

/// Returns the number of geodes that can be mined at most, following the
/// provided [bluePrint].
///
/// TODO:
/// Greedily build geode robots if you can, then obsidian robots if you can,
/// then try all remaining options (clay, ore, none) and see which one is best.
int iterate(
  int minutesLeft,
  BluePrint bluePrint,
  Inventory currentInventory,
) {
  if (minutesLeft == 0) {
    int geode = currentInventory.minerals.geode;
    if (geode > geodeRecord) {
      print(currentInventory);
      geodeRecord = geode;
    }
    return geode;
  }

  // Check if upperbound estimate of geode can be higher than record. If not,
  // just return record.
  if (currentInventory.minerals.geode +
          minutesLeft * currentInventory.geodeRobots +
          minutesLeft * (minutesLeft - 1) / 2 <
      geodeRecord) {
    // print(
    //     'Estimate ${currentInventory.minerals.geode + minutesLeft * currentInventory.geodeRobots + minutesLeft * (minutesLeft - 1) / 2}');
    // print('Geode record: $geodeRecord');
    // print('pruning');
    return geodeRecord;
  }

  List<int> geodes = [0];

  if (currentInventory.minerals >= bluePrint.geodeRobotCost) {
    int geode = iterate(minutesLeft - 1, bluePrint,
        currentInventory.mine().buildGeodeRobot(bluePrint));
    geodes.add(geode);
  }

  if (currentInventory.minerals >= bluePrint.obsidianRobotCost) {
    int geode = iterate(
      minutesLeft - 1,
      bluePrint,
      currentInventory.mine().buildObsidianRobot(bluePrint),
    );
    geodes.add(geode);
  }

  if (currentInventory.minerals >= bluePrint.oreRobotCost) {
    int geode = iterate(
      minutesLeft - 1,
      bluePrint,
      currentInventory.mine().buildOreRobot(bluePrint),
    );
    geodes.add(geode);
  }

  if (currentInventory.minerals >= bluePrint.clayRobotCost) {
    int geode = iterate(
      minutesLeft - 1,
      bluePrint,
      currentInventory.mine().buildClayRobot(bluePrint),
    );
    geodes.add(geode);
  }

  int geode = iterate(
    minutesLeft - 1,
    bluePrint,
    currentInventory.mine(),
  );
  geodes.add(geode);

  return geodes.reduce((a, b) => a > b ? a : b);
}

void main() {
  List<String> input = File('2022/dart/19/input.txt').readAsLinesSync();

  int answer1 = part1(input);
  print(answer1);

  int answer2 = part2(input);
  print(answer2);
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

int part1(List<String> input) {
  List<BluePrint> bluePrints = input.map((e) => parseBluePrint(e)).toList();
  print('Parsed blueprints');

  List<int> qualityLevels = [];
  for (int bluePrintIndex = 0;
      bluePrintIndex < bluePrints.length;
      bluePrintIndex++) {
    print('---');
    print('Calculating optimal path for blueprint ${bluePrintIndex + 1}');
    geodeRecord = 0;
    int geode = iterate(24, bluePrints[bluePrintIndex], Inventory.initial());
    print(geode);
    int qualityLevel = (bluePrintIndex + 1) * geode;
    qualityLevels.add(qualityLevel);
  }
  return qualityLevels.reduce((a, b) => a + b);
}

int part2(List<String> input) {
  return -1;
}
