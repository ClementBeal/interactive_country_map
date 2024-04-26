import 'dart:ui';

// ignore: avoid_classes_with_only_static_members
///
class MappingHelper {
  ///
  static Map<String, Color> sameColor(Color color, List<String> codes) {
    final result = <String, Color>{};

    for (final code in codes) {
      result[code] = color;
    }

    return result;
  }
}