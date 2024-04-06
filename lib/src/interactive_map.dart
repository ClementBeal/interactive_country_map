import 'dart:io';

import 'package:flutter/material.dart';
import 'package:interactive_country_map/src/map_painter.dart';
import 'package:interactive_country_map/src/svg/svg_parser.dart';

class InteractiveMapTheme {
  final double zoom;

  InteractiveMapTheme({required this.zoom});
}

class InteractiveMap extends StatefulWidget {
  const InteractiveMap({super.key});

  @override
  State<InteractiveMap> createState() => _InteractiveMapState();
}

class _InteractiveMapState extends State<InteractiveMap> {
  double _scale = 1;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GeographicMap(
          file: File(
            "/home/clement/Documents/Projets/librairies/interactive_country_map/assets/france.svg",
          ),
          theme: InteractiveMapTheme(zoom: _scale),
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
                _scale = (_scale >= 0) ? _scale - 1 : _scale;
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
  const GeographicMap({super.key, required this.file, required this.theme});

  final File file;
  final InteractiveMapTheme theme;

  @override
  State<GeographicMap> createState() => _GeographicMapState();
}

class _GeographicMapState extends State<GeographicMap> {
  List<CountryPath> countries = [];
  Offset? cursorPosition;

  @override
  void initState() {
    super.initState();

    _parseSvg();
  }

  Future<void> _parseSvg() async {
    final newPaths = await SvgParser().parse(widget.file);

    setState(() {
      countries = newPaths;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        setState(() {
          cursorPosition = details.globalPosition;
        });
      },
      child: CustomPaint(
        size: const Size.square(800),
        painter: MapPainter(
          countries: countries,
          cursorPosition: cursorPosition,
          theme: widget.theme,
        ),
      ),
    );
  }
}
