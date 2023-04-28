extension IntExtension on int {
  /// Executes function [f] n times, where n is this.
  void times(Function f) {
    fori((_) => f);
  }

  /// Executes function [f] n times, passing in the current iteration as an
  /// argument.
  void fori(Function(int) f) {
    range().map((int i) => f(i));
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
