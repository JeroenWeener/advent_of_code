import 'package:aoc/aoc.dart';

class Pair<L, R> {
  const Pair(this.left, this.right);

  /// Creates a [Pair] for iterable [it].
  ///
  /// For every element in [it], the first element is used as [left] and the
  /// second element is used as [right].
  ///
  /// If a value in [it] is of type [String], but the provided type is [int] or
  /// [double], the value is automatically cast. For example:
  ///
  /// ```dart
  /// Pair<String, int> pair = Pair<String, int>.fromIterable('up 8'.split(' '));
  /// ```
  factory Pair.fromIterable(Iterable it) {
    L left;
    switch (L) {
      case int:
        left = int.parse(it.first) as L;
        break;
      case double:
        left = double.parse(it.first) as L;
        break;
      default:
        left = it.first;
    }

    R right;
    switch (R) {
      case int:
        right = int.parse(it.second) as R;
        break;
      case double:
        right = double.parse(it.second) as R;
        break;
      default:
        right = it.second;
    }

    return Pair(left, right);
  }

  final L left;
  final R right;

  /// Shorthand for [left].
  L get l => left;

  /// Shorthand for [right].
  R get r => right;

  Pair<R, L> get flip => Pair(r, l);

  @override
  int get hashCode => Object.hash(left, right);

  @override
  bool operator ==(Object other) {
    return other is Pair<L, R> && left == other.left && right == other.right;
  }

  @override
  String toString() {
    return '<$l, $r>';
  }
}

extension IntIntPairExtension on Pair<int, int> {
  /// Returns a [List] of [int]s, starting a [l], increasing with [step] until
  /// [r].
  Iterable<int> range({int step = 1}) {
    assert(l < r);
    assert(step >= 1);

    return (r - l).range(step: 1).map((int e) => e + l);
  }
}
