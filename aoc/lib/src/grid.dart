import 'package:aoc/src/int_extensions.dart';
import 'package:aoc/src/iterable_extensions.dart';
import 'package:aoc/src/point.dart';

typedef Grid<E> = Map<Point2, E>;
typedef GridItem<E> = MapEntry<Point2, E>;

extension GridExtension<E> on Grid<E> {
  int get minX => keys.map((Point2 p) => p.x).min();
  int get maxX => keys.map((Point2 p) => p.x).max();
  int get minY => keys.map((Point2 p) => p.y).min();
  int get maxY => keys.map((Point2 p) => p.y).max();
  int get width => maxX - minX + 1;
  int get height => maxY - minY + 1;

  Grid<E> clone() => {...this};

  /// Shorthand for [neighbors].
  List<GridItem<E>> ns(Point2 p) => neighbors(p);

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

    if (!considerDiagonals) {
      return [
        if (u != null) u,
        if (r != null) r,
        if (d != null) d,
        if (l != null) l,
      ];
    } else {
      final GridItem<E>? ur = entriesNullable
          .firstWhere((e) => e!.key == point.u.r, orElse: () => null);
      final GridItem<E>? dr = entriesNullable
          .firstWhere((e) => e!.key == point.d.r, orElse: () => null);
      final GridItem<E>? dl = entriesNullable
          .firstWhere((e) => e!.key == point.d.l, orElse: () => null);
      final GridItem<E>? ul = entriesNullable
          .firstWhere((e) => e!.key == point.u.l, orElse: () => null);
      return [
        if (u != null) u,
        if (ur != null) ur,
        if (r != null) r,
        if (dr != null) dr,
        if (d != null) d,
        if (dl != null) dl,
        if (l != null) l,
        if (ul != null) ul,
      ];
    }
  }

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
      ...values.map((e) => e.toString().length),
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

    final String output = range(0, height)
        .map(
          (int y) => addBorder(
            range(0, width).map(
              (int x) {
                final E? element = this[Point2(x + minX, y + minY)];
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
