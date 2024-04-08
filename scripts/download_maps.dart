// ignore_for_file: avoid_print

import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';

void main() async {
  const url = 'https://mapsvg.com/maps';
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final document = parse(response.body);
    final links = extractLinks(document);

    for (var (i, l) in links.indexed) {
      print("${i + 1}/${links.length}");
      await downloadMap(l);
    }
  } else {
    print('Failed to load website: ${response.statusCode}');
  }
}

List<String> extractLinks(Document document) {
  return document
      .querySelectorAll('.maps-list a')
      .map((e) => e.attributes["href"]!)
      .map((e) => e.substring(6))
      .toList();
}

Future<void> downloadMap(String link) async {
  final url = "https://mapsvg.com/maps/$link";

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final document = parse(response.body);
    final svgLink = document
        .querySelectorAll(".btn-primary")
        .firstWhere((element) => element.text.contains("Download"))
        .attributes["href"];

    final svg = await http.get(Uri.parse("https://mapsvg.com/$svgLink"));

    File("assets/$link.svg").writeAsStringSync(svg.body);
  } else {
    print('Failed to load website: ${response.statusCode}');
  }
}
