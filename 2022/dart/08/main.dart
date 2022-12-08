import 'dart:io';
import 'dart:math';

void main() {
  final List<String> input = File('2022/dart/08/input.txt').readAsLinesSync();

  final int answer1 = part1(input);
  print(answer1);

  final int answer2 = part2(input);
  print(answer2);
}

/// Direction enum.
enum Direction {
  north,
  east,
  south,
  west,
}

/// Get the height of a tree at location ([x], [y]), described in [input].
int getTreeHeight(List<String> input, int x, int y) {
  return int.parse(input[x][y]);
}

/// Get a list of trees, starting from tree with location ([x], [y]), in
/// direction [direction].
List<int> getTreesInDirection(
  List<String> input,
  int x,
  int y,
  Direction direction,
) {
  switch (direction) {
    case Direction.north:
      return input
          .getRange(0, x)
          .map((treeString) => int.parse(treeString[y]))
          .toList()
          .reversed
          .toList();
    case Direction.east:
      return input[x]
          .substring(y + 1)
          .codeUnits
          .map((codeUnit) => int.parse(String.fromCharCode(codeUnit)))
          .toList();
    case Direction.south:
      return input
          .getRange(x + 1, input.length)
          .map((treeString) => int.parse(treeString[y]))
          .toList();
    case Direction.west:
      return input[x]
          .substring(0, y)
          .codeUnits
          .reversed
          .map((codeUnit) => int.parse(String.fromCharCode(codeUnit)))
          .toList();
  }
}

/// Check if tree at location ([x], [y]) is visible from outside the forest.
///
/// If the tree can 'see' the outside from any direction it is visible.
bool isTreeVisible(
  List<String> input,
  int x,
  int y,
) {
  final int treeHeight = getTreeHeight(input, x, y);

  return Direction.values
      .map((direction) => getTreesInDirection(input, x, y, direction))
      .any((trees) => trees.every((tree) => tree < treeHeight));
}

/// Extensions for [List].
extension ListExtension on List {
  /// Strip lagging duplicates in this [List].
  ///
  /// Examples:
  /// - [1,2,3].removeLaggingDuplicates() -> [1,2,3]
  /// - [1,2,2,3,3].removeLaggingDuplicates() -> [1,2,2,3]
  List<T> removeLaggingDuplicates<T>() {
    final List<T> reversedList = this.reversed.toList() as List<T>;
    final List<T> newList = [];

    for (int index = 0; index < reversedList.length - 1; index++) {
      if (reversedList[index] != reversedList[index + 1]) {
        newList.addAll(reversedList.sublist(index));
        break;
      }
    }
    return newList.reversed.toList();
  }
}

/// Returns the scenic score of a tree at location ([x], [y]).
///
/// The scenic score is the product of the number of trees that can be seen from
/// any direction from the tree at ([x], [y]).
int getScenicScore(
  List<String> input,
  int x,
  int y,
) {
  final int treeHeight = getTreeHeight(input, x, y);

  final List<List<int>> treeRanges = Direction.values
      .map((direction) => getTreesInDirection(input, x, y, direction))
      .toList();

  if (treeRanges.any((treeRange) => treeRange.length == 0)) {
    return 0;
  }

  return treeRanges.map((treeRange) {
    int visibleTrees = 0;
    for (int treeIndex = 0; treeIndex < treeRange.length; treeIndex++) {
      visibleTrees++;

      if (treeRange[treeIndex] >= treeHeight) {
        break;
      }
    }
    return visibleTrees;
  }).reduce((score, visibleTrees) => score * visibleTrees);
}

