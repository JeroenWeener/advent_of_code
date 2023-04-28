
extension IntExtension on int {
  /// Executes function [f] n times, where n is this.
  void times(Function f) {
    for (int i = 0; i < this; i++) {
      f();
    }
  }
}
