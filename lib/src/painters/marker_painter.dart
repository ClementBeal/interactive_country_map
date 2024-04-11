import 'package:flutter/material.dart' hide Path;
import 'package:interactive_country_map/src/interactive_map_theme.dart';
import 'package:interactive_country_map/src/svg/markers.dart';
import 'package:interactive_country_map/src/svg/svg_parser.dart';

class MarkerPainter extends CustomPainter {
  final CountryMap countryMap;
  final InteractiveMapTheme theme;
  final List<MarkerGroup> markers;
  final double scale;

  MarkerPainter({
    super.repaint,
    required this.countryMap,
    required this.theme,
    required this.markers,
    required this.scale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final borderPointPainter = Paint()
      ..strokeWidth = 2 / scale
      ..isAntiAlias = true
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final pointPainter = Paint()
      ..strokeWidth = 18 / scale
      ..isAntiAlias = true
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill;

    for (var markerGroup in markers) {
      borderPointPainter.color = markerGroup.borderColor;
      pointPainter.color = markerGroup.backgroundColor;

      final pointsToDraw =
          markerGroup.markers.map((e) => _getOffset(e, size)).toList();
      for (var marker in pointsToDraw) {
        canvas.drawCircle(marker, 18 / scale, borderPointPainter);
        canvas.drawCircle(marker, 17 / scale, pointPainter);
      }
    }
  }

  Offset _getOffset(AMarker marker, Size size) {
    switch (marker) {
      case Marker():
        return Offset(marker.x, marker.y);
      case GeoMarker():
        return marker.getOffset(
          countryMap.rightLong,
          countryMap.topLat,
          countryMap.leftLong,
          countryMap.bottomLat,
          size,
        );
    }
  }

  @override
  bool shouldRepaint(covariant MarkerPainter oldDelegate) {
    return oldDelegate.markers != markers ||
        oldDelegate.scale != scale ||
        oldDelegate.countryMap != countryMap ||
        oldDelegate.theme != theme;
  }
}
