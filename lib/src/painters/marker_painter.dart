import 'dart:ui';

import 'package:flutter/material.dart' hide Path;
import 'package:interactive_country_map/src/interactive_map_theme.dart';
import 'package:interactive_country_map/src/svg/markers.dart';
import 'package:interactive_country_map/src/svg/svg_parser.dart';

class MarkerPainter extends CustomPainter {
  final CountryMap countryMap;
  final InteractiveMapTheme theme;
  final List<MarkerGroup> markers;

  MarkerPainter({
    super.repaint,
    required this.countryMap,
    required this.theme,
    required this.markers,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final borderPointPainter = Paint()
      ..strokeWidth = 5
      ..isAntiAlias = true
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill;

    final pointPainter = Paint()
      ..strokeWidth = 4
      ..isAntiAlias = true
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill;

    for (var markerGroup in markers) {
      borderPointPainter.color = markerGroup.borderColor;
      pointPainter.color = markerGroup.backgroundColor;

      // for (var marker in markerGroup.markers) {
      //   final markerOffset = _getOffset(marker, size);
      //   // canvas.drawLine(
      //   //     markerOffset, markerOffset + Offset(0, 0), borderPointPainter);
      // }
      // draw border
      canvas.drawPoints(
        PointMode.points,
        markerGroup.markers.map((e) => _getOffset(e, size)).toList(),
        borderPointPainter,
      );

      // draw background
      canvas.drawPoints(
        PointMode.points,
        markerGroup.markers.map((e) => _getOffset(e, size)).toList(),
        pointPainter,
      );
    }
  }

  Offset _getOffset(AMarker marker, Size size) {
    return switch (marker) {
      Marker m => Offset(m.x, m.y),
      GeoMarker m => m.getOffset(countryMap.minLat, countryMap.minLong,
          countryMap.maxLat, countryMap.maxLong, size),
    };
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
