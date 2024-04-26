import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:interactive_country_map/interactive_country_map.dart';
import 'package:interactive_country_map/src/loaders.dart';
import 'package:interactive_country_map/src/painters/map_painter.dart';
import 'package:interactive_country_map/src/painters/marker_painter.dart';
import 'package:interactive_country_map/src/svg/svg_parser.dart';

/// Draw an interactive map from a SVG.
///
/// The SVG files must have `<path` with a field `id` otherwise the interactivity will not work
class InteractiveMap extends StatefulWidget {
  /// Use one of the pre-delivered map of the package
  InteractiveMap(
    MapEntity map, {
    super.key,
    this.onError,
    this.onLoaded,
    this.onCountrySelected,
    this.theme = const InteractiveMapTheme(),
    this.loadingBuilder,
    this.minScale = 0.5,
    this.currentScale,
    this.maxScale = 8,
    this.selectedCode,
    this.initialScale,
    this.markers = const [],
  }) : loader = MapEntityLoader(entity: map);

  /// Load a map from an user's file
  InteractiveMap.file(
    File file, {
    super.key,
    this.onError,
    this.onLoaded,
    this.onCountrySelected,
    this.theme = const InteractiveMapTheme(),
    this.loadingBuilder,
    this.minScale = 0.5,
    this.currentScale,
    this.maxScale = 8,
    this.selectedCode,
    this.initialScale,
    this.markers = const [],
  }) : loader = FileLoader(file: file);

  /// Load a map from the assets of the app
  InteractiveMap.asset(
    String assetName, {
    super.key,
    this.onError,
    this.onLoaded,
    this.onCountrySelected,
    this.theme = const InteractiveMapTheme(),
    this.loadingBuilder,
    this.minScale = 0.5,
    this.currentScale,
    this.maxScale = 8,
    this.selectedCode,
    this.initialScale,
    this.markers = const [],
  }) : loader = AssetLoader(assetName: assetName);

  /// Used to load the SVG's string from somewhere(assets, files, others...)
  final SvgLoader loader;

  /// Called when a country/region is selected. Return the code as defined by the ISO 3166-2
  /// https://en.wikipedia.org/wiki/ISO_3166-2
  final void Function(String code)? onCountrySelected;

  /// Draw layers of markers over the map
  final List<MarkerGroup> markers;

  /// Theme
  final InteractiveMapTheme theme;

  /// Widget we display during the loading of the map
  final Widget Function(BuildContext context)? loadingBuilder;

  /// Provide a callback when loaded
  final Future<void> Function(String svgData)? onLoaded;

  /// Error routine
  final Widget? Function(FlutterErrorDetails errorDetails, String? svgData)?
      onError;

  /// Minimum value of a scale. Must be greater than 0
  final double minScale;

  /// Maximum scale value
  final double maxScale;

  /// Initial scale value
  final double? initialScale;

  /// Initial value for the zoom
  final double? currentScale;

  /// Code of the selected country/region
  final String? selectedCode;

  @override
  State<InteractiveMap> createState() => _InteractiveMapState();
}

// Good practice to hide the State class as a Library private member
class _InteractiveMapState extends State<InteractiveMap> {
  //
  String? svgData;
  Future<String>? _future;
  late final TransformationController _controller;
  late double _scale;

  @override
  void initState() {
    super.initState();
    _scale = widget.initialScale ?? 1.0;
    final scaleMatrix = Matrix4.identity()..scale(_scale);
    _controller = TransformationController(scaleMatrix);
    _future = loadMap();
  }

  @override
  void didUpdateWidget(InteractiveMap oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.loader != widget.loader) {
      _future = loadMap();
      setState(() {});
    }

