import 'package:flutter/material.dart';
import 'package:interactive_country_map/interactive_country_map.dart';

import 'svg_error_screen.dart';

class LatLongMarkersScreen extends StatelessWidget {
  const LatLongMarkersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Flexible(
            child: InteractiveMap(
              MapEntity.japan,
              onError: (details, svgData) {
                final String message = details.exceptionAsString();
                final StackTrace? stack = details.stack;
                return svgErrorWidget(message);
              },
              theme: InteractiveMapTheme(
                backgroundColor: Colors.grey.shade200,
                defaultCountryColor: Colors.green.shade200,
                borderWidth: 0.5,
              ),
              markers: [
                MarkerGroup(
                  usePinMarker: true,
                  markers: [
                    GeoMarker(lat: 35.6895, long: 139.6917),
                    GeoMarker(lat: 35.4437, long: 139.6380),
                    GeoMarker(lat: 34.6937, long: 135.5023),
                    GeoMarker(lat: 35.1815, long: 136.9066),
                    GeoMarker(lat: 43.0621, long: 141.3544),
                    GeoMarker(lat: 35.0116, long: 135.7681),
                    GeoMarker(lat: 34.6937, long: 135.1959),
                    GeoMarker(lat: 33.5904, long: 130.4017),
                    GeoMarker(lat: 35.5293, long: 139.7020),
                    GeoMarker(lat: 34.3853, long: 132.4553),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