/// --- Day 8: Treetop Tree House ---
///
/// The expedition comes across a peculiar patch of tall trees all planted
/// carefully in a grid. The Elves explain that a previous expedition planted
/// these trees as a reforestation effort. Now, they're curious if this would be
/// a good location for a tree house.
///
/// First, determine whether there is enough tree cover here to keep a tree
/// house hidden. To do this, you need to count the number of trees that are
/// visible from outside the grid when looking directly along a row or column.
///
/// The Elves have already launched a quadcopter to generate a map with the
/// height of each tree (your puzzle input). For example:
///
/// 30373
/// 25512
/// 65332
/// 33549
/// 35390
///
///
/// Each tree is represented as a single digit whose value is its height, where
/// 0 is the shortest and 9 is the tallest.
///
/// A tree is visible if all of the other trees between it and an edge of the
/// grid are shorter than it. Only consider trees in the same row or column;
/// that is, only look up, down, left, or right from any given tree.
///
/// All of the trees around the edge of the grid are visible - since they are
/// already on the edge, there are no trees to block the view. In this example,
/// that only leaves the interior nine trees to consider:
///
/// - The top-left 5 is visible from the left and top. (It isn't visible from
///   the right or bottom since other trees of height 5 are in the way.)
/// - The top-middle 5 is visible from the top and right.
/// - The top-right 1 is not visible from any direction; for it to be visible,
///   there would need to only be trees of height 0 between it and an edge.
/// - The left-middle 5 is visible, but only from the right.
/// - The center 3 is not visible from any direction; for it to be visible,
///   there would need to be only trees of at most height 2 between it and an
///   edge.
/// - The right-middle 3 is visible from the right.
/// - In the bottom row, the middle 5 is visible, but the 3 and 4 are not.
///
///
/// With 16 trees visible on the edge and another 5 visible in the interior, a
/// total of 21 trees are visible in this arrangement.
///
/// Consider your map; how many trees are visible from outside the grid?
int part1(List<String> input) {
  int visibleTrees = 0;
  for (int x = 0; x < input.length; x++) {
    for (int y = 0; y < input[0].length; y++) {
      if (isTreeVisible(input, x, y)) {
        visibleTrees++;
      }
    }
  }
  return visibleTrees;
}

/// --- Part Two ---
///
/// Content with the amount of tree cover available, the Elves just need to know
/// the best spot to build their tree house: they would like to be able to see a
/// lot of trees.
///
/// To measure the viewing distance from a given tree, look up, down, left, and
/// right from that tree; stop if you reach an edge or at the first tree that is
/// the same height or taller than the tree under consideration. (If a tree is
/// right on the edge, at least one of its viewing distances will be zero.)
///
/// The Elves don't care about distant trees taller than those found by the
/// rules above; the proposed tree house has large eaves to keep it dry, so they
/// wouldn't be able to see higher than the tree house anyway.
///
/// In the example above, consider the middle 5 in the second row:
///
/// 30373
/// 25512
/// 65332
/// 33549
/// 35390
///
///
/// - Looking up, its view is not blocked; it can see 1 tree (of height 3).
/// - Looking left, its view is blocked immediately; it can see only 1 tree (of
///   height 5, right next to it).
/// - Looking right, its view is not blocked; it can see 2 trees.
/// - Looking down, its view is blocked eventually; it can see 2 trees (one of
///   height 3, then the tree of height 5 that blocks its view).
///
///
/// A tree's scenic score is found by multiplying together its viewing distance
/// in each of the four directions. For this tree, this is 4 (found by
/// multiplying 1 * 1 * 2 * 2).
///
/// However, you can do even better: consider the tree of height 5 in the middle
/// of the fourth row:
///
/// 30373
/// 25512
/// 65332
/// 33549
/// 35390
///
///
/// - Looking up, its view is blocked at 2 trees (by another tree with a height
///   of 5).
/// - Looking left, its view is not blocked; it can see 2 trees.
/// - Looking down, its view is also not blocked; it can see 1 tree.
/// - Looking right, its view is blocked at 2 trees (by a massive tree of height
///   9).
///
///
/// This tree's scenic score is 8 (2 * 2 * 1 * 2); this is the ideal spot for
/// the tree house.
///
/// Consider each tree on your map. What is the highest scenic score possible
/// for any tree?
int part2(List<String> input) {
  int maxScore = 0;
  for (int x = 0; x < input.length; x++) {
    for (int y = 0; y < input[0].length; y++) {
      maxScore = max(getScenicScore(input, x, y), maxScore);
    }
  }
  return maxScore;
}