    if (oldWidget.currentScale != widget.currentScale) {
      final scaleMatrix = Matrix4.identity()..scale(widget.currentScale ?? 1.0);
      _controller.value = scaleMatrix;
    }
  }

  /// Load the SVG's data
  Future<String> loadMap() async {
    final svg = await widget.loader.load(context);
    svgData = svg;
    await widget.onLoaded?.call(svg);
    return svg;
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<String>(
        key: ValueKey<State>(this),
        future: _future,
        builder: _buildMap,
      );

  /// Returns the appropriate widget when the Future is completed.
  Widget _buildMap(BuildContext context, AsyncSnapshot<String> snapshot) {
    //
    Widget? mapWidget;
    FlutterErrorDetails? errorDetails;

    if (snapshot.connectionState == ConnectionState.done) {
      //
      if (snapshot.hasError) {
        // Optionally supply a Widget
        mapWidget = _svgDataError(snapshot.error!, svgData, 'loadMap() failed');
      }

      // Display an interactive map
      if (svgData != null && mapWidget == null) {
        //
        try {
          //
          // throw Exception('Error Test!');   // <--- Uncomment this line to see the _svgDataError() run

          mapWidget = InteractiveViewer(
            transformationController: _controller,
            minScale: widget.minScale,
            maxScale: widget.maxScale,
            onInteractionUpdate: (details) {
              setState(() {
                _scale = _controller.value[0];
              });
            },
            child: GeographicMap(
              svgData: svgData!,
              theme: widget.theme,
              onCountrySelected: widget.onCountrySelected,
              selectedCode: widget.selectedCode,
              markers: widget.markers,
              scale: _scale,
            ),
          );
        } catch (e, stack) {
          // Optionally supply a Widget
          mapWidget = _svgDataError(e, svgData, 'InteractiveViewer() failed', stack: stack);
        }
        // A large string is cleared
        svgData = null;
      }
    }
    // A Widget must be supplied.
    return mapWidget ??=
        widget.loadingBuilder?.call(context) ?? const SizedBox.shrink();
  }

  // Handle any errors. Optionally supply a Widget
  Widget? _svgDataError(Object exception, String? svgData, String message, {StackTrace? stack}) {
    //
    final errorDetails = FlutterErrorDetails(
      exception: exception,
      stack: stack ?? (exception is Error ? exception.stackTrace : null),
      library: 'interactive_map.dart',
      context: ErrorDescription(message),
    );
    // Optionally supply a Widget
    return widget.onError?.call(errorDetails, svgData);
  }
}

///
class GeographicMap extends StatefulWidget {
  ///
  const GeographicMap({
    super.key,
    required this.svgData,
    required this.theme,
    this.onCountrySelected,
    this.selectedCode,
    required this.markers,
    required this.scale,
  });

  ///
  final String svgData;

  ///
  final InteractiveMapTheme theme;

  ///
  final void Function(String code)? onCountrySelected;

  ///
  final List<MarkerGroup> markers;

  ///
  final double scale;

  ///
  final String? selectedCode;

  @override
  State<GeographicMap> createState() => _GeographicMapState();
}

class _GeographicMapState extends State<GeographicMap> {
  CountryMap? countryMap;
  Offset? cursorPosition;

  String? _selectedCode;

  // final _painterKey = GlobalKey<CustomPaint>();

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
    return LayoutBuilder(
      builder: (context, constraints) => GestureDetector(
        onTapUp: (details) {
          setState(() {
            // we need the cursor local position to detect if the cursor is inside a region or not
            cursorPosition = details.localPosition;
          });

          // we crawl all the countries and just keep the first containing the cursor position
          final selectedCountry = countryMap?.countryPaths
              .firstWhereOrNull((element) => element.path
                  .toPath(
                    maxSize: Size(constraints.maxWidth, constraints.maxHeight),
                    originalMapSize:
                        Size(countryMap!.width, countryMap!.height),
                  )
                  .contains(details.localPosition));

          if (selectedCountry != null && widget.onCountrySelected != null) {
            widget.onCountrySelected!(selectedCountry.countryCode);
            setState(() {
              _selectedCode = selectedCountry.countryCode;
            });
          }
        },
        child: Builder(
          builder: (context) {
            if (countryMap == null) {
              return const CircularProgressIndicator();
            }

            final countryMapAspectRatio =
                Size(countryMap!.width, countryMap!.height).aspectRatio;

            return AspectRatio(
              aspectRatio: countryMapAspectRatio,
              child: CustomPaint(
                painter: MapPainter(
                  countryMap: countryMap!,
                  cursorPosition: cursorPosition,
                  theme: widget.theme,
                  selectedCode: _selectedCode,
                  canSelect: widget.onCountrySelected != null,
                  scale: widget.scale,
                ),
                foregroundPainter: MarkerPainter(
                  countryMap: countryMap!,
                  theme: widget.theme,
                  markers: widget.markers,
                  scale: widget.scale,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
