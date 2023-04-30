import 'package:aoc/aoc.dart';

void main(List<String> args) async {
  final List<String> puzzleInput = await AocApiManager().getPuzzleInput();

  final Iterable<int> draws =
      puzzleInput.first.split(',').map((e) => int.parse(e));
  final List<Board> boards = parseBoards(puzzleInput.skip(2)).toList();

  final int solution1 = part1(draws, boards);
  print(solution1);

  final int solution2 = part2(draws, boards);
  print(solution2);
}

class Board {
  Board.fromNumbers(Iterable<Iterable<int>> numbers)
      : _numbers = List.generate(
          numbers.length,
          (int i) => List.generate(
            numbers.first.length,
            (int j) => Pair(numbers.elementAt(i).elementAt(j), false),
          ),
        );

  const Board(Iterable<Iterable<Pair<int, bool>>> numbers) : _numbers = numbers;

  final Iterable<Iterable<Pair<int, bool>>> _numbers;

  Board mark(int number) {
    return Board(_numbers.map(
      (Iterable<Pair<int, bool>> e) =>
          e.map((Pair<int, bool> p) => p.l == number ? Pair(p.l, true) : p),
    ));
  }

  bool get hasWinner => hasRow || hasColumn;
  bool get hasColumn => _numbers
      .transpose()
      .any((element) => element.every((element) => element.r));
  bool get hasRow =>
      _numbers.any((element) => element.every((element) => element.r));

  int get unmarkedScore => hasWinner
      ? _numbers.expand((element) => element).map((e) => e.r ? 0 : e.l).sum()
      : 0;

  @override
  String toString() {
    return _numbers.map((e) => e.join(',')).join('\n');
  }
}

Board parseBoard(Iterable<String> boardStrings) {
  return Board.fromNumbers(boardStrings
      .map((boardString) => boardString.splitWs().map((e) => int.parse(e))));
}

Iterable<Board> parseBoards(Iterable<String> boardStrings) {
  return boardStrings.splitOnEmptyLine().map((List<String> e) => parseBoard(e));
}

int part1(Iterable<int> draws, List<Board> boards) {
  for (int draw in draws) {
    for (int boardIndex = 0; boardIndex < boards.length; boardIndex++) {
      boards[boardIndex] = boards[boardIndex].mark(draw);
      if (boards[boardIndex].hasWinner) {
        return boards[boardIndex].unmarkedScore * draw;
      }
    }
  }

  return -1;
}

int part2(Iterable<int> draws, List<Board> boards) {
  for (int draw in draws) {
    List<int> indexesToRemove = [];
    for (int boardIndex = 0; boardIndex < boards.length; boardIndex++) {
      boards[boardIndex] = boards[boardIndex].mark(draw);
      if (boards[boardIndex].hasWinner) {
        if (boards.length == 1) {
          return boards[boardIndex].unmarkedScore * draw;
        } else {
          indexesToRemove.add(boardIndex);
        }
      }
    }

    for (int index in indexesToRemove.reversed) {
      boards.removeAt(index);
    }
    indexesToRemove = [];
  }

  return -1;
}
