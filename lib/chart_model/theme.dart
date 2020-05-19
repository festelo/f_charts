import 'dart:ui';

import 'package:flutter/material.dart';

class ChartTheme {
  final LineTheme xPointer;
  final LineTheme yMarker;
  final int yMarkersCount;
  final LineTheme line;
  final LineTheme xAxis;
  final LineTheme yAxis;
  final CircleTheme point;

  const ChartTheme({
    this.xPointer = const LineTheme(color: Colors.grey),
    this.yMarker = const LineTheme(color: Colors.black12),
    this.line = const LineTheme(width: 2),
    this.xAxis = const LineTheme(color: Colors.grey),
    this.yAxis = const LineTheme(color: Colors.grey),
    this.point = const CircleTheme(),
    this.yMarkersCount = 5,
  });
}

class LineTheme {
  final double width;
  final Color color;
  const LineTheme({this.width = 1, this.color = Colors.black});
}

class CircleTheme {
  final double radius;
  final Color color;
  const CircleTheme({this.radius = 5, this.color = Colors.black});
}
