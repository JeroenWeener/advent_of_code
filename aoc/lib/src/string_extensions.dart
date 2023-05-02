import 'package:aoc/src/int_extensions.dart';

extension StringExtension on String {
  String operator &(String other) => this + (other - this);
  String operator |(String other) => where((s) => other.contains(s)).join();
  String operator ^(String other) => (other - this) + (this - other);
  String operator -(String other) => where((s) => !other.contains(s)).join();

  /// Pick single characters between [start] (inclusive) and [end] (exclusive),
  /// skipping [step] characters in between.
  String pick(int start, int end, [int? step]) =>
      range(start, end, step ?? (start < end ? 1 : -1))
          .map((int index) => this[index])
          .join();

  String get first => this[0];
  String get second => this[1];
  String get last => this[length - 1];

  /// Returns a [String] without the first [n] characters.
  String skip(int n) => substring(n);

  /// Returns a [String]s first [n] characters.
  String take(int n) => substring(0, n);

  /// Returns a [String] containing the first character and every [n]th
  /// character thereafter.
  String takeOneEvery(int n) => range(0, length, n).map((s) => this[s]).join();

  /// Performs classic [map] on the characters of the [String].
  Iterable<String> map(String Function(String c) f) =>
      range(0, length).map((int index) => f(this[index]));

  /// Performs classic [every] on the characters of the [String].
  bool every(bool Function(String s) f) =>
      range(0, length).every((int index) => f(this[index]));

  /// Performs classic [any] on the characters of the [String].
  bool any(bool Function(String s) f) =>
      range(0, length).any((int index) => f(this[index]));

  /// Performs classic [where] on the characters of the [String].
  Iterable<String> where(bool Function(String s) f) => range(0, length)
      .map((int index) => this[index])
      .where((String character) => f(character));

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
}
