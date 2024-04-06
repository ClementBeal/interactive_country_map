import 'dart:ui';

import 'package:flutter/material.dart' hide Path;
import 'package:interactive_country_map/src/svg/svg_parser.dart';

class MapPainter extends CustomPainter {
  final List<CountryPath> countries;

  MapPainter({super.repaint, required this.countries});

  @override
  void paint(Canvas canvas, Size size) {
    final paintFiller = Paint()
      ..color = Colors.red.shade200
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
      canvas.drawPath(path, paintFiller);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
