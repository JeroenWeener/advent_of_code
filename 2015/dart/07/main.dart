import 'dart:io';

void main() {
  final List<String> input = File('2015/dart/07/input.txt').readAsLinesSync();

  final int answer1 = part1(input);
  print(answer1);

  final int answer2 = part2(input);
  print(answer2);
}

/// Regex expressions for recognizing the different operations and capturing the
/// relevant register names and values.
final RegExp assignRegex = RegExp(r'([a-z]+|[0-9]+) -> [a-z]+');
final RegExp andRegex =
    RegExp(r'([a-z]+|[0-9]+) AND ([a-z]+|[0-9]+) -> [a-z]+');
final RegExp orRegex = RegExp(r'([a-z]+|[0-9]+) OR ([a-z]+|[0-9]+) -> [a-z]+');
final RegExp rShiftRegex = RegExp(r'([a-z]+) RSHIFT ([0-9]+) -> [a-z]+');
final RegExp lShiftRegex = RegExp(r'([a-z]+) LSHIFT ([0-9]+) -> [a-z]+');
final RegExp notRegex = RegExp(r'NOT ([a-z]+) -> [a-z]+');

/// Calculate the value of the provided [register], either by fetching it from
/// the [cache] or by calculating it from the [circuit].
int getValueOfRegister(
  List<String> circuit,
  Map<String, int> cache,
  String register,
) {
  // Return cached values immediately.
  if (cache[register] != null) {
    return cache[register]!;
  }

  final String operation =
      circuit.firstWhere((line) => line.endsWith('-> $register'));

  int result;

  if (andRegex.hasMatch(operation)) {
    RegExpMatch match = andRegex.firstMatch(operation)!;
    final String registerA = match.group(1)!;
    final String registerB = match.group(2)!;
    final int? valueA = int.tryParse(registerA);
    final int? valueB = int.tryParse(registerB);
    result = (valueA ?? getValueOfRegister(circuit, cache, registerA)) &
        (valueB ?? getValueOfRegister(circuit, cache, registerB));
  } else if (orRegex.hasMatch(operation)) {
    RegExpMatch match = orRegex.firstMatch(operation)!;
    final String registerA = match.group(1)!;
    final String registerB = match.group(2)!;
    final int? valueA = int.tryParse(registerA);
    final int? valueB = int.tryParse(registerB);
    result = (valueA ?? getValueOfRegister(circuit, cache, registerA)) |
        (valueB ?? getValueOfRegister(circuit, cache, registerB));
  } else if (rShiftRegex.hasMatch(operation)) {
    RegExpMatch match = rShiftRegex.firstMatch(operation)!;
    final String registerA = match.group(1)!;
    final int value = int.parse(match.group(2)!);
    result = getValueOfRegister(circuit, cache, registerA) >>> value;
  } else if (lShiftRegex.hasMatch(operation)) {
    RegExpMatch match = lShiftRegex.firstMatch(operation)!;
    final String registerA = match.group(1)!;
    final int value = int.parse(match.group(2)!);
    result = getValueOfRegister(circuit, cache, registerA) << value;
  } else if (notRegex.hasMatch(operation)) {
    RegExpMatch match = notRegex.firstMatch(operation)!;
    final String registerA = match.group(1)!;
    result = ~getValueOfRegister(circuit, cache, registerA);
  } else if (assignRegex.hasMatch(operation)) {
    RegExpMatch match = assignRegex.firstMatch(operation)!;
    final String registerA = match.group(1)!;
    final int? value = int.tryParse(registerA);
    result = value ?? getValueOfRegister(circuit, cache, registerA);
  } else {
    throw Exception('Unable to parse line $operation');
  }

  // Enforce 16 bit numbers.
  result &= 0xFFFF;

  // Update cache.
  cache[register] = result;

  return result;
}

/// --- Day 7: Some Assembly Required ---
///
/// This year, Santa brought little Bobby Tables a set of wires and bitwise
/// logic gates! Unfortunately, little Bobby is a little under the recommended
/// age range, and he needs help assembling the circuit.
///
/// Each wire has an identifier (some lowercase letters) and can carry a 16-bit
/// signal (a number from 0 to 65535). A signal is provided to each wire by a
///gate, another wire, or some specific value. Each wire can only get a signal
///from one source, but can provide its signal to multiple destinations. A gate
///provides no signal until all of its inputs have a signal.
///
/// The included instructions booklet describes how to connect the parts
/// together: x AND y -> z means to connect wires x and y to an AND gate, and
/// then connect its output to wire z.
///
/// For example:
///
/// - 123 -> x means that the signal 123 is provided to wire x.
/// - x AND y -> z means that the bitwise AND of wire x and wire y is provided
///   to wire z.
/// - p LSHIFT 2 -> q means that the value from wire p is left-shifted by 2 and
///   then provided to wire q.
/// - NOT e -> f means that the bitwise complement of the value from wire e is
///   provided to wire f.
///
///
/// Other possible gates include OR (bitwise OR) and RSHIFT (right-shift). If,
/// for some reason, you'd like to emulate the circuit instead, almost all
/// programming languages (for example, C, JavaScript, or Python) provide
/// operators for these gates.
///
/// For example, here is a simple circuit:
///
/// - 123 -> x
/// - 456 -> y
/// - x AND y -> d
/// - x OR y -> e
/// - x LSHIFT 2 -> f
/// - y RSHIFT 2 -> g
/// - NOT x -> h
/// - NOT y -> i
///
///
/// After it is run, these are the signals on the wires:
///
/// - d: 72
/// - e: 507
/// - f: 492
/// - g: 114
/// - h: 65412
/// - i: 65079
/// - x: 123
/// - y: 456
///
///
/// In little Bobby's kit's instructions booklet (provided as your puzzle
/// input), what signal is ultimately provided to wire a?
int part1(List<String> input) {
  return getValueOfRegister(input, {}, 'a');
}

/// --- Part Two ---
///
/// Now, take the signal you got on wire a, override wire b to that signal, and
/// reset the other wires (including wire a). What new signal is ultimately
/// provided to wire a?
int part2(List<String> input) {
  // Calculate 'a'.
  final int valueA = getValueOfRegister(input, {}, 'a');

  // Override 'b'.
  input.removeWhere((element) => element.endsWith('-> b'));
  input.add('$valueA -> b');

  // Recalculate 'a'.
  return getValueOfRegister(input, {}, 'a');
}
