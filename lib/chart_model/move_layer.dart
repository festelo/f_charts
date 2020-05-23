import 'dart:ui';

import 'package:f_charts/chart_animation/animated_series.dart';
import 'package:f_charts/chart_animation/viewport_animation.dart';
import 'package:f_charts/chart_model/layer.dart';
import 'package:f_charts/extensions.dart';
import 'package:f_charts/model/base.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'theme.dart';

typedef AnimatedSeriesBuilder = AnimatedSeries Function(
  ChartBounds boundsFrom,
  ChartBounds boundsTo,
  ChartSeries seriesFrom,
  ChartSeries seriesTo,
);

typedef AnimatedViewportBuilder = Animatable<Size> Function(
  ChartBounds boundsFrom,
  ChartBounds boundsTo,
);

class MoveAnimation {
  final List<AnimatedSeries> series;
  final Animatable<Size> viewportAnimatable;
  final ChartBounds boundsFrom;
  final ChartBounds boundsTo;

  MoveAnimation(
    this.series, {
    @required this.boundsFrom,
    @required this.boundsTo,
    @required this.viewportAnimatable,
  });

  factory MoveAnimation.between(
    ChartData from,
    ChartData to, {
    AnimatedSeriesBuilder animatedSeriesBuilder,
    AnimatedViewportBuilder animatedViewportBuilder,
  }) {
    animatedViewportBuilder ??= AnimatedViewport.tween;
    animatedSeriesBuilder ??=
        (boundsFrom, boundsTo, seriesFrom, seriesTo) => AnimatedSeries.curve(
              boundsFrom: boundsFrom,
              boundsTo: boundsTo,
              seriesFrom: seriesFrom,
              seriesTo: seriesTo,
              curve: Curves.easeInOut
            );

    final boundsFrom = from.getBounds();
    final boundsTo = to.getBounds();
    final mappedFrom =
        Map.fromEntries(from.series.map((c) => MapEntry(c.name, c)));
    final mappedTo = Map.fromEntries(to.series.map((c) => MapEntry(c.name, c)));
    final series = <AnimatedSeries>[];
    for (final key in mappedFrom.keys) {
      series.add(animatedSeriesBuilder(
          boundsFrom, boundsTo, mappedFrom[key], mappedTo[key]));
    }
    final viewportAnimatable = animatedViewportBuilder(boundsFrom, boundsTo);
    return MoveAnimation(
      series,
      boundsFrom: boundsFrom,
      boundsTo: boundsTo,
      viewportAnimatable: viewportAnimatable,
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
      for (var i = 0; i < points.length; i++) {
        points[i].viewportSize = animation.viewportAnimatable.evaluate(parent);
      }
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
