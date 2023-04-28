import 'package:aoc/aoc.dart';

extension IterableExtension<T> on Iterable<T> {
  /// Zips this with [other].
  ///
  /// Returns an iterable containing lists, where the first element is from this
  /// and the second element is from [other].
  ///
  /// The resulting iterable will have the same length as the shortest iterable
  /// of the two. Values of the longer iterable that are 'alone' are dropped.
  Iterable<List<dynamic>> zip<R>(Iterable<R> other) sync* {
    final iteratorA = iterator;
    final iteratorB = other.iterator;

    while (iteratorA.moveNext() && iteratorB.moveNext()) {
      yield [iteratorA.current, iteratorB.current];
    }
  }

  /// Returns a sliding window for a window of size [windowSize].
  ///
  /// Throws an [Exception] if [windowSize] is larger than [length].
  Iterable<List<T>> sw(int windowSize) sync* {
    if (windowSize > length) {
      throw Exception('`windowSize` is larger than number of elements');
    }

    List<T> window = [];

    final Iterator valueIterator = iterator;

    windowSize.times(() {
      valueIterator.moveNext();
      window.add(valueIterator.current);
    });

    yield window;

    while (valueIterator.moveNext()) {
      window.removeAt(0);
      window.add(valueIterator.current);

      yield window;
    }
  }
}

extension IterableNumberExtension<T extends num> on Iterable<T> {
  /// Returns the lowest value in this.
  T min() {
    return reduce((T a, T b) => a < b ? a : b);
  }

  /// Returns the highest value in this.
  T max() {
    return reduce((T a, T b) => a > b ? a : b);
  }

  /// Quick access to the second value of this.
  T second() {
    return elementAt(2);
  }

  /// Returns the sum of the values in this.
  T sum() {
    return reduce((T a, T b) => a + b as T);
  }

  /// Returns an [Iterable] emitting the differences between the values in this.
  ///
  /// If there is less than 2 elements, the resulting iterable will not emit
  /// anything.
  Iterable<T> diff() sync* {
    if (length < 2) return;

    final Iterator valueIterator = iterator;

    valueIterator.moveNext();
    T value = valueIterator.current;

    while (valueIterator.moveNext()) {
      final T current = valueIterator.current;
      yield current - value as T;
      value = current;
    }
  }

  /// Sames as [diff], but returns the differences as absolute values.
  Iterable<T> diffAbs() {
    return diff().map((e) => e.abs() as T);
  }
}
