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
  double _scale = 1;

  String? svgData;

  @override
  void initState() {
    super.initState();

    Future.delayed(
      Durations.extralong4,
      () async {
        final tmp = await DefaultAssetBundle.of(context).loadString(
            "packages/interactive_country_map/res/maps/${widget.map.filename}.svg");

        setState(() {
          svgData = tmp;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (svgData != null)
          Center(
            child: GeographicMap(
              svgData: svgData!,
              theme: InteractiveMapTheme(zoom: _scale),
              onCountrySelected: widget.onCountrySelected,
            ),
          ),
        Align(
          alignment: Alignment.topRight,
          child: ZoomInOutButton(
            onZoomIn: () {
              setState(() {
                _scale = (_scale + 1 <= 8) ? _scale + 1 : _scale;
              });
            },
            onZoomOut: () {
              setState(() {
                _scale = (_scale > 1) ? _scale - 1 : _scale;
              });
            },
          ),
        ),
      ],
    );
  }
}

class ZoomInOutButton extends StatelessWidget {
  const ZoomInOutButton(
      {super.key, required this.onZoomIn, required this.onZoomOut});

  final void Function() onZoomIn;
  final void Function() onZoomOut;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(onPressed: onZoomOut, icon: const Icon(Icons.remove)),
        IconButton(onPressed: onZoomIn, icon: const Icon(Icons.add)),
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
        // onScaleUpdate: (details) {
        //   // print(details.scale * 1);

        //   setState(() {
        //     offset = offset + details.localFocalPoint;
        //   });
        // },
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
