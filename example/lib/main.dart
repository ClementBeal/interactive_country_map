import 'package:example/screens/france_departments_screen.dart';
import 'package:example/screens/france_wolf_screen.dart';
import 'package:example/screens/lat_long_markers_screen.dart';
import 'package:example/screens/world_map_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.purple,
          ),
          colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.purple, brightness: Brightness.dark),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Interactive Country Map"),
      ),
      body: ListView(
        children: [
          ListTile(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const FranceDepartmentsPage(),
              ));
            },
            leading: const Text("1"),
            title: const Text("Select on click and programmatically a region"),
            subtitle: const Text("France departments"),
          ),
          ListTile(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const FrancePlot(),
              ));
            },
            leading: const Text("2"),
            title: const Text("Plot example"),
          ),
          ListTile(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const WorldMapScreen(),
              ));
            },
            leading: const Text("3"),
            title: const Text("World Map"),
          ),
          ListTile(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const LatLongMarkersScreen(),
              ));
            },
            leading: const Text("4"),
            title: const Text("Lat/Long markers"),
          ),
        ],
      ),
    );
  }
}
