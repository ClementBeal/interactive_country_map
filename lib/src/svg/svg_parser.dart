import 'dart:io';

import 'package:xml/xml.dart';

class Point {
  final double x;
  final double y;

  Point({required this.x, required this.y});
}

class ClosePoint extends Point {
  ClosePoint() : super(x: 0, y: 0);
}

class MovePoint extends Point {
  final List<Point> relativePoints;

  MovePoint(this.relativePoints, {required super.x, required super.y});
}

class SvgPath {
  final List<Point> points;

  SvgPath({required this.points});
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

    for (var i = 0; i < path.length; i++) {
      final token = path[i];

      if (token == "m" || token == "M") {
        final firstCoordinates = path[++i].split(",");
        final movePoints = MovePoint(
          [],
          x: double.parse(firstCoordinates[0]),
          y: double.parse(firstCoordinates[1]),
        );

        i++;

        while (i < path.length && !["m", "z"].contains(path[i].toLowerCase())) {
          final point = path[i++].split(",");
          final newPoint = Point(
            x: double.parse(point[0]),
            y: double.parse(point[1]),
          );

          movePoints.relativePoints.add(newPoint);
        }

        newSvgPath.points.add(movePoints);
      } else if (token == "z" || token == "Z") {
        newSvgPath.points.add(ClosePoint());
      }
    }

    return CountryPath(
      countryCode: countryCode,
      path: newSvgPath,
    );
  }
}
