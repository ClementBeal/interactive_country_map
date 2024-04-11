import 'dart:io';

import 'package:flutter/material.dart';
import 'package:interactive_country_map/interactive_country_map.dart';

abstract class SvgLoader {
  Future<String> load(BuildContext context);
}

class MapEntityLoader extends SvgLoader {
  final MapEntity entity;

  MapEntityLoader({required this.entity});

  @override
  Future<String> load(BuildContext context) async {
    return await DefaultAssetBundle.of(context).loadString(
        "packages/interactive_country_map/res/maps/${entity.filename}.svg");
  }
}

class FileLoader extends SvgLoader {
  final File file;

  FileLoader({required this.file});

  @override
  Future<String> load(BuildContext context) async {
    return await file.readAsString();
  }
}

class AssetLoader extends SvgLoader {
  final String assetName;

  AssetLoader({required this.assetName});

  @override
  Future<String> load(BuildContext context) async {
    return await DefaultAssetBundle.of(context).loadString(assetName);
  }
}
