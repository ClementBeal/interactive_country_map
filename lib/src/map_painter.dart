import 'dart:ui';

import 'package:flutter/material.dart' hide Path;
import 'package:interactive_country_map/interactive_country_map.dart';
import 'package:interactive_country_map/src/interactive_map.dart';
import 'package:interactive_country_map/src/svg/svg_parser.dart';

class MapPainter extends CustomPainter {
  final List<CountryPath> countries;
  final Offset? cursorPosition;
  final InteractiveMapTheme theme;

  MapPainter({
    super.repaint,
    required this.countries,
    required this.cursorPosition,
    required this.theme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scale = theme.zoom;

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

      for (var point in country.path.points) {
        if (point is MovePoint) {
          path.relativeMoveTo(point.x * scale, point.y * scale);

          for (var point in point.relativePoints) {
            path.relativeLineTo(point.x * scale, point.y * scale);
          }
        }
        if (point is ClosePoint) {
          path.close();
        }
      }

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
    return true;
  }
}
