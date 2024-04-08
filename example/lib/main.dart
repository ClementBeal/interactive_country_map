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
                  borderColor: Colors.red.shade200,
                  borderWidth: 2.0,
                  selectedBorderWidth: 3.0,
                  defaultCountryColor: Colors.green.shade700,
                  defaultSelectedCountryColor: Colors.orange.shade300,
                  mappingCode: {
                    "FR-U": Colors.black,
                  },
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
                selectedCode: "FR-U",
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
