import 'dart:math';

import 'package:flutter/material.dart';

///
sealed class AMarker {}

///
class Marker extends AMarker {
  ///
  Marker({required this.x, required this.y});
  ///
  final double x;
  ///
  final double y;

}

///
class GeoMarker extends AMarker {
  ///
  GeoMarker({required this.lat, required this.long});
  ///
  final double lat;
  ///
  final double long;

  ///
  double degreeToRadian(double degree) {
    return degree * pi / 180;
  }

  /// Big thanks to this person
  ///
  /// https://stackoverflow.com/a/10401734
  ///
  /// <?php
  ///
  /// $mapWidth = 1500;
  /// $mapHeight = 1577;
  ///
  /// $mapLonLeft = 9.8;
  /// $mapLonRight = 10.2;
  /// $mapLonDelta = $mapLonRight - $mapLonLeft;
  ///
  /// $mapLatBottom = 53.45;
  /// $mapLatBottomDegree = $mapLatBottom * M_PI / 180;
  ///
  /// function convertGeoToPixel($lat, $lon)
  /// {
  ///     global $mapWidth, $mapHeight, $mapLonLeft, $mapLonDelta, $mapLatBottom, $mapLatBottomDegree;
  ///
  ///     $x = ($lon - $mapLonLeft) * ($mapWidth / $mapLonDelta);
  ///
  ///     $lat = $lat * M_PI / 180;
  ///     $worldMapWidth = (($mapWidth / $mapLonDelta) * 360) / (2 * M_PI);
  ///     $mapOffsetY = ($worldMapWidth / 2 * log((1 + sin($mapLatBottomDegree)) / (1 - sin($mapLatBottomDegree))));
  ///     $y = $mapHeight - (($worldMapWidth / 2 * log((1 + sin($lat)) / (1 - sin($lat)))) - $mapOffsetY);
  ///
  ///     return array($x, $y);
  /// }
  ///
  /// $position = convertGeoToPixel(53.7, 9.95);
  /// echo "x: ".$position[0]." / ".$position[1];
  ///
  /// ?>
  Offset getOffset(double rightLong, double topLat, double leftLong,
      double bottomLat, Size mapSize) {
    final longDelta = rightLong - leftLong;
    final mapLatBottomDegree = bottomLat * pi / 180;
    final x = (long - leftLong) * (mapSize.width / longDelta);

    final radLat = lat * pi / 180;

    final worldMapWidth = ((mapSize.width / longDelta) * 180) / pi;
    final mapOffsetY = worldMapWidth /
        2 *
        log((1 + sin(mapLatBottomDegree)) / (1 - sin(mapLatBottomDegree)));
    final y = mapSize.height -
        ((worldMapWidth / 2 * log((1 + sin(radLat)) / (1 - sin(radLat)))) -
            mapOffsetY);

    return Offset(x, y);
  }
}

///
class MarkerGroup {
  ///
  MarkerGroup({
    required this.markers,
    this.borderColor,
    this.backgroundColor,
    this.borderWidth,
    this.markerSize,
    this.usePinMarker = false,
  }) : assert((borderWidth == null && markerSize == null && usePinMarker) ||
      (borderWidth != null && markerSize != null && !usePinMarker));

  ///
  final List<AMarker> markers;
  ///
  Color? borderColor;
  ///
  Color? backgroundColor;

  /// The border with of the circle/scare
  final double? borderWidth;

  /// It will depends if we draw a circle (diameter) or a scare (side)
  final double? markerSize;

  /// Provide an image to draw
  final bool usePinMarker;
}
