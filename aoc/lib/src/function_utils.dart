import 'package:aoc/src/int_extensions.dart';

extension FunctionExtension<T> on T Function(T) {
  /// Applies this [Function] on [value] for [n] iterations, feeding the output
  /// of one iteration to the input of the next iteration.
  ///
  /// See also [IntExtension.iterate].
  T applyNTimes(T value, int n) {
    return n.iterate(value, this);
  }
}
