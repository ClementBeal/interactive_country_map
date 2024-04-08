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
    final pointPainter = Paint()
      ..strokeWidth = 6
      ..isAntiAlias = true
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (var markerGroup in markers) {
      pointPainter.color = markerGroup.color;

      canvas.drawPoints(
        PointMode.points,
        markerGroup.markers.map((e) => Offset(e.x, e.y)).toList(),
        pointPainter,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
