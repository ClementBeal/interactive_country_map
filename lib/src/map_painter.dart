import 'dart:ui';

import 'package:flutter/material.dart' hide Path;
import 'package:interactive_country_map/src/svg/svg_parser.dart';

class MapPainter extends CustomPainter {
  final List<CountryPath> countries;
  final Offset? cursorPosition;

  MapPainter({
    super.repaint,
    required this.countries,
    required this.cursorPosition,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paintFiller = Paint()
      ..color = Colors.red.shade200
      ..isAntiAlias = true
      ..style = PaintingStyle.fill
      ..strokeWidth = 2.0;
    final selectedPaintFiller = Paint()
      ..color = Colors.red.shade100
      ..isAntiAlias = true
      ..style = PaintingStyle.fill
      ..strokeWidth = 2.0;
    final paintBorder = Paint()
      ..color = Colors.white
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (var country in countries) {
      final path = Path();
      final firstPoint = country.path.points.first;
      path.moveTo(firstPoint.x, firstPoint.y);

      for (var point in country.path.points.skip(1)) {
        path.relativeLineTo(point.x, point.y);
      }
      path.close();

      canvas.drawPath(path, paintBorder);
      if (cursorPosition != null && path.contains(cursorPosition!)) {
        canvas.drawPath(path, selectedPaintFiller);
      } else {
        canvas.drawPath(path, paintFiller);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return (oldDelegate as MapPainter).cursorPosition != cursorPosition;
  }
}
