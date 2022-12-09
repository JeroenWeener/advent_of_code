import 'dart:io';

void main() {
  List<String> input = File('2015/dart/09/input.txt').readAsLinesSync();

  int answer1 = part1(input);
  print(answer1);

  int answer2 = part2(input);
  print(answer2);
}

/// Generate all possible permutations of a [List<T>].
List<List<T>> permutation<T>(
  List<List<T>> generatedPermutations,
  List<T> currentPermutation,
  List<T> elementsToPermute,
) {
  if (elementsToPermute.isNotEmpty) {
    return elementsToPermute.map((element) {
      List<T> nextPermutation = [...currentPermutation, element];
      List<T> remainingElement = [...elementsToPermute];
      remainingElement.remove(element);
      return permutation(
          generatedPermutations, nextPermutation, remainingElement);
    }).fold(
      [],
      (allPermutations, permutation) => allPermutations + permutation,
    );
  } else {
    return [...generatedPermutations, currentPermutation];
  }
}

/// Get all cities present in the puzzle input.
List<String> getCities(List<String> input) {
  String firstCity = input[0].split(' ')[0];
  return [firstCity]..addAll(
      input
          .takeWhile((line) => line.startsWith(firstCity))
          .map((line) => line.split(' ')[2]),
    );
}

/// Road between two cities: [cityA] and [cityB] with a [distance].
///
/// Roads are bidirectional: for every a,b -> Road(a, b) == Road(b, a).
class Road {
  Road(
    cityA,
    cityB,
    this.distance,
  )   : cityA = cityA.compareTo(cityB) < 0 ? cityA : cityB,
        cityB = cityA.compareTo(cityB) < 0 ? cityB : cityA;

  String cityA;
  String cityB;

  int distance;
}

/// Construct [List<Road>] from puzzle input.
List<Road> getRoads(List<String> input) {
  return input.map(
    (line) {
      List<String> parts = line.split(' ');
      String cityA = parts[0];
      String cityB = parts[2];
      int distance = int.parse(parts[4]);

      return Road(cityA, cityB, distance);
    },
  ).toList();
}

/// Calculate the cost of a [route].
///
/// For every subsequent pair of cities in [route], look up the distance of
/// their road in [roads].
int getCostOfRoute(List<String> route, List<Road> roads) {
  int distance = 0;
  for (int cityIndex = 0; cityIndex < route.length - 1; cityIndex++) {
    String cityA = route[cityIndex];
    String cityB = route[cityIndex + 1];

    Road road = roads.firstWhere((road) =>
        (road.cityA == cityA && road.cityB == cityB) ||
        (road.cityA == cityB && road.cityB == cityA));

    distance += road.distance;
  }

  return distance;
}

/// --- Day 9: All in a Single Night ---
///
/// Every year, Santa manages to deliver all of his presents in a single night.
///
/// This year, however, he has some new locations to visit; his elves have
/// provided him the distances between every pair of locations. He can start and
/// end at any two (different) locations he wants, but he must visit each
/// location exactly once. What is the shortest distance he can travel to
/// achieve this?
///
/// For example, given the following distances:
///
/// - London to Dublin = 464
/// - London to Belfast = 518
/// - Dublin to Belfast = 141
///
///
/// The possible routes are therefore:
///
/// - Dublin -> London -> Belfast = 982
/// - London -> Dublin -> Belfast = 605
/// - London -> Belfast -> Dublin = 659
/// - Dublin -> Belfast -> London = 659
/// - Belfast -> Dublin -> London = 605
/// - Belfast -> London -> Dublin = 982
///
///
/// The shortest of these is London -> Dublin -> Belfast = 605, and so the
/// answer is 605 in this example.
///
/// What is the distance of the shortest route?
int part1(List<String> input) {
  List<String> cities = getCities(input);
  List<Road> roads = getRoads(input);
  List<List<String>> routes = permutation([], [], cities);
  List<int> distances = routes.map((e) => getCostOfRoute(e, roads)).toList()
    ..sort();
  return distances.first;
}

/// --- Part Two ---
///
/// The next year, just to show off, Santa decides to take the route with the
/// longest distance instead.
///
/// He can still start and end at any two (different) locations he wants, and he
/// still must visit each location exactly once.
///
/// For example, given the distances above, the longest route would be 982 via
/// (for example) Dublin -> London -> Belfast.
///
/// What is the distance of the longest route?
int part2(List<String> input) {
  List<String> cities = getCities(input);
  List<Road> roads = getRoads(input);
  List<List<String>> routes = permutation([], [], cities);
  List<int> distances = routes.map((e) => getCostOfRoute(e, roads)).toList();
  distances.sort((a, b) => b - a);
  return distances.first;
}
