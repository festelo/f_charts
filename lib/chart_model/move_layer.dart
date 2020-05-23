import 'dart:ui';

import 'package:f_charts/chart_animation/move_animation.dart';
import 'package:f_charts/chart_model/layer.dart';
import 'package:f_charts/model/base.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'theme.dart';

typedef AnimatedSeriesBuilder = AnimatedSeries Function(
  ChartBounds bounds,
  ChartSeries from,
  ChartSeries to,
);

class MoveAnimation {
  final List<AnimatedSeries> series;

  MoveAnimation(this.series);

  factory MoveAnimation.between({
    ChartData from,
    ChartData to,
    AnimatedSeriesBuilder builder,
  }) {
    final bounds = from.getBounds();
    final mappedFrom =
        Map.fromEntries(from.series.map((c) => MapEntry(c.name, c)));
    final mappedTo = Map.fromEntries(to.series.map((c) => MapEntry(c.name, c)));
    final series = <AnimatedSeries>[];
    for (final key in mappedFrom.keys) {
      series.add(builder(bounds, mappedFrom[key], mappedTo[key]));
    }
    return MoveAnimation(series);
  }
}

class ChartMoveLayer extends Layer {
  final Animation<double> parent;
  final MoveAnimation animation;

  final ChartTheme theme;
  ChartMoveLayer({this.animation, this.theme, this.parent})
      : assert(theme != null);

  @override
  bool themeChangeAffected(ChartTheme theme) {
    return false;
  }

  @override
  void draw(Canvas canvas, Size size) {
    for (final s in animation.series) {
      final points = s.points(parent);
      if (points.isEmpty) continue;
      Offset b;
      for (var i = 1; i < points.length; i++) {
        var a = points[i - 1].toOffset(size);
        b = points[i].toOffset(size);
        drawPoint(canvas, a, s.from.color);
        drawPoint(canvas, b, s.from.color);
        drawLine(canvas, a, b, s.from.color);
      }
      drawPoint(canvas, b ?? points[0].toOffset(size), s.from.color);
    }
  }

  void drawPoint(Canvas canvas, Offset offset, Color color) {
    canvas.drawCircle(
      offset,
      theme.point.radius,
      Paint()..color = color,
    );
  }

  void drawLine(Canvas canvas, Offset a, Offset b, Color color) {
    canvas.drawLine(
      a,
      b,
      Paint()
        ..color = color
        ..strokeWidth = theme.line.width,
    );
  }
}
