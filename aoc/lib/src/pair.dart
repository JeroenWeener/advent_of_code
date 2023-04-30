import 'package:aoc/aoc.dart';

class Pair<S, T> {
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
    S left;
    switch (S) {
      case int:
        left = int.parse(l.first) as S;
        break;
      case double:
        left = double.parse(l.first) as S;
        break;
      default:
        left = l.first;
    }

    T right;
    switch (T) {
      case int:
        right = int.parse(l.second) as T;
        break;
      case double:
        right = double.parse(l.second) as T;
        break;
      default:
        right = l.second;
    }

    return Pair(left, right);
  }

  final S left;
  final T right;

  /// Shorthand for [left].
  S get l => left;

  /// Shorthand for [right].
  T get r => right;

  @override
  int get hashCode => Object.hash(left, right);

  @override
  operator ==(Object other) {
    return other is Pair && left == other.left && right == other.right;
  }

  @override
  String toString() {
    return '<$l, $r>';
  }
}
