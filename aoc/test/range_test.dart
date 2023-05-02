import 'package:aoc/src/int_extensions.dart';
import 'package:test/test.dart';

void main() {
  group('range', () {
    group('returns list of ints', () {
      test('0..n', () {
        final int start = 0;
        final int end = 10;

        final Iterable<int> actual = range(start, end);

        expect(actual.toList(), [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]);
      });

      test('n..k', () {
        final int start = 5;
        final int end = 10;

        final Iterable<int> actual = range(start, end);

        expect(actual.toList(), [5, 6, 7, 8, 9]);
      });

      test('for step', () {
        final int step = 3;

        final Iterable<int> actual = range(0, 10, step);

        expect(actual.toList(), [0, 3, 6, 9]);
      });
    });

    test('works for negative step', () {
      final step = -1;

      final Iterable<int> actual = range(10, 0, step);

      expect(actual.toList(), [10, 9, 8, 7, 6, 5, 4, 3, 2, 1]);
    });

    test('asserts step', () {
      final int step = 0;

      f() => range(1, 2, step);

      expect(f, throwsA(isA<AssertionError>()));
    });
  });
}
