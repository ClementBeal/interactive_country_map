import 'package:flutter/material.dart' hide Path;
import 'package:interactive_country_map/src/interactive_map_theme.dart';
import 'package:interactive_country_map/src/svg/svg_parser.dart';

class MapPainter extends CustomPainter {
  final List<CountryPath> countries;
  final Offset? cursorPosition;
  final InteractiveMapTheme theme;
  final Offset offset;

  MapPainter({
    super.repaint,
    required this.countries,
    required this.cursorPosition,
    required this.theme,
    required this.offset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const scale = 1.0;

    final paintFiller = Paint()
      ..color = theme.defaultCountryColor
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;

    final selectedPaintFiller = Paint()
      ..color = theme.defaultSelectedCountryColor
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;

    final paintBorder = Paint()
      ..color = theme.borderColor
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = theme.borderWidth;
    final selectedPaintBorder = Paint()
      ..color = theme.borderColor
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = theme.selectedBorderWidth;

    for (var country in countries) {
      final path = country.path.toPath(scale, offset);
      paintFiller.color =
          theme.mappingCode?[country.countryCode] ?? theme.defaultCountryColor;

      if (cursorPosition != null && path.contains(cursorPosition!)) {
        canvas.drawPath(path, selectedPaintFiller);
        canvas.drawPath(path, selectedPaintBorder);
      } else {
        canvas.drawPath(path, paintFiller);
        canvas.drawPath(path, paintBorder);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
