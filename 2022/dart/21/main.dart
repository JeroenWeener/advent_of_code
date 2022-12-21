import 'dart:io';

void main() {
  List<String> input = File('2022/dart/21/input.txt').readAsLinesSync();

  int answer1 = part1(input);
  print(answer1);

  int answer2 = part2(input);
  print(answer2);
}

/// Regex expressions for recognizing the different operations and capturing the
/// relevant monkey names and values.
RegExp numberRegex = RegExp(r'^([a-z]+): (\d+)$');
RegExp additionRegex = RegExp(r'^([a-z]+): ([a-z]+) \+ ([a-z]+)$');
RegExp subtractionRegex = RegExp(r'^([a-z]+): ([a-z]+) - ([a-z]+)$');
RegExp multiplicationRegex = RegExp(r'^([a-z]+): ([a-z]+) \* ([a-z]+)$');
RegExp divisionRegex = RegExp(r'^([a-z]+): ([a-z]+) / ([a-z]+)$');
RegExp equalityRegex = RegExp(r'^([a-z]+): ([a-z]+) = ([a-z]+)$');
RegExp assignmentRegex = RegExp(r'^([a-z]+): ([a-z]+)$');

/// Calculate the value of the provided [monkey] by calculating it from the
/// [jobs].
int calculateMonkeyValue(
  List<String> jobs,
  String monkey,
) {
  String job = jobs.firstWhere((job) => job.startsWith(monkey));

  int result;

  if (numberRegex.hasMatch(job)) {
    // a: 1
    RegExpMatch match = numberRegex.firstMatch(job)!;
    result = int.parse(match.group(2)!);
  } else if (additionRegex.hasMatch(job)) {
    // a: b + c
    RegExpMatch match = additionRegex.firstMatch(job)!;
    String monkeyA = match.group(2)!;
    String monkeyB = match.group(3)!;
    result = calculateMonkeyValue(jobs, monkeyA) +
        calculateMonkeyValue(jobs, monkeyB);
  } else if (subtractionRegex.hasMatch(job)) {
    // a: b - c
    RegExpMatch match = subtractionRegex.firstMatch(job)!;
    String monkeyA = match.group(2)!;
    String monkeyB = match.group(3)!;
    result = calculateMonkeyValue(jobs, monkeyA) -
        calculateMonkeyValue(jobs, monkeyB);
  } else if (multiplicationRegex.hasMatch(job)) {
    // a: b * c
    RegExpMatch match = multiplicationRegex.firstMatch(job)!;
    String monkeyA = match.group(2)!;
    String monkeyB = match.group(3)!;
    result = calculateMonkeyValue(jobs, monkeyA) *
        calculateMonkeyValue(jobs, monkeyB);
  } else if (divisionRegex.hasMatch(job)) {
    // a: b / c
    RegExpMatch match = divisionRegex.firstMatch(job)!;
    String monkeyA = match.group(2)!;
    String monkeyB = match.group(3)!;
    result = calculateMonkeyValue(jobs, monkeyA) ~/
        calculateMonkeyValue(jobs, monkeyB);
  } else if (assignmentRegex.hasMatch(job)) {
    // a: b
    RegExpMatch match = assignmentRegex.firstMatch(job)!;
    String monkeyA = match.group(2)!;
    result = calculateMonkeyValue(jobs, monkeyA);
  } else {
    throw Exception('Unsupported job: $job');
  }

  return result;
}

