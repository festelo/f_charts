import 'dart:ui';

import 'package:f_charts/widget_models/_.dart';
import 'package:f_charts/data_models/_.dart';
import 'package:f_charts/extensions.dart';
import 'package:flutter/material.dart';

import 'layer.dart';

class ChartDrawBaseLayer extends Layer {
  final List<RelativePoint> points;
  final List<RelativeLine> lines;
  final ChartState state;

  final ChartTheme theme;

  ChartDrawBaseLayer({
    List<RelativePoint> points,
    List<RelativeLine> lines,
    @required this.theme,
    @required this.state,
  })  : assert(theme != null),
        points = points ?? [],
        lines = lines ?? [];

  factory ChartDrawBaseLayer.calculate(
    ChartData data,
    ChartTheme theme,
    ChartState state,
    ChartMapper mapper,
  ) {
    final bounds = ChartBoundsDoubled.fromData(data, mapper);
    final layer = ChartDrawBaseLayer(theme: theme, state: state);

    for (final s in data.series) {
      layer._placeSeries(s, bounds, mapper);
    }
    return layer;
  }

  void _placeSeries(
    ChartSeries series,
    ChartBoundsDoubled bounds,
    ChartMapper mapper,
  ) {
    if (series.entities.isEmpty) return;
    RelativeOffset bo;

    for (var i = 1; i < series.entities.length; i++) {
      var a = series.entities[i - 1];
      var b = series.entities[i];
      final ao = a.toRelativeOffset(mapper, bounds);
      bo = b.toRelativeOffset(mapper, bounds);
      placeLine(ao, bo, series.color);
      placePoint(ao, series.color);
    }
    placePoint(bo ?? series.entities[0].toRelativeOffset(mapper, bounds), series.color);
  }

  void placePoint(RelativeOffset o, Color color) {
    if (theme.point == null) return;
    points.add(RelativePoint(
      o,
      color: color ?? theme.point.color,
      radius: theme.point.radius,
    ));
  }

  void placeLine(RelativeOffset a, RelativeOffset b, Color color) {
    if (theme.line == null) return;
    lines.add(RelativeLine(a, b,
        color: color ?? theme.line.color, width: theme.line.width));
  }

  @override
  bool themeChangeAffected(ChartTheme theme) {
    return theme.line != this.theme.line || theme.point != this.theme.point;
  }

  @override
  bool shouldDraw() => !state.isMoving;

  @override
  void draw(Canvas canvas, Size size) {
    for (final l in lines) {
      canvas.drawLine(
        l.a.toOffset(size),
        l.b.toOffset(size),
        Paint()
          ..color = l.color
          ..strokeWidth = l.width,
      );
    }

    for (final p in points) {
      canvas.drawCircle(
        p.offset.toOffset(size),
        theme.point.radius,
        Paint()..color = p.color,
      );
    }
  }
}
