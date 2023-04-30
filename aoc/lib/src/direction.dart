/// Wind direction with 8 possible options.
enum DirectionEight {
  north,
  northeast,
  east,
  southeast,
  south,
  southwest,
  west,
  northwest;

  DirectionEight get left => DirectionEight.values[(index - 1) % 8];
  DirectionEight get right => DirectionEight.values[(index + 1) % 8];
  DirectionEight get opposite => DirectionEight.values[(index + 4) % 8];
}

/// Wind direction with 4 possible options.
enum DirectionFour {
  north,
  east,
  south,
  west;

  DirectionFour get left => DirectionFour.values[(index - 1) % 4];
  DirectionFour get right => DirectionFour.values[(index + 1) % 4];
  DirectionFour get opposite => DirectionFour.values[(index + 2) % 4];
}
