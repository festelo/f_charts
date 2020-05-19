import 'dart:ui';

import 'package:f_charts/chart_model/layer.dart';
import 'package:f_charts/model/base.dart';
import 'package:f_charts/model/stuff.dart';

import 'theme.dart';

class ChartDrawBaseLayer implements Layer {
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
    final maxYEntity = data.maxOrdinate();
    final minYEntity = data.minOrdinate();
    final maxXEntity = data.maxAbscissa();
    final minXEntity = data.minAbscissa();

    final maxY = maxYEntity.ordinate.stepValue(minYEntity.ordinate.value);
    final maxX = maxXEntity.abscissa.stepValue(minXEntity.abscissa.value);

    final layer = ChartDrawBaseLayer(theme: theme);
    final viewportSize = Size(maxX, maxY);

    final abscissaLimits =
        Pair(minXEntity.abscissa.value, maxXEntity.abscissa.value);
    final ordinataLimits =
        Pair(minYEntity.ordinate.value, maxYEntity.ordinate.value);

    for (final s in data.series) {
      layer._placeSeries(
        abscissaLimits: abscissaLimits,
        ordinataLimits: ordinataLimits,
        series: s,
        viewportSize: viewportSize,
      );
    }
    return layer;
  }

  void _placeSeries({
    ChartSeries series,
    Pair<dynamic> abscissaLimits,
    Pair<dynamic> ordinataLimits,
    Size viewportSize,
  }) {
    RelativeOffset entityToOffset(ChartEntity e) {
      var ex = e.abscissa.stepValue(abscissaLimits.a);
      var ey = e.ordinate.stepValue(ordinataLimits.a);
      return RelativeOffset(ex, ey, viewportSize).reverseY();
    }

    if (series.entities.isEmpty) return;
    RelativeOffset bo;

    for (var i = 1; i < series.entities.length; i++) {
      var a = series.entities[i - 1];
      var b = series.entities[i];
      final ao = entityToOffset(a);
      bo = entityToOffset(b);
      placeLine(ao, bo, series.color);
      placePoint(ao, series.color);
    }
    placePoint(bo ?? entityToOffset(series.entities[0]), series.color);
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
