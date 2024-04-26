import 'package:flutter/material.dart';
import 'package:interactive_country_map/interactive_country_map.dart';

import 'svg_error_screen.dart';

class FrancePlot extends StatefulWidget {
  const FrancePlot({super.key});

  @override
  State<FrancePlot> createState() => _FrancePlotState();
}

class _FrancePlotState extends State<FrancePlot> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Flexible(
            child: InteractiveMap(
              MapEntity.franceDepartments,
              onLoaded: (svgData) async {
                final countryMap = await SvgParser().parse(svgData);
                countryMap.getCountryCodeFromLocation(40.7128, -74.0060);
                throw Exception('Test onError()');   // <--- Uncomment this line to see the onError() run
              },
              onError: (details, svgData) {
                final String message = details.exceptionAsString();
                final StackTrace? stack = details.stack;
                return svgErrorWidget(message);
              },
              theme: InteractiveMapTheme(
                  borderColor: Colors.green.shade800,
                  borderWidth: 1.0,
                  selectedBorderWidth: 2.0,
                  defaultCountryColor: Colors.green.shade200,
                  backgroundColor: Colors.lightBlue.shade100,
                  mappingCode: {
                    ...MappingHelper.sameColor(
                      Colors.red.shade200,
                      [
                        "FR-05",
                        "FR-06",
                        "FR-38",
                        "FR-04",
                        "FR-26",
                        "FR-2A",
                        "FR-2B"
                      ],
                    ),
                    ...MappingHelper.sameColor(
                      Colors.blue.shade300,
                      [
                        "FR-09",
                        "FR-66",
                        "FR-31",
                      ],
                    ),
                  }),
              loadingBuilder: (context) =>
                  const Center(child: CircularProgressIndicator()),
              minScale: 0.3,
              maxScale: 32,
              markers: [
                MarkerGroup(
                  markers: [
                    // GeoMarker(lat: 48.864716, long: 2.349014), // Paris, France
                    // GeoMarker(
                    //     lat: 38.9072, long: -77.0369), // Washington D.C., USA
                    // GeoMarker(lat: 51.5074, long: -0.1278), // London, UK
                    // GeoMarker(lat: 35.6895, long: 139.6917), // Tokyo, Japan
                    // GeoMarker(lat: -33.4489, long: -70.6693), // Santiago, Chile
                    // GeoMarker(
                    //     lat: 40.7128, long: -74.0060), // New York City, USA
                    // GeoMarker(lat: 55.7558, long: 37.6176), // Moscow, Russia
                    // GeoMarker(
                    //     lat: -34.6037,
                    //     long: -58.3816), // Buenos Aires, Argentina
                    // GeoMarker(lat: 52.5200, long: 13.4050), // Berlin, Germany
                    // GeoMarker(lat: 40.4168, long: -3.7038), // Madrid, Spain
                    // GeoMarker(
                    //     lat: -6.2088, long: 106.8456), // Jakarta, Indonesia
                    // GeoMarker(
                    //     lat: -23.5505, long: -46.6333), // São Paulo, Brazil
                    // GeoMarker(
                    //     lat: 55.7558, long: 12.5523), // Copenhagen, Denmark
                    // GeoMarker(lat: 59.3293, long: 18.0686), // Stockholm, Sweden
                    // GeoMarker(lat: 41.9028, long: 12.4964), // Rome, Italy
                    // GeoMarker(lat: 48.2100, long: 16.3636), // Vienna, Austria
                    // GeoMarker(lat: 45.4215, long: -75.6919), // Ottawa, Canada
                    // GeoMarker(lat: 52.2297, long: 21.0122), // Warsaw, Poland
                    // GeoMarker(
                    //     lat: -22.9068,
                    //     long: -43.1729), // Rio de Janeiro, Brazil
                    // GeoMarker(
                    //     lat: -22.9068,
                    //     long: -43.1729), // Rio de Janeiro, Brazil
                    // GeoMarker(
                    //     lat: -35.2809, long: 149.1300), // Canberra, Australia
                    // GeoMarker(lat: 38.7223, long: -9.1393), // Lisbon, Portugal
                    // GeoMarker(lat: 35.6895, long: 51.3890), // Tehran, Iran
                    // GeoMarker(
                    //     lat: 35.6892,
                    //     long:
                    //         51.3889), // Tehran, Iran (alternative coordinates)
                    // GeoMarker(lat: 41.7151, long: 44.8271), // Tbilisi, Georgia
                    // GeoMarker(lat: 32.8872, long: 13.1913), // Tripoli, Libya
                    // GeoMarker(lat: 33.8886, long: 35.4955), // Beirut, Lebanon
                  ],
                  borderColor: Colors.blue.shade700,
                  backgroundColor: Colors.blue.shade200.withOpacity(0.4),
                  usePinMarker: true,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              shrinkWrap: true,
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade300,
                  ),
                  title: const Text("Bears"),
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.red.shade200,
                  ),
                  title: const Text("Wolves"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
