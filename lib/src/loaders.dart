import 'dart:io';

import 'package:flutter/material.dart';
import 'package:interactive_country_map/interactive_country_map.dart';

///
abstract class SvgLoader {
  ///
  Future<String> load(BuildContext context);
}

///
class MapEntityLoader extends SvgLoader {
  ///
  MapEntityLoader({required this.entity});

  ///
  final MapEntity entity;

  @override
  Future<String> load(BuildContext context) =>
      DefaultAssetBundle.of(context).loadString(
          'packages/interactive_country_map/res/maps/${entity.filename}.svg');
}

///
class FileLoader extends SvgLoader {
  ///
  FileLoader({required this.file});

  ///
  final File file;

  @override
  Future<String> load(BuildContext context) => file.readAsString();
}

///
class AssetLoader extends SvgLoader {
  ///
  AssetLoader({required this.assetName});

  ///
  final String assetName;

  @override
  Future<String> load(BuildContext context) =>
      DefaultAssetBundle.of(context).loadString(assetName);
}
