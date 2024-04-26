import 'dart:ui';

import 'package:flutter/material.dart' hide Path;
import 'package:interactive_country_map/src/interactive_map_theme.dart';
import 'package:interactive_country_map/src/svg/markers.dart';
import 'package:interactive_country_map/src/svg/svg_parser.dart';

///
class MarkerPainter extends CustomPainter {
  ///
  MarkerPainter({
    super.repaint,
    required this.countryMap,
    required this.theme,
    required this.markers,
    required this.scale,
  });
  ///
  final CountryMap countryMap;
  ///
  final InteractiveMapTheme theme;
  ///
  final List<MarkerGroup> markers;
  ///
  final double scale;



  @override
  void paint(Canvas canvas, Size size) {
    final borderPointPainter = Paint()
      ..isAntiAlias = true
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final pointPainter = Paint()
      ..isAntiAlias = true
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill;

    for (final markerGroup in markers) {
      final pointsToDraw =
      markerGroup.markers.map((e) => _getOffset(e, size)).toList();

      if (markerGroup.usePinMarker) {
        pointPainter.color = const Color(0xffeb2f06);

        final centerDisk = Paint()
          ..color = Colors.white
          ..isAntiAlias = true
          ..strokeWidth = 2.0 / scale
          ..style = PaintingStyle.fill;

        // we draw a custom pin. Until I find an easy way to draw an image, I'll keep this solution
        for (final marker in pointsToDraw) {
          final path = Path()
            ..moveTo(marker.dx, marker.dy)
            ..relativeLineTo(-7 / scale, -15 / scale)
            ..relativeLineTo(14 / scale, 0)
            ..close();

          canvas.drawPath(path, pointPainter);
          canvas.drawCircle(
              marker + Offset(0, -15 / scale), 7 / scale, pointPainter);
          canvas.drawCircle(
              marker + Offset(0, -15 / scale), 4.5 / scale, centerDisk);
        }
      } else {
        pointPainter.color = markerGroup.backgroundColor ?? Colors.black;
        borderPointPainter
          ..color = markerGroup.borderColor ?? Colors.black
          ..strokeWidth = markerGroup.borderWidth! / scale;

        for (final marker in pointsToDraw) {
          canvas.drawCircle(
              marker, markerGroup.markerSize! / scale, borderPointPainter);
          canvas.drawCircle(
              marker, markerGroup.markerSize! / scale, pointPainter);
        }
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
