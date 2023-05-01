import 'function_utils.dart';

extension IntExtension on int {
  /// Shorthand for [fibonacci].
  int fib() => fibonacci();

  /// Calculates the nth fibonacci number.
  ///
  /// fib(0) = 0
  /// fib(1) = 1
  /// fib(n) = fib(n-1) + fib(n-2)
  int fibonacci() {
    return this <= 1 ? this : (this - 1).fib() + (this - 2).fib();
  }

  /// Calculates the nth triangular number.
  ///
  /// t(0) = 0
  /// t(1) = 1
  /// t(2) = 3
  /// t(3) = 6
  /// t(n) = n*(n+1)/2
  int triangular() {
    return (this * (this + 1)) >> 1;
  }

  int fac() => factorial();

  /// Calculates the factorial of this [int].
  ///
  /// fac(0) = 0
  /// fac(1) = 1
  /// fac(2) = 2
  /// fac(3) = 6
  /// fac(n) = n * fac(n-1)
  int factorial() {
    assert(this >= 0);
    return this * (this - 1).fac();
  }

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
    int step = 1,
  }) sync* {
    assert(step >= 1);

    for (int i = 0; i < this; i += step) {
      yield i;
    }
  }
}
