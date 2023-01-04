import 'dart:io';

void main() {
  List<String> input = File('2022/dart/16/input.txt').readAsLinesSync();

  int answer1 = part1(input);
  print(answer1);

  int answer2 = part2(input);
  print(answer2);
}

int MAX_INT = ~(1 << 63);

class Valve {
  const Valve(
    this.name,
    this.flowRate,
  );

  final String name;
  final int flowRate;

  @override
  bool operator ==(Object other) {
    return other is Valve && name == other.name;
  }

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() {
    return '$name $flowRate';
  }
}

class Pipe {
  const Pipe(
    this.valveA,
    this.valveB,
    this.cost,
  );

  final Valve valveA;
  final Valve valveB;
  final int cost;

  @override
  String toString() {
    return '$valveA $valveB ($cost)';
  }
}

class Graph {
  const Graph(
    this.valves,
    this.pipes,
  );

  final Iterable<Valve> valves;
  final Iterable<Pipe> pipes;

  @override
  String toString() {
    return 'Valves: $valves\nPipes:$pipes';
  }
}

Iterable<Valve> parseValves(List<String> input) {
  return input
      .map(
        (line) => RegExp(r'^Valve ([A-Z][A-Z]) has flow rate=(\d+);.*')
            .firstMatch(line)!
            .groups([1, 2]),
      )
      .map((data) => Valve(data[0]!, int.parse(data[1]!)));
}

Iterable<Pipe> parsePipes(List<String> input, Iterable<Valve> valves) {
  return input.map((line) {
    Valve from = valves.firstWhere((valve) => valve.name == line.split(' ')[1]);
    Iterable<Valve> toValves = line
        .split(', ')
        .map((parts) => parts.split(' ').last)
        .map((valveName) =>
            valves.firstWhere((valve) => valve.name == valveName));
    return toValves.map((to) => Pipe(from, to, 1)).toList();
  }).reduce((allPipes, valvePipes) => allPipes + valvePipes);
}

/// Runs Dijkstra for every valve in [graph].
Graph dijkstra(Graph graph) {
  List<Pipe> pipes = [];

  for (Valve valve in graph.valves) {
    Iterable<Pipe> es = dijkstraIteration(graph, valve);
    pipes.addAll(es);
  }

  return Graph(graph.valves, pipes);
}

/// Perform Dijkstra on [graph] with [source] as source node.
Iterable<Pipe> dijkstraIteration(Graph graph, Valve source) {
  Map<Valve, int> dist = {};
  List<Valve> Q = [];

  for (Valve valve in graph.valves) {
    dist[valve] = MAX_INT;
    Q.add(valve);
  }
  dist[source] = 0;

  while (Q.isNotEmpty) {
    Valve u = getClosestValve(Map.fromEntries(
        dist.entries.where((entries) => Q.contains(entries.key))));
    Q.remove(u);

    Iterable<Valve> neighborsInQ = Q.where(
      (neighborInQ) => graph.pipes.any(
        (pipe) =>
            (pipe.valveA == u && pipe.valveB == neighborInQ) ||
            (pipe.valveA == neighborInQ && pipe.valveB == u),
      ),
    );
    for (Valve v in neighborsInQ) {
      int alt = dist[u]! +
          graph.pipes
              .firstWhere(
                  (element) => element.valveA == u && element.valveB == v)
              .cost;
      if (alt < dist[v]!) {
        dist[v] = alt;
      }
    }
  }

  dist.remove(source);
  return dist.entries.map((entry) => Pipe(source, entry.key, entry.value));
}

Valve getClosestValve(Map<Valve, int> distances) {
  Iterable<MapEntry<Valve, int>> sortedDistances = distances.entries.toList()
    ..sort(((a, b) => a.value - b.value));
  return sortedDistances.first.key;
}

/// Simplify the graph by removing [Valve]s with a [Valve.flowRate] of 0 and
/// [Pipe]s connected to those valves, with the exception of [initialValve].
///
/// We do not remove [initialValve], as we need to maintain our starting
/// position.
Graph simplifyGraph(Graph g, Valve initialValve) {
  Iterable<Valve> relevantValves =
      g.valves.where((valve) => valve == initialValve || valve.flowRate > 0);
  Iterable<Pipe> relevantPipes = g.pipes.where((pipe) =>
      relevantValves.contains(pipe.valveA) &&
      relevantValves.contains(pipe.valveB));

  return Graph(relevantValves, relevantPipes);
}

