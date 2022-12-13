import 'dart:io';
import 'dart:math';

void main() {
  List<String> input = File('2022/dart/13/input.txt').readAsLinesSync();

  int answer1 = part1(input);
  print(answer1);

  int answer2 = part2(input);
  print(answer2);
}

/// Recursive algorithm to determines whether [a] and [b] are in order according
/// to the rules presented by the puzzle.
///
/// As order can be undetermined, this algorithm returns [bool?], using [null]
/// to represent the undetermined state.
///
/// [intWasWrapped] is set to true if an [int] was wrapped in a list in a
/// previous iteration. This will slightly change the logic.
bool? isInOrder<T, U>(T a, U b, {bool intWasWrapped = false}) {
  // If both values are integers, the lower integer should come first.
  if (a is int && b is int) {
    // Left side is smaller, so inputs are in the right order.
    if (a < b) {
      return true;
    }
    // Right side is smaller, so inputs are not in the right order.
    if (a > b) {
      return false;
    }
    // Inputs are the same integer; continue checking the next part of the
    // input.
    return null;
  }

  // If both values are lists,
  if (a is List && b is List) {
    // compare the first value of each list, then the second value, and so on.
    for (int listIndex = 0; listIndex < min(a.length, b.length); listIndex++) {
      bool? isPairInOrder = isInOrder(a[listIndex], b[listIndex]);
      if (isPairInOrder != null) {
        return isPairInOrder;
      }
    }

    // Left side ran out of elements, so inputs are in the right order.
    if (a.length < b.length) {
      return true;
    }

    // Right side ran out of elements, so inputs are not in the right order.
    if (a.length > b.length) {
      return false;
    }

    // No comparison made a decision about the order, continue checking the next
    // part of the input.
    return null;
  }

  // If exactly one value is an integer, convert the integer to a list which
  // contains that integer as its only value, then retry the comparison.
  if (a is int && b is List) {
    return isInOrder<List, List>([a], b, intWasWrapped: true);
  }
  if (a is List && b is int) {
    return isInOrder<List, List>(a, [b], intWasWrapped: true);
  }

  return null;
}

/// Merge sort implementation for a [List] containing element of type [T].
///
/// Merge sort uses the divide-and-conquer approach to sort its list.
List<T> mergeSort<T>(List<T> list) {
  // Nothing to sort, return [list].
  if (list.length == 1) {
    return list;
  }

  // Split list halfway.
  List<T> partA = mergeSort(list.sublist(0, list.length ~/ 2));
  List<T> partB = mergeSort(list.sublist(list.length ~/ 2));

  List<T> result = [];

  // Add elements from the front of both lists until one of them is empty. Pick
  // the lowest of the two elements to add.
  while (partA.isNotEmpty && partB.isNotEmpty) {
    if (isInOrder(partA.first, partB.first) ?? true) {
      result.add(partA.removeAt(0));
    } else {
      result.add(partB.removeAt(0));
    }
  }

  // One of the lists is empty at this point. Add all remaining elements from
  // the other list to the result.
  result.addAll(partA);
  result.addAll(partB);

  assert(partA.isEmpty && partB.isEmpty);

  return result;
}

/// Parse [String] as a list by iterating over its characters chronologically.
List parseList(String listString) {
  assert(listString[0] == '[');
  assert(listString[listString.length - 1] == ']');

  // Default case, return empty list ([]).
  if (listString == '[]') {
    return [];
  }

  // Remove outermost '[' and ']'.
  listString = listString.substring(1, listString.length - 1);

  // Scope the character under evaluation is in. If it is not in scope 0, we are
  // not interested, as it will be parsed deeper in the recursion.
  int scope = 0;

  // The elements in this list.
  List elements = [];

  // The starting position of a deeper scope.
  int start = -1;

  // Consecutive number characters. Will be parsed to a number as soon as a
  // non-number character is found or the string ends.
  String number = '';

  for (int characterIndex = 0;
      characterIndex < listString.length;
      characterIndex++) {
    // New scope is opened.
    if (listString[characterIndex] == '[') {
      if (scope == 0) {
        // Record start of scope that is one level beneath.
        start = characterIndex;
      }
      scope++;
      // Deepest scope is closed.
    } else if (listString[characterIndex] == ']') {
      scope--;
      if (scope == 0) {
        // Parse inner list
        List innerList =
            parseList(listString.substring(start, characterIndex + 1));
        elements.add(innerList);
      }
    } else if (scope == 0) {
      if (int.tryParse(listString[characterIndex]) != null) {
        // Store number characters.
        number += listString[characterIndex];
      } else if (number.isNotEmpty) {
        // Flush number as soon as a non-number character is found.
        elements.add(int.parse(number));
        number = '';
      }
    }
  }

  // Flush remaining numbers.
  if (number.isNotEmpty) {
    elements.add(int.parse(number));
  }

  return elements;
}

