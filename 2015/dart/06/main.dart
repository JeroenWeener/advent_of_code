import 'dart:io';

void main() {
  final List<String> input = File('2015/dart/06/input.txt').readAsLinesSync();

  final int answer1 = part1(input);
  print(answer1);

  final int answer2 = part2(input);
  print(answer2);
}

/// --- Day 6: Probably a Fire Hazard ---
///
/// Because your neighbors keep defeating you in the holiday house decorating
/// contest year after year, you've decided to deploy one million lights in a
/// 1000x1000 grid.
///
/// Furthermore, because you've been especially nice this year, Santa has mailed
/// you instructions on how to display the ideal lighting configuration.
///
/// Lights in your grid are numbered from 0 to 999 in each direction; the lights
/// at each corner are at 0,0, 0,999, 999,999, and 999,0. The instructions
/// include whether to turn on, turn off, or toggle various inclusive ranges
/// given as coordinate pairs. Each coordinate pair represents opposite corners
/// of a rectangle, inclusive; a coordinate pair like 0,0 through 2,2 therefore
/// refers to 9 lights in a 3x3 square. The lights all start turned off.
///
/// To defeat your neighbors this year, all you have to do is set up your lights
/// by doing the instructions Santa sent you in order.
///
/// For example:
///
/// - turn on 0,0 through 999,999 would turn on (or leave on) every light.
/// - toggle 0,0 through 999,0 would toggle the first line of 1000 lights,
///   turning off the ones that were on, and turning on the ones that were off.
/// - turn off 499,499 through 500,500 would turn off (or leave off) the middle
///   four lights.
///
///
/// After following the instructions, how many lights are lit?
int part1(List<String> input) {
  final List<List<bool>> lights =
      List.generate(1000, (index) => List.generate(1000, (index) => false));

  input.forEach(
    (line) {
      final List<int> numbers = line
          .split(RegExp(r'[, ]'))
          .map((word) => int.tryParse(word))
          .whereType<int>()
          .toList();

      for (int x = numbers[0]; x <= numbers[2]; x++) {
        for (int y = numbers[1]; y <= numbers[3]; y++) {
          lights[x][y] = line.startsWith('turn off')
              ? false
              : line.startsWith('turn on')
                  ? true
                  : !lights[x][y];
        }
      }
    },
  );

  return lights.fold(
    0,
    (totalLightsOn, lightsOnInRow) =>
        totalLightsOn +
        lightsOnInRow.fold(
          0,
          (lightsOn, isLightOn) => lightsOn + (isLightOn ? 1 : 0),
        ),
  );
}

/// --- Part Two ---
///
/// You just finish implementing your winning light pattern when you realize you
/// mistranslated Santa's message from Ancient Nordic Elvish.
///
/// The light grid you bought actually has individual brightness controls; each
/// light can have a brightness of zero or more. The lights all start at zero.
///
/// The phrase turn on actually means that you should increase the brightness of
/// those lights by 1.
///
/// The phrase turn off actually means that you should decrease the brightness
/// of those lights by 1, to a minimum of zero.
///
/// The phrase toggle actually means that you should increase the brightness of
/// those lights by 2.
///
/// What is the total brightness of all lights combined after following Santa's
/// instructions?
///
/// For example:
///
/// - turn on 0,0 through 0,0 would increase the total brightness by 1.
/// - toggle 0,0 through 999,999 would increase the total brightness by 2000000.
int part2(List<String> input) {
  final List<List<int>> lights =
      List.generate(1000, (index) => List.generate(1000, (index) => 0));

  input.forEach(
    (line) {
      final List<int> numbers = line
          .split(RegExp(r'[, ]'))
          .map((word) => int.tryParse(word))
          .whereType<int>()
          .toList();

      for (int x = numbers[0]; x <= numbers[2]; x++) {
        for (int y = numbers[1]; y <= numbers[3]; y++) {
          lights[x][y] += line.startsWith('turn off')
              ? -1
              : line.startsWith('turn on')
                  ? 1
                  : 2;
          lights[x][y] = lights[x][y] < 0 ? 0 : lights[x][y];
        }
      }
    },
  );

  return lights.fold(
    0,
    (totalBrightness, rowBrightness) =>
        totalBrightness +
        rowBrightness.fold(
          0,
          (columnBrightness, brightness) => columnBrightness + brightness,
        ),
  );
}