/// Depth-first search that calculates the maximum pressure that can be released
/// in [graph] in [minutesLeft] minutes, where we have released
/// [releasedPressure] already, have a flow rate of [flowRate], are located in
/// [currentValve] with [unvisitedValves] as remaining valves we can visit.
int soloDfs(
  int minutesLeft,
  Graph graph,
  Valve currentValve,
  int releasedPressure,
  int flowRate,
  Iterable<Valve> unvisitedValves,
) {
  return [
    releasedPressure + flowRate * minutesLeft,
    ...graph.pipes
        .where(
      (pipe) =>
          pipe.valveA == currentValve &&
          unvisitedValves.contains(pipe.valveB) &&
          pipe.cost < minutesLeft,
    )
        .map((pipe) {
      Valve nextValve = pipe.valveB;

      // traveling + opening valve.
      int cost = pipe.cost + 1;

      return soloDfs(
        minutesLeft - cost,
        graph,
        nextValve,
        releasedPressure + flowRate * cost,
        flowRate + nextValve.flowRate,
        unvisitedValves.where((valve) => valve != nextValve),
      );
    })
  ].reduce((a, b) => a > b ? a : b);
}

/// Global variables used for pruning in [duoDfs].
late List<int> releasedPressureRecordPerMinute;
late int maxFlowRate;
late Iterable<int> maxFlowRatePerMinute;

/// Depth-first search that calculates the maximum pressure that can be released
/// in [graph] by two (A and B) in [minutesLeft] minutes, where we have released
/// [releasedPressure] already, have a flow rate of [flowRate], and A is headed
/// for [nextValveA] and B is headed for [nextValveB]. A has to wait for
/// [cooldownA] minutes until it is finished traveling to [nextValveA]. B has to
/// wait for [cooldownB] minutes until it is finished traveling to [nextValveB].
/// [unvisitedValves] are the valves that have not been visited by either A or
/// B.
///
/// Prunes branches using [releasedPressureRecordPerMinute], [maxFlowRate] and
/// [maxFlowRatePerMinute].
int duoDfs(
  int minutesLeft,
  Graph graph,
  Valve nextValveA,
  Valve nextValveB,
  int cooldownA,
  int cooldownB,
  int releasedPressure,
  int flowRate,
  Iterable<Valve> unvisitedValves,
) {
  if (minutesLeft == 0) {
    // Update the released pressure per minute records.
    if (releasedPressure > releasedPressureRecordPerMinute[minutesLeft]) {
      releasedPressureRecordPerMinute[minutesLeft] = releasedPressure;
      for (int i = 1; i < releasedPressureRecordPerMinute.length - 1; i++) {
        releasedPressureRecordPerMinute[i] =
            releasedPressureRecordPerMinute[i - 1] -
                maxFlowRatePerMinute.elementAt(i - 1);
      }
    }
    return releasedPressure;
  }

  // Prune branches that are unable to improve upon the current released
  // pressure record.
  if (releasedPressure < releasedPressureRecordPerMinute[minutesLeft]) {
    return 0;
  }

  Iterable<Pipe> pipesA = [];
  if (cooldownA == 0) {
    flowRate = flowRate + nextValveA.flowRate;
    pipesA = graph.pipes.where((pipe) =>
        pipe.valveA == nextValveA &&
        unvisitedValves.contains(pipe.valveB) &&
        pipe.cost < minutesLeft);
  }

  Iterable<Pipe> pipesB = [];
  if (cooldownB == 0) {
    flowRate = flowRate + nextValveB.flowRate;
    pipesB = graph.pipes.where((pipe) =>
        pipe.valveA == nextValveB &&
        unvisitedValves.contains(pipe.valveB) &&
        pipe.cost < minutesLeft);
  }

  Iterable<Valve> valvesA = [
    ...pipesA.map((e) => e.valveB),
    if (pipesA.length == 0) nextValveA,
  ];
  Iterable<Valve> valvesB = [
    ...pipesB.map((e) => e.valveB),
    if (pipesB.length == 0) nextValveB,
  ];

  List<int> releasedPressureOutcomes = [];

  for (Valve newValveA in valvesA) {
    for (Valve newValveB in valvesB) {
      // Do not let A and B travel to the same pipe.
      if (newValveA == newValveB) {
        continue;
      }

      int newCooldownA = cooldownA - 1;
      int newCooldownB = cooldownB - 1;

      if (newValveA != nextValveA) {
        newCooldownA = graph.pipes
            .firstWhere((element) =>
                element.valveA == nextValveA && element.valveB == newValveA)
            .cost;
      }
      if (newValveB != nextValveB) {
        newCooldownB = graph.pipes
            .firstWhere((element) =>
                element.valveA == nextValveB && element.valveB == newValveB)
            .cost;
      }

      int releasedPressureOutcome = duoDfs(
          minutesLeft - 1,
          graph,
          newValveA,
          newValveB,
          newCooldownA,
          newCooldownB,
          releasedPressure + flowRate,
          flowRate,
          unvisitedValves
              .where((valve) => valve != newValveA && valve != newValveB));

      releasedPressureOutcomes.add(releasedPressureOutcome);
    }
  }

  return [0, ...releasedPressureOutcomes].reduce((a, b) => a > b ? a : b);
}

