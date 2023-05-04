import 'dart:convert';
import 'dart:io';

import 'package:aoc/src/utils.dart';

/// Communicates with the AoC website over HTTP.
///
/// - Downloads puzzle input
/// - Extracts test input
/// - Posts solutions
class AocManager {
  AocManager({
    required int year,
    required int day,
  })  : _year = year,
        _day = day;

  final String _sessionId = getSessionId();
  final int _year;
  final int _day;

  String get _puzzleInputFileName => 'puzzles/input_$_dayString.txt';
  String get _testInputFileName => 'puzzles/test_input_$_dayString.txt';
  String get _dayString => _day.toString().padLeft(2, '0');

  Future<bool> _downloadTestInput() async {
    final String url = 'https://adventofcode.com/$_year/day/$_day';
    final HttpClient client = HttpClient();
    final HttpClientRequest request = await client.getUrl(Uri.parse(url));
    request.cookies.add(Cookie('session', _sessionId));
    final HttpClientResponse response = await request.close();
    final String html = await response.transform(utf8.decoder).join();
    try {
      final String testInput = html
          .split('example')[1]
          .split('<pre><code>')[1]
          .split('</code></pre>')[0]
          .replaceAll('<em>', '')
          .replaceAll('</em>', '')
          .replaceAll('&lt;', '<')
          .replaceAll('&gt;', '>');
      final File file = File(_testInputFileName);
      file.createSync(recursive: true);
      file.writeAsStringSync(testInput);
    } on Error {
      print(highlight('Error parsing test input.', HighlightColor.red));
      client.close();
      return false;
    } finally {
      client.close();
    }
    return true;
  }

  List<String> _getCachedTestInput() {
    return File(_testInputFileName).readAsLinesSync();
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
    client.close();
  }

  List<String> _getCachedPuzzleInput() {
    return File(_puzzleInputFileName).readAsLinesSync();
  }

  Future<List<String>?> readTestInput() async {
    final File inputFile = File(_testInputFileName);

    if (!inputFile.existsSync()) {
      final bool isSuccess = await _downloadTestInput();
      if (!isSuccess) return null;
    }
    return _getCachedTestInput();
  }

  Future<List<String>> readPuzzleInput() async {
    final File inputFile = File(_puzzleInputFileName);

    if (!inputFile.existsSync()) {
      await _downloadPuzzleInput();
    }
    return _getCachedPuzzleInput();
  }
}
