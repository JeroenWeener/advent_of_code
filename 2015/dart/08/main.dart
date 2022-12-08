import 'dart:io';

void main() {
  final List<String> input = File('2015/dart/08/input.txt').readAsLinesSync();

  final int answer1 = part1(input);
  print(answer1);

  final int answer2 = part2(input);
  print(answer2);
}

int part1(List<String> input) {
  return input
      .map((line) =>
          line.length -
          line
              .substring(1, line.length - 1)
              .replaceAll(RegExp(r'\x[0-9][0-9]'), 'x')
              .replaceAll('\\"', 'x')
              .replaceAll('\\\\', 'x')
              .length)
      .reduce((totalDifference, difference) => totalDifference + difference);
}

int part2(List<String> input) {
  return -1;
}