/// --- Day 16: Proboscidea Volcanium ---
///
/// The sensors have led you to the origin of the distress signal: yet another
/// handheld device, just like the one the Elves gave you. However, you don't
/// see any Elves around; instead, the device is surrounded by elephants! They
/// must have gotten lost in these tunnels, and one of the elephants apparently
/// figured out how to turn on the distress signal.
///
/// The ground rumbles again, much stronger this time. What kind of cave is
/// this, exactly? You scan the cave with your handheld device; it reports
/// mostly igneous rock, some ash, pockets of pressurized gas, magma... this
/// isn't just a cave, it's a volcano!
///
/// You need to get the elephants out of here, quickly. Your device estimates
/// that you have 30 minutes before the volcano erupts, so you don't have time
/// to go back out the way you came in.
///
/// You scan the cave for other options and discover a network of pipes and
/// pressure-release valves. You aren't sure how such a system got into a
/// volcano, but you don't have time to complain; your device produces a report
/// (your puzzle input) of each valve's flow rate if it were opened (in pressure
/// per minute) and the tunnels you could use to move between the valves.
///
/// There's even a valve in the room you and the elephants are currently
/// standing in labeled AA. You estimate it will take you one minute to open a
/// single valve and one minute to follow any tunnel from one valve to another.
/// What is the most pressure you could release?
///
/// For example, suppose you had the following scan output:
///
///   Valve AA has flow rate=0; tunnels lead to valves DD, II, BB
///   Valve BB has flow rate=13; tunnels lead to valves CC, AA
///   Valve CC has flow rate=2; tunnels lead to valves DD, BB
///   Valve DD has flow rate=20; tunnels lead to valves CC, AA, EE
///   Valve EE has flow rate=3; tunnels lead to valves FF, DD
///   Valve FF has flow rate=0; tunnels lead to valves EE, GG
///   Valve GG has flow rate=0; tunnels lead to valves FF, HH
///   Valve HH has flow rate=22; tunnel leads to valve GG
///   Valve II has flow rate=0; tunnels lead to valves AA, JJ
///   Valve JJ has flow rate=21; tunnel leads to valve II
///
///
/// All of the valves begin closed. You start at valve AA, but it must be
/// damaged or jammed or something: its flow rate is 0, so there's no point in
/// opening it. However, you could spend one minute moving to valve BB and
/// another minute opening it; doing so would release pressure during the
/// remaining 28 minutes at a flow rate of 13, a total eventual pressure release
/// of 28 * 13 = 364. Then, you could spend your third minute moving to valve CC
/// and your fourth minute opening it, providing an additional 26 minutes of
/// eventual pressure release at a flow rate of 2, or 52 total pressure released
/// by valve CC.
///
/// Making your way through the tunnels like this, you could probably open many
/// or all of the valves by the time 30 minutes have elapsed. However, you need
/// to release as much pressure as possible, so you'll need to be methodical.
/// Instead, consider this approach:
///
///   == Minute 1 ==
///   No valves are open.
///   You move to valve DD.
///
///   == Minute 2 ==
///   No valves are open.
///   You open valve DD.
///
///   == Minute 3 ==
///   Valve DD is open, releasing 20 pressure.
///   You move to valve CC.
///
///   == Minute 4 ==
///   Valve DD is open, releasing 20 pressure.
///   You move to valve BB.
///
///   == Minute 5 ==
///   Valve DD is open, releasing 20 pressure.
///   You open valve BB.
///
///   == Minute 6 ==
///   Valves BB and DD are open, releasing 33 pressure.
///   You move to valve AA.
///
///   == Minute 7 ==
///   Valves BB and DD are open, releasing 33 pressure.
///   You move to valve II.
///
///   == Minute 8 ==
///   Valves BB and DD are open, releasing 33 pressure.
///   You move to valve JJ.
///
///   == Minute 9 ==
///   Valves BB and DD are open, releasing 33 pressure.
///   You open valve JJ.
///
///   == Minute 10 ==
///   Valves BB, DD, and JJ are open, releasing 54 pressure.
///   You move to valve II.
///
///   == Minute 11 ==
///   Valves BB, DD, and JJ are open, releasing 54 pressure.
///   You move to valve AA.
///
///   == Minute 12 ==
///   Valves BB, DD, and JJ are open, releasing 54 pressure.
///   You move to valve DD.
///
///   == Minute 13 ==
///   Valves BB, DD, and JJ are open, releasing 54 pressure.
///   You move to valve EE.
///
///   == Minute 14 ==
///   Valves BB, DD, and JJ are open, releasing 54 pressure.
///   You move to valve FF.
///
///   == Minute 15 ==
///   Valves BB, DD, and JJ are open, releasing 54 pressure.
///   You move to valve GG.
///
///   == Minute 16 ==
///   Valves BB, DD, and JJ are open, releasing 54 pressure.
///   You move to valve HH.
///
///   == Minute 17 ==
///   Valves BB, DD, and JJ are open, releasing 54 pressure.
///   You open valve HH.
///
///   == Minute 18 ==
///   Valves BB, DD, HH, and JJ are open, releasing 76 pressure.
///   You move to valve GG.
///
///   == Minute 19 ==
///   Valves BB, DD, HH, and JJ are open, releasing 76 pressure.
///   You move to valve FF.
///
///   == Minute 20 ==
///   Valves BB, DD, HH, and JJ are open, releasing 76 pressure.
///   You move to valve EE.
///
///   == Minute 21 ==
///   Valves BB, DD, HH, and JJ are open, releasing 76 pressure.
///   You open valve EE.
///
///   == Minute 22 ==
///   Valves BB, DD, EE, HH, and JJ are open, releasing 79 pressure.
///   You move to valve DD.
///
///   == Minute 23 ==
///   Valves BB, DD, EE, HH, and JJ are open, releasing 79 pressure.
///   You move to valve CC.
///
///   == Minute 24 ==
///   Valves BB, DD, EE, HH, and JJ are open, releasing 79 pressure.
///   You open valve CC.
///
///   == Minute 25 ==
///   Valves BB, CC, DD, EE, HH, and JJ are open, releasing 81 pressure.
///
///   == Minute 26 ==
///   Valves BB, CC, DD, EE, HH, and JJ are open, releasing 81 pressure.
///
///   == Minute 27 ==
///   Valves BB, CC, DD, EE, HH, and JJ are open, releasing 81 pressure.
///
///   == Minute 28 ==
///   Valves BB, CC, DD, EE, HH, and JJ are open, releasing 81 pressure.
///
///   == Minute 29 ==
///   Valves BB, CC, DD, EE, HH, and JJ are open, releasing 81 pressure.
///
///   == Minute 30 ==
///   Valves BB, CC, DD, EE, HH, and JJ are open, releasing 81 pressure.
///
///
/// This approach lets you release the most pressure possible in 30 minutes with
/// this valve layout, 1651.
///
/// Work out the steps to release the most pressure in 30 minutes. What is the
/// most pressure you can release?
int part1(List<String> input) {
  int minutes = 30;
  String startingValveName = 'AA';

  Iterable<Valve> valves = parseValves(input);
  Iterable<Pipe> pipes = parsePipes(input, valves);

  Graph graph = dijkstra(Graph(valves, pipes));
  Graph reducedGraph = simplifyGraph(
      graph, valves.firstWhere((valve) => valve.name == startingValveName));

  // Sort valves according to flow rate (descending) and sort pipes according
  // to cost (ascending). This will likely speed up the dfs, as we assume that
  // the optimal path is more likely to use low-cost paths and start opening
  // valves with a high flow rate.
  reducedGraph = Graph(
      reducedGraph.valves.toList()..sort((a, b) => b.flowRate - a.flowRate),
      reducedGraph.pipes.toList()..sort((a, b) => a.cost - b.cost));

  int releasedPressure = soloDfs(
    minutes,
    reducedGraph,
    valves.firstWhere((valve) => valve.name == startingValveName),
    0,
    0,
    valves.where((valve) => valve.name != startingValveName),
  );

  return releasedPressure;
}

