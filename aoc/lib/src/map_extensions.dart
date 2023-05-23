import 'package:aoc/src/pair.dart';

extension MapExtension<K, V> on Map<K, V> {
  List<Pair<K, V>> toPairs() =>
      entries.map((MapEntry<K, V> entry) => entry.toPair()).toList();
}

extension MapEntryExtension<K, V> on MapEntry<K, V> {
  Pair<K, V> toPair() => Pair(key, value);
}
