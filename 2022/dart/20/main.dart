import 'dart:io';

void main() {
  List<String> input = File('2022/dart/20/input.txt').readAsLinesSync();

  int answer1 = part1(input);
  print(answer1);

  int answer2 = part2(input);
  print(answer2);
}

class RingElement {
  RingElement({
    required this.value,
  });

  final int value;
  late RingElement predecessor;
  late RingElement successor;

  RingElement getRelativeElement(int i) {
    if (i == 0) {
      return this;
    }
    return i > 0
        ? successor.getRelativeElement(--i)
        : predecessor.getRelativeElement(++i);
  }

  void move() {
    if (value == 0) {
      return;
    }

    if (value > 0) {
      RingElement newPredecessor = getRelativeElement(value);
      if (newPredecessor == this) {
        newPredecessor = successor;
      }
      RingElement newSuccessor = newPredecessor.successor;
      if (newSuccessor == this) {
        newSuccessor = successor;
      }

      predecessor.successor = successor;
      successor.predecessor = predecessor;
      newPredecessor.successor = this;
      newSuccessor.predecessor = this;
      predecessor = newPredecessor;
      successor = newSuccessor;
    }

    if (value < 0) {
      RingElement newSuccessor = getRelativeElement(value);
      if (newSuccessor == this) {
        newSuccessor = predecessor;
      }
      RingElement newPredecessor = newSuccessor.predecessor;
      if (newPredecessor == this) {
        newPredecessor = predecessor;
      }

      predecessor.successor = successor;
      successor.predecessor = predecessor;
      newPredecessor.successor = this;
      newSuccessor.predecessor = this;
      predecessor = newPredecessor;
      successor = newSuccessor;
    }
  }

  String _printRing(RingElement starter) {
    return starter == this
        ? '$value'
        : '$value,${successor._printRing(starter)}';
  }

  String printRing() {
    return _printRing(predecessor);
  }

  int _size(RingElement starter) {
    if (starter == this) {
      return 1;
    }
    return 1 + successor._size(starter);
  }

  int size() {
    return _size(predecessor);
  }
}

int part1(List<String> input) {
  List<RingElement> elements =
      input.map((value) => RingElement(value: int.parse(value))).toList();

  for (int i = 0; i < elements.length; i++) {
    RingElement element = elements[i];
    RingElement formerElement = elements[(i - 1) % elements.length];
    RingElement laterElement = elements[(i + 1) % elements.length];
    element.predecessor = formerElement;
    element.successor = laterElement;
  }

  elements.forEach((element) => element.move());

  RingElement zero = elements.firstWhere((element) => element.value == 0);

  return [1000, 2000, 3000]
      .map((groveCoordinate) => zero.getRelativeElement(groveCoordinate).value)
      .reduce((a, b) => a + b);
}

int part2(List<String> input) {
  return -1;
}
