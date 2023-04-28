import 'package:aoc/aoc.dart';

class Point {
  const Point(this.x, this.y);

  factory Point.origin() {
    return Point(0, 0);
  }

  /// Adds multiple [Point]s together by summing their [x]s and [y]s.
  factory Point.add(Iterable<Point> points) {
    return Point(
      points.map((Point p) => p.x).sum(),
      points.map((Point p) => p.y).sum(),
    );
  }

  final int x;
  final int y;

  /// Adds two [Point]s by adding their [x]s and [y]s.
  operator +(Point other) {
    return Point(x + other.x, y + other.y);
  }

  /// Subtracts two [Point]s by subtracting [other]'s x and y from [x] and [y],
  /// respectively.
  operator -(Point other) {
    return Point(x - other.x, y - other.y);
  }

  /// Shorthand for [transpose].
  Point get t => Point(y, x);

  /// Transposes the point around the line y=x, effectively swapping [x] and
  /// [y].
  Point get transpose => Point(y, x);

  /// Returns the product of [x] and [y].
  int get product => x * y;

  /// Returns a new [Point] with [this.x] increased by [x] and [this.y]
  /// increased by [y].
  Point add({int? x, int? y}) {
    return Point(this.x + (x ?? 0), this.y + (y ?? 0));
  }

  @override
  int get hashCode => Object.hash(x, y);

  @override
  operator ==(Object other) {
    return other is Point && x == other.x && y == other.y;
  }
}
