import 'dart:math';
import 'dart:ui';

import 'package:f_charts/chart_model/layer.dart';
import 'package:f_charts/extensions.dart';
import 'package:f_charts/model/base.dart';
import 'package:f_charts/model/stuff.dart';
import 'package:f_charts/utils.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'base_layer.dart';
import 'theme.dart';

class AnimatedSeries {
  final List<Tween<RelativeOffset>> intersactionTweens;
  final ChartSeries from;
  final ChartSeries to;

  AnimatedSeries({this.intersactionTweens, this.from, this.to});
  
  factory AnimatedSeries.between(ChartBounds bounds, ChartSeries from, ChartSeries to) {
    final fromOffsets = from.entities.map((e) => e.toRelativeOffset(bounds)).toList();
    final toOffsets = to?.entities?.map((e) => e.toRelativeOffset(bounds))?.toList() ?? [];
    List<Tween<RelativeOffset>> values = [
      ..._intersectBetween(fromOffsets, toOffsets),
      ..._intersectBetween(toOffsets, fromOffsets, reverse: true)
    ];
    return AnimatedSeries(from: from, to: to, intersactionTweens: values);
  }
  
  static List<Tween<RelativeOffset>> _intersectBetween(List<RelativeOffset> a, List<RelativeOffset> b, {bool reverse = false}) {
    List<Tween<RelativeOffset>> values = [];
    for(var i = 1; i < a.length; i++) {
      var line = Pair(a[i-1], a[i]);
      for (final p in b) {
        final xPosition = p.dx;
        if (!(line.a.dx <= xPosition && line.b.dx >= xPosition)) continue;
        final xLine = Pair(
          Point(xPosition, 0),
          Point(xPosition, p.viewportSize.height),
        );
        final targetLine = Pair(
          Point(line.a.dx, line.a.dy),
          Point(line.b.dx, line.b.dy)
        );
        final cross = intersection(
          targetLine, 
          xLine
        );
        if (reverse) {
          values.add(
            Tween<RelativeOffset>(
              begin: p,
              end: RelativeOffset(cross.x.toDouble(), cross.y.toDouble(), p.viewportSize)
            )
          );
        }
        else {
          values.add(
            Tween<RelativeOffset>(
              begin: RelativeOffset(cross.x.toDouble(), cross.y.toDouble(), p.viewportSize),
              end: p
            )
          );
        }
      }
    }
    return values;
  }
  
  List<RelativeOffset> points(Animation<double> animation) {
    return intersactionTweens.map((e) => e.evaluate(animation)).toList();
  }
}

class MoveAnimation {
  final List<AnimatedSeries> series;

  MoveAnimation(this.series);
  factory MoveAnimation.between(ChartData from, ChartData to) {
    final bounds = from.getBounds();
    final mappedFrom = Map.fromEntries(from.series.map((c) => MapEntry(c.name, c)));
    final mappedTo = Map.fromEntries(to.series.map((c) => MapEntry(c.name, c)));
    final series = <AnimatedSeries>[];
    for(final key in mappedFrom.keys) {
      series.add(AnimatedSeries.between(bounds, mappedFrom[key], mappedTo[key]));
    }
    return MoveAnimation(series);
  }
}

class ChartMoveLayer extends Layer {
  final Animation<double> parent;
  final MoveAnimation animation;

  final ChartTheme theme;
  ChartMoveLayer({
    this.animation,
    this.theme,
    this.parent
  })  : assert(theme != null);

  @override
  bool themeChangeAffected(ChartTheme theme) {
    return false;
  }

  @override
  void draw(Canvas canvas, Size size) {
    for(final s in animation.series) {
      final points = s.points(parent);
      if (points.isEmpty) continue;
      Offset b;
      for (var i = 1; i < points.length; i++) {
        var a = points[i-1].toOffset(size);
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
      Paint()..color =color,
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