/// Rewrite the jobs so that [monkey] can be evaluated.
///
/// This is an iterative process where multiple jobs might be rewritten.
/// Jobs will be rewritten by inverting the operation they are performing.
///
/// For example:
///   a: b + c -> c: a - b
///   a: b / c -> c: b / a
void rewriteJobs(
  List<String> jobs,
  String monkey,
) {
  // Ignore number and assignment jobs.
  Iterable<String> irrelevantJobs = jobs.where((job) => job.startsWith(monkey));
  if (irrelevantJobs.isNotEmpty &&
      (numberRegex.hasMatch(irrelevantJobs.first) ||
          assignmentRegex.hasMatch(irrelevantJobs.first))) {
    return;
  }

  // Return if there are no jobs to invert.
  if (!jobs.any((job) => job.contains(monkey) && !job.startsWith(monkey))) {
    return;
  }

  // Select a job to invert by finding a job with [monkey] in its right-hand
  // side.
  String jobToInvert =
      jobs.firstWhere((job) => job.contains(monkey) && !job.startsWith(monkey));

  if (additionRegex.hasMatch(jobToInvert)) {
    // a: b + c
    RegExpMatch match = additionRegex.firstMatch(jobToInvert)!;
    List<String> monkeys = match
        .groups([1, 2, 3])
        .whereType<String>()
        .where((e) => e != monkey)
        .toList();

    jobs.remove(jobToInvert);
    rewriteJobs(jobs, monkeys[0]);
    rewriteJobs(jobs, monkeys[1]);

    // b = a - c
    // c = a - b
    jobs.add('$monkey: ${monkeys[0]} - ${monkeys[1]}');
  } else if (subtractionRegex.hasMatch(jobToInvert)) {
    // a: b - c
    RegExpMatch match = subtractionRegex.firstMatch(jobToInvert)!;
    List<String> monkeys = match.groups([1, 2, 3]).whereType<String>().toList();

    jobs.remove(jobToInvert);
    rewriteJobs(jobs, monkeys[0]);
    rewriteJobs(jobs, monkey == monkeys[1] ? monkeys[2] : monkeys[1]);

    if (monkey == monkeys[1]) {
      // b: a + c
      jobs.add('$monkey: ${monkeys[0]} + ${monkeys[2]}');
    } else {
      // c: b - a
      jobs.add('$monkey: ${monkeys[1]} - ${monkeys[0]}');
    }
  } else if (multiplicationRegex.hasMatch(jobToInvert)) {
    // a: b * c
    RegExpMatch match = multiplicationRegex.firstMatch(jobToInvert)!;
    List<String> monkeys = match
        .groups([1, 2, 3])
        .whereType<String>()
        .where((e) => e != monkey)
        .toList();

    jobs.remove(jobToInvert);
    rewriteJobs(jobs, monkeys[0]);
    rewriteJobs(jobs, monkeys[1]);

    // b: a / c
    // c: a / c
    jobs.add('$monkey: ${monkeys[0]} / ${monkeys[1]}');
  } else if (divisionRegex.hasMatch(jobToInvert)) {
    // a: b / c
    RegExpMatch match = divisionRegex.firstMatch(jobToInvert)!;
    List<String> monkeys = match.groups([1, 2, 3]).whereType<String>().toList();

    jobs.remove(jobToInvert);
    rewriteJobs(jobs, monkeys[0]);
    rewriteJobs(jobs, monkey == monkeys[1] ? monkeys[2] : monkeys[1]);

    if (monkey == monkeys[1]) {
      // b: a * c
      jobs.add('$monkey: ${monkeys[0]} * ${monkeys[2]}');
    } else {
      // c: b / a
      jobs.add('$monkey: ${monkeys[1]} / ${monkeys[0]}');
    }
  } else if (equalityRegex.hasMatch(jobToInvert)) {
    // a: b = c
    RegExpMatch match = equalityRegex.firstMatch(jobToInvert)!;
    List<String> monkeys = match
        .groups([1, 2, 3])
        .whereType<String>()
        .where((e) => e != monkey)
        .toList();

    jobs.remove(jobToInvert);

    // b: c
    jobs.add('$monkey: ${monkeys[1]}');
  } else {
    throw Exception('Unsupported job: $jobToInvert');
  }
}

