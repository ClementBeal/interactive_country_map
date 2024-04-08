import 'package:flutter/material.dart';

sealed class AMarker {}

class Marker extends AMarker {
  final double x;
  final double y;

  Marker({required this.x, required this.y});
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
