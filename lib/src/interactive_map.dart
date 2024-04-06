import 'dart:io';

import 'package:flutter/material.dart';
import 'package:interactive_country_map/src/map_painter.dart';
import 'package:interactive_country_map/src/svg/svg_parser.dart';

class InteractiveMap extends StatelessWidget {
  const InteractiveMap({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _InteractiveMap(
          file: File(
            "/home/clement/Documents/Projets/librairies/interactive_country_map/assets/france.svg",
          ),
        ),
        const Align(
          alignment: Alignment.topRight,
          child: ZoomInOutButton(),
        ),
      ],
    );
  }
}

class ZoomInOutButton extends StatelessWidget {
  const ZoomInOutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.remove)),
        IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
      ],
    );
  }
}

class _InteractiveMap extends StatefulWidget {
  const _InteractiveMap({required this.file});

  final File file;

  @override
  State<_InteractiveMap> createState() => _InteractiveMapState();
}

class _InteractiveMapState extends State<_InteractiveMap> {
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
        ),
      ),
    );
  }
}
