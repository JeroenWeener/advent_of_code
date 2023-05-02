import 'package:aoc/aoc.dart';

class Point2 {
  const Point2(this.x, this.y);

  factory Point2.origin() {
    return Point2(0, 0);
  }

  /// Adds multiple [Point2]s together by summing their [x]s and [y]s.
  factory Point2.add(Iterable<Point2> points) {
    return Point2(
      points.map((Point2 p) => p.x).sum(),
      points.map((Point2 p) => p.y).sum(),
    );
  }

  final int x;
  final int y;

  /// Adds two [Point2]s by adding their [x]s and [y]s.
  Point2 operator +(Point2 other) => Point2(x + other.x, y + other.y);

  /// Subtracts two [Point2]s by subtracting [other]'s x and y from [x] and [y],
  /// respectively.
  Point2 operator -(Point2 other) => Point2(x - other.x, y - other.y);

  /// Returns a [Point2] with its values scaled by [factor].
  Point2 operator *(int factor) => Point2(factor * x, factor * y);

  /// Returns a [Point2] with -[x] and -[y].
  Point2 operator -() => flipXY;

  Point2 get flipX => Point2(-x, y);
  Point2 get flipY => Point2(x, -y);
  Point2 get flipXY => Point2(-x, -y);

  Point2 get l => left;
  Point2 get left => Point2(x - 1, y);
  Point2 get r => right;
  Point2 get right => Point2(x + 1, y);
  Point2 get u => up;
  Point2 get up => Point2(x, y - 1);
  Point2 get d => down;
  Point2 get down => Point2(x, y + 1);

  /// Shorthand for [transpose].
  Point2 get t => Point2(y, x);

  /// Transposes the point around the line y=x, effectively swapping [x] and
  /// [y].
  Point2 get transpose => Point2(y, x);

  /// Returns the product of [x] and [y].
  int get product => x * y;

  /// Returns a new [Point2] with [this.x] increased by [x] and [this.y]
  /// increased by [y].
  Point2 add({int? x, int? y}) {
    return Point2(this.x + (x ?? 0), this.y + (y ?? 0));
  }

  /// Transforms this [Point2] to a [Point3] with z=0.
  Point3 toPoint3() => Point3(x, y, 0);

  @override
  int get hashCode => Object.hash(x, y);

  @override
  bool operator ==(Object other) {
    return other is Point2 && x == other.x && y == other.y;
  }

  @override
  String toString() {
    return '($x, $y)';
  }
}

class Point3 {
  const Point3(this.x, this.y, this.z);

  factory Point3.origin() {
    return Point3(0, 0, 0);
  }

  /// Adds multiple [Point3]s together by summing their [x]s, [y]s and [z]s.
  factory Point3.add(Iterable<Point3> points) {
    return Point3(
      points.map((Point3 p) => p.x).sum(),
      points.map((Point3 p) => p.y).sum(),
      points.map((Point3 p) => p.z).sum(),
    );
  }

  final int x;
  final int y;
  final int z;

  /// Adds two [Point3]s by adding their [x]s, [y]s and [z]s.
  Point3 operator +(Point3 other) =>
      Point3(x + other.x, y + other.y, z + other.z);

  /// Subtracts two [Point3]s by subtracting [other]'s x, y and z from [x], [y]
  /// and [z] respectively.
  Point3 operator -(Point3 other) =>
      Point3(x - other.x, y - other.y, z - other.z);

  /// Returns a [Point3] with its values scaled by [factor].
  Point3 operator *(int factor) => Point3(factor * x, factor * y, factor * z);

  /// Returns a [Point3] with -[x], -[y] and -[z].
  Point3 operator -() => flipXYZ;

  Point3 get flipX => Point3(-x, y, z);
  Point3 get flipY => Point3(x, -y, z);
  Point3 get flipZ => Point3(x, y, -z);
  Point3 get flipXY => Point3(-x, -y, z);
  Point3 get flipXZ => Point3(-x, y, -z);
  Point3 get flipYZ => Point3(x, -y, -z);
  Point3 get flipXYZ => Point3(-x, -y, -z);

  /// Returns the product of [x], [y] and [z].
  int get product => x * y * z;

  /// Returns a new [Point3] with [this.x] increased by [x], [this.y] increased
  /// by [y] and [this.z] increased by [z].
  Point3 add({int? x, int? y, int? z}) {
    return Point3(this.x + (x ?? 0), this.y + (y ?? 0), this.z + (z ?? 0));
  }

  @override
  int get hashCode => Object.hash(x, y, z);

  @override
  bool operator ==(Object other) {
    return other is Point3 && x == other.x && y == other.y && z == other.z;
  }

  @override
  String toString() {
    return '($x, $y, $z)';
  }
}
