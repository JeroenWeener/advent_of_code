import 'dart:io';

void main() {
  final List<String> input = File('2015/dart/05/input.txt').readAsLinesSync();

  final int answer1 = part1(input);
  print(answer1);

  final int answer2 = part2(input);
  print(answer2);
}

int part1(List<String> input) {
  return input.where((line) {
    final bool req1 = line.codeUnits
            .where((c) => 'aeiou'.contains(String.fromCharCode(c)))
            .length >=
        3;

    final bool req2 = List.generate(
      26,
      (index) => String.fromCharCode('a'.codeUnits.first + index) * 2,
      growable: false,
    ).where((pair) => line.contains(pair)).isNotEmpty;

    final bool req3 = !(line.contains('ab') ||
        line.contains('cd') ||
        line.contains('pq') ||
        line.contains('xy'));

    return req1 && req2 && req3;
  }).length;
}

int part2(List<String> input) {
  return -1;
}
