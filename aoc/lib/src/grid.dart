import 'package:aoc/src/int_extensions.dart';
import 'package:aoc/src/iterable_extensions.dart';
import 'package:aoc/src/point.dart';

class Grid<E> {
  const Grid([Map<Point2, E>? grid]) : _grid = grid ?? const {};

  final Map<Point2, E> _grid;

  E? operator [](Point2 p) => _grid[p];
  void operator []=(Point2 p, E v) => _grid[p] = v;

  int get minX => _grid.keys.map((Point2 p) => p.x).min();
  int get maxX => _grid.keys.map((Point2 p) => p.x).max();
  int get minY => _grid.keys.map((Point2 p) => p.y).min();
  int get maxY => _grid.keys.map((Point2 p) => p.y).max();
  int get width => maxX - minX + 1;
  int get height => maxY - minY + 1;

  Grid<E> clone() => Grid({..._grid});

  String toPrettyString({
    E? defaultValue,
    String separatorVertical = '',
    String? separatorHorizontal,
    String? separatorIntersection,
    bool showBorder = false,
  }) {
    assert(
        separatorIntersection == null ||
            separatorVertical.length == separatorIntersection.length,
        'Vertical separator and intersection separator are of different length.');
    assert((separatorHorizontal?.length ?? 0) <= 1,
        'Horizontal separator is too long. It can only contain a single character.');

    String addBorder(String s) => showBorder ? '|$s|' : s;

    final int elementCharacterSize = [
      ..._grid.values.map((e) => e.toString().length),
      defaultValue.toString().length
    ].max();
    final String intersectionString =
        separatorIntersection ?? separatorVertical * separatorVertical.length;
    final String verticalString =
        (separatorHorizontal ?? '') * elementCharacterSize;
    final String lineSeparator =
        '$verticalString$intersectionString' * (width - 1) + verticalString;
    final String joinString =
        lineSeparator.isEmpty ? '\n' : '\n${addBorder(lineSeparator)}\n';

    final String output = height
        .range()
        .map(
          (int y) => addBorder(
            width.range().map(
              (int x) {
                final E? element = _grid[Point2(x + minX, y + minY)];
                final String elementString =
                    (element ?? defaultValue ?? ' ').toString();
                final int padding = elementCharacterSize - elementString.length;
                return elementString
                    .padLeft(elementCharacterSize - padding ~/ 2)
                    .padRight(elementCharacterSize);
              },
            ).join(separatorVertical),
          ),
        )
        .join(joinString);

    if (showBorder) {
      final borderString =
          '+${'-' * (width * (elementCharacterSize + separatorVertical.length) - separatorVertical.length)}+';
      return '$borderString\n$output\n$borderString';
    }
    return output;
  }
}
