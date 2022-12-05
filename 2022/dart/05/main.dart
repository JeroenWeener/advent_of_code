import 'dart:collection';
import 'dart:io';

void main() {
  final List<String> input = File('2022/dart/05/input.txt').readAsLinesSync();

  final String answer1 = part1(input);
  print(answer1);

  final String answer2 = part2(input);
  print(answer2);
}

/// Convert puzzle input to [Instructions].
Instructions parseInstructions(List<String> input) {
  final List<MoveCommand> commands = [];
  final List<Queue<int>> stacks = List.generate(
    (input.first.length + 1) ~/ 4,
    (e) => Queue<int>(),
    growable: false,
  );

  bool isParsingCommands = false;

  for (final line in input) {
    if (line.isEmpty || line.startsWith(' 1')) {
      isParsingCommands = true;
      continue;
    }

    if (!isParsingCommands) {
      for (int i = 0; i < (line.length + 1) ~/ 4; i++) {
        final int location = i * 4 + 1;
        final int crate = line.codeUnitAt(location);

        // Ignore spaces.
        if (crate != ' '.codeUnitAt(0)) {
          stacks.elementAt(i).add(crate);
        }
      }
    } else {
      commands.add(MoveCommand.fromLine(line));
    }
  }

  return Instructions(
    stacks: stacks,
    commands: commands,
  );
}

/// [Instructions] class representing both the initial crate setup as the
/// rearrangement commands.
class Instructions {
  const Instructions({
    required this.stacks,
    required this.commands,
  });

  final List<Queue<int>> stacks;
  final List<MoveCommand> commands;
}

/// [CrateMover] class representing the crate mover.
///
/// Given [instructions] and a [moveCrates] function, calling [rearrange] will
/// provide a [String] describing the top crates.
class CrateMover {
  CrateMover({
    required Instructions instructions,
    required this.moveCrates,
  })  : stacks = instructions.stacks,
        commands = instructions.commands;

  final List<Queue<int>> stacks;
  final List<MoveCommand> commands;
  final Function(int, Queue<int>, Queue<int>) moveCrates;

  /// Rearrange the crates in [stacks] according to the moves in [commands] and
  /// return a [String] describing the top items in the final configuration.
  String rearrange() {
    commands.forEach((command) => moveCrates(
          command.amount,
          stacks[command.from - 1],
          stacks[command.to - 1],
        ));
    return stacks
        .map((stack) => String.fromCharCode(stack.first))
        .reduce((total, char) => total + char);
  }
}

/// [MoveCommand] class representing a single move for a [CrateMover].
class MoveCommand {
  const MoveCommand({
    required this.amount,
    required this.from,
    required this.to,
  });

  /// Create a new [MoveCommand] from a single line of input.
  ///
  /// Example: move 3 from 1 to 7.
  factory MoveCommand.fromLine(String line) {
    List<int> numbers = line
        .split(' ')
        .map((e) => int.tryParse(e))
        .where((element) => element != null)
        .map((e) => e!)
        .toList();
    return MoveCommand(
      amount: numbers[0],
      from: numbers[1],
      to: numbers[2],
    );
  }

  final int amount;
  final int from;
  final int to;

  @override
  String toString() {
    return '{$amount $from $to}';
  }
}

