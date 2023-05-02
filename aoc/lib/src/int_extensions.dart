import 'function_utils.dart';

extension IntExtension on int {
  /// Shorthand for [fibonacci].
  int fib() => fibonacci();

  /// Calculates the nth fibonacci number.
  ///
  /// fib(1) = 1
  /// fib(2) = 1
  /// fib(n) = fib(n-1) + fib(n-2)
  int fibonacci() {
    assert(this > 0);
    return this <= 2 ? 1 : (this - 1).fib() + (this - 2).fib();
  }

  /// Calculates the nth triangular number.
  ///
  /// t(0) = 0
  /// t(1) = 1
  /// t(2) = 3
  /// t(3) = 6
  /// t(n) = n*(n+1)/2
  int triangular() {
    assert(this >= 0);
    return (this * (this + 1)) >> 1;
  }

  /// Shorthand for [factorial].
  int fac() => factorial();

  /// Calculates the factorial of this [int].
  ///
  /// fac(0) = 1
  /// fac(1) = 1
  /// fac(2) = 2
  /// fac(3) = 6
  /// fac(n) = n * fac(n-1)
  int factorial() {
    assert(this >= 0);
    return this <= 1 ? 1 : this * (this - 1).fac();
  }

  /// Executes function [f] n times, returning a [List] of outcomes.
  List<T> times<T>(T Function() f) => fori((_) => f());

  /// Applies function [f] on [value] this [int]'s amount of times, feeding the
  /// output of one iteration to the input of the next iteration.
  ///
  /// See also [FunctionExtension.applyNTimes].
  T iterate<T>(T value, T Function(T) f) => times(() => value = f(value)).last;

  /// Executes function [f] n times, returning a [List] of outcomes.
  ///
  /// Passes in the current iteration as an argument.
  List<T> fori<T>(T Function(int i) f) =>
      range(0, this).map((int i) => f(i)).toList();
}

/// Generates an [Iterable] of [int]s start with [start] (inclusive), increasing
/// by [step] until [end] (exclusive).
Iterable<int> range(int start, int end, [int? step]) sync* {
  assert(step != 0);

  step ??= start < end ? 1 : -1;

  int i = start;
  while (step > 0 ? i < end : i > end) {
    yield i;
    i += step;
  }
}
