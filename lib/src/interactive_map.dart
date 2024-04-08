import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:interactive_country_map/src/interactive_map_theme.dart';
import 'package:interactive_country_map/src/map_entity.dart';
import 'package:interactive_country_map/src/map_painter.dart';
import 'package:interactive_country_map/src/painters/marker_painter.dart';
import 'package:interactive_country_map/src/svg/markers.dart';
import 'package:interactive_country_map/src/svg/svg_parser.dart';

class InteractiveMap extends StatefulWidget {
  const InteractiveMap({
    super.key,
    this.onCountrySelected,
    required this.map,
    this.theme = const InteractiveMapTheme(),
    this.loadingWidget,
    this.minZoom = 0.5,
    this.currentScale,
    this.maxZoom = 12,
    this.selectedCode,
    this.initialScale,
    this.markers = const [],
  }) : assert(minZoom > 0);

  /// Called when a country/region is selected. Return the code as defined by the ISO 3166-2
  /// https://en.wikipedia.org/wiki/ISO_3166-2
  final void Function(String code)? onCountrySelected;

  ///
  final List<MarkerGroup> markers;

  /// The name of the map to use (USA, China, France...)
  final MapEntity map;

  // Theme
  final InteractiveMapTheme theme;

  /// Widget we display during the loading of the map
  final Widget? loadingWidget;

  /// Minimum value of a zoom. Must be greater than 0
  final double minZoom;

  /// Maximum zoom value
  final double maxZoom;

  /// Initial scale value
  final double? initialScale;

  /// Initial value for the zoom
  final double? currentScale;

  /// Code of the selected country/region
  final String? selectedCode;

  @override
  State<InteractiveMap> createState() => _InteractiveMapState();
}

class _InteractiveMapState extends State<InteractiveMap> {
  String? svgData;
  late final TransformationController _controller;

  @override
  void initState() {
    super.initState();

    final scaleMatrix = Matrix4.identity()..scale(widget.initialScale ?? 1.0);
    _controller = TransformationController(scaleMatrix);

    Future.delayed(Duration.zero, loadMap);
  }

  @override
  void didUpdateWidget(InteractiveMap oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.map.name != widget.map.name) {
      loadMap();
    }

    if (oldWidget.currentScale != widget.currentScale) {
      final scaleMatrix = Matrix4.identity()..scale(widget.currentScale ?? 1.0);
      _controller.value = scaleMatrix;
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
    if (svgData != null) {
      return InteractiveViewer(
        transformationController: _controller,
        minScale: widget.minZoom,
        maxScale: widget.maxZoom,
        panEnabled: true,
        child: GeographicMap(
          svgData: svgData!,
          theme: widget.theme,
          onCountrySelected: widget.onCountrySelected,
          selectedCode: widget.selectedCode,
          markers: widget.markers,
        ),
      );
    } else {
      return widget.loadingWidget ?? const SizedBox.shrink();
    }
  }
}

class GeographicMap extends StatefulWidget {
  const GeographicMap({
    super.key,
    required this.svgData,
    required this.theme,
    this.onCountrySelected,
    this.selectedCode,
    required this.markers,
  });

  final String svgData;
  final InteractiveMapTheme theme;
  final void Function(String code)? onCountrySelected;
  final List<MarkerGroup> markers;

  final String? selectedCode;

  @override
  State<GeographicMap> createState() => _GeographicMapState();
}

class _GeographicMapState extends State<GeographicMap> {
  CountryMap? countryMap;
  Offset? cursorPosition;

  String? _selectedCode;

  @override
  void initState() {
    super.initState();

    _selectedCode = widget.selectedCode;

    _parseSvg();
  }

  @override
  void didUpdateWidget(GeographicMap oldWidget) {
    super.didUpdateWidget(oldWidget);

    // only reparse the SVG when the svg data are differet
    if (oldWidget.svgData != widget.svgData) {
      _parseSvg();
    }
    if (oldWidget.selectedCode != widget.selectedCode) {
      setState(() {
        _selectedCode = widget.selectedCode;
      });
    }
  }

  Future<void> _parseSvg() async {
    final newPaths = await SvgParser().parse(widget.svgData);

    setState(() {
      countryMap = newPaths;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapUp: (details) {
        setState(() {
          // we need the cursor local position to detect if the cursor is inside a region or not
          cursorPosition = details.localPosition;
        });

        // we crawl all the countries and just keep the first containing the cursor position
        final selectedCountry = countryMap?.countryPaths.firstWhereOrNull(
            (element) => element.path.toPath().contains(details.localPosition));

        if (selectedCountry != null && widget.onCountrySelected != null) {
          widget.onCountrySelected!(selectedCountry.countryCode);
          setState(() {
            _selectedCode = selectedCountry.countryCode;
          });
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (countryMap == null) {
            return const CircularProgressIndicator();
          }
          return CustomPaint(
            size: Size(constraints.maxWidth, constraints.maxHeight),
            painter: MapPainter(
              countryMap: countryMap!,
              cursorPosition: cursorPosition,
              theme: widget.theme,
              selectedCode: _selectedCode,
              canSelect: widget.onCountrySelected != null,
            ),
            foregroundPainter: MarkerPainter(
              countryMap: countryMap!,
              theme: widget.theme,
              markers: widget.markers,
            ),
          );
        },
      ),
    );
  }
}
