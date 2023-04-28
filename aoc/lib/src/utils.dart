import 'dart:io';

/// Reads the AoC session identifier associated with the user's account from
/// `advent_of_code/session_id.txt`.
///
/// Assumes the current working directory is `advent_of_code/year/dart`.
String getSessionId() {
  return File('../../session_id.txt').readAsStringSync().replaceAll('\n', '');
}

/// Determines the year from the directory structure.
///
/// Assumes the current working directory is `advent_of_code/year/dart`.
String getYearString() {
  return Directory.current.parent.path.split(Platform.pathSeparator).last;
}

/// Same as [getYearString], but returns an [int].
int getYearInt() {
  return int.parse(getYearString());
}

/// Determines the day from the executing file.
///
/// The day is represented using two characters, ie. day 1 is 01.
///
/// Assumes the executable file is named `*_xx.dart`, where xx is the number of
/// the day, using two characters (using a leading zero wherever necessary).
String getDayString() {
  return Platform.script.path
      .split(Platform.pathSeparator)
      .last
      .split(RegExp(r'[_.]'))[1];
}

/// Same as [getDayString], but returns an [int].
///
/// This is useful when not interested in leading zeros, for example when
/// requesting puzzle input by url.
int getDayInt() {
  return int.parse(getDayString());
}
