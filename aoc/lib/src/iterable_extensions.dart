import 'package:aoc/aoc.dart';

extension IterableExtension<T> on Iterable<T> {
  /// Returns all unique elements paired with the number of occurences they have
  /// in this [Iterable].
  Iterable<Pair<T, int>> counts() {
    final Map<T, int> counts = {};
    final Iterator elementIterator = iterator;
    while (elementIterator.moveNext()) {
      final T element = elementIterator.current;
      final int? count = counts[element];
      counts[element] = count == null ? 1 : count + 1;
    }

    return counts.entries
        .map((MapEntry<T, int> entry) => Pair(entry.key, entry.value));
  }

  /// Convience getter for accessing the second element in an [Iterable].
  T get second => elementAt(1);

  /// Implementation of [map] that passes both the iteration and the element to
  /// the provided function [f].
  Iterable<R> mapI<R>(R Function(int, T) f) {
    return zip(length.range()).map((Pair<T, int> e) => f(e.r, e.l));
  }

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

extension StringIterableExtensions on Iterable<String> {
  /// Transposes characters as if they were in a matrix.
  ///
  /// Example:
  ///
  /// ```dart
  /// List<String> m = [
  ///   'abc',
  ///   'def',
  ///   'ghi',
  /// ];
  ///
  /// List<String> t = m.transpose();
  ///
  /// print(t);
  ///
  /// ---
  ///
  /// [
  ///   'adg',
  ///   'beh',
  ///   'cfi',
  /// ]
  /// ```
  Iterable<String> transpose() {
    assert(skip(1).every((e) => e.length == first.length),
        'Strings are not of same length');

    return first.length.fori((int i) => map((String s) => s[i]).join());
  }

  /// Splits this iterable into multiple iterables, splitting on empty strings.
  Iterable<List<String>> splitOnEmptyLine() sync* {
    final Iterator iterableIterator = iterator;
    List<String> nextList = [];

    while (iterableIterator.moveNext()) {
      final String line = iterableIterator.current;

      if (line.isEmpty) {
        yield nextList;
        nextList = [];
      } else {
        nextList.add(line);
      }
    }

    if (nextList.isNotEmpty) {
      yield nextList;
    }
  }
}

extension IterableIterableExtensions<T> on Iterable<Iterable<T>> {
  /// Transpose elements as if they were in a matrix.
  Iterable<Iterable<T>> transpose() {
    assert(skip(1).every((e) => e.length == first.length),
        'Iterables are not of same length');

    return first.length.fori((int i) => map(
          (Iterable<T> innerIterable) => innerIterable.elementAt(i),
        ));
  }

  /// Flattens the iterable of iterables into a single iterable.
  Iterable<T> flatten() {
    return expand((Iterable<T> innerIterable) => innerIterable);
  }
}
