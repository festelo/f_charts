import 'dart:ui';

import 'package:f_charts/chart_animations/animated_series.dart';
import 'package:f_charts/widget_models/_.dart';
import 'package:f_charts/data_models/_.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'layer.dart';

typedef AnimatedSeriesBuilder = AnimatedSeries Function(
  ChartBoundsDoubled boundsFrom,
  ChartBoundsDoubled boundsTo,
  ChartSeries seriesFrom,
  ChartSeries seriesTo,
);

class MoveAnimation {
  final List<AnimatedSeries> series;
  final ChartBounds boundsFrom;
  final ChartBounds boundsTo;

  MoveAnimation(
    this.series, {
    @required this.boundsFrom,
    @required this.boundsTo,
  });

  factory MoveAnimation.between(
    ChartData from,
    ChartData to,
    ChartMapper mapper, {
    AnimatedSeriesBuilder animatedSeriesBuilder,
  }) {
    animatedSeriesBuilder ??=
        (boundsFrom, boundsTo, seriesFrom, seriesTo) => AnimatedSeries.curve(
              boundsFrom: boundsFrom,
              boundsTo: boundsTo,
              seriesFrom: seriesFrom,
              seriesTo: seriesTo,
              mapper: mapper,
            );

    final boundsFrom = ChartBoundsDoubled.fromData(from, mapper);
    final boundsTo = ChartBoundsDoubled.fromData(to, mapper);
    final mappedFrom =
        Map.fromEntries(from.series.map((c) => MapEntry(c.name, c)));
    final mappedTo = Map.fromEntries(to.series.map((c) => MapEntry(c.name, c)));
    final series = <AnimatedSeries>[];
    for (final key in mappedFrom.keys) {
      series.add(animatedSeriesBuilder(
          boundsFrom, boundsTo, mappedFrom[key], mappedTo[key]));
    }
    ;
    return MoveAnimation(
      series,
      boundsFrom: boundsFrom,
      boundsTo: boundsTo,
    );
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
        drawLine(canvas, a, b, s.from.color);
      }
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
