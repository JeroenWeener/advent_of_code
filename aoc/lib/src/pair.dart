class Pair<S, T> {
  const Pair(this.left, this.right);

  final S left;
  final T right;

  @override
  int get hashCode => Object.hash(left, right);

  @override
  operator ==(Object other) {
    return other is Pair && left == other.left && right == other.right;
  }
}