/// Group a [List] in groups of [groupSize].
List<List> groupLists(
  List lists, {
  int groupSize = 2,
}) {
  List<List> groups = [];

  for (int listsIndex = 0; listsIndex < lists.length; listsIndex += groupSize) {
    List group = lists.sublist(listsIndex, listsIndex + groupSize);
    groups.add(group);
  }

  return groups;
}

/// Extract a [List] of [List]s from the puzzle [input].
List<List> extractLists(List<String> input) {
  return input
      .where((line) => line != '')
      .map((listLine) => parseList(listLine))
      .toList();
}

/// --- Day 13: Distress Signal ---
///
/// You climb the hill and again try contacting the Elves. However, you instead
/// receive a signal you weren't expecting: a distress signal.
///
/// Your handheld device must still not be working properly; the packets from
/// the distress signal got decoded out of order. You'll need to re-order the
/// list of received packets (your puzzle input) to decode the message.
///
/// Your list consists of pairs of packets; pairs are separated by a blank line.
/// You need to identify how many pairs of packets are in the right order.
///
/// For example:
///
///   [1,1,3,1,1]
///   [1,1,5,1,1]
///
///   [[1],[2,3,4]]
///   [[1],4]
///
///   [9]
///   [[8,7,6]]
///
///   [[4,4],4,4]
///   [[4,4],4,4,4]
///
///   [7,7,7,7]
///   [7,7,7]
///
///   []
///   [3]
///
///   [[[]]]
///   [[]]
///
///   [1,[2,[3,[4,[5,6,7]]]],8,9]
///   [1,[2,[3,[4,[5,6,0]]]],8,9]
///
///
/// Packet data consists of lists and integers. Each list starts with [, ends
/// with ], and contains zero or more comma-separated values (either integers or
/// other lists). Each packet is always a list and appears on its own line.
///
/// When comparing two values, the first value is called left and the second
/// value is called right. Then:
///
/// - If both values are integers, the lower integer should come first. If the
///   left integer is lower than the right integer, the inputs are in the right
///   order. If the left integer is higher than the right integer, the inputs
///   are not in the right order. Otherwise, the inputs are the same integer;
///   continue checking the next part of the input.
/// - If both values are lists, compare the first value of each list, then the
///   second value, and so on. If the left list runs out of items first, the
///   inputs are in the right order. If the right list runs out of items first,
///   the inputs are not in the right order. If the lists are the same length
///   and no comparison makes a decision about the order, continue checking the
///   next part of the input.
/// - If exactly one value is an integer, convert the integer to a list which
///   contains that integer as its only value, then retry the comparison.
///   For example, if comparing [0,0,0] and 2, convert the right value to [2]
///   (a list containing 2); the result is then found by instead comparing
///   [0,0,0] and [2].
///
///
/// Using these rules, you can determine which of the pairs in the example are
/// in the right order:
///
///   == Pair 1 ==
///   - Compare [1,1,3,1,1] vs [1,1,5,1,1]
///     - Compare 1 vs 1
///     - Compare 1 vs 1
///     - Compare 3 vs 5
///       - Left side is smaller, so inputs are in the right order
///
///   == Pair 2 ==
///   - Compare [[1],[2,3,4]] vs [[1],4]
///     - Compare [1] vs [1]
///       - Compare 1 vs 1
///     - Compare [2,3,4] vs 4
///       - Mixed types; convert right to [4] and retry comparison
///       - Compare [2,3,4] vs [4]
///         - Compare 2 vs 4
///           - Left side is smaller, so inputs are in the right order
///
///   == Pair 3 ==
///   - Compare [9] vs [[8,7,6]]
///     - Compare 9 vs [8,7,6]
///       - Mixed types; convert left to [9] and retry comparison
///       - Compare [9] vs [8,7,6]
///         - Compare 9 vs 8
///           - Right side is smaller, so inputs are not in the right order
///
///   == Pair 4 ==
///   - Compare [[4,4],4,4] vs [[4,4],4,4,4]
///     - Compare [4,4] vs [4,4]
///       - Compare 4 vs 4
///       - Compare 4 vs 4
///     - Compare 4 vs 4
///     - Compare 4 vs 4
///     - Left side ran out of items, so inputs are in the right order
///
///   == Pair 5 ==
///   - Compare [7,7,7,7] vs [7,7,7]
///     - Compare 7 vs 7
///     - Compare 7 vs 7
///     - Compare 7 vs 7
///     - Right side ran out of items, so inputs are not in the right order
///
///   == Pair 6 ==
///   - Compare [] vs [3]
///     - Left side ran out of items, so inputs are in the right order
///
///   == Pair 7 ==
///   - Compare [[[]]] vs [[]]
///     - Compare [[]] vs []
///       - Right side ran out of items, so inputs are not in the right order
///
///   == Pair 8 ==
///   - Compare [1,[2,[3,[4,[5,6,7]]]],8,9] vs [1,[2,[3,[4,[5,6,0]]]],8,9]
///     - Compare 1 vs 1
///     - Compare [2,[3,[4,[5,6,7]]]] vs [2,[3,[4,[5,6,0]]]]
///       - Compare 2 vs 2
///       - Compare [3,[4,[5,6,7]]] vs [3,[4,[5,6,0]]]
///         - Compare 3 vs 3
///         - Compare [4,[5,6,7]] vs [4,[5,6,0]]
///           - Compare 4 vs 4
///           - Compare [5,6,7] vs [5,6,0]
///             - Compare 5 vs 5
///             - Compare 6 vs 6
///             - Compare 7 vs 0
///               - Right side is smaller, so inputs are not in the right order
///
///
/// What are the indices of the pairs that are already in the right order? (The
/// first pair has index 1, the second pair has index 2, and so on.) In the
/// above example, the pairs in the right order are 1, 2, 4, and 6; the sum of
/// these indices is 13.
///
/// Determine which pairs of packets are already in the right order. What is the
/// sum of the indices of those pairs?
int part1(List<String> input) {
  List<List> listPairs = groupLists(extractLists(input), groupSize: 2);

  int indexSum = 0;
  for (int index = 0; index < listPairs.length; index++) {
    bool? areListsOrdered = isInOrder<List, List>(
          listPairs[index][0],
          listPairs[index][1],
        ) ??
        false;
    if (areListsOrdered) {
      indexSum += index + 1;
    }
  }

  return indexSum;
}

