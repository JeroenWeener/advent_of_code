import 'dart:io';

import 'package:aoc/src/utils.dart';

/// Solver that can connect to the AoC API.
///
/// The manager can:
/// - Download puzzle input
/// - Execute provided solutions on both test and real data
/// - Measure execution times
///
/// Solver functions [_part1] and [_part2] take input of type [I] and output type
/// [O].
///
/// The manager automatically derives the year and day based off the directory
/// the program was started in.
///
/// Internally the manager reads `session_id.txt`, expected it to contain
/// the session identifier needed for authentication.
class Solver<I, O> {
  Solver({
    O Function(I)? part1,
    O Function(I)? part2,
    I? testInput,
    O? testOutput1,
    O? testOutput2,
    bool testsOnly = false,
    I Function(List<String>)? inputTransformer,
    bool uploadAnswers = false,
    int? year,
    int? day,
  })  : _part1 = part1,
        _part2 = part2,
        _testOutput1 = testOutput1,
        _testOutput2 = testOutput2,
        _testInput = testInput,
        _testsOnly = testsOnly,
        _uploadAnswers = uploadAnswers,
        assert((inputTransformer != null || Solver._isSupportedInputType<I>()),
            'No input transformer is provided and input is not of type List<String>, String, List<int> or int'),
        _inputTransformer = inputTransformer,
        _year = year ?? getYearInt(),
        _day = day ?? getDayInt();

  final String _sessionId = getSessionId();
  final int _year;
  final int _day;
  String get _dayString => _day.toString().padLeft(2, '0');

  String get _puzzleInputFileName => 'puzzles/input_$_dayString.txt';

  final I? _testInput;
  final O? _testOutput1;
  final O? _testOutput2;
  final O Function(I)? _part1;
  final O Function(I)? _part2;
  final I Function(List<String>)? _inputTransformer;

  /// Only execute tests.
  ///
  /// Refrains from running [_part1] and [_part2] on the puzzle input.
  final bool _testsOnly;

  final bool _uploadAnswers;

  /// Returns whether the provided input type [T] is supported by default, or
  /// whether it requires a custom Input Transformer.
  static bool _isSupportedInputType<T>() {
    switch (T) {
      case List<String>:
      case String:
      case List<int>:
      case int:
        return true;
      default:
        return false;
    }
  }

  void _executeTest(O Function(I) solution, O expected) {
    if (_testInput != null) {
      final stopwatch = Stopwatch()..start();
      final O actual = solution(_testInput as I);
      final int executionTimeMillis = stopwatch.elapsedMilliseconds;

      if (expected == null) {
        print('Test: Actual: $actual ($executionTimeMillis ms)');
      } else {
        if (expected == actual) {
          print('Test: Passed ($executionTimeMillis ms)');
        } else {
          print(
              'Test: Failed. Expected: $expected. Actual: $actual ($executionTimeMillis ms)');
        }
      }
    }
  }

  Future<void> _executeReal(O Function(I) solution) async {
    final I puzzleInput = await _getPuzzleInput();
    final stopwatch = Stopwatch()..start();
    final O output = solution(puzzleInput);
    final int executionTimeMillis = stopwatch.elapsedMilliseconds;
    if (_uploadAnswers) {
      // TODO(jweener): upload answer.
    } else {
      print('Real: $output ($executionTimeMillis ms)');
    }
  }

  Future<void> execute() async {
    print('Executing $_year, day $_day');

    if (_part1 != null) {
      print('');
      print('--- Part 1 ---');
      _executeTest(_part1!, _testOutput1 as O);
      if (!_testsOnly) {
        await _executeReal(_part1!);
      }
    } else {
      print('No parameters provided for part 1.');
    }

    if (_part2 != null) {
      print('');
      print('--- Part 2 ---');
      _executeTest(_part2!, _testOutput2 as O);
      if (!_testsOnly) {
        await _executeReal(_part2!);
      }
    } else {
      print('No parameters provided for part 2.');
    }
  }

  Future<void> _downloadPuzzleInput() async {
    final String url = 'https://adventofcode.com/$_year/day/$_day/input';
    final HttpClient client = HttpClient();
    final HttpClientRequest request = await client.getUrl(Uri.parse(url));
    request.cookies.add(Cookie('session', _sessionId));
    final HttpClientResponse response = await request.close();
    final File file = File(_puzzleInputFileName);
    file.createSync(recursive: true);
    await response.pipe(file.openWrite());
  }

  List<String> _getCachedPuzzleInput() {
    return File(_puzzleInputFileName).readAsLinesSync();
  }

  Future<I> _getPuzzleInput() async {
    if (_inputTransformer != null) {
      return _inputTransformer!(await _readPuzzleInput());
    }

    switch (I) {
      case List<String>:
        return (await _readPuzzleInput()) as I;
      case String:
        return (await _readPuzzleInput()).first as I;
      case List<int>:
        return (await _readPuzzleInputAsInts()) as I;
      case int:
        return (await _readPuzzleInputAsInts()).first as I;
      default:
        throw Exception('No valid input transformer');
    }
  }

  Future<List<String>> _readPuzzleInput() async {
    final File inputFile = File(_puzzleInputFileName);

    if (!inputFile.existsSync()) {
      await _downloadPuzzleInput();
    }
    return _getCachedPuzzleInput();
  }

  Future<List<int>> _readPuzzleInputAsInts() async {
    return (await _readPuzzleInput()).map((String s) => int.parse(s)).toList();
  }

  @override
  String toString() {
    return 'AocApiManager $hashCode: {year: $_year, day: $_day, sessionId: $_sessionId}';
  }
}