/// --- Day 21: Monkey Math ---
///
/// The monkeys are back! You're worried they're going to try to steal your
/// stuff again, but it seems like they're just holding their ground and making
/// various monkey noises at you.
///
/// Eventually, one of the elephants realizes you don't speak monkey and comes
/// over to interpret. As it turns out, they overheard you talking about trying
/// to find the grove; they can show you a shortcut if you answer their riddle.
///
/// Each monkey is given a job: either to yell a specific number or to yell the
/// result of a math operation. All of the number-yelling monkeys know their
/// number from the start; however, the math operation monkeys need to wait for
/// two other monkeys to yell a number, and those two other monkeys might also
/// be waiting on other monkeys.
///
/// Your job is to work out the number the monkey named root will yell before
/// the monkeys figure it out themselves.
///
/// For example:
///
///   root: pppw + sjmn
///   dbpl: 5
///   cczh: sllz + lgvd
///   zczc: 2
///   ptdq: humn - dvpt
///   dvpt: 3
///   lfqf: 4
///   humn: 5
///   ljgn: 2
///   sjmn: drzm * dbpl
///   sllz: 4
///   pppw: cczh / lfqf
///   lgvd: ljgn * ptdq
///   drzm: hmdt - zczc
///   hmdt: 32
///
///
/// Each line contains the name of a monkey, a colon, and then the job of that
/// monkey:
///
///   - A lone number means the monkey's job is simply to yell that number.
///   - A job like aaaa + bbbb means the monkey waits for monkeys aaaa and bbbb
///     to yell each of their numbers; the monkey then yells the sum of those
///     two numbers.
///   - aaaa - bbbb means the monkey yells aaaa's number minus bbbb's number.
///   - Job aaaa * bbbb will yell aaaa's number multiplied by bbbb's number.
///   - Job aaaa / bbbb will yell aaaa's number divided by bbbb's number.
///
///
/// So, in the above example, monkey drzm has to wait for monkeys hmdt and zczc
/// to yell their numbers. Fortunately, both hmdt and zczc have jobs that
/// involve simply yelling a single number, so they do this immediately: 32 and
/// 2. Monkey drzm can then yell its number by finding 32 minus 2: 30.
///
/// Then, monkey sjmn has one of its numbers (30, from monkey drzm), and already
/// has its other number, 5, from dbpl. This allows it to yell its own number by
/// finding 30 multiplied by 5: 150.
///
/// This process continues until root yells a number: 152.
///
/// However, your actual situation involves considerably more monkeys. What
/// number will the monkey named root yell?
int part1(List<String> input) {
  return calculateMonkeyValue(input, 'root');
}

/// --- Part Two ---
///
/// Due to some kind of monkey-elephant-human mistranslation, you seem to have
/// misunderstood a few key details about the riddle.
///
/// First, you got the wrong job for the monkey named root; specifically, you
/// got the wrong math operation. The correct operation for monkey root should
/// be =, which means that it still listens for two numbers (from the same two
/// monkeys as before), but now checks that the two numbers match.
///
/// Second, you got the wrong monkey for the job starting with humn:. It isn't a
/// monkey - it's you. Actually, you got the job wrong, too: you need to figure
/// out what number you need to yell so that root's equality check passes. (The
/// number that appears after humn: in your input is now irrelevant.)
///
/// In the above example, the number you need to yell to pass root's equality
/// test is 301. (This causes root to get the same number, 150, from both of its
/// monkeys.)
///
/// What number do you yell to pass root's equality test?
int part2(List<String> input) {
  String rootJob = input.firstWhere((job) => job.startsWith('root'));
  String humnJob = input.firstWhere((job) => job.startsWith('humn'));

  List<String> rootJobParts = rootJob.split(' ');
  String newRootJob = [
    ...rootJobParts.take(2),
    '=',
    ...rootJobParts.skip(3),
  ].join(' ');

  input.remove(rootJob);
  input.add(newRootJob);
  input.remove(humnJob);

  rewriteJobs(input, 'humn');

  return calculateMonkeyValue(input, 'humn');
}
