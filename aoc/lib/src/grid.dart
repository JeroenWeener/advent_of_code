import 'package:aoc/src/int_extensions.dart';
import 'package:aoc/src/iterable_extensions.dart';
import 'package:aoc/src/pair.dart';
import 'package:aoc/src/point.dart';
import 'package:aoc/src/utils.dart';

typedef Grid<E> = Map<Point2, E>;
typedef GridItem<E> = MapEntry<Point2, E>;
typedef StringGrid = List<String>;
typedef StringGridItem = Pair<Point2, String>;

void main(List<String> args) {
  StringGrid grid = [
    'abc',
    'def',
    'ghi',
  ];

  print(grid.toPrettyString(
    highlightedPoints: [Point2(1, 1)],
    showBorder: true,
    rowSeparator: '-',
    columnSeparator: '|',
  ));

  print([
    [1, 2, 4],
    [1, 5, 7],
    [7, 3, 7],
  ].toGrid().toPrettyString(
        showBorder: true,
        rowSeparator: '-',
        columnSeparator: '|',
      ));
}

extension StringGridItemExtension on StringGridItem {
  Point2 get point2 => left;
  String get value => right;
}

extension StringGridExtension on StringGrid {
  int get minX => 0;
  int get maxX => isEmpty ? 0 : first.length;
  int get minY => 0;
  int get maxY => length;
  int get width => maxX;
  int get height => maxY;

  StringGrid clone() => [...this];

  List<StringGridItem> ns(
    Point2 point, {
    bool considerDiagonals = false,
  }) =>
      neighbors(
        point,
        considerDiagonals: considerDiagonals,
      );

  List<StringGridItem> neighbors(
    Point2 point, {
    bool considerDiagonals = false,
  }) {
    List<StringGridItem> neighbors = [
      if (point.y > minY) StringGridItem(point.u, this[point.y - 1][point.x]),
      if (point.x > minX) StringGridItem(point.l, this[point.y][point.x - 1]),
      if (point.y < maxY) StringGridItem(point.d, this[point.y + 1][point.x]),
      if (point.x < maxX) StringGridItem(point.r, this[point.y][point.x + 1]),
    ];
    if (!considerDiagonals) {
      return neighbors;
    }

    return [
      ...neighbors,
      if (point.y > minY && point.x < maxX)
        StringGridItem(point.u.r, this[point.y - 1][point.x + 1]),
      if (point.y < maxY && point.x < maxX)
        StringGridItem(point.d.r, this[point.y + 1][point.x + 1]),
      if (point.y < maxY && point.x > minX)
        StringGridItem(point.d.l, this[point.y + 1][point.x - 1]),
      if (point.y > minY && point.x < maxX)
        StringGridItem(point.u.l, this[point.y - 1][point.x - 1]),
    ];
  }

  String toPrettyString({
    String columnSeparator = '',
    String rowSeparator = '',
    String? intersectionSeparator,
    bool showBorder = false,
    Iterable<Point2> highlightedPoints = const <Point2>[],
  }) {
    assert(
        intersectionSeparator == null ||
            columnSeparator.length == intersectionSeparator.length,
        'Vertical separator and intersection separator are of different length.');
    assert(rowSeparator.length <= 1,
        'Horizontal separator is too long. It can only contain a single character.');

    String addBorder(String s) => showBorder ? '|$s|' : s;

    final String intersectionString =
        intersectionSeparator ?? ' ' * columnSeparator.length;
    final String lineSeparator =
        '$rowSeparator$intersectionString' * (width - 1) + rowSeparator;
    final String joinString =
        lineSeparator.isEmpty ? '\n' : '\n${addBorder(lineSeparator)}\n';

    final String output = range(0, height)
        .map(
          (int y) => addBorder(
            range(0, width).map(
              (int x) {
                final Point2 point = Point2(x + minX, y + minY);
                final String element = this[y][x];

                return (highlightedPoints.contains(point)
                    ? highlight(element)
                    : element);
              },
            ).join(columnSeparator),
          ),
        )
        .join(joinString);

    if (showBorder) {
      final borderString =
          '+${'-' * (width * (1 + columnSeparator.length) - columnSeparator.length)}+';
      return '$borderString\n$output\n$borderString';
    }
    return output;
  }
}

extension GridItemExtension<E> on GridItem<E> {
  Pair<Point2, E> toPair() => Pair(key, value);

  Point2 get point2 => key;
}

