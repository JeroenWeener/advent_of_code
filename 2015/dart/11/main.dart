import 'dart:io';

void main() {
  String input = File('2015/dart/11/input.txt').readAsStringSync();

  String answer1 = part1(input);
  print(answer1);

  String answer2 = part2(input);
  print(answer2);
}

typedef CodeUnit = int;

/// Extension for [CodeUnit].
extension CodeUnitExtensions on CodeUnit {
  /// Get the next [CodeUnit] from [this]. Wraps 'z' to 'a' and ignores 'i', 'l'
  /// and 'o'.
  CodeUnit next() {
    return this == 'h'.codeUnits.first
        ? 'j'.codeUnits.first
        : this == 'k'.codeUnits.first
            ? 'm'.codeUnits.first
            : this == 'n'.codeUnits.first
                ? 'p'.codeUnits.first
                : ((this - 'a'.codeUnits.first + 1) % 26) + 'a'.codeUnits.first;
  }
}

/// Generate the next word based on the current [word].
///
/// By using [CodeUnit.next], we ensure generated words adhere to requirement 2.
List<CodeUnit> nextWord(List<CodeUnit> word) {
  List<CodeUnit> codeUnits = [...word];

  for (int i = codeUnits.length - 1; i > 0; i--) {
    codeUnits[i] = codeUnits[i].next();
    if (codeUnits[i] != 'a'.codeUnits.first) {
      break;
    }
  }

  return codeUnits;
}

bool adheresToReq1(List<CodeUnit> password) {
  for (int passwordIndex = 0;
      passwordIndex < password.length - 2;
      passwordIndex++) {
    // Do not use [CodeUnit.next], as we want to consider all alphabet
    // characters and disregard wrapping.
    if (password[passwordIndex] + 1 == password[passwordIndex + 1] &&
        password[passwordIndex + 1] + 1 == password[passwordIndex + 2]) {
      return true;
    }
  }
  return false;
}

bool adheresToReq3(List<CodeUnit> password) {
  int? usedPair;
  for (int passwordIndex = 0;
      passwordIndex < password.length - 1;
      passwordIndex++) {
    if (password[passwordIndex] == password[passwordIndex + 1] &&
        password[passwordIndex] != usedPair) {
      if (usedPair != null) {
        return true;
      } else {
        usedPair = password[passwordIndex];
      }
    }
  }
  return false;
}

/// --- Day 11: Corporate Policy ---
///
/// Santa's previous password expired, and he needs help choosing a new one.
///
/// To help him remember his new password after the old one expires, Santa has
/// devised a method of coming up with a password based on the previous one.
/// Corporate policy dictates that passwords must be exactly eight lowercase
/// letters (for security reasons), so he finds his new password by incrementing
/// his old password string repeatedly until it is valid.
///
/// Incrementing is just like counting with numbers: xx, xy, xz, ya, yb, and so
/// on. Increase the rightmost letter one step; if it was z, it wraps around to
/// a, and repeat with the next letter to the left until one doesn't wrap
/// around.
///
/// Unfortunately for Santa, a new Security-Elf recently started, and he has
/// imposed some additional password requirements:
///
/// - Passwords must include one increasing straight of at least three letters,
///   like abc, bcd, cde, and so on, up to xyz. They cannot skip letters; abd
///   doesn't count.
/// - Passwords may not contain the letters i, o, or l, as these letters can be
///   mistaken for other characters and are therefore confusing.
/// - Passwords must contain at least two different, non-overlapping pairs of
///   letters, like aa, bb, or zz.
///
///
/// For example:
///
/// - hijklmmn meets the first requirement (because it contains the straight
///   hij) but fails the second requirement requirement (because it contains i
///   and l).
/// - abbceffg meets the third requirement (because it repeats bb and ff) but
///   fails the first requirement.
/// - abbcegjk fails the third requirement, because it only has one double
///   letter (bb).
/// - The next password after abcdefgh is abcdffaa.
/// - The next password after ghijklmn is ghjaabcc, because you eventually skip
///   all the passwords that start with ghi..., since i is not allowed.
///
///
/// Given Santa's current password (your puzzle input), what should his next
/// password be?
String part1(String input) {
  List<CodeUnit> password = input.codeUnits;
  do {
    password = nextWord(password);
  } while (!(adheresToReq1(password) && adheresToReq3(password)));

  return String.fromCharCodes(password);
}

/// --- Part Two ---
///
/// Santa's password expired again. What's the next one?
String part2(String input) {
  List<CodeUnit> password = part1(input).codeUnits;
  do {
    password = nextWord(password);
  } while (!(adheresToReq1(password) && adheresToReq3(password)));

  return String.fromCharCodes(password);
}
