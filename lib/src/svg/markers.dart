import 'package:flutter/material.dart';

class Marker {
  final double x;
  final double y;

  Marker({required this.x, required this.y});
}

class MarkerGroup {
  final List<Marker> markers;
  final Color borderColor;
  final Color backgroundColor;

  MarkerGroup({
    required this.markers,
    required this.borderColor,
    required this.backgroundColor,
  });
}
