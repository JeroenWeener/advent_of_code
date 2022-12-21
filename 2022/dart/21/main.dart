import 'dart:io';

void main() {
  final List<String> input = File('2022/dart/21/input.txt').readAsLinesSync();

  final int answer1 = part1(input);
  print(answer1);

  final int answer2 = part2(input);
  print(answer2);
}

/// Regex expressions for recognizing the different operations and capturing the
/// relevant register names and values.
final RegExp numberRegex = RegExp(r'[a-z]+: (\d+)');
final RegExp additionRegex = RegExp(r'[a-z]+: ([a-z]+) \+ ([a-z]+)');
final RegExp subtractionRegex = RegExp(r'[a-z]+: ([a-z]+) - ([a-z]+)');
final RegExp multiplicationRegex = RegExp(r'[a-z]+: ([a-z]+) \* ([a-z]+)');
final RegExp divisionRegex = RegExp(r'[a-z]+: ([a-z]+) / ([a-z]+)');
final RegExp equalityRegex = RegExp(r'[a-z]+: ([a-z]+) = ([a-z]+)');

/// Calculate the value of the provided [register], either by fetching it from
/// the [cache] or by calculating it from the [circuit].
int getYelledNumber(
  List<String> circuit,
  Map<String, int> cache,
  String monkey,
) {
  if (cache[monkey] != null) {
    return cache[monkey]!;
  }

  String job = circuit.firstWhere((element) => element.startsWith(monkey));

  int result;

  if (numberRegex.hasMatch(job)) {
    RegExpMatch match = numberRegex.firstMatch(job)!;
    result = int.parse(match.group(1)!);
  } else if (additionRegex.hasMatch(job)) {
    RegExpMatch match = additionRegex.firstMatch(job)!;
    String monkeyA = match.group(1)!;
    String monkeyB = match.group(2)!;
    result = getYelledNumber(circuit, cache, monkeyA) +
        getYelledNumber(circuit, cache, monkeyB);
  } else if (subtractionRegex.hasMatch(job)) {
    RegExpMatch match = subtractionRegex.firstMatch(job)!;
    String monkeyA = match.group(1)!;
    String monkeyB = match.group(2)!;
    result = getYelledNumber(circuit, cache, monkeyA) -
        getYelledNumber(circuit, cache, monkeyB);
  } else if (multiplicationRegex.hasMatch(job)) {
    RegExpMatch match = multiplicationRegex.firstMatch(job)!;
    String monkeyA = match.group(1)!;
    String monkeyB = match.group(2)!;
    result = getYelledNumber(circuit, cache, monkeyA) *
        getYelledNumber(circuit, cache, monkeyB);
  } else if (divisionRegex.hasMatch(job)) {
    RegExpMatch match = divisionRegex.firstMatch(job)!;
    String monkeyA = match.group(1)!;
    String monkeyB = match.group(2)!;
    result = getYelledNumber(circuit, cache, monkeyA) ~/
        getYelledNumber(circuit, cache, monkeyB);
  } else if (equalityRegex.hasMatch(job)) {
    RegExpMatch match = equalityRegex.firstMatch(job)!;
    String monkeyA = match.group(1)!;
    String monkeyB = match.group(2)!;
    result = getYelledNumber(circuit, cache, monkeyA) ==
            getYelledNumber(circuit, cache, monkeyB)
        ? 1
        : 0;
  } else {
    throw Exception('Unsupported operation');
  }

  // Cache result.
  cache[monkey] = result;

  return result;
}

int part1(List<String> input) {
  return getYelledNumber(input, {}, 'root');
}

int part2(List<String> input) {
  int rootIndex = input.indexWhere((element) => element.startsWith('root'));
  List<String> parts = input[rootIndex].split(' ');
  input[rootIndex] = [...parts.take(2), '=', ...parts.skip(3)].join(' ');
  print(input[rootIndex]);
  return -1;
}
