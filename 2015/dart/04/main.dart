import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart' as crypto;
import 'package:convert/convert.dart';

void main() {
  final String input = File('input.txt').readAsStringSync();

  final int answer1 = part1(input);
  print(answer1);

  final int answer2 = part2(input);
  print(answer2);
}

/// Calculate the MD5 hash of the provided [String].
String md5(String data) {
  final content = Utf8Encoder().convert(data);
  final md5 = crypto.md5;
  final digest = md5.convert(content);
  return hex.encode(digest.bytes);
}

/// --- Day 4: The Ideal Stocking Stuffer ---
///
/// Santa needs help mining some AdventCoins (very similar to bitcoins) to use
/// as gifts for all the economically forward-thinking little girls and boys.
///
/// To do this, he needs to find MD5 hashes which, in hexadecimal, start with at
/// least five zeroes. The input to the MD5 hash is some secret key (your puzzle
/// input, given below) followed by a number in decimal. To mine AdventCoins,
/// you must find Santa the lowest positive number (no leading zeroes: 1, 2, 3,
/// ...) that produces such a hash.
///
/// For example:
///
/// - If your secret key is abcdef, the answer is 609043, because the MD5 hash
///   of abcdef609043 starts with five zeroes (000001dbbfa...), and it is the
///   lowest such number to do so.
/// - If your secret key is pqrstuv, the lowest number it combines with to make
///   an MD5 hash starting with five zeroes is 1048970; that is, the MD5 hash of
///   pqrstuv1048970 looks like 000006136ef....
int part1(String input) {
  int i = 0;
  while (true) {
    if (md5(input + i.toString()).startsWith('00000')) {
      return i;
    }
    i++;
  }
}

/// --- Part Two ---
///
/// Now find one that starts with six zeroes.
int part2(String input) {
  int i = 0;
  while (true) {
    if (md5(input + i.toString()).startsWith('000000')) {
      return i;
    }
    i++;
  }
}
