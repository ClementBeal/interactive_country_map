import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
  MapEntity map = MapEntity.colombia;

  @override
  void initState() {
    super.initState();

    var counter = 0;
    Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        map = switch (counter) {
          0 => MapEntity.france,
          1 => MapEntity.chile,
          _ => MapEntity.china,
        };
      });

      if (counter++ > 3) {
        timer.cancel();
      }
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
                onCountrySelected: (code) {
                  setState(() {
                    selectedRegion = code;
                  });
                },
                map: map,
              ),
            ),
            if (selectedRegion != null)
              Text(
                "Selected area: $selectedRegion",
                style: Theme.of(context).textTheme.displaySmall,
              ),
          ],
        ),
      ),
    );
  }
}
