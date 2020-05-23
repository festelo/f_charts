import 'dart:ui';

import 'package:f_charts/chart_animation/move_animation.dart';
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

  factory MoveAnimation.between({
    ChartData from,
    ChartData to,
    AnimatedSeriesBuilder builder,
    Animatable<Size> viewportAnimatable,
  }) {
    final boundsFrom = from.getBounds();
    final boundsTo = to.getBounds();
    final mappedFrom =
        Map.fromEntries(from.series.map((c) => MapEntry(c.name, c)));
    final mappedTo = Map.fromEntries(to.series.map((c) => MapEntry(c.name, c)));
    final series = <AnimatedSeries>[];
    for (final key in mappedFrom.keys) {
      series.add(builder(boundsFrom, boundsTo, mappedFrom[key], mappedTo[key]));
    }
    viewportAnimatable ??= Tween(
      begin: Size(boundsFrom.maxAbscissaStep, boundsFrom.maxOrdinateStep),
      end: Size(boundsTo.maxAbscissaStep, boundsTo.maxOrdinateStep),
    );
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
      final textStyle = TextStyle(
        color: Colors.black,
        fontSize: 16,
      );
      final textSpan = TextSpan(
        text: points[0].viewportSize.toString(),
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(
        minWidth: 0,
        maxWidth: size.width,
      );
      final offset = Offset(50, 100);
      textPainter.paint(canvas, offset);
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
