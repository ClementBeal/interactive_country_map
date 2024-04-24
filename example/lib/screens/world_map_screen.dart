import 'package:flutter/material.dart';
import 'package:interactive_country_map/interactive_country_map.dart';

class WorldMapScreen extends StatelessWidget {
  const WorldMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Expanded(
            child: InteractiveMap(
              MapEntity.world,
              theme: InteractiveMapTheme(
                borderWidth: 1,
                backgroundColor: Colors.blue.shade800,
                borderColor: Colors.black26,
                defaultCountryColor: Colors.orange.shade200,
              ),
              initialScale: 3,
            ),
          ),
        ],
      ),
    );
  }
}
