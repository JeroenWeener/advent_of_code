import 'function_utils.dart';

extension IntExtension on int {
  /// Executes function [f] n times, returning a [List] of outcomes.
  List<T> times<T>(T Function() f) {
    return fori((_) => f());
  }

  /// Applies function [f] on [value] this [int]'s amount of times, feeding the
  /// output of one iteration to the input of the next iteration.
  ///
  /// See also [FunctionExtension.applyNTimes].
  T iterate<T>(T value, T Function(T) f) {
    return times(() => value = f(value)).last;
  }

  /// Executes function [f] n times, returning a [List] of outcomes.
  ///
  /// Passes in the current iteration as an argument.
  List<T> fori<T>(T Function(int) f) {
    return range().map((int i) => f(i)).toList();
  }

  /// Returns an [Iterable] containing the numbers 0 through this [int].
  Iterable<int> range({
    int? step,
  }) sync* {
    for (int i = 0; i < this; i += (step ?? 1)) {
      yield i;
    }
  }
}
