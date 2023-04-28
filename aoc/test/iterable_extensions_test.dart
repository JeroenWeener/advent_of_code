import 'package:aoc/aoc.dart';
import 'package:test/test.dart';

void main() {
  group('Iterable<T extends num>', () {
    group('diff()', () {
      test('returns differences', () {
        final Iterable<int> iterable = [1, 2, 4, 7, 11, 6, 0];

        final Iterable<int> actual = iterable.diff();

        expect(actual.toList(), [1, 2, 3, 4, -5, -6]);
      });

      test('returns an empty iterable if there are no elements', () {
        final Iterable<int> iterable = [];

        final Iterable<int> actual = iterable.diff();

        expect(actual.isEmpty, isTrue);
      });

      test('returns an empty iterable if there is only one element', () {
        final Iterable<int> iterable = [1];

        final Iterable<int> actual = iterable.diff();

        expect(actual.isEmpty, isTrue);
      });
    });

    group('diffAbs()', () {
      test('returns absolute differences', () {
        final Iterable<int> iterable = [1, 2, 4, 7, 11, 6, 0];

        final Iterable<int> actual = iterable.diffAbs();

        expect(actual.toList(), [1, 2, 3, 4, 5, 6]);
      });
    });
  });
}
