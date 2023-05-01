import 'package:aoc/aoc.dart';

class Pair<L, R> {
  const Pair(this.left, this.right);

  /// Creates a [Pair] for list [l].
  ///
  /// For every element in [l], the first element is used as [left] and the
  /// second element is used as [right].
  ///
  /// If a value in [l] is of type [String], but the provided type is [int] or
  /// [double], the value is automatically cast. For example:
  ///
  /// ```dart
  /// Pair<String, int> pair = Pair<String, int>.fromList('up 8'.split(' '));
  /// ```
  factory Pair.fromList(List l) {
    L left;
    switch (L) {
      case int:
        left = int.parse(l.first) as L;
        break;
      case double:
        left = double.parse(l.first) as L;
        break;
      default:
        left = l.first;
    }

    R right;
    switch (R) {
      case int:
        right = int.parse(l.second) as R;
        break;
      case double:
        right = double.parse(l.second) as R;
        break;
      default:
        right = l.second;
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
