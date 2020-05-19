import 'package:f_charts/chart_model/theme.dart';
import 'package:flutter/material.dart';

abstract class Layer {
  bool themeChangeAffected(ChartTheme theme);
  void draw(Canvas canvas, Size size);
}