import 'package:f_charts/widget_models/theme.dart';
import 'package:flutter/material.dart';

abstract class Layer {
  bool themeChangeAffected(ChartTheme theme);
  void draw(Canvas canvas, Size size);

  bool hitTest(Offset position) {
    return false;
  }

  bool shouldDraw() {
    return true;
  }
}
