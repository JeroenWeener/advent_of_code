import 'package:aoc/aoc.dart';

extension IterableExtension<T> on Iterable<T> {
  /// Convience getter for accessing the second element in an [Iterable].
  T get second => elementAt(1);

  /// Zips this with [other].
  ///
  /// Returns an iterable containing [Pair]s, where the left element is from
  /// this and the right element is from [other].
  ///
  /// The resulting iterable will have the same length as the shortest iterable
  /// of the two. Values of the longer iterable that are 'alone' are dropped.
  Iterable<Pair<T, R>> zip<R>(Iterable<R> other) sync* {
    final iteratorA = iterator;
    final iteratorB = other.iterator;

    while (iteratorA.moveNext() && iteratorB.moveNext()) {
      yield Pair(iteratorA.current, iteratorB.current);
    }
  }

  /// Shorthand for [slidingWindow].
  Iterable<List<T>> sw(int windowSize) => slidingWindow(windowSize);

  /// Returns a sliding window for a window of size [windowSize].
  ///
  /// [windowSize] should be [1..length].
  Iterable<List<T>> slidingWindow(int windowSize) sync* {
    assert(
        windowSize <= length, 'window size is larger than number of elements');
    assert(windowSize > 0, 'window size should be at least 1');

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

extension NumberIterableExtension<T extends num> on Iterable<T> {
  /// Scales all elements in this with [factor].
  Iterable<num> operator *(int factor) {
    return map((T e) => e * factor);
  }

  /// Scales elements in this with elements in [other].
  Iterable<num> multiply(Iterable<num> other) {
    assert(other.length >= length, 'Error: not enough elements to multiply');
    return zip(other).map((Pair<T, num> e) => e.l * e.r);
  }

  /// Returns the lowest value in this.
  T min() {
    return reduce((T a, T b) => a < b ? a : b);
  }

  /// Returns the highest value in this.
  T max() {
    return reduce((T a, T b) => a > b ? a : b);
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
    return diff().map((T e) => e.abs() as T);
  }
}
