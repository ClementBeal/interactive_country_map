import 'package:flutter/material.dart';
import 'package:interactive_country_map/src/svg/svg_parser.dart';

sealed class AMarker {}

class Marker extends AMarker {
  final double x;
  final double y;

  Marker({required this.x, required this.y});
}

class GeoMarker extends AMarker {
  final double long;
  final double lat;

  GeoMarker({
    required this.long,
    required this.lat,
  });

  Offset translate(CountryMap map, Size size) {
    // print("Lat: ${map.minLat} ${map.maxLat}");
    // print("Long: ${map.minLong} ${map.maxLong}");

    return Offset(
      size.width / 360 * (180 + long),
      size.height / 180 * (90 - lat),
    );
  }
}

class MarkerGroup {
  final List<AMarker> markers;
  final Color borderColor;
  final Color backgroundColor;

  MarkerGroup({
    required this.markers,
    required this.borderColor,
    required this.backgroundColor,
  });
}
