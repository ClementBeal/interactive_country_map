import 'dart:ui';

class MappingHelper {
  static Map<String, Color> sameColor(Color color, List<String> codes) {
    final result = <String, Color>{};

    for (var code in codes) {
      result[code] = color;
    }

    return result;
  }
}
