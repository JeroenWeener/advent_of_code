import 'dart:io';

void main() {
  final List<String> input = File('2022/dart/07/input.txt').readAsLinesSync();

  final int answer1 = part1(input);
  print(answer1);

  final int answer2 = part2(input);
  print(answer2);
}

abstract class SystemItem {
  const SystemItem({
    required this.name,
  });

  final String name;

  factory SystemItem.fromOutput({
    required SystemDirectory parent,
    required String output,
  }) {
    final List<String> parts = output.split(' ');

    if (parts[0] == 'dir') {
      return SystemDirectory(parent: parent, name: parts[1], files: []);
    } else {
      return SystemFile(name: parts[1], size: int.parse(parts[0]));
    }
  }
}

class SystemFile extends SystemItem {
  const SystemFile({
    required super.name,
    required this.size,
  });

  final int size;

  @override
  String toString() {
    return '$name ($size)';
  }
}

class SystemDirectory extends SystemItem {
  SystemDirectory({
    required super.name,
    this.parent,
    this.files = const [],
  });

  final SystemDirectory? parent;
  List<SystemItem> files;

  int calculateSize() {
    return files.map((e) {
      if (e is SystemFile) {
        return e.size;
      } else if (e is SystemDirectory) {
        return e.calculateSize();
      } else {
        return 0;
      }
    }).reduce((totalSize, fileSize) => totalSize + fileSize);
  }

  SystemDirectory cd(String location) {
    if (location == '/') {
      return parent == null ? this : parent!.cd(location);
    }
    if (location == '..') {
      return parent ?? this;
    }
    return files.firstWhere(
            (element) => element.name == location && element is SystemDirectory)
        as SystemDirectory;
  }

  void ls(List<String> output) {
    this.files = output
        .map((line) => SystemItem.fromOutput(
              parent: this,
              output: line,
            ))
        .toList();
  }

  @override
  String toString() {
    return '[$name] {${files.map((file) => file.toString())}}';
  }
}

int part1(List<String> input) {
  SystemDirectory root = SystemDirectory(name: '/');
  SystemDirectory currentDirectory = root;

  List<String> output = [];

  bool readingInput = true;

  input.skip(1).map((line) {
    List<String> parts = line.split(' ');
    bool foundInput = parts[0] == '\$';

    // Output has ended.
    if (foundInput && !readingInput) {
      currentDirectory.ls(output);
      output = [];
    }

    readingInput = foundInput;

    if (readingInput) {
      if (parts[1] == 'cd') {
        currentDirectory = currentDirectory.cd(parts[2]);
      }
    } else {
      output.add(line);
    }
  });
  print(root);
  return -1;
}

int part2(List<String> input) {
  return -1;
}
