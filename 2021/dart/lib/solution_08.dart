import 'package:aoc/aoc.dart';

void main(List<String> args) async {
  Solver<List<List<List<String>>>, int>(
    part1: part1,
    part2: part2,
    inputTransformer: transformInput,
    testInput: transformInput([
      'be cfbegad cbdgef fgaecd cgeb fdcge agebfd fecdb fabcd edb | fdgacbe cefdb cefbgd gcbe',
      'edbfga begcd cbg gc gcadebf fbgde acbgfd abcde gfcbed gfec | fcgedb cgb dgebacf gc',
      'fgaebd cg bdaec gdafb agbcfd gdcbef bgcad gfac gcb cdgabef | cg cg fdcagb cbg',
      'fbegcd cbd adcefb dageb afcb bc aefdc ecdab fgdeca fcdbega | efabcd cedba gadfec cb',
      'aecbfdg fbg gf bafeg dbefa fcge gcbea fcaegb dgceab fcbdga | gecf egdcabf bgf bfgea',
      'fgeab ca afcebg bdacfeg cfaedg gcfdb baec bfadeg bafgc acf | gebdcfa ecba ca fadegcb',
      'dbcfg fgd bdegcaf fgec aegbdf ecdfab fbedc dacgb gdcebf gf | cefg dcbef fcge gbcadfe',
      'bdfegc cbegaf gecbf dfcage bdacg ed bedf ced adcbefg gebcd | ed bcgafe cdgba cbgef',
      'egadfb cdbfeg cegd fecab cgb gbdefca cg fgcdab egfdb bfceg | gbdfcae bgc cg cgb',
      'gcafb gcf dcaebfg ecagb gf abcdeg gaef cafbge fdbac fegbdc | fgae cfgab fg bagce',
    ]),
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

    final String one = leftSegment.firstWhere((element) => element.length == 2);
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
