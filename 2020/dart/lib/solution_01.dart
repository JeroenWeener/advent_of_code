import 'package:aoc/aoc.dart';

void main(List<String> args) {
  Solver(
    part1: part1,
    part2: part2,
    testOutput1: 514579,
    testOutput2: 241861950,
  ).execute();
}

int part1(List<int> numbers) {
  for (int i = 0; i < numbers.length; i++) {
    for (int j = i + 1; j < numbers.length; j++) {
      if (numbers[i] + numbers[j] == 2020) {
        return numbers[i] * numbers[j];
      }
    }
  }
  return -1;
}

int part2(List<int> numbers) {
  for (int i = 0; i < numbers.length; i++) {
    for (int j = i + 1; j < numbers.length; j++) {
      for (int k = j + 1; k < numbers.length; k++) {
        if (numbers[i] + numbers[j] + numbers[k] == 2020) {
          return numbers[i] * numbers[j] * numbers[k];
        }
      }
    }
  }
  return -1;
}
