import 'dart:io';

void main() {
  String input = File('2016/dart/01/input.txt').readAsStringSync();

  int answer1 = part1(input);
  print(answer1);

  int answer2 = part2(input);
  print(answer2);
}

class Position {
  Position(this.x, this.y);

  final int x;
  final int y;

  Position up({int? distance}) => Position(x, y + (distance ?? 1));
  Position right({int? distance}) => Position(x + (distance ?? 1), y);
  Position down({int? distance}) => Position(x, y - (distance ?? 1));
  Position left({int? distance}) => Position(x - (distance ?? 1), y);

  @override
  bool operator ==(Object other) {
    return other is Position && x == other.x && y == other.y;
  }

  @override
  int get hashCode => x << 32 + y;

  @override
  String toString() {
    return '$x $y';
  }
}

int part1(String input) {
  Position position = Position(0, 0);
  int direction = 0;
  List<String> instructions = input.split(', ');

  for (String instruction in instructions) {
    direction += (instruction[0] == 'L' ? 1 : -1);
    int distance = int.parse(instruction.substring(1));

    switch (direction % 4) {
      case 0:
        position = position.up(distance: distance);
        break;
      case 1:
        position = position.left(distance: distance);
        break;
      case 2:
        position = position.down(distance: distance);
        break;
      case 3:
        position = position.right(distance: distance);
        break;
    }
  }
  return (position.x + position.y).abs();
}

int part2(String input) {
  int direction = 0;
  List<String> instructions = input.split(', ');
  Set<Position> visitedPositions = {Position(0, 0)};
  Position currentPosition = Position(0, 0);

  for (String instruction in instructions) {
    direction += (instruction[0] == 'L' ? 1 : -1);
    int distance = int.parse(instruction.substring(1));

    for (int i = 0; i < distance; i++) {
      switch (direction % 4) {
        case 0:
          currentPosition = currentPosition.up();
          break;
        case 1:
          currentPosition = currentPosition.left();
          break;
        case 2:
          currentPosition = currentPosition.down();
          break;
        case 3:
          currentPosition = currentPosition.right();
          break;
      }

      if (visitedPositions.contains(currentPosition)) {
        return (currentPosition.x + currentPosition.y).abs();
      }
      visitedPositions.add(currentPosition);
    }
  }

  return -1;
}