/// --- Part Two ---
///
/// Now, you just need to put all of the packets in the right order. Disregard
/// the blank lines in your list of received packets.
///
/// The distress signal protocol also requires that you include two additional
/// divider packets:
///
///   [[2]]
///   [[6]]
///
///
/// Using the same rules as before, organize all packets - the ones in your list
/// of received packets as well as the two divider packets - into the correct
/// order.
///
/// For the example above, the result of putting the packets in the correct
/// order is:
///
///   []
///   [[]]
///   [[[]]]
///   [1,1,3,1,1]
///   [1,1,5,1,1]
///   [[1],[2,3,4]]
///   [1,[2,[3,[4,[5,6,0]]]],8,9]
///   [1,[2,[3,[4,[5,6,7]]]],8,9]
///   [[1],4]
///   [[2]]
///   [3]
///   [[4,4],4,4]
///   [[4,4],4,4,4]
///   [[6]]
///   [7,7,7]
///   [7,7,7,7]
///   [[8,7,6]]
///   [9]
///
///
/// Afterward, locate the divider packets. To find the decoder key for this
/// distress signal, you need to determine the indices of the two divider
/// packets and multiply them together. (The first packet is at index 1, the
/// second packet is at index 2, and so on.) In this example, the divider
/// packets are 10th and 14th, and so the decoder key is 140.
///
/// Organize all of the packets into the correct order. What is the decoder key
/// for the distress signal?
int part2(List<String> input) {
  List<List> lists = extractLists(input);

  List<List> extraPackets = [
    [
      [2]
    ],
    [
      [6]
    ]
  ];

  List<List> sortedLists = mergeSort<List>([...extraPackets, ...lists]);

  return extraPackets
      .map((packet) => sortedLists.indexOf(packet) + 1)
      .reduce((product, index) => product * index);
}
