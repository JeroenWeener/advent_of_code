import 'dart:io';
import 'dart:math';

void main() {
  List<String> input = File('2022/dart/15/input.txt').readAsLinesSync();

  int answer1 = part1(input);
  print(answer1);

  int answer2 = part2(input);
  print(answer2);
}

class Position {
  const Position(this.x, this.y);

  final int x;
  final int y;

  int distanceFrom(Position other) {
    return (x - other.x).abs() + (y - other.y).abs();
  }

  @override
  operator ==(Object other) {
    return other is Position && x == other.x && y == other.y;
  }

  @override
  String toString() {
    return '$x $y';
  }
}

class Sensor {
  const Sensor({
    required this.position,
    required this.radius,
  });

  Sensor.fromBeacon({
    required this.position,
    required Position beaconPosition,
  }) : radius = position.distanceFrom(beaconPosition);

  final Position position;
  final int radius;

  bool coversPosition(Position position) {
    return position.distanceFrom(this.position) <= radius;
  }

  @override
  String toString() {
    return 'S(${position} $radius)';
  }
}

List<Sensor> extractSensors(List<String> input) {
  return input
      .map(
        (line) => RegExp(
          r'Sensor at x=(-?\d+), y=(-?\d+): closest beacon is at x=(-?\d+), y=(-?\d+)',
        )
            .firstMatch(line)!
            .groups([1, 2, 3, 4])
            .map((numberString) => int.parse(numberString!))
            .toList(),
      )
      .map(
        (numberList) => Sensor.fromBeacon(
          position: Position(numberList[0], numberList[1]),
          beaconPosition: Position(numberList[2], numberList[3]),
        ),
      )
      .toList();
}

List<Position> extractBeacons(List<String> input) {
  return input
      .map(
        (line) => RegExp(
          r'Sensor at x=(-?\d+), y=(-?\d+): closest beacon is at x=(-?\d+), y=(-?\d+)',
        )
            .firstMatch(line)!
            .groups([3, 4])
            .map((numberString) => int.parse(numberString!))
            .toList(),
      )
      .map(
        (numberList) => Position(numberList[0], numberList[1]),
      )
      .toList();
}

int part1(List<String> input) {
  List<Sensor> sensors = extractSensors(input);
  List<Position> beacons = extractBeacons(input);

  int minX = sensors
      .map((sensor) => sensor.position.x - sensor.radius)
      .reduce((a, b) => a < b ? a : b);
  int maxX = sensors
      .map((sensor) => sensor.position.x + sensor.radius)
      .reduce((a, b) => a > b ? a : b);

  int y = 2000000;

  int coveredLocations = 0;
  for (int x = minX; x <= maxX; x++) {
    Position position = Position(x, y);
    bool covered = sensors
        .map((sensor) => sensor.coversPosition(position))
        .any((isCovering) => isCovering);

    bool containsBeacon = beacons.any((beacon) => beacon == position);

    if (covered && !containsBeacon) {
      coveredLocations++;
    }
  }

  return coveredLocations;
}

int part2(List<String> input) {
  return -1;
}