/// --- Day 5: Supply Stacks ---
///
/// The expedition can depart as soon as the final supplies have been unloaded
/// from the ships. Supplies are stored in stacks of marked crates, but because
/// the needed supplies are buried under many other crates, the crates need to
/// be rearranged.
///
/// The ship has a giant cargo crane capable of moving crates between stacks. To
/// ensure none of the crates get crushed or fall over, the crane operator will
/// rearrange them in a series of carefully-planned steps. After the crates are
/// rearranged, the desired crates will be at the top of each stack.
///
/// The Elves don't want to interrupt the crane operator during this delicate
/// procedure, but they forgot to ask her which crate will end up where, and
/// they want to be ready to unload them as soon as possible so they can embark.
///
/// They do, however, have a drawing of the starting stacks of crates and the
/// rearrangement procedure (your puzzle input). For example:
///
///     [D]
/// [N] [C]
/// [Z] [M] [P]
///  1   2   3
///
/// move 1 from 2 to 1
/// move 3 from 1 to 3
/// move 2 from 2 to 1
/// move 1 from 1 to 2
///
///
/// In this example, there are three stacks of crates. Stack 1 contains two
/// crates: crate Z is on the bottom, and crate N is on top. Stack 2 contains
/// three crates; from bottom to top, they are crates M, C, and D. Finally,
/// stack 3 contains a single crate, P.
///
/// Then, the rearrangement procedure is given. In each step of the procedure, a
/// quantity of crates is moved from one stack to a different stack. In the
/// first step of the above rearrangement procedure, one crate is moved from
/// stack 2 to stack 1, resulting in this configuration:
///
/// [D]
/// [N] [C]
/// [Z] [M] [P]
///  1   2   3
///
///
/// In the second step, three crates are moved from stack 1 to stack 3. Crates
/// are moved one at a time, so the first crate to be moved (D) ends up below
/// the second and third crates:
///
///         [Z]
///         [N]
///     [C] [D]
///     [M] [P]
///  1   2   3
///
///
/// Then, both crates are moved from stack 2 to stack 1. Again, because crates
/// are moved one at a time, crate C ends up below crate M:
///
///         [Z]
///         [N]
/// [M]     [D]
/// [C]     [P]
///  1   2   3
///
///
/// Finally, one crate is moved from stack 1 to stack 2:
///
///         [Z]
///         [N]
///         [D]
/// [C] [M] [P]
///  1   2   3
///
///
/// The Elves just need to know which crate will end up on top of each stack; in
/// this example, the top crates are C in stack 1, M in stack 2, and Z in stack
/// 3, so you should combine these together and give the Elves the message CMZ.
///
/// After the rearrangement procedure completes, what crate ends up on top of
/// each stack?
String part1(List<String> input) {
  return CrateMover(
    instructions: parseInstructions(input),
    moveCrates: (int amount, Queue<int> from, Queue<int> to) {
      for (int i = 0; i < amount; i++) {
        int i = from.removeFirst();
        to.addFirst(i);
      }
    },
  ).rearrange();
}

/// --- Part Two ---
///
/// As you watch the crane operator expertly rearrange the crates, you notice
/// the process isn't following your prediction.
///
/// Some mud was covering the writing on the side of the crane, and you quickly
/// wipe it away. The crane isn't a CrateMover 9000 - it's a CrateMover 9001.
///
/// The CrateMover 9001 is notable for many new and exciting features: air
/// conditioning, leather seats, an extra cup holder, and the ability to pick up
/// and move multiple crates at once.
///
/// Again considering the example above, the crates begin in the same
/// configuration:
///
///     [D]
/// [N] [C]
/// [Z] [M] [P]
///  1   2   3
///
///
/// Moving a single crate from stack 2 to stack 1 behaves the same as before:
///
/// [D]
/// [N] [C]
/// [Z] [M] [P]
///  1   2   3
///
///
/// However, the action of moving three crates from stack 1 to stack 3 means
/// that those three moved crates stay in the same order, resulting in this new
/// configuration:
///
///         [D]
///         [N]
///     [C] [Z]
///     [M] [P]
///  1   2   3
///
///
/// Next, as both crates are moved from stack 2 to stack 1, they retain their
/// order as well:
///
///         [D]
///         [N]
/// [C]     [Z]
/// [M]     [P]
///  1   2   3
///
///
/// Finally, a single crate is still moved from stack 1 to stack 2, but now it's
/// crate C that gets moved:
///
///         [D]
///         [N]
///         [Z]
/// [M] [C] [P]
///  1   2   3
///
///
/// In this example, the CrateMover 9001 has put the crates in a totally
/// different order: MCD.
///
/// Before the rearrangement process finishes, update your simulation so that
/// the Elves know where they should stand to be ready to unload the final
/// supplies. After the rearrangement procedure completes, what crate ends up on
/// top of each stack?
String part2(List<String> input) {
  return CrateMover(
    instructions: parseInstructions(input),
    moveCrates: (int amount, Queue<int> from, Queue<int> to) {
      List<int> numbers = List.generate(amount, (index) => null)
          .map((e) => from.removeFirst())
          .toList();
      numbers.reversed.forEach((element) => to.addFirst(element));
    },
  ).rearrange();
}
