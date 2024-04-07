import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:interactive_country_map/src/Interactive_map_theme.dart';
import 'package:interactive_country_map/src/map_entity.dart';
import 'package:interactive_country_map/src/map_painter.dart';
import 'package:interactive_country_map/src/svg/svg_parser.dart';

class InteractiveMap extends StatefulWidget {
  const InteractiveMap(
      {super.key, required this.onCountrySelected, required this.map});

  final void Function(String code) onCountrySelected;
  final MapEntity map;

  @override
  State<InteractiveMap> createState() => _InteractiveMapState();
}

class _InteractiveMapState extends State<InteractiveMap> {
  String? svgData;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, loadMap);
  }

  @override
  void didUpdateWidget(InteractiveMap oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.map.name != widget.map.name) {
      loadMap();
    }
  }

  Future<void> loadMap() async {
    final tmp = await DefaultAssetBundle.of(context).loadString(
        "packages/interactive_country_map/res/maps/${widget.map.filename}.svg");

    setState(() {
      svgData = tmp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (svgData != null)
          Center(
            child: GeographicMap(
              svgData: svgData!,
              theme: InteractiveMapTheme(
                zoom: 1,
              ),
              onCountrySelected: widget.onCountrySelected,
            ),
          ),
      ],
    );
  }
}

class GeographicMap extends StatefulWidget {
  const GeographicMap(
      {super.key,
      required this.svgData,
      required this.theme,
      required this.onCountrySelected});

  final String svgData;
  final InteractiveMapTheme theme;
  final void Function(String code) onCountrySelected;

  @override
  State<GeographicMap> createState() => _GeographicMapState();
}

class _GeographicMapState extends State<GeographicMap> {
  List<CountryPath> countries = [];
  Offset? cursorPosition;
  Offset offset = Offset.zero;

  @override
  void initState() {
    super.initState();

    _parseSvg();
  }

  @override
  void didUpdateWidget(GeographicMap oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.svgData != widget.svgData) {
      _parseSvg();
    }
  }

  Future<void> _parseSvg() async {
    final newPaths = await SvgParser().parse(widget.svgData);

    setState(() {
      countries = newPaths;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => GestureDetector(
        onTapDown: (details) {
          setState(() {
            cursorPosition = details.localPosition;
          });

          final selectedCountry = countries.firstWhereOrNull((element) =>
              element.path.toPath(1, offset).contains(details.localPosition));

          if (selectedCountry != null) {
            widget.onCountrySelected(selectedCountry.countryCode);
          }
        },
        onScaleUpdate: (details) {
          setState(() {
            offset = offset + details.focalPointDelta;
          });
        },
        child: CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: MapPainter(
            countries: countries,
            cursorPosition: cursorPosition,
            offset: offset,
            theme: widget.theme,
          ),
        ),
      ),
    );
  }
}
