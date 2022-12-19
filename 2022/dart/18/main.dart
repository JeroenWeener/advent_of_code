import 'dart:io';

void main() {
  List<String> input = File('2022/dart/18/input.txt').readAsLinesSync();

  int answer1 = part1(input);
  print(answer1);

  int answer2 = part2(input);
  print(answer2);
}

/// Returns the 6 blocks adjacent to the provided [block].
Iterable<String> adjacentBlocks(String block) {
  List<int> coordinates = block.split(',').map((e) => int.parse(e)).toList();
  return [
    [coordinates[0], coordinates[1], coordinates[2] - 1],
    [coordinates[0], coordinates[1], coordinates[2] + 1],
    [coordinates[0], coordinates[1] - 1, coordinates[2]],
    [coordinates[0], coordinates[1] + 1, coordinates[2]],
    [coordinates[0] - 1, coordinates[1], coordinates[2]],
    [coordinates[0] + 1, coordinates[1], coordinates[2]],
  ].map((coordinates) => coordinates.join(','));
}

/// Iteratively removes blocks in [blocks] that are adjacent to [block].
///
/// If [block] is not in [blocks], nothing happens.
void removeAdjacentBlocks(List<String> blocks, String block) {
  if (blocks.contains(block)) {
    blocks.remove(block);
    adjacentBlocks(block)
        .where((adjBlock) => blocks.contains(adjBlock))
        .forEach((adjBlock) => removeAdjacentBlocks(blocks, adjBlock));
  }
}

/// --- Day 18: Boiling Boulders ---
///
/// You and the elephants finally reach fresh air. You've emerged near the base
/// of a large volcano that seems to be actively erupting! Fortunately, the lava
/// seems to be flowing away from you and toward the ocean.
///
/// Bits of lava are still being ejected toward you, so you're sheltering in the
/// cavern exit a little longer. Outside the cave, you can see the lava landing
/// in a pond and hear it loudly hissing as it solidifies.
///
/// Depending on the specific compounds in the lava and speed at which it cools,
/// it might be forming obsidian! The cooling rate should be based on the
/// surface area of the lava droplets, so you take a quick scan of a droplet as
/// it flies past you (your puzzle input).
///
/// Because of how quickly the lava is moving, the scan isn't very good; its
/// resolution is quite low and, as a result, it approximates the shape of the
/// lava droplet with 1x1x1 cubes on a 3D grid, each given as its x,y,z
/// position.
///
/// To approximate the surface area, count the number of sides of each cube that
/// are not immediately connected to another cube. So, if your scan were only
/// two adjacent cubes like 1,1,1 and 2,1,1, each cube would have a single side
/// covered and five sides exposed, a total surface area of 10 sides.
///
/// Here's a larger example:
///
///   2,2,2
///   1,2,2
///   3,2,2
///   2,1,2
///   2,3,2
///   2,2,1
///   2,2,3
///   2,2,4
///   2,2,6
///   1,2,5
///   3,2,5
///   2,1,5
///   2,3,5
///
///
/// In the above example, after counting up all the sides that aren't connected
/// to another cube, the total surface area is 64.
///
/// What is the surface area of your scanned lava droplet?
int part1(List<String> input) {
  return input
      .map((block) =>
          6 -
          adjacentBlocks(block)
              .where((adjacent) => input.contains(adjacent))
              .length)
      .reduce((total, faces) => total + faces);
}

/// --- Part Two ---
///
/// Something seems off about your calculation. The cooling rate depends on
/// exterior surface area, but your calculation also included the surface area
///of air pockets trapped in the lava droplet.
///
/// Instead, consider only cube sides that could be reached by the water and
/// steam as the lava droplet tumbles into the pond. The steam will expand to
/// reach as much as possible, completely displacing any air on the outside of
/// the lava droplet but never expanding diagonally.
///
/// In the larger example above, exactly one cube of air is trapped within the
/// lava droplet (at 2,2,5), so the exterior surface area of the lava droplet is
/// 58.
///
/// What is the exterior surface area of your scanned lava droplet?
int part2(List<String> input) {
  /// Determine rough dimensions of lava droplet.
  List<int> xs = input.map((e) => int.parse(e.split(',')[0])).toList();
  List<int> ys = input.map((e) => int.parse(e.split(',')[1])).toList();
  List<int> zs = input.map((e) => int.parse(e.split(',')[2])).toList();

  int minX = xs.reduce((a, b) => a < b ? a : b);
  int maxX = xs.reduce((a, b) => a > b ? a : b);
  int minY = ys.reduce((a, b) => a < b ? a : b);
  int maxY = ys.reduce((a, b) => a > b ? a : b);
  int minZ = zs.reduce((a, b) => a < b ? a : b);
  int maxZ = zs.reduce((a, b) => a > b ? a : b);

  /// Construct the negation of the input; all empty spaces within previously
  /// calculated dimensions.
  List<String> emptySpaces = [];

  for (int x = minX; x <= maxX; x++) {
    for (int y = minY; y <= maxY; y++) {
      for (int z = minZ; z <= maxZ; z++) {
        final coordinate = '$x,$y,$z';

        if (!input.contains(coordinate)) {
          emptySpaces.add(coordinate);
        }
      }
    }
  }

  /// Loop over the outer area of the dimensions to iteratively remove groups of
  /// empty spaces. The remaining spaces are those that are contained within the
  /// droplet.

  /// Go over faces 1 and 2.
  for (int x = minX; x <= maxX; x++) {
    for (int y = minY; y <= maxY; y++) {
      removeAdjacentBlocks(emptySpaces, '$x,$y,$minZ');
      removeAdjacentBlocks(emptySpaces, '$x,$y,$maxZ');
    }
  }

  /// Go over faces 3 and 4.
  for (int x = minX; x <= maxX; x++) {
    for (int z = minZ; z <= maxZ; z++) {
      removeAdjacentBlocks(emptySpaces, '$x,$minY,$z');
      removeAdjacentBlocks(emptySpaces, '$x,$maxY,$z');
    }
  }

  /// Go over faces 5 and 6.
  for (int y = minY; y <= maxY; y++) {
    for (int z = minZ; z <= maxZ; z++) {
      removeAdjacentBlocks(emptySpaces, '$minX,$y,$z');
      removeAdjacentBlocks(emptySpaces, '$maxX,$y,$z');
    }
  }

  /// Calculate the total surface area as we did in part 1.
  int totalSurfaceArea = input
      .map((block) =>
          6 -
          adjacentBlocks(block)
              .where((adjacent) => input.contains(adjacent))
              .length)
      .reduce((total, faces) => total + faces);

  /// Calculate the total surface area of the remaining empty spaces, where
  /// an empty block 'has a surface' when it touches a non-empty block.
  int insideSurfaceArea = emptySpaces
      .map((block) => adjacentBlocks(block)
          .where((adjacent) =>
              input.contains(adjacent)) // <- `input` rather than `emptySpaces`
          .length)
      .reduce((total, faces) => total + faces);

  /// The outer surface area is equal to the total surface area of the droplet
  /// minus the total surface area of the contained empty spaces.
  return totalSurfaceArea - insideSurfaceArea;
}
