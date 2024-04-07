import 'dart:io';

import 'package:collection/collection.dart';
import 'package:recase/recase.dart';

void main() {
  final assets = Directory("assets")
      .listSync()
      .whereType<File>()
      .toList()
      .map((e) => e.path.split("/").last.split(".").first)
      .sorted((a, b) => a.compareTo(b));

  for (var asset in assets) {
    print("${asset.camelCase}(\"${asset}\"),");
  }
}
