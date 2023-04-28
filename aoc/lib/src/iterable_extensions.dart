import 'package:aoc/aoc.dart';

extension IterableExtension<T> on Iterable<T> {
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
