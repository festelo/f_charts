import 'dart:ui';

import 'package:f_charts/chart_models/_.dart';
import 'package:f_charts/data_models/_.dart';
import 'package:f_charts/extensions.dart';
import 'package:flutter/material.dart';

import 'layer.dart';

class PointsNameLayer extends Layer {
  final List<RelativeText> pointTexts;

  final ChartTheme theme;
  final ChartState state;

  PointsNameLayer({
    List<RelativeText> pointTexts,
    List<RelativeLine> lines,
    @required this.theme,
    @required this.state,
  })  : assert(theme != null),
        pointTexts = pointTexts ?? [];

  factory PointsNameLayer.calculate(
    ChartData data,
    ChartTheme theme,
    ChartState state,
  ) {
    final bounds = data.getBounds();
    final layer = PointsNameLayer(theme: theme, state: state);

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
      style: TextStyle(color: Colors.red, fontSize: 13),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    pointTexts.add(RelativeText(a, textPainter));
  }

  @override
  bool shouldDraw() => !state.isMoving;

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
