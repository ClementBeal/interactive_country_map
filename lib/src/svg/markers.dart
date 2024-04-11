import 'dart:math';

import 'package:flutter/material.dart';

sealed class AMarker {}

class Marker extends AMarker {
  final double x;
  final double y;

  Marker({required this.x, required this.y});
}

class GeoMarker extends AMarker {
  final double lat;
  final double long;

  GeoMarker({required this.lat, required this.long});

  Offset _getPosition(double lat, double long, double l) {
    const earthRadius = 6371;
    final x = earthRadius * long * cos(l);
    final y = earthRadius * lat;

    return Offset(x, y);
  }

  Offset _normalize(
      Offset topLeftCorner, Offset bottomRightCorner, Offset position) {
    return Offset(
        (position.dx - topLeftCorner.dx) /
            (bottomRightCorner.dx - topLeftCorner.dx),
        (position.dy - topLeftCorner.dy) /
            (bottomRightCorner.dy - topLeftCorner.dy));
  }

  Offset getOffset(double minLat, double minLong, double maxLat, double maxLong,
      Size mapSize) {
    final l = (maxLat + minLat) / 2;

    final topLeftCorner = _getPosition(minLat, minLong, l);
    final bottomRightCorner = _getPosition(maxLat, maxLong, l);

    final normalizedTopLeftCorner =
        _normalize(topLeftCorner, bottomRightCorner, topLeftCorner);

    final normalizedBottomRightCorner =
        _normalize(topLeftCorner, bottomRightCorner, bottomRightCorner);

    // print(normalizedTopLeftCorner);
    // print(normalizedBottomRightCorner);

    final currentPos = _getPosition(lat, long, l);
    // print(currentPos);
    // print(mapSize);
    final n = _normalize(topLeftCorner, bottomRightCorner, currentPos);
    print(n);

    // print(currentPos);

    // print(_getPosition(l, (maxLong + minLong) / 2, l));

    // print((bottomRightCorner.dx - topLeftCorner.dx));

    return Offset(mapSize.width * n.dx, mapSize.height * n.dy);
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
