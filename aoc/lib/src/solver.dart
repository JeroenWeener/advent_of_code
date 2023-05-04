import 'dart:convert';
import 'dart:io';

import 'package:aoc/src/aoc_manager.dart';
import 'package:aoc/src/utils.dart';

/// Solver that can connect to the AoC API.
///
/// The manager:
/// - Downloads puzzle input
/// - Downloads test input
/// - Executes provided solutions on both test and real data
/// - Measures execution times
///
/// Solver functions [_part1] and [_part2] take input of type [I] and output
/// type [O].
///
/// The manager automatically derives the year and day based off the directory
/// the program was started in.
///
/// Internally the manager reads `session_id.txt`, expected it to contain the
/// session identifier needed for authentication.
class Solver<I, O> {
  Solver({
    I Function(List<String>)? inputTransformer,
    O Function(I)? part1,
    O Function(I)? part2,
    O? testOutput1,
    O? testOutput2,
    bool testsOnly = false,
    bool uploadAnswers = false,
    int? year,
    int? day,
  })  : assert((inputTransformer != null || Solver._isSupportedInputType<I>()),
            'No input transformer is provided and input is not of type List<String>, String, List<int> or int'),
        _inputTransformer = inputTransformer,
        _part1 = part1,
        _part2 = part2,
        _testOutput1 = testOutput1,
        _testOutput2 = testOutput2,
        _testsOnly = testsOnly,
        _uploadAnswers = uploadAnswers,
        _year = year ?? getYearInt(),
        _day = day ?? getDayInt(),
        _aocManager = AocManager(
          year: year ?? getYearInt(),
          day: day ?? getDayInt(),
        );

  final int _year;
  final int _day;
  final AocManager _aocManager;

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

  Future<void> _executeTest(O Function(I) solution, O expected) async {
    final I? testInput = await _getTestInput();
    if (testInput == null) {
      print('Missing test input.');
      return;
    }

    final Stopwatch stopwatch = Stopwatch()..start();
    final O actual = solution(testInput);
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
    print('');

    if (_part1 != null) {
      print('--- Part 1 ---');
      await _executeTest(_part1!, _testOutput1 as O);
      if (!_testsOnly) {
        await _executeReal(_part1!);
      }
    } else {
      print('No parameters provided for part 1.');
    }

    print('');

    if (_part2 != null) {
      print('--- Part 2 ---');
      await _executeTest(_part2!, _testOutput2 as O);
      if (!_testsOnly) {
        await _executeReal(_part2!);
      }
    } else {
      print('No parameters provided for part 2.');
    }
  }

  Future<I> _getPuzzleInput() async {
    final List<String> puzzleInput = await _aocManager.readPuzzleInput();
    return _transformInput(puzzleInput);
  }

  Future<I?> _getTestInput() async {
    final List<String>? testInput = await _aocManager.readTestInput();
    if (testInput == null) return null;

    return _transformInput(testInput);
  }

  Future<I> _transformInput(List<String> input) async {
    if (_inputTransformer != null) {
      return _inputTransformer!(input);
    }

    switch (I) {
      case List<String>:
        return input as I;
      case String:
        return input.first as I;
      case List<int>:
        return input.map((String s) => int.parse(s)).toList() as I;
      case int:
        return input.map((String s) => int.parse(s)).toList().first as I;
      default:
        throw Exception('No valid input transformer');
    }
  }
}
