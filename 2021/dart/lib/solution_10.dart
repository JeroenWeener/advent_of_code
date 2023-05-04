import 'dart:collection';

import 'package:aoc/aoc.dart';

void main(List<String> args) async {
  Solver<List<String>, int>(
    part1: part1,
    part2: part2,
    testOutput1: 26397,
    testOutput2: 288957,
  ).execute();
}

List openingBrackets = ['(', '[', '{', '<'];
List closingBrackets = [')', ']', '}', '>'];

int part1(List<String> input) {
  return input
      .map((String line) {
        Queue q = Queue();
        for (int i = 0; i < line.length; i++) {
          String bracket = line[i];

          if (openingBrackets.contains(bracket)) {
            q.add(bracket);
          } else {
            String previousOpeningBracket = q.removeLast();
            if (openingBrackets.indexOf(previousOpeningBracket) !=
                closingBrackets.indexOf(bracket)) {
              return bracket;
            }
          }
        }
        return null;
      })
      .whereType<String>()
      .map((String corruptedBracket) {
        return [3, 57, 1197, 25137][closingBrackets.indexOf(corruptedBracket)];
      })
      .sum();
}

int part2(List<String> input) {
  List<String> incorrectLines = input.where((String line) {
    Queue q = Queue();
    for (int i = 0; i < line.length; i++) {
      String bracket = line[i];
      if (openingBrackets.contains(bracket)) {
        q.add(bracket);
      } else {
        String corruptedBracket = q.removeLast();
        if (openingBrackets.indexOf(corruptedBracket) !=
            closingBrackets.indexOf(bracket)) {
          return false;
        }
      }
    }
    return true;
  }).toList();

  Iterable<List<int>> bracketScores = incorrectLines.map((String line) {
    Queue<String> q = Queue();
    for (int i = 0; i < line.length; i++) {
      String bracket = line[i];

      if (openingBrackets.contains(bracket)) {
        q.add(bracket);
      } else {
        q.removeLast();
      }
    }
    return q.toList().reversed;
  }).map((Iterable<String> openingSequence) => openingSequence
      .map((String bracket) => openingBrackets.indexOf(bracket) + 1)
      .toList());

  Iterable<int> sequenceScores = bracketScores.map((List<int> score) {
    int total = 0;
    for (int i = 0; i < score.length; i++) {
      total *= 5;
      total += score[i];
    }
    return total;
  }).toList()
    ..sort();

  return sequenceScores.middle;
}
