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

  /// Shorthand for [splitWhitespace].
  List<String> splitWs() {
    return splitWhitespace();
  }

  /// Splits a string on white spaces.
  ///
  /// Deals with preceding and trailing whitespaces.
  List<String> splitWhitespace() {
    return trim().split(RegExp(r'\s+'));
  }

  /// Returns a [List] containing the [int]s that were found in this [String].
  ///
  /// [int]s appear in order of appearance in the string.
  List<int> extractInts() {
    return replaceAll(RegExp(r'[^\d+]'), ' ')
        .splitWhitespace()
        .map((String e) => int.parse(e))
        .toList();
  }
}
