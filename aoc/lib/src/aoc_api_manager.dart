import 'dart:io';

import 'package:aoc/src/utils.dart';

/// Manager that can connect to the AoC API.
///
/// The manager automatically derives the year and day based off the directory
/// the program was started in.
///
/// Internally the manager reads `session_id.txt`, expected it to contain
/// the session identifier needed for authentication.
class AocApiManager {
  AocApiManager()
      : _sessionId = getSessionId(),
        _year = getYearInt(),
        _day = getDayInt(),
        _dayString = getDayString();

  final String _sessionId;
  final int _year;
  final int _day;
  final String _dayString;

  Future<void> _downloadPuzzleInput() async {
    final String url = 'https://adventofcode.com/$_year/day/$_day/input';
    final HttpClient client = HttpClient();
    final HttpClientRequest request = await client.getUrl(Uri.parse(url));
    request.cookies.add(Cookie('session', _sessionId));
    final HttpClientResponse response = await request.close();
    final File file = File('puzzles/input_$_dayString.txt');
    file.createSync(recursive: true);
    await response.pipe(file.openWrite());
  }

  List<String> _readPuzzleInput() {
    return File('puzzles/input_$_dayString.txt').readAsLinesSync();
  }

  Future<List<String>> getPuzzleInput() async {
    final File inputFile = File('puzzles/input_$_dayString.txt');

    if (!inputFile.existsSync()) {
      await _downloadPuzzleInput();
    }
    return _readPuzzleInput();
  }

  Future<List<int>> getPuzzleInputAsInts() async {
    return (await getPuzzleInput()).map((String s) => int.parse(s)).toList();
  }

  @override
  String toString() {
    return 'AoCApiManager $hashCode: {year: $_year, day: $_day, sessionId: $_sessionId';
  }
}
