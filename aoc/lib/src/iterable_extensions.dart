import 'package:aoc/aoc.dart';

extension IterableExtension<E> on Iterable<E> {
  /// Prints elements emitted by the [Iterable] and re-emits them.
  ///
  /// Optionally, a function [f] can be passed that dictates what should be
  /// printed exactly.
  Iterable<E> mapPrint([Function(E element)? f]) {
    return map((E e) {
      print(f == null ? e : f(e));
      return e;
    });
  }

  Iterable<E> printLength() {
    print(length);
    return this;
  }

  /// Returns all unique elements paired with the number of occurences they have
  /// in this [Iterable].
  Iterable<Pair<E, int>> counts() {
    final Map<E, int> counts = {};
    final Iterator elementIterator = iterator;
    while (elementIterator.moveNext()) {
      final E element = elementIterator.current;
      final int? count = counts[element];
      counts[element] = count == null ? 1 : count + 1;
    }

    return counts.entries
        .map((MapEntry<E, int> entry) => Pair(entry.key, entry.value));
  }

  /// Convenience getter for accessing the second element in an [Iterable].
  E get second => elementAt(1);

  /// Convenience getter for accessing the middle element in an [Iterable].
  ///
  /// Asserts whether the iterable has an uneven number of elements.
  E get middle {
    assert(
      length % 2 == 1,
      'Cannot get middle element of iterable with an even number of elements',
    );
    return elementAt(length ~/ 2);
  }

  /// Implementation of [map] that passes both the iteration and the element to
  /// the provided function [f].
  Iterable<R> mapI<R>(R Function(int index, E element) f) =>
      zip(range(0, length)).map((Pair<E, int> e) => f(e.r, e.l));

  /// Zips this with [other].
  ///
  /// Returns an iterable containing [Pair]s, where the left element is from
  /// this and the right element is from [other].
  ///
  /// The resulting iterable will have the same length as the shortest iterable
  /// of the two. Values of the longer iterable that are 'alone' are dropped.
  Iterable<Pair<E, R>> zip<R>(Iterable<R> other) sync* {
    final iteratorA = iterator;
    final iteratorB = other.iterator;

    while (iteratorA.moveNext() && iteratorB.moveNext()) {
      yield Pair(iteratorA.current, iteratorB.current);
    }
  }

  /// Shorthand for [slidingWindow].
  Iterable<List<E>> sw(int windowSize) => slidingWindow(windowSize);

  /// Returns a sliding window for a window of size [windowSize].
  ///
  /// [windowSize] should be [1..length].
  Iterable<List<E>> slidingWindow(int windowSize) sync* {
    assert(
        windowSize <= length, 'Window size is larger than number of elements');
    assert(windowSize > 0, 'Window size should be at least 1');

    List<E> window = [];
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

extension NumberIterableExtension<E extends num> on Iterable<E> {
  /// Scales all elements in this with [factor].
  Iterable<num> operator *(int factor) => map((E e) => e * factor);

  /// Scales elements in this with elements in [other].
  Iterable<num> multiply(Iterable<num> other) {
    assert(other.length >= length, 'Not enough elements to multiply');
    return zip(other).map((Pair<E, num> e) => e.l * e.r);
  }

  /// Returns the lowest value in this.
  E min() => reduce((E a, E b) => a < b ? a : b);

  /// Returns the highest value in this.
  E max() => reduce((E a, E b) => a > b ? a : b);

  /// Returns the sum of the values in this.
  E sum() => length == 0 ? 0 as E : reduce((E a, E b) => a + b as E);

  /// Returns the product of the values in this.
  E product() => reduce((E a, E b) => (a * b) as E);

  /// Returns an [Iterable] emitting the differences between the values in this.
  ///
  /// If there is less than 2 elements, the resulting iterable will not emit
  /// anything.
  Iterable<E> diff() sync* {
    if (length < 2) return;

    final Iterator valueIterator = iterator;

    valueIterator.moveNext();
    E value = valueIterator.current;

    while (valueIterator.moveNext()) {
      final E current = valueIterator.current;
      yield current - value as E;
      value = current;
    }
  }

  /// Sames as [diff], but returns the differences as absolute values.
  Iterable<E> diffAbs() => diff().map((E e) => e.abs() as E);
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

  /// Concatenates all elements.
  String asString() => join('');

  /// Transforms this [Iterable] of [String]s to a [UnboundGrid].
  ///
  /// Each [String] is a row. The characters of the [String] are the elements in
  /// the row.
  UnboundGrid toUnboundGrid() =>
      map((String line) => line.toIterable().toList()).toList().toUnboundGrid();

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

extension IterableIterableExtensions<E> on Iterable<Iterable<E>> {
  /// Parses this [Iterable] of [Iterable]s to an [UnboundGrid].
  ///
  /// The outer [Iterable] specifies the row, while inner [Iterable]s specify
  /// column.
  UnboundGrid<E> toUnboundGrid() {
    return UnboundGrid.fromEntries(
      mapI(
        (int y, Iterable<E> innerIterable) => innerIterable.mapI(
          (int x, E element) => UnboundGridItem<E>(Point2(x, y), element),
        ),
      ).flatten(),
    );
  }

  /// Transpose elements as if they were in a matrix.
  Iterable<Iterable<E>> transpose() {
    assert(skip(1).every((e) => e.length == first.length),
        'Iterables are not of same length');

    return first.length.fori((int i) => map(
          (Iterable<E> innerIterable) => innerIterable.elementAt(i),
        ));
  }

  /// Flattens the iterable of iterables into a single iterable.
  Iterable<E> flatten() => expand((Iterable<E> innerIterable) => innerIterable);
}
