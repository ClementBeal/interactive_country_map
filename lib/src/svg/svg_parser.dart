import 'dart:math';
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

  MovePoint(this.relativePoints, {required super.x, required super.y});
}

class LinePoint extends Point {
  LinePoint({required super.x, required super.y});
}

class SvgPath {
  final List<Point> points;

  SvgPath({required this.points});

  Path toPath({Size? originalMapSize, Size? maxSize}) {
    final path = Path();
    for (var point in points) {
      if (point is MovePoint) {
        // because the path is relative, we only add the offset to the first point
        path.relativeMoveTo(point.x, point.y);

        for (var point in point.relativePoints) {
          path.relativeLineTo(point.x, point.y);
        }
      }
      if (point is ClosePoint) {
        path.close();
      }
      if (point is LinePoint) {
        path.relativeLineTo(point.x, point.y);
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

  CountryMap({
    required this.countryPaths,
    required this.width,
    required this.height,
  });
}

class SvgParser {
  Future<CountryMap> parse(String data) async {
    final xml = XmlDocument.parse(data);

    final svgElement = xml.getElement("svg");

    final countryPaths =
        xml.findAllElements("path").map((e) => _getCountryPath(e)).toList();

    final countryMap = CountryMap(
      countryPaths: countryPaths,
      width: double.parse(svgElement!.getAttribute("width")!),
      height: double.parse(svgElement.getAttribute("height")!),
    );

    return countryMap;
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

      // Path command to `moveRelativeTo`
      // The first point is the initial value and the following are relative to the previous one
      if (token == "m") {
        final firstCoordinates = path[++i].split(",");
        final movePoints = MovePoint(
          [],
          x: double.parse(firstCoordinates[0]),
          y: double.parse(firstCoordinates[1]),
        );

        i++;

        while (i < path.length &&
            !["m", "z", "l"].contains(path[i].toLowerCase())) {
          final point = path[i++].split(",");
          final newPoint = Point(
            x: double.parse(point[0]),
            y: double.parse(point[1]),
          );

          movePoints.relativePoints.add(newPoint);
        }

        newSvgPath.points.add(movePoints);
      } else if (token == "z") {
        newSvgPath.points.add(ClosePoint());
      } else if (token == "l") {
        final coordinates = path[++i].split(",");
        newSvgPath.points.add(LinePoint(
          x: double.parse(coordinates[0]),
          y: double.parse(coordinates[1]),
        ));
      }
    }

    return CountryPath(
      countryCode: countryCode,
      path: newSvgPath,
    );
  }
}
