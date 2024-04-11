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
  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        home: FranceWolfMap(),
      ),
    );
  }
}

class FranceDepartmentsPage extends StatefulWidget {
  const FranceDepartmentsPage({super.key});

  @override
  State<FranceDepartmentsPage> createState() => _FranceDepartmentsPageState();
}

class _FranceDepartmentsPageState extends State<FranceDepartmentsPage> {
  String? selectedRegion;
  MapEntity map = MapEntity.franceDepartments;

  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: InteractiveMap(
              map,
              theme: InteractiveMapTheme(
                borderColor: Colors.green.shade800,
                borderWidth: 1.0,
                selectedBorderWidth: 3.0,
                defaultCountryColor: Colors.grey.shade300,
                defaultSelectedCountryColor: Colors.green.shade200,
              ),
              loadingBuilder: (context) =>
                  const Center(child: CircularProgressIndicator()),
              selectedCode: selectedRegion,
              minScale: 0.3,
              maxScale: 4,
              onCountrySelected: (code) {
                setState(() {
                  selectedRegion = code;
                  _controller.text = departments[code]!;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              readOnly: true,
              controller: _controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Where were you born?",
              ),
              onTap: () async {
                final value = await showModalBottomSheet<String>(
                  context: context,
                  builder: (context) => const FrenchDepartementsList(),
                );

                if (value != null) {
                  _controller.text = departments[value]!;
                  setState(() {
                    selectedRegion = value;
                  });
                }
              },
            ),
          )
        ],
      ),
    );
  }
}

class FrenchDepartementsList extends StatelessWidget {
  const FrenchDepartementsList({super.key});

  @override
  Widget build(BuildContext context) {
    final entries = departments.entries.toList();

    return ListView.builder(
      shrinkWrap: true,
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final d = entries[index];

        return ListTile(
          title: Text(d.value),
          onTap: () {
            Navigator.of(context).pop(d.key);
          },
        );
      },
    );
  }
}

class FranceWolfMap extends StatelessWidget {
  const FranceWolfMap({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: InteractiveMap(
              MapEntity.world,
              theme: InteractiveMapTheme(
                  borderColor: Colors.green.shade800,
                  borderWidth: 1.0,
                  selectedBorderWidth: 3.0,
                  defaultCountryColor: Colors.green.shade200,
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
              maxScale: 4,
              markers: [
                MarkerGroup(
                  markers: [
                    GeoMarker(lat: 48.864716, long: 2.349014),
                    GeoMarker(lat: 38.9072, long: -77.0369),
                    GeoMarker(lat: 51.5074, long: -0.1278),
                    GeoMarker(lat: 35.6895, long: 139.6917),
                    GeoMarker(lat: -33.4489, long: -70.6693),
                  ],
                  borderColor: Colors.blue.shade700,
                  backgroundColor: Colors.blue.shade200.withOpacity(0.4),
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

final departments = {
  "FR-01": "Ain",
  "FR-02": "Aisne",
  "FR-03": "Allier",
  "FR-04": "Alpes-de-Haute-Provence",
  "FR-05": "Hautes-Alpes",
  "FR-06": "Alpes-Maritimes",
  "FR-07": "Ardèche",
  "FR-08": "Ardennes",
  "FR-09": "Ariège",
  "FR-10": "Aube",
  "FR-11": "Aude",
  "FR-12": "Aveyron",
  "FR-13": "Bouches-du-Rhône",
  "FR-14": "Calvados",
  "FR-15": "Cantal",
  "FR-16": "Charente",
  "FR-17": "Charente-Maritime",
  "FR-18": "Cher",
  "FR-19": "Corrèze",
  "FR-21": "Côte-d'Or",
  "FR-22": "Côtes-d'Armor",
  "FR-23": "Creuse",
  "FR-24": "Dordogne",
  "FR-25": "Doubs",
  "FR-26": "Drôme",
  "FR-27": "Eure",
  "FR-28": "Eure-et-Loir",
  "FR-29": "Finistère",
  "FR-2A": "Corse-du-Sud",
  "FR-2B": "Haute-Corse",
  "FR-30": "Gard",
  "FR-31": "Haute-Garonne",
  "FR-32": "Gers",
  "FR-33": "Gironde",
  "FR-34": "Hérault",
  "FR-35": "Ille-et-Vilaine",
  "FR-36": "Indre",
  "FR-37": "Indre-et-Loire",
  "FR-38": "Isère",
  "FR-39": "Jura",
  "FR-40": "Landes",
  "FR-41": "Loir-et-Cher",
  "FR-42": "Loire",
  "FR-43": "Haute-Loire",
  "FR-44": "Loire-Atlantique",
  "FR-45": "Loiret",
  "FR-46": "Lot",
  "FR-47": "Lot-et-Garonne",
  "FR-48": "Lozère",
  "FR-49": "Maine-et-Loire",
  "FR-50": "Manche",
  "FR-51": "Marne",
  "FR-52": "Haute-Marne",
  "FR-53": "Mayenne",
  "FR-54": "Meurthe-et-Moselle",
  "FR-55": "Meuse",
  "FR-56": "Morbihan",
  "FR-57": "Moselle",
  "FR-58": "Nièvre",
  "FR-59": "Nord",
  "FR-60": "Oise",
  "FR-61": "Orne",
  "FR-62": "Pas-de-Calais",
  "FR-63": "Puy-de-Dôme",
  "FR-64": "Pyrénées-Atlantiques",
  "FR-65": "Hautes-Pyrénées",
  "FR-66": "Pyrénées-Orientales",
  "FR-67": "Bas-Rhin",
  "FR-68": "Haut-Rhin",
  "FR-69": "Rhône",
  "FR-70": "Haute-Saône",
  "FR-71": "Saône-et-Loire",
  "FR-72": "Sarthe",
  "FR-73": "Savoie",
  "FR-74": "Haute-Savoie",
  "FR-75": "Paris",
  "FR-76": "Seine-Maritime",
  "FR-77": "Seine-et-Marne",
  "FR-78": "Yvelines",
  "FR-79": "Deux-Sèvres",
  "FR-80": "Somme",
  "FR-81": "Tarn",
  "FR-82": "Tarn-et-Garonne",
  "FR-83": "Var",
  "FR-84": "Vaucluse",
  "FR-85": "Vendée",
  "FR-86": "Vienne",
  "FR-87": "Haute-Vienne",
  "FR-88": "Vosges",
  "FR-89": "Yonne",
  "FR-90": "Territoire de Belfort",
  "FR-91": "Essonne",
  "FR-92": "Hauts-de-Seine",
  "FR-93": "Seine-Saint-Denis",
  "FR-94": "Val-de-Marne",
  "FR-95": "Val-d'Oise"
};