/// --- Part Two ---
///
/// You're worried that even with an optimal approach, the pressure released
/// won't be enough. What if you got one of the elephants to help you?
///
/// It would take you 4 minutes to teach an elephant how to open the right
/// valves in the right order, leaving you with only 26 minutes to actually
/// execute your plan. Would having two of you working together be better, even
/// if it means having less time? (Assume that you teach the elephant before
/// opening any valves yourself, giving you both the same full 26 minutes.)
///
/// In the example above, you could teach the elephant to help you as follows:
///
///   == Minute 1 ==
///   No valves are open.
///   You move to valve II.
///   The elephant moves to valve DD.
///
///   == Minute 2 ==
///   No valves are open.
///   You move to valve JJ.
///   The elephant opens valve DD.
///
///   == Minute 3 ==
///   Valve DD is open, releasing 20 pressure.
///   You open valve JJ.
///   The elephant moves to valve EE.
///
///   == Minute 4 ==
///   Valves DD and JJ are open, releasing 41 pressure.
///   You move to valve II.
///   The elephant moves to valve FF.
///
///   == Minute 5 ==
///   Valves DD and JJ are open, releasing 41 pressure.
///   You move to valve AA.
///   The elephant moves to valve GG.
///
///   == Minute 6 ==
///   Valves DD and JJ are open, releasing 41 pressure.
///   You move to valve BB.
///   The elephant moves to valve HH.
///
///   == Minute 7 ==
///   Valves DD and JJ are open, releasing 41 pressure.
///   You open valve BB.
///   The elephant opens valve HH.
///
///   == Minute 8 ==
///   Valves BB, DD, HH, and JJ are open, releasing 76 pressure.
///   You move to valve CC.
///   The elephant moves to valve GG.
///
///   == Minute 9 ==
///   Valves BB, DD, HH, and JJ are open, releasing 76 pressure.
///   You open valve CC.
///   The elephant moves to valve FF.
///
///   == Minute 10 ==
///   Valves BB, CC, DD, HH, and JJ are open, releasing 78 pressure.
///   The elephant moves to valve EE.
///
///   == Minute 11 ==
///   Valves BB, CC, DD, HH, and JJ are open, releasing 78 pressure.
///   The elephant opens valve EE.
///
///   (At this point, all valves are open.)
///
///   == Minute 12 ==
///   Valves BB, CC, DD, EE, HH, and JJ are open, releasing 81 pressure.
///
///   ...
///
///   == Minute 20 ==
///   Valves BB, CC, DD, EE, HH, and JJ are open, releasing 81 pressure.
///
///   ...
///
///   == Minute 26 ==
///   Valves BB, CC, DD, EE, HH, and JJ are open, releasing 81 pressure.
///
///
/// With the elephant helping, after 26 minutes, the best you could do would
/// release a total of 1707 pressure.
///
/// With you and an elephant working together for 26 minutes, what is the most
/// pressure you could release?
int part2(List<String> input) {
  int minutes = 26;
  String startingValveName = 'AA';

  Iterable<Valve> valves = parseValves(input);
  Iterable<Pipe> pipes = parsePipes(input, valves);

  Graph graph = dijkstra(Graph(valves, pipes));
  Graph reducedGraph = simplifyGraph(
      graph, valves.firstWhere((valve) => valve.name == startingValveName));

  // Sort valves according to flow rate (descending) and sort pipes according
  // to cost (ascending). This will likely speed up the dfs, as we assume that
  // the optimal path is more likely to use low-cost paths and start opening
  // valves with a high flow rate.
  reducedGraph = Graph(
      reducedGraph.valves.toList()..sort((a, b) => b.flowRate - a.flowRate),
      reducedGraph.pipes.toList()..sort((a, b) => a.cost - b.cost));

  releasedPressureRecordPerMinute = List.filled(minutes + 1, 0);
  maxFlowRate =
      reducedGraph.valves.map((e) => e.flowRate).reduce((a, b) => a + b);
  Iterable<int> sortedFlowRates = reducedGraph.valves
      .map((e) => e.flowRate)
      .toList()
    ..sort(((a, b) => b - a));
  maxFlowRatePerMinute = List.generate(
      minutes + 1,
      (index) => [...sortedFlowRates.take(index ~/ 2), 0]
          .reduce((value, element) => value + element)).reversed;

  int releasedPressure = duoDfs(
    minutes,
    reducedGraph,
    valves.firstWhere((valve) => valve.name == startingValveName),
    valves.firstWhere((valve) => valve.name == startingValveName),
    0,
    0,
    0,
    0,
    valves.where((valve) => valve.name != startingValveName),
  );

  return releasedPressure;
}
