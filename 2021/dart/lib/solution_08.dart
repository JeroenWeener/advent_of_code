import 'package:aoc/aoc.dart';

void main(List<String> args) async {
  Solver<List<List<List<String>>>, int>(
    part1: part1,
    part2: part2,
    inputTransformer: transformInput,
    testOutput1: 26,
    testOutput2: 61229,
  ).execute();
}

List<List<List<String>>> transformInput(List<String> input) {
  return input
      .map((String line) => line
          .split(' | ')
          .map((String segment) => segment.split(' '))
          .toList())
      .toList();
}

int part1(List<List<List<String>>> input) {
  return input
      .map((List<List<String>> line) => line.second
          .where((String sequence) =>
              sequence.length == 2 ||
              sequence.length == 3 ||
              sequence.length == 4 ||
              sequence.length == 7)
          .length)
      .sum();
}

int part2(List<List<List<String>>> input) {
  return input.map((List<List<String>> line) {
    final Iterable<String> leftSegment = line.first;

    final String one =
        leftSegment.firstWhere((String sequence) => sequence.length == 2);
    final String three = leftSegment.firstWhere(
        (String sequence) => sequence.length == 5 && (one - sequence).isEmpty);
    final String six = leftSegment.firstWhere((String sequence) =>
        sequence.length == 6 && (one - sequence).isNotEmpty);
    final String five = leftSegment.firstWhere(
        (String sequence) => sequence.length == 5 && (sequence - six).isEmpty);
    final String zero = leftSegment.firstWhere((String sequence) =>
        sequence.length == 6 && (five - sequence).isNotEmpty);
    final String two = leftSegment.firstWhere((String sequence) =>
        sequence.length == 5 &&
        (sequence - six).isNotEmpty &&
        (one - sequence).isNotEmpty);
    final String nine = leftSegment.firstWhere((String sequence) =>
        sequence.length == 6 &&
        (five - sequence).isEmpty &&
        (one - sequence).isEmpty);

    String sequenceToDigit(String sequence) {
      if (sequence.length == 7) {
        return '8';
      } else if (sequence.length == 2) {
        return '1';
      } else if (sequence.length == 4) {
        return '4';
      } else if (sequence.length == 3) {
        return '7';
      } else if (sequence.length == zero.length && (zero - sequence).isEmpty) {
        return '0';
      } else if (sequence.length == two.length && (two - sequence).isEmpty) {
        return '2';
      } else if (sequence.length == three.length &&
          (three - sequence).isEmpty) {
        return '3';
      } else if (sequence.length == five.length && (five - sequence).isEmpty) {
        return '5';
      } else if (sequence.length == six.length && (six - sequence).isEmpty) {
        return '6';
      } else if (sequence.length == nine.length && (nine - sequence).isEmpty) {
        return '9';
      } else {
        throw Exception('Unexpected sequence $sequence');
      }
    }

    return int.parse(
        line.second.map((String sequence) => sequenceToDigit(sequence)).join());
  }).sum();
}