extension GridExtension<E> on Grid<E> {
  int get minX => keys.map((Point2 p) => p.x).min();
  int get maxX => keys.map((Point2 p) => p.x).max();
  int get minY => keys.map((Point2 p) => p.y).min();
  int get maxY => keys.map((Point2 p) => p.y).max();
  int get width => maxX - minX + 1;
  int get height => maxY - minY + 1;

  Grid<E> clone() => {...this};

  /// Shorthand for [neighbors].
  List<GridItem<E>> ns(
    Point2 p, {
    bool considerDiagonals = false,
  }) =>
      neighbors(
        p,
        considerDiagonals: considerDiagonals,
      );

  /// Returns a list of neighbors.
  ///
  /// Neighbors are defined as the [Point2]s next to [point], either
  /// horizontally or vertically. If [considerDiagonals] is set, diagonal points
  /// are also returned as neighbors.
  List<GridItem<E>> neighbors(
    Point2 point, {
    bool considerDiagonals = false,
  }) {
    final Iterable<GridItem<E>?> entriesNullable = entries.cast<GridItem<E>?>();
    final GridItem<E>? u = entriesNullable.firstWhere((e) => e!.key == point.u,
        orElse: () => null);
    final GridItem<E>? r = entriesNullable.firstWhere((e) => e!.key == point.r,
        orElse: () => null);
    final GridItem<E>? d = entriesNullable.firstWhere((e) => e!.key == point.d,
        orElse: () => null);
    final GridItem<E>? l = entriesNullable.firstWhere((e) => e!.key == point.l,
        orElse: () => null);

    List<GridItem<E>> neighbors = [
      if (u != null) u,
      if (r != null) r,
      if (d != null) d,
      if (l != null) l,
    ];

    if (!considerDiagonals) {
      return neighbors;
    }

    final GridItem<E>? ur = entriesNullable
        .firstWhere((e) => e!.key == point.u.r, orElse: () => null);
    final GridItem<E>? dr = entriesNullable
        .firstWhere((e) => e!.key == point.d.r, orElse: () => null);
    final GridItem<E>? dl = entriesNullable
        .firstWhere((e) => e!.key == point.d.l, orElse: () => null);
    final GridItem<E>? ul = entriesNullable
        .firstWhere((e) => e!.key == point.u.l, orElse: () => null);

    return [
      ...neighbors,
      if (ur != null) ur,
      if (dr != null) dr,
      if (dl != null) dl,
      if (ul != null) ul,
    ];
  }

  String toPrettyString({
    E? defaultValue,
    String columnSeparator = '',
    String? rowSeparator,
    String? intersectionSeparator,
    bool showBorder = false,
    Iterable<Point2> highlightedPoints = const <Point2>[],
  }) {
    assert(
        intersectionSeparator == null ||
            columnSeparator.length == intersectionSeparator.length,
        'Column separator and intersection separator are of different length.');
    assert((rowSeparator?.length ?? 0) <= 1,
        'Row separator is too long. It can only contain a single character.');

    String addBorder(String s) => showBorder ? '|$s|' : s;

    final int elementCharacterSize = [
      ...values.map((e) => e.toString().length),
      if (defaultValue != null) defaultValue.toString().length,
    ].max();
    final String intersectionString = intersectionSeparator ??
        rowSeparator ??
        columnSeparator * columnSeparator.length;
    final String verticalString = (rowSeparator ?? '') * elementCharacterSize;
    final String lineSeparator =
        '$verticalString$intersectionString' * (width - 1) + verticalString;
    final String joinString =
        lineSeparator.isEmpty ? '\n' : '\n${addBorder(lineSeparator)}\n';

    final String output = range(0, height)
        .map(
          (int y) => addBorder(
            range(0, width).map(
              (int x) {
                final Point2 point = Point2(x + minX, y + minY);
                final E? element = this[point];
                final String elementString =
                    (element ?? defaultValue ?? ' ').toString();
                final int padding = elementCharacterSize - elementString.length;

                return (highlightedPoints.contains(point)
                        ? highlight(elementString)
                        : elementString)
                    .padLeft(elementCharacterSize - padding ~/ 2)
                    .padRight(elementCharacterSize);
              },
            ).join(columnSeparator),
          ),
        )
        .join(joinString);

    if (showBorder) {
      final borderString =
          '+${'-' * (width * (elementCharacterSize + columnSeparator.length) - columnSeparator.length)}+';
      return '$borderString\n$output\n$borderString';
    }
    return output;
  }
}
