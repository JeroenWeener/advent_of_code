import 'package:aoc/src/int_extensions.dart';
import 'package:aoc/src/iterable_extensions.dart';
import 'package:aoc/src/point.dart';
import 'package:aoc/src/utils.dart';

typedef UnboundGrid<E> = Map<Point2, E>;
typedef UnboundGridItem<E> = MapEntry<Point2, E>;

extension UnboundGridItemExtension<E> on UnboundGridItem<E> {
  Point2 get point2 => key;
}

extension UnboundGridExtension<E> on UnboundGrid<E> {
  int get minX => keys.map((Point2 p) => p.x).min();
  int get maxX => keys.map((Point2 p) => p.x).max();
  int get minY => keys.map((Point2 p) => p.y).min();
  int get maxY => keys.map((Point2 p) => p.y).max();
  int get width => maxX - minX + 1;
  int get height => maxY - minY + 1;

  UnboundGrid<E> clone() => {...this};

  /// Shorthand for [neighbors].
  List<UnboundGridItem<E>> ns(
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
  List<UnboundGridItem<E>> neighbors(
    Point2 point, {
    bool considerDiagonals = false,
  }) {
    final Iterable<UnboundGridItem<E>?> entriesNullable =
        entries.cast<UnboundGridItem<E>?>();
    final UnboundGridItem<E>? u = entriesNullable
        .firstWhere((e) => e!.key == point.u, orElse: () => null);
    final UnboundGridItem<E>? r = entriesNullable
        .firstWhere((e) => e!.key == point.r, orElse: () => null);
    final UnboundGridItem<E>? d = entriesNullable
        .firstWhere((e) => e!.key == point.d, orElse: () => null);
    final UnboundGridItem<E>? l = entriesNullable
        .firstWhere((e) => e!.key == point.l, orElse: () => null);

    List<UnboundGridItem<E>> neighbors = [
      if (u != null) u,
      if (r != null) r,
      if (d != null) d,
      if (l != null) l,
    ];

    if (!considerDiagonals) {
      return neighbors;
    }

    final UnboundGridItem<E>? ur = entriesNullable
        .firstWhere((e) => e!.key == point.u.r, orElse: () => null);
    final UnboundGridItem<E>? dr = entriesNullable
        .firstWhere((e) => e!.key == point.d.r, orElse: () => null);
    final UnboundGridItem<E>? dl = entriesNullable
        .firstWhere((e) => e!.key == point.d.l, orElse: () => null);
    final UnboundGridItem<E>? ul = entriesNullable
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
