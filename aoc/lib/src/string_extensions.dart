extension StringExtension on String {
  /// Performs classic [where] on the characters of the [String].
  Iterable<String> where(bool Function(String s) f) sync* {
    for (int i = 0; i < length; i++) {
      String c = this[i];
      if (f(c)) {
        yield c;
      }
    }
  }

  /// Shorthand for [binaryToInt].
  int b2i() {
    return binaryToInt();
  }

  /// Transforms a [String] representation of a binary number to an [int].
  int binaryToInt() {
    return int.parse(this, radix: 2);
  }
}
