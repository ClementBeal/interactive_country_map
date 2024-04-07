import 'package:flutter/material.dart';

class InteractiveMapTheme {
  final double zoom;
  final Color defaultCountryColor;
  final Color defaultSelectedCountryColor;

  InteractiveMapTheme({
    required this.zoom,
    this.defaultCountryColor = const Color(0xff27ae60),
    this.defaultSelectedCountryColor = const Color(0xff2ecc71),
  });
}
