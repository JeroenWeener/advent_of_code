import 'package:aoc/aoc.dart';

void main(List<String> args) {
  Solver<Pair<String, Map<String, String>>, int>(
    inputTransformer: transformInput,
    part1: part1,
    testOutput1: 1588,
  ).execute();
}

Pair<String, Map<String, String>> transformInput(List<String> input) {
  String template = input.first;
  Map<String, String> instructions =
      Map.fromEntries(input.skip(2).map((String line) {
    List<String> x = line.split(' -> ');
    return MapEntry(x[0], x[1]);
  }).toList());
  return Pair(template, instructions);
}

int part1(Pair<String, Map<String, String>> input) {
  String insert(String sequence) {
    for (int i = sequence.length - 1; i >= 1; i--) {
      String pair = sequence[i - 1] + sequence[i];
      String c = input.r[pair]!;
      sequence = sequence.insert(c, i);
    }
    return sequence;
  }

  String sequence = input.l;
  for (int i = 0; i < 10; i++) {
    sequence = insert(sequence);
  }

  List<Pair<String, int>> counts = sequence.counts().toList()
    ..sort((a, b) => a.r - b.r);
  return counts.last.r - counts.first.r;
}
