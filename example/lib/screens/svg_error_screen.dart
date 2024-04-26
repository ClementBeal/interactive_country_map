import 'package:flutter/material.dart';


// The widget displayed in onError90
Widget svgErrorWidget(String message) => Container(
  alignment: Alignment.centerLeft,
  margin: const EdgeInsets.all(30),
  decoration: BoxDecoration(
    color: Colors.purple,
    gradient: const LinearGradient(
        colors: [Colors.pink, Colors.lightBlueAccent],
        begin: Alignment.bottomLeft,
        end: Alignment.topRight),
    border: Border.all(
      color: Colors.lightGreenAccent,
      width: 6.0,
      style: BorderStyle.solid,
    ),
    borderRadius: const BorderRadius.all(Radius.circular(10.0)),
    boxShadow: const [
      BoxShadow(
        color: Colors.grey,
        blurRadius: 15.0,
        spreadRadius: 3.0,
        offset: Offset(10.0, 10.0),
      ),
    ],
  ),
  padding: const EdgeInsets.only(left: 15, top: 100, bottom: 30),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      const Center(
        child: Text(
          'Oops!',
          style: TextStyle(color: Colors.red, fontSize: 24),
        ),
      ),
      const SizedBox(height: 20),
      Text(
        message,
        style: const TextStyle(color: Colors.white70),
      ),
      const Text(
        'Optionally return a Widget from onError()',
        style: TextStyle(color: Colors.white70),
      ),
    ],
  ),
);

