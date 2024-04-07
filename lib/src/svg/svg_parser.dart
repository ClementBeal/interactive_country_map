import 'dart:ui';

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

  Path toPath(double scale, Offset offset) {
    final path = Path();
    var hasAddedOffset = false;

    for (var point in points) {
      if (point is MovePoint) {
        // because the path is relative, we only add the offset to the first point
        if (!hasAddedOffset) {
          path.relativeMoveTo(
              offset.dx + (point.x) * scale, offset.dy + (point.y) * scale);
          hasAddedOffset = true;
        } else {
          path.relativeMoveTo((point.x) * scale, (point.y) * scale);
        }
        for (var point in point.relativePoints) {
          path.relativeLineTo((point.x) * scale, (point.y) * scale);
        }
      }
      if (point is ClosePoint) {
        path.close();
      }
      if (point is LinePoint) {
        path.relativeLineTo(point.x, point.y);
      }
    }
    return path;
  }
}

class CountryPath {
  final String countryCode;
  final SvgPath path;

  CountryPath({required this.countryCode, required this.path});
}

class SvgParser {
  Future<List<CountryPath>> parse(String data) async {
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
