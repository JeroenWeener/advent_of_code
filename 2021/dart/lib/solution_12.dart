import 'package:aoc/aoc.dart';

void main(List<String> args) {
  Solver<List<Pair<String, String>>, int>(
    inputTransformer: transformInput,
    part1: part1,
    part2: part2,
    testOutput1: 10,
    testOutput2: 36,
  ).execute();
}

List<Pair<String, String>> transformInput(List<String> input) => input
    .map((String line) => Pair<String, String>.fromIterable(line.split('-')))
    .toList();

int part1(List<Pair<String, String>> paths) {
  int dfs(List<String> currentPath) {
    String src = currentPath.last;
    Iterable<Pair<String, String>> nextPaths = paths
        .where((Pair<String, String> path) => path.l == src || path.r == src);

    return nextPaths.map((Pair<String, String> path) {
      String dest = path.l == src ? path.r : path.l;

      if (dest == 'start') return 0;
      if (dest == 'end') return 1;
      if (dest == dest.toLowerCase() && currentPath.contains(dest)) return 0;

      return dfs([...currentPath, dest]);
    }).sum();
  }

  return dfs(['start']);
}

int part2(List<Pair<String, String>> paths) {
  int dfs(
    List<String> currentPath,
    bool usedSmallCaveTwice,
  ) {
    String src = currentPath.last;
    Iterable<Pair<String, String>> nextPaths = paths
        .where((Pair<String, String> path) => path.l == src || path.r == src);

    return nextPaths.map((Pair<String, String> nextPath) {
      String dest = nextPath.l == src ? nextPath.r : nextPath.l;

      if (dest == 'start') return 0;
      if (dest == 'end') return 1;

      if (dest == dest.toLowerCase() && currentPath.contains(dest)) {
        if (usedSmallCaveTwice) return 0;
        return dfs([...currentPath, dest], true);
      }

      return dfs([...currentPath, dest], usedSmallCaveTwice);
    }).sum();
  }

  return dfs(['start'], false);
}
