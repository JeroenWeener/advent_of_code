import 'package:aoc/aoc.dart';
import 'package:test/test.dart';

void main() {
  group('triangular', () {
    test('works for n > 0', () {
      final int n = 5;

      final int actual = n.triangular();

      expect(actual, 15);
    });

    test('works for n = 0', () {
      final int n = 0;

      final int actual = n.triangular();

      expect(actual, 0);
    });

    test('asserts for n < 0', () {
      final int n = -1;

      f() => n.triangular();

      expect(f, throwsA(isA<AssertionError>()));
    });
  });

  group('fibonacci', () {
    test('works for n > 0', () {
      final int n = 5;

      final int actual = n.fibonacci();

      expect(actual, 5);
    });

    test('asserts for n = 0', () {
      final int n = 0;

      f() => n.fibonacci();

      expect(f, throwsA(isA<AssertionError>()));
    });

    test('asserts for n < 0', () {
      final int n = -1;

      f() => n.fibonacci();

      expect(f, throwsA(isA<AssertionError>()));
    });
  });

  group('factorial', () {
    test('works for n > 0', () {
      final int n = 5;

      final int actual = n.factorial();

      expect(actual, 120);
    });

    test('works for n = 0', () {
      final int n = 0;

      final int actual = n.factorial();

      expect(actual, 1);
    });

    test('asserts for n < 0', () {
      final int n = -1;

      f() => n.factorial();

      expect(f, throwsA(isA<AssertionError>()));
    });
  });
}
