extension BoolExtension on bool {
  /// Transforms this [bool] to 1 if true and 0 if false.
  int get i01 => this ? 1 : 0;

  /// Transfors this [bool] to 1 if true and -1 if false.
  int get i11 => this ? 1 : -1;

  /// Convenience getter for negating this.
  ///
  /// This escapes having to use parentheses when chaining methods on a [bool].
  /// For example:
  ///
  /// ```dart
  /// bool b = true;
  /// int i = b.not.i();
  /// ```
  ///
  /// instead of:
  ///
  /// ```dart
  /// bool b = true;
  /// int i = (!b).i();
  /// ```
  bool get not => !this;
}
