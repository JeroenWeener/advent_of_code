extension IntExtension on int {
  /// Executes function [f] n times, returning a [List] of outcomes.
  List<T> times<T>(T Function() f) {
    return fori((_) => f());
  }

  /// Executes function [f] n times, returning a [List] of outcomes.
  ///
  /// Passes in the current iteration as an argument.
  List<T> fori<T>(T Function(int) f) {
    return range().map((int i) => f(i)).toList();
  }

  /// Returns an [Iterable] containing the numbers 0 through this.
  Iterable<int> range({
    int? step,
  }) sync* {
    for (int i = 0; i < this; i += (step ?? 1)) {
      yield i;
    }
  }
}
