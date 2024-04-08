import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:interactive_country_map/src/interactive_map_theme.dart';
import 'package:interactive_country_map/src/map_entity.dart';
import 'package:interactive_country_map/src/map_painter.dart';
import 'package:interactive_country_map/src/svg/svg_parser.dart';

class InteractiveMap extends StatefulWidget {
  const InteractiveMap({
    super.key,
    required this.onCountrySelected,
    required this.map,
    this.theme = const InteractiveMapTheme(),
    this.controller,
    this.loadingWidget,
    this.minZoom = 0.5,
    this.initialZoom = 1.0,
    this.maxZoom = 12,
    this.selectedCode,
  }) : assert(minZoom > 0);

  /// Called when a country/region is selected. Return the code as defined by the ISO 3166-2
  /// https://en.wikipedia.org/wiki/ISO_3166-2
  final void Function(String code) onCountrySelected;

  /// The name of the map to use (USA, China, France...)
  final MapEntity map;
  final InteractiveMapTheme theme;

  /// Control the interactive map zoom
  final InteractiveMapController? controller;

  /// Widget we display during the loading of the map
  final Widget? loadingWidget;

  /// Minimum value of a zoom. Must be greater than 0
  final double minZoom;

  /// Maximum zoom value
  final double maxZoom;

  /// Initial value for the zoom
  final double initialZoom;

  /// Code of the selected country/region
  final String? selectedCode;

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
    if (svgData != null) {
      return Center(
        child: GeographicMap(
          svgData: svgData!,
          theme: widget.theme,
          onCountrySelected: widget.onCountrySelected,
          minZoom: widget.minZoom,
          maxZoom: widget.maxZoom,
          initialZoom: widget.initialZoom,
          controller: widget.controller,
          selectedCode: widget.selectedCode,
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
    required this.onCountrySelected,
    required this.minZoom,
    required this.maxZoom,
    this.controller,
    required this.initialZoom,
    this.selectedCode,
  });

  final String svgData;
  final InteractiveMapTheme theme;
  final void Function(String code) onCountrySelected;
  final InteractiveMapController? controller;

  final double minZoom;
  final double maxZoom;
  final double initialZoom;
  final String? selectedCode;

  @override
  State<GeographicMap> createState() => _GeographicMapState();
}

class _GeographicMapState extends State<GeographicMap> {
  List<CountryPath> countries = [];
  Offset? cursorPosition;
  Offset offset = Offset.zero;

  String? _selectedCode;

  double _scale = 1.0;
  double _draggingScale = 1.0;

  @override
  void initState() {
    super.initState();

    _selectedCode = widget.selectedCode;

    _scale = widget.initialZoom;

    widget.controller?.addListener(() {
      switch (widget.controller!.state) {
        case InteractiveMapControllerState.none:
          break;
        case InteractiveMapControllerState.zoomIn:
          setState(() {
            if (_scale + widget.controller!.quantity <= widget.maxZoom) {
              _scale += widget.controller!.quantity;
            } else {
              _scale = widget.maxZoom;
            }
          });

        case InteractiveMapControllerState.zoomOut:
          setState(() {
            if (_scale - widget.controller!.quantity >= widget.minZoom) {
              _scale -= widget.controller!.quantity;
            } else {
              _scale = widget.minZoom;
            }
          });
        case InteractiveMapControllerState.reset:
          setState(() {
            _scale = widget.initialZoom;
          });
      }
    });

    _parseSvg();
  }

  @override
  void didUpdateWidget(GeographicMap oldWidget) {
    super.didUpdateWidget(oldWidget);

    // only reparse the SVG when the svg data are differet
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
            // we need the cursor local position to detect if the cursor is inside a region or not
            cursorPosition = details.localPosition;
          });

          // we crawl all the countries and just keep the first containing the cursor position
          final selectedCountry = countries.firstWhereOrNull((element) =>
              element.path.toPath(1, offset).contains(details.localPosition));

          if (selectedCountry != null) {
            widget.onCountrySelected(selectedCountry.countryCode);
            setState(() {
              _selectedCode = selectedCountry.countryCode;
            });
          }
        },
        onScaleStart: (details) {
          // we need to store the current zoom value because the new value multiply it
          _draggingScale = _scale;
        },
        onScaleUpdate: (details) {
          setState(() {
            offset = offset + details.focalPointDelta;
            cursorPosition = details.localFocalPoint;

            final possibleNewScale = _draggingScale * details.scale;
            if (widget.minZoom <= possibleNewScale &&
                possibleNewScale <= widget.maxZoom) {
              _scale = _draggingScale * details.scale;
            }
          });
        },
        child: CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: MapPainter(
            countries: countries,
            cursorPosition: cursorPosition,
            offset: offset,
            theme: widget.theme,
            scale: _scale,
            selectedCode: _selectedCode,
          ),
        ),
      ),
    );
  }
}

enum InteractiveMapControllerState { none, zoomIn, zoomOut, reset }

class InteractiveMapController with ChangeNotifier {
  double _quantity = 1.0;
  get quantity => _quantity;

  InteractiveMapControllerState state = InteractiveMapControllerState.none;

  /// Zoom in in the map
  /// @quantity : the amount of zoom to apply
  void zoomIn({double quantity = 1.0}) {
    _quantity = quantity;
    state = InteractiveMapControllerState.zoomIn;

    notifyListeners();
  }

  /// Zoom in in the map
  /// @quantity : the amount of zoom to remove
  void zoomOut({double quantity = 1.0}) {
    _quantity = quantity;
    state = InteractiveMapControllerState.zoomOut;

    notifyListeners();
  }

  /// Reset the zoom at the initial value
  void resetZoom() {
    state = InteractiveMapControllerState.reset;

    notifyListeners();
  }
}
