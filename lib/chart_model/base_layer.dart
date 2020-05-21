import 'dart:ui';

import 'package:f_charts/chart_model/layer.dart';
import 'package:f_charts/extensions.dart';
import 'package:f_charts/model/base.dart';
import 'package:f_charts/model/stuff.dart';

import 'theme.dart';

class ChartDrawBaseLayer extends Layer {
  final List<RelativePoint> points;
  final List<RelativeLine> lines;

  final ChartTheme theme;

  ChartDrawBaseLayer({
    List<RelativePoint> points,
    List<RelativeLine> lines,
    this.theme,
  })  : assert(theme != null),
        points = points ?? [],
        lines = lines ?? [];

  factory ChartDrawBaseLayer.calculate(ChartData data, ChartTheme theme) {
    final bounds = data.getBounds();
    final layer = ChartDrawBaseLayer(theme: theme);

    for (final s in data.series) {
      layer._placeSeries(s, bounds);
    }
    return layer;
  }

  void _placeSeries(
    ChartSeries series,
    ChartBounds bounds,
  ) {

    if (series.entities.isEmpty) return;
    RelativeOffset bo;

    for (var i = 1; i < series.entities.length; i++) {
      var a = series.entities[i - 1];
      var b = series.entities[i];
      final ao = a.toRelativeOffset(bounds);
      bo = b.toRelativeOffset(bounds);
      placeLine(ao, bo, series.color);
      placePoint(ao, series.color);
    }
    placePoint(bo ?? series.entities[0].toRelativeOffset(bounds), series.color);
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
