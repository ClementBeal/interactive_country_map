import 'dart:io';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:xml/xml.dart';

class Point {
  final double x;
  final double y;

  Point({required this.x, required this.y});

  Point add(double x, y) {
    return Point(x: this.x + x, y: this.y + y);
  }

  @override
  String toString() {
    return "x: $x ; y: $y";
  }
}

class SvgPath {
  final List<Point> points;

  SvgPath({required this.points});

  SvgPath normalizePoints() {
    final minWidth = points.map((e) => e.x).toList().min;
    final minHeight = points.map((e) => e.y).toList().min;

    print(minWidth);

    print(minHeight);

    return SvgPath(
      points: points.map((e) {
        return e.add((minWidth < 0) ? -minWidth : minWidth,
            (minHeight < 0) ? -minHeight : minHeight);
      }).toList(),
    );
  }
}

class CountryPath {
  final String countryCode;
  final SvgPath path;

  CountryPath({required this.countryCode, required this.path});
}

class SvgParser {
  Future<List<CountryPath>> parse(File svgFile) async {
    final data = await svgFile.readAsString();

    final xml = XmlDocument.parse(data);

    return xml.findAllElements("path").map((e) => _getCountryPath(e)).toList();
  }

  CountryPath _getCountryPath(XmlElement element) {
    final countryCode = element.getAttribute("id");

    if (countryCode == null) {
      throw Exception();
    }

    final path = element.getAttribute("d")!.split(" ");
    final newSvgPath = SvgPath(points: []);

    for (var i = 1; i < (path.length - 1); i++) {
      final coordinates = path[i].split(",");

      newSvgPath.points.add(
        Point(
          x: double.parse(coordinates[0]),
          y: double.parse(coordinates[1]),
        ),
      );
    }

    return CountryPath(
      countryCode: countryCode,
      path: newSvgPath,
    );
  }
}
