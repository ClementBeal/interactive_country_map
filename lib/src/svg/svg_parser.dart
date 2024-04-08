import 'dart:ui';

import 'package:flutter/material.dart';
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

  MovePoint(this.relativePoints,
      {required super.x, required super.y, required this.isRelative});

  final bool isRelative;
}

class LinePoint extends Point {
  LinePoint({required super.x, required super.y, required this.isRelative});

  final bool isRelative;
}

class SvgPath {
  final List<Point> points;

  SvgPath({required this.points});

  Path toPath({Size? originalMapSize, Size? maxSize}) {
    final path = Path();
    for (var point in points) {
      if (point is MovePoint) {
        // because the path is relative, we only add the offset to the first point
        if (point.isRelative) {
          path.relativeMoveTo(point.x, point.y);
        } else {
          path.moveTo(point.x, point.y);
        }

        for (var point in point.relativePoints) {
          path.relativeLineTo(point.x, point.y);
        }
      } else if (point is ClosePoint) {
        path.close();
      } else if (point is LinePoint) {
        if (point.isRelative) {
          path.relativeLineTo(point.x, point.y);
        } else {
          path.lineTo(point.x, point.y);
        }
      }
    }

    if (maxSize != null && originalMapSize != null) {
      double scaleX = maxSize.width / originalMapSize.width;
      double scaleY = maxSize.height / originalMapSize.height;

      // Choose the minimum scale factor to maintain the aspect ratio
      double scale = scaleX < scaleY ? scaleX : scaleY;

      final scaleMatrix = Matrix4.identity()..scale(scale, scale);
      return path.transform(scaleMatrix.storage);
    }

    return path;
  }
}

class CountryPath {
  final String countryCode;
  final SvgPath path;

  CountryPath({required this.countryCode, required this.path});
}

class CountryMap {
  final List<CountryPath> countryPaths;
  final double width;
  final double height;

  final double minLat;
  final double minLong;
  final double maxLat;
  final double maxLong;

  CountryMap({
    required this.countryPaths,
    required this.width,
    required this.height,
    required this.minLat,
    required this.maxLat,
    required this.maxLong,
    required this.minLong,
  });
}

class SvgParser {
  Future<CountryMap> parse(String data) async {
    final xml = XmlDocument.parse(data);

    final svgElement = xml.getElement("svg");
    final geoBox = svgElement!.getAttribute("mapsvg:geoViewBox")!.split(" ");

    final countryPaths =
        xml.findAllElements("path").map((e) => _getCountryPath(e)).toList();

    final countryMap = CountryMap(
      countryPaths: countryPaths,
      width: double.parse(svgElement.getAttribute("width")!),
      height: double.parse(svgElement.getAttribute("height")!),
      maxLat: double.parse(geoBox[1]),
      maxLong: double.parse(geoBox[2]),
      minLat: double.parse(geoBox[3]),
      minLong: double.parse(geoBox[0]),
    );

    return countryMap;
  }

  CountryPath _getCountryPath(XmlElement element) {
    final countryCode = element.getAttribute("id");

    if (countryCode == null) {
      throw Exception();
    }

    final List<String> path;
    final pathString = element.getAttribute("d")!;

    if (pathString.contains(" ")) {
      path = pathString.split(" ");
    } else {
      path = pathString
          .replaceAllMapped(
              RegExp(r"[a-zA-Z]"), (match) => " ${match.group(0)} ")
          .trim()
          .split(" ")
          .where((element) => element.isNotEmpty)
          .toList();
    }

    final newSvgPath = SvgPath(points: []);

    for (var i = 0; i < path.length; i++) {
      final token = path[i];

      // Path command to `moveRelativeTo`
      // The first point is the initial value and the following are relative to the previous one
      if (token == "m" || token == "M") {
        final firstCoordinates = path[++i].split(",");
        final movePoints = MovePoint(
          [],
          x: double.parse(firstCoordinates[0]),
          y: double.parse(firstCoordinates[1]),
          isRelative: token == "m",
        );

        while (i + 1 < path.length &&
            !["m", "z", "l", "v", "h"].contains(path[i + 1].toLowerCase())) {
          final point = path[++i].split(",");
          final newPoint = Point(
            x: double.parse(point[0]),
            y: double.parse(point[1]),
          );

          movePoints.relativePoints.add(newPoint);
        }

        newSvgPath.points.add(movePoints);
      } else if (token == "z") {
        newSvgPath.points.add(ClosePoint());
      } else if (token == "l" || token == "L") {
        final coordinates = path[++i].split(",");
        newSvgPath.points.add(LinePoint(
          x: double.parse(coordinates[0]),
          y: double.parse(coordinates[1]),
          isRelative: token == "l",
        ));
      } else if (token == "v" || token == "V") {
        final coordinates = path[++i];
        newSvgPath.points.add(
          LinePoint(
              x: -1, y: double.parse(coordinates), isRelative: token == "v"),
        );
      } else if (token == "h" || token == "H") {
        final coordinates = path[++i];
        newSvgPath.points.add(LinePoint(
            x: double.parse(coordinates), isRelative: token == "h", y: 0));
      } else {
        print(i);
        print(token);
        print(path.length);
        throw Exception(path);
      }
    }

    return CountryPath(
      countryCode: countryCode,
      path: newSvgPath,
    );
  }
}
