import 'package:flutter/material.dart';

/// Customize the InteractiveMap widget with this theme
class InteractiveMapTheme {
  // The default color to paint a country
  final Color defaultCountryColor;

  // The default color to paint a country when it's selected
  final Color defaultSelectedCountryColor;

  // We want to map the code of a country region to a special color
  // eg: FR -> Colors.red.shade200
  final Map<String, Color>? mappingCode;

  // The border width of the countries
  final double borderWidth;

  // The border width of the selected country
  final double selectedBorderWidth;

  // The color of the country's border
  final Color borderColor;

  const InteractiveMapTheme({
    this.defaultCountryColor = const Color(0xff60435f),
    this.defaultSelectedCountryColor = const Color(0xff845c83),
    this.mappingCode,
    this.borderWidth = 2.0,
    this.selectedBorderWidth = 3.0,
    this.borderColor = Colors.white,
  });
}
