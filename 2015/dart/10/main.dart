import 'dart:io';

void main() {
  String input = File('2015/dart/10/input.txt').readAsStringSync();

  int answer1 = part1(input);
  print(answer1);

  int answer2 = part2(input);
  print(answer2);
}

/// Perform one iteration.
///
/// Calculate the amount of repeating characters from left to right. And convert
/// the result to a string of the form
/// '${count1}${character1}${count2}${character2}...'.
///
/// Characters can be counted multiple times if they appear apart from each
/// other.
///
/// For example:
///
/// 12 -> 1112
/// 1123331 -> 21123311
/// 45533441 -> 1425232411
String iterate(String s) {
  int currentCount = 1;
  String consideredElement = s[0];

  String result = '';

  for (int sIndex = 1; sIndex < s.length; sIndex++) {
    if (s[sIndex] == consideredElement) {
      currentCount++;
    } else {
      result += '$currentCount$consideredElement';
      consideredElement = s[sIndex];
      currentCount = 1;
    }
  }

  result += '$currentCount$consideredElement';

  return result;
}

/// --- Day 10: Elves Look, Elves Say ---
///
/// Today, the Elves are playing a game called look-and-say. They take turns
/// making sequences by reading aloud the previous sequence and using that
/// reading as the next sequence. For example, 211 is read as "one two, two
/// ones", which becomes 1221 (1 2, 2 1s).
///
/// Look-and-say sequences are generated iteratively, using the previous value
/// as input for the next step. For each step, take the previous value, and
/// replace each run of digits (like 111) with the number of digits (3) followed
/// by the digit itself (1).
///
/// For example:
///
/// - 1 becomes 11 (1 copy of digit 1).
/// - 11 becomes 21 (2 copies of digit 1).
/// - 21 becomes 1211 (one 2 followed by one 1).
/// - 1211 becomes 111221 (one 1, one 2, and two 1s).
/// - 111221 becomes 312211 (three 1s, two 2s, and one 1).
///
///
/// Starting with the digits in your puzzle input, apply this process 40 times.
/// What is the length of the result?
int part1(String input) {
  int iterations = 40;
  String r = input;

  for (int iteration = 0; iteration < iterations; iteration++) {
    r = iterate(r);
  }

  return r.length;
}

/// --- Part Two ---
///
/// Neat, right? You might also enjoy hearing John Conway talking about this
/// sequence (that's Conway of Conway's Game of Life fame).
///
/// Now, starting again with the digits in your puzzle input, apply this process
/// 50 times. What is the length of the new result?
int part2(String input) {
  int iterations = 50;
  String r = input;

  for (int iteration = 0; iteration < iterations; iteration++) {
    r = iterate(r);
  }

  return r.length;
}
