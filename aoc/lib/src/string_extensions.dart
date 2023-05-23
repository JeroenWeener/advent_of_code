import 'package:aoc/src/int_extensions.dart';

extension StringExtension on String {
  String operator &(String other) => this + (other - this);
  String operator |(String other) =>
      toIterable().where((s) => other.contains(s)).join();
  String operator ^(String other) => (other - this) + (this - other);
  String operator -(String other) =>
      toIterable().where((s) => !other.contains(s)).join();

  /// Returns all unique elements paired with the number of occurences they have
  /// in this [Iterable].
  Map<String, int> counts() {
    final Map<String, int> counts = {};
    for (int i = 0; i < length; i++) {
      final String element = this[i];
      final int? count = counts[element];
      counts[element] = count == null ? 1 : count + 1;
    }
    return counts;
  }

  String replaceLast(Pattern from, String to, [int startIndex = 0]) {
    int lastIndex = lastIndexOf(from);
    return replaceFirst(from, to, lastIndex);
  }

  /// Picks single characters between [start] (inclusive) and [end] (exclusive),
  /// skipping [step] characters in between.
  String pick(int start, [int? end, int? step]) =>
      range(start, end ?? length, step ?? (start < (end ?? length) ? 1 : -1))
          .map((int index) => this[index])
          .join();

  String get first => this[0];
  String get second => this[1];
  String get third => this[2];
  String get last => this[length - 1];

  /// Returns a [String] without the first [n] characters.
  String skip(int n) => substring(n);

  /// Returns a [String]s first [n] characters.
  String take(int n) => substring(0, n);

  /// Returns a [String] containing the first character and every [n]th
  /// character thereafter.
  String takeOneEvery(int n) => range(0, length, n).map((s) => this[s]).join();

  String insert(String s, int index) => take(index) + s + skip(index);

  /// Shorthand for [binaryToInt].
  int b2i() => binaryToInt();

  /// Transforms a [String] representation of a binary number to an [int].
  int binaryToInt() => int.parse(this, radix: 2);

  /// Shorthand for [splitWhitespace].
  List<String> splitWs() => splitWhitespace();

  /// Splits a string on white spaces.
  ///
  /// Deals with preceding and trailing whitespaces.
  List<String> splitWhitespace() => trim().split(RegExp(r'\s+'));

  /// Returns a [List] containing the [int]s that were found in this [String].
  ///
  /// [int]s appear in order of appearance in the string.
  List<int> extractInts() => replaceAll(RegExp(r'[^\d+]'), ' ')
      .splitWhitespace()
      .map((String integerString) => int.parse(integerString))
      .toList();

  /// Returns an [Iterable] containing the characters in the [String] as
  /// separate [String]s.
  Iterable<String> toIterable() sync* {
    for (int charIndex = 0; charIndex < length; charIndex++) {
      yield this[charIndex];
    }
  }
}
