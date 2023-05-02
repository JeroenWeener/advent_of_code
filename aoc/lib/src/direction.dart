/// Wind direction with 8 possible options.
enum Direction8 {
  north,
  northeast,
  east,
  southeast,
  south,
  southwest,
  west,
  northwest;

  Direction8 operator ~() => flip;

  Direction8 get l => rotateLeft;
  Direction8 get rotateLeft => Direction8.values[(index - 1) % 8];
  Direction8 get r => rotateRight;
  Direction8 get rotateRight => Direction8.values[(index + 1) % 8];
  Direction8 get f => flip;
  Direction8 get flip => Direction8.values[(index + 4) % 8];
}

/// Wind direction with 4 possible options.
enum Direction4 {
  north,
  east,
  south,
  west;

  Direction4 operator ~() => flip;

  Direction4 get l => rotateLeft;
  Direction4 get rotateLeft => Direction4.values[(index - 1) % 4];
  Direction4 get r => rotateRight;
  Direction4 get rotateRight => Direction4.values[(index + 1) % 4];
  Direction4 get f => flip;
  Direction4 get flip => Direction4.values[(index + 2) % 4];

  Direction8 toDirection8() => Direction8.values[2 * index];
}
