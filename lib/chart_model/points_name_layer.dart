import 'dart:ui';

import 'package:f_charts/chart_model/layer.dart';
import 'package:f_charts/extensions.dart';
import 'package:f_charts/model/base.dart';
import 'package:f_charts/model/stuff.dart';
import 'package:flutter/material.dart';

import 'theme.dart';

class PointsNameLayer extends Layer {
  final List<RelativeText> pointTexts;

  final ChartTheme theme;

  PointsNameLayer({
    List<RelativeText> pointTexts,
    List<RelativeLine> lines,
    this.theme,
  })  : assert(theme != null),
        pointTexts = pointTexts ?? [];

  factory PointsNameLayer.calculate(ChartData data, ChartTheme theme) {
    final bounds = data.getBounds();
    final layer = PointsNameLayer(theme: theme);

    for (final s in data.series) {
      layer._placeTexts(s, bounds);
    }
    return layer;
  }

  void _placeTexts(
    ChartSeries series,
    ChartBounds bounds,
  ) {

    for (final e in series.entities) {
      final offset = e.toRelativeOffset(bounds);
      placeText(offset, offset.toString(), Colors.red);
    }
  }

  void placeText(RelativeOffset a, String text, Color color) {
    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: Colors.red,
        fontSize: 13
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    pointTexts.add(RelativeText(a, textPainter));
  }

  @override
  bool themeChangeAffected(ChartTheme theme) {
    return false;
  }

  @override
  void draw(Canvas canvas, Size size) {
    for (final t in pointTexts) {
      t.painter.paint(canvas, t.offset.toOffset(size));
    }
  }
}