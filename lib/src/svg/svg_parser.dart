import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:interactive_country_map/src/svg/markers.dart';
import 'package:xml/xml.dart';

sealed class Point {
  final bool isRelative;

  Point({required this.isRelative});
}

class ClosePoint extends Point {
  ClosePoint({required super.isRelative});
}

class RelativePoint {
  final double x;
  final double y;

  RelativePoint({required this.x, required this.y});
}

class MovePoint extends Point {
  final List<RelativePoint> relativePoints;

  final double x;
  final double y;

  MovePoint(this.relativePoints,
      {required this.x, required this.y, required super.isRelative});
}

class LinePoint extends Point {
  LinePoint(this.relativePoints,
      {required this.x, required this.y, required super.isRelative});

  final double x;
  final double y;
  final List<RelativePoint> relativePoints;
}

class CurvePoint extends Point {
  CurvePoint(
      {required this.a,
      required this.b,
      required this.c,
      required super.isRelative});

  final RelativePoint a;
  final RelativePoint b;
  final RelativePoint c;
}

class SvgPath {
  final List<Point> points;

  SvgPath({required this.points});

  Path toPath({Size? originalMapSize, Size? maxSize}) {
    final path = Path();
    for (var point in points) {
      switch (point) {
        case ClosePoint():
          path.close();

        case MovePoint point:
          // because the path is relative, we only add the offset to the first point
          if (point.isRelative) {
            path.relativeMoveTo(point.x, point.y);
          } else {
            path.moveTo(point.x, point.y);
          }

          for (var relativePoint in point.relativePoints) {
            path.relativeLineTo(relativePoint.x, relativePoint.y);
          }
          break;
        case LinePoint point:
          if (point.isRelative) {
            path.relativeLineTo(point.x, point.y);
          } else {
            path.lineTo(point.x, point.y);
          }
        case CurvePoint point:
          if (point.isRelative) {
            path.relativeCubicTo(point.a.x, point.a.y, point.b.x, point.b.y,
                point.c.x, point.c.y);
          } else {
            path.cubicTo(point.a.x, point.a.y, point.b.x, point.b.y, point.c.x,
                point.c.y);
          }
          break;
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

  final double topLat;
  final double bottomLat;
  final double leftLong;
  final double rightLong;

  CountryMap({
    required this.countryPaths,
    required this.width,
    required this.height,
    required this.topLat,
    required this.leftLong,
    required this.rightLong,
    required this.bottomLat,
  });

  String? getCountryCodeFromLocation(double lat, double long) {
    final position = GeoMarker(lat: lat, long: long)
        .getOffset(rightLong, topLat, leftLong, bottomLat, Size(width, height));

    final selectedCountry =
        countryPaths.firstWhereOrNull((element) => element.path
            .toPath(
              maxSize: Size(width, height),
              originalMapSize: Size(width, height),
            )
            .contains(position));

    return selectedCountry?.countryCode;
  }
}

class SvgParser {
  Future<CountryMap> parse(String data) async {
    final xml = XmlDocument.parse(data);

    final svgElement = xml.getElement("svg");
    final geoBoxElement = svgElement!.getAttribute("mapsvg:geoViewBox");

    // TODO: some maps doesn't have the geoviewbox
    final geoBox = (geoBoxElement != null)
        ? geoBoxElement.split(" ")
        : ["0", "0", '0', "0"];

    final countryPaths =
        xml.findAllElements("path").map((e) => _getCountryPath(e)).toList();

    final countryMap = CountryMap(
      countryPaths: countryPaths,
      width: double.parse(svgElement.getAttribute("width")!),
      height: double.parse(svgElement.getAttribute("height")!),
      leftLong: double.parse(geoBox[0]),
      rightLong: double.parse(geoBox[2]),
      topLat: double.parse(geoBox[1]),
      bottomLat: double.parse(geoBox[3]),
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

    path = pathString
        .replaceAllMapped(RegExp(r"(\S)?([mlhvzcMLHVZC])"), (match) {
          if (match.group(1) != null) {
            return "${match.group(1)} ${match.group(2)} ";
          }
          return "${match.group(2)} ";
        })
        .trim()
        .split(" ")
        .where((element) => element.isNotEmpty)
        .toList();

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
            !["m", "z", "l", "v", "h", "c"]
                .contains(path[i + 1].toLowerCase())) {
          final point = path[++i].split(",");
          final newPoint = RelativePoint(
            x: double.parse(point[0]),
            y: double.parse(point[1]),
          );

          movePoints.relativePoints.add(newPoint);
        }

        newSvgPath.points.add(movePoints);
      } else if (token == "z" || token == "Z") {
        newSvgPath.points.add(ClosePoint(isRelative: false));
      } else if (token == "l" || token == "L") {
        final coordinates = path[++i].split(",");
        final newLinePoint = LinePoint(
          [],
          x: double.parse(coordinates[0]),
          y: double.parse(coordinates[1]),
          isRelative: token == "l",
        );

        while (i + 1 < path.length &&
            !["m", "z", "l", "v", "h", "c"]
                .contains(path[i + 1].toLowerCase())) {
          final point = path[++i].split(",");
          final newPoint = RelativePoint(
            x: double.parse(point[0]),
            y: double.parse(point[1]),
          );
          newLinePoint.relativePoints.add(newPoint);
        }

        newSvgPath.points.add(newLinePoint);
      } else if (token == "v" || token == "V") {
        final coordinates = path[++i];

        final newLinePoint = LinePoint([],
            x: -1, y: double.parse(coordinates), isRelative: token == "v");

        while (i + 1 < path.length &&
            !["m", "z", "l", "v", "h", "c"]
                .contains(path[i + 1].toLowerCase())) {
          final point = path[++i].split(",");
          final newPoint = RelativePoint(
            x: double.parse(point[0]),
            y: double.parse(point[1]),
          );
          newLinePoint.relativePoints.add(newPoint);
        }

        newSvgPath.points.add(newLinePoint);
      } else if (token == "h" || token == "H") {
        final coordinates = path[++i];
        newSvgPath.points.add(LinePoint([],
            x: double.parse(coordinates), isRelative: token == "h", y: 0));
      } else if (token == "c" || token == "C") {
        final point1 = path[i + 1].split(",");
        final point2 = path[i + 2].split(",");
        final point3 = path[i + 3].split(",");

        i += 3;

        newSvgPath.points.add(
          CurvePoint(
            a: RelativePoint(
              x: double.parse(point1[0]),
              y: double.parse(point1[1]),
            ),
            b: RelativePoint(
              x: double.parse(point2[0]),
              y: double.parse(point2[1]),
            ),
            c: RelativePoint(
              x: double.parse(point3[0]),
              y: double.parse(point3[1]),
            ),
            isRelative: token == "c",
          ),
        );
      } else {
        throw Exception("Cannot parse this path. Unknown token $token");
      }
    }

    return CountryPath(
      countryCode: countryCode,
      path: newSvgPath,
    );
  }
}
