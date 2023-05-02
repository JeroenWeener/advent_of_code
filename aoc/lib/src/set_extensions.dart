extension SetExtension<E> on Set<E> {
  Set<E> operator &(Set<E> other) => union(other);
  Set<E> operator |(Set<E> other) => intersection(other);
  Set<E> operator ^(Set<E> other) => (this & other) - (this | other);
  Set<E> operator -(Set<E> other) => difference(other);
}
