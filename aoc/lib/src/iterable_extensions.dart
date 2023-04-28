extension IterableExtension on Iterable {}

extension IterableNumberExtension<T extends num> on Iterable<T> {
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

  Iterable<T> diffAbs() {
    return diff().map((e) => e.abs() as T);
  }
}
