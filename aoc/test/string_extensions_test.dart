import 'package:aoc/aoc.dart';
import 'package:test/test.dart';

void main() {
  group('extractInts', () {
    test('extracts ints correctly', () {
      final String s = ' a1b23 c 456 ';

      final List<int> actual = s.extractInts();

      expect(actual, [1, 23, 456]);
    });
  });
}
