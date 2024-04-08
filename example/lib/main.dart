import 'dart:async';

import 'package:flutter/material.dart';
import 'package:interactive_country_map/interactive_country_map.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? selectedRegion;
  MapEntity map = MapEntity.france;

  InteractiveMapController controller = InteractiveMapController();

  @override
  void initState() {
    super.initState();
    var i = 0;
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (i > 2) {
        timer.cancel();
      }

      setState(() {
        selectedRegion = switch (i) {
          0 => "FR-A",
          1 => "FR-B",
          2 => "FR-C",
          _ => "FR-D",
        };
      });
      i++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      home: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: InteractiveMap(
                controller: controller,
                theme: InteractiveMapTheme(
                  borderColor: Colors.green.shade800,
                  borderWidth: 1.0,
                  selectedBorderWidth: 3.0,
                  defaultCountryColor: Colors.green.shade300,
                  defaultSelectedCountryColor: Colors.green.shade200,
                ),
                loadingWidget: Container(
                  color: Colors.red,
                  width: 100,
                  height: 100,
                ),
                onCountrySelected: (code) {
                  setState(() {
                    selectedRegion = code;
                  });
                },
                map: map,
                selectedCode: selectedRegion,
              ),
            ),
            if (selectedRegion != null)
              Text(
                "Selected area: $selectedRegion",
                style: Theme.of(context).textTheme.displaySmall,
              ),
            FilledButton(
              onPressed: () {
                controller.zoomIn();
              },
              child: Text("Zoom in"),
            ),
            FilledButton(
              onPressed: () {
                controller.zoomOut();
              },
              child: Text("Zoom out"),
            ),
          ],
        ),
      ),
    );
  }
}
