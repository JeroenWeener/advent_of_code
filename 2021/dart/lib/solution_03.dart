import 'package:aoc/aoc.dart';

void main(List<String> args) async {
  Solver<List<String>, int>(
    part1: part1,
    part2: part2,
    testInput: [
      '00100',
      '11110',
      '10110',
      '10111',
      '10101',
      '01111',
      '00111',
      '11100',
      '10000',
      '11001',
      '00010',
      '01010',
    ],
    testOutput1: 198,
    testOutput2: 230,
  ).execute();
}

int part1(List<String> input) {
  final String gamma = input.transpose().map((String row) {
    final int zeros = row.where((String s) => s == '0').length;
    final int ones = row.length - zeros;
    return (zeros < ones).i01;
  }).join();
  final String epsilon =
      gamma.replaceAll('0', '2').replaceAll('1', '0').replaceAll('2', '1');
  return gamma.b2i() * epsilon.b2i();
}

int part2(List<String> input) {
  Iterable<String> ogrCandidates = input.toList();
  Iterable<String> csrCandidates = input.toList();

  for (int i = 0; i < input.first.length; i++) {
    if (ogrCandidates.length > 1) {
      final String row = ogrCandidates.map((String c) => c[i]).join();
      final int zeros = row.where((String bit) => bit == '0').length;
      final int ones = row.length - zeros;
      final String mcb = (zeros <= ones).i01.toString();
      ogrCandidates = ogrCandidates.where((String c) => c[i] == mcb);
    }

    if (csrCandidates.length > 1) {
      final String row = csrCandidates.map((String c) => c[i]).join();
      final int zeros = row.where((String bit) => bit == '0').length;
      final int ones = row.length - zeros;
      final String mcb = (zeros > ones).i01.toString();
      csrCandidates = csrCandidates.where((String c) => c[i] == mcb);
    }

    if (ogrCandidates.length == 1 && csrCandidates.length == 1) {
      return ogrCandidates.first.b2i() * csrCandidates.first.b2i();
    }
  }
  return -1;
}
