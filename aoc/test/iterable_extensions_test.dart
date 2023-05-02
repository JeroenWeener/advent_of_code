import 'package:aoc/src/grid.dart';
import 'package:aoc/src/iterable_extensions.dart';
import 'package:aoc/src/pair.dart';
import 'package:aoc/src/point.dart';
import 'package:test/test.dart';

void main() {
  group('Iterable<T>', () {
    group('count', () {
      test('counts correctly', () {
        final Iterable<int> iterable = [1, 2, 2, 3, 3, 3];

        final Iterable<Pair<int, int>> actual = iterable.counts();

        expect(actual, [
          Pair(1, 1),
          Pair(2, 2),
          Pair(3, 3),
        ]);
      });
    });

    group('zip', () {
      test('returns a zipped iterable', () {
        final Iterable<int> iterableA = [1, 2, 3];
        final Iterable<String> iterableB = ['1', '2', '3'];

        final Iterable<Pair<int, String>> actual = iterableA.zip(iterableB);

        expect(actual.toList(), [
          Pair(1, '1'),
          Pair(2, '2'),
          Pair(3, '3'),
        ]);
      });

      test('ignores exceeding elements', () {
        final Iterable<int> iterableA = [1, 2, 3];
        final Iterable<int> iterableB = [1, 2, 3, 4];

        final Iterable<Pair<int, int>> actual = iterableA.zip(iterableB);

        expect(actual.toList(), [
          Pair(1, 1),
          Pair(2, 2),
          Pair(3, 3),
        ]);
      });
    });

    group('sw', () {
      test('returns a sliding window', () {
        final Iterable<int> iterable = [1, 2, 3, 4, 5, 6, 7, 8, 9];

        final Iterable<List<int>> actual = iterable.sw(3);

        expect(actual, [
          [1, 2, 3],
          [2, 3, 4],
          [3, 4, 5],
          [4, 5, 6],
          [5, 6, 7],
          [6, 7, 8],
          [7, 8, 9],
        ]);
      });

      test('asserts if window size is too large', () {
        final Iterable iterable = [1, 2, 3];

        expect(() => iterable.sw(4), throwsA(isA<AssertionError>()));
      });
    });
  });

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

  group('Iterable<String>', () {
    group('toGrid', () {
      test('correctly parses grid', () {
        final Iterable<String> iterable = [
          'abc',
          'def',
          'ghi',
        ];

        final Grid<String> actual = iterable.toGrid();

        expect(
          actual.entries.map((e) => e.toPair()).toList(),
          [
            Pair(Point2(0, 0), 'a'),
            Pair(Point2(1, 0), 'b'),
            Pair(Point2(2, 0), 'c'),
            Pair(Point2(0, 1), 'd'),
            Pair(Point2(1, 1), 'e'),
            Pair(Point2(2, 1), 'f'),
            Pair(Point2(0, 2), 'g'),
            Pair(Point2(1, 2), 'h'),
            Pair(Point2(2, 2), 'i'),
          ],
        );
      });

      test('leaves out space characters', () {
        final Iterable<String> iterable = [
          'ab ',
          'd f',
          ' hi',
        ];

        final Grid<String> actual = iterable.toGrid();

        expect(actual.entries.map((e) => e.toPair()).toList(), [
          Pair(Point2(0, 0), 'a'),
          Pair(Point2(1, 0), 'b'),
          Pair(Point2(0, 1), 'd'),
          Pair(Point2(2, 1), 'f'),
          Pair(Point2(1, 2), 'h'),
          Pair(Point2(2, 2), 'i'),
        ]);
      });

      test('handles unequal line lengths', () {
        final Iterable<String> iterable = [
          'abc',
          'de',
          'g',
        ];

        final Grid<String> actual = iterable.toGrid();

        expect(actual.entries.map((e) => e.toPair()).toList(), [
          Pair(Point2(0, 0), 'a'),
          Pair(Point2(1, 0), 'b'),
          Pair(Point2(2, 0), 'c'),
          Pair(Point2(0, 1), 'd'),
          Pair(Point2(1, 1), 'e'),
          Pair(Point2(0, 2), 'g'),
        ]);
      });
    });

    group('splitOnEmptyLine', () {
      test('splits on empty line', () {
        final Iterable<String> iterable = ['this', 'is', '', 'a', 'test'];

        final Iterable<Iterable<String>> actual = iterable.splitOnEmptyLine();

        expect(actual.toList(), [
          ['this', 'is'],
          ['a', 'test'],
        ]);
      });
    });
  });

  group('Iterable<Iterable<T>>', () {
    group('toGrid', () {
      test('correctly parses grid', () {
        final Iterable<Iterable<int>> iterable = [
          [1, 2, 3],
          [4, 5, 6],
          [7, 8, 9],
        ];

        final Grid<int> actual = iterable.toGrid();

        expect(
          actual.entries.map((e) => e.toPair()).toList(),
          [
            Pair(Point2(0, 0), 1),
            Pair(Point2(1, 0), 2),
            Pair(Point2(2, 0), 3),
            Pair(Point2(0, 1), 4),
            Pair(Point2(1, 1), 5),
            Pair(Point2(2, 1), 6),
            Pair(Point2(0, 2), 7),
            Pair(Point2(1, 2), 8),
            Pair(Point2(2, 2), 9),
          ],
        );
      });

      test('handles unequal iterable lengths', () {
        final Iterable<Iterable<int>> iterable = [
          [1, 2, 3],
          [4, 5],
          [7],
        ];

        final Grid<int> actual = iterable.toGrid();

        expect(actual.entries.map((e) => e.toPair()).toList(), [
          Pair(Point2(0, 0), 1),
          Pair(Point2(1, 0), 2),
          Pair(Point2(2, 0), 3),
          Pair(Point2(0, 1), 4),
          Pair(Point2(1, 1), 5),
          Pair(Point2(0, 2), 7),
        ]);
      });
    });

    group('transpose', () {
      test('transposes the iterable', () {
        final Iterable<Iterable<int>> iterable = [
          [1, 2, 3],
          [4, 5, 6],
        ];

        final Iterable<Iterable<int>> actual = iterable.transpose();

        expect(actual, [
          [1, 4],
          [2, 5],
          [3, 6],
        ]);
      });
    });

    group('flatten', () {
      test('flattens iterable of iterables', () {
        final Iterable<Iterable<int>> iterable = [
          [1, 2],
          [3, 4, 5],
        ];

        final Iterable<int> actual = iterable.flatten();

        expect(actual, [1, 2, 3, 4, 5]);
      });
    });
  });
}
