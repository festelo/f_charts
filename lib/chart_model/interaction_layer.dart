import 'dart:math';
import 'dart:ui';

import 'package:f_charts/chart_model/layer.dart';
import 'package:f_charts/model/base.dart';
import 'package:f_charts/model/stuff.dart';
import 'package:f_charts/utils.dart';
import 'package:f_charts/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

import 'theme.dart';

class ChartInteractionLayer implements Layer {
  double xPosition;
  final ChartTheme theme;
  final List<RelativeLine> lines;

  ChartInteractionLayer({
    this.theme,
    List<RelativeLine> lines,
  }) : assert(theme != null),
    lines = lines ?? [];

  factory ChartInteractionLayer.calculate(ChartData data, ChartTheme theme) {
    final maxYEntity = data.maxOrdinate();
    final minYEntity = data.minOrdinate();
    final maxXEntity = data.maxAbscissa();
    final minXEntity = data.minAbscissa();

    final maxY = maxYEntity.ordinate.stepValue(minYEntity.ordinate.value);
    final maxX = maxXEntity.abscissa.stepValue(minXEntity.abscissa.value);

    final layer = ChartInteractionLayer(theme: theme);
    final viewportSize = Size(maxX, maxY);

    final abscissaLimits =
        Pair(minXEntity.abscissa.value, maxXEntity.abscissa.value);
    final ordinataLimits =
        Pair(minYEntity.ordinate.value, maxYEntity.ordinate.value);

    for (final s in data.series) {
      layer._placeLines(
        abscissaLimits: abscissaLimits,
        ordinataLimits: ordinataLimits,
        series: s,
        viewportSize: viewportSize,
      );
    }
    return layer;
  }

  void _placeLines({
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

    for (var i = 1; i < series.entities.length; i++) {
      var a = series.entities[i - 1];
      var b = series.entities[i];
      placeLine(entityToOffset(a), entityToOffset(b));
    }
  }

  void placeLine(RelativeOffset a, RelativeOffset b) {
    if (theme.line == null) return;
    lines.add(
        RelativeLine(a, b, color: theme.line.color, width: theme.line.width));
  }

  @override
  bool themeChangeAffected(ChartTheme theme) {
    return false;
  }

  @override
  void draw(Canvas canvas, Size size) {
    if(xPosition == null) return;
    _drawXHightlight(canvas, size);
    if (theme.xPointer != null)
      _drawXPointerLine(canvas, size);
  }
  
  void _drawXPointerLine(Canvas canvas, Size size) {
    canvas.drawLine(
      Offset(xPosition, 0),
      Offset(xPosition, size.height),
      Paint()
        ..strokeWidth = theme.xPointer.width
        ..color = theme.xPointer.color,
    );
  }

  Paint _gradientPaint(Size gradientSize, Offset offset, [bool reversed = false]) {
    return Paint()
      ..strokeWidth = 3
      ..shader = LinearGradient(
        colors: !reversed ? [
          Colors.cyan, 
          Colors.transparent
        ] : [
          Colors.transparent,
          Colors.cyan, 
        ],
      ).createShader(offset & gradientSize);
  }

  Size oldSize;
  List<Pair<Offset>> cachedAbsoluteLines;
  void _drawXHightlight(Canvas canvas, Size size) {
    final absoluteLines = cachedAbsoluteLines = size == oldSize 
      ? cachedAbsoluteLines
      : lines.map((c) => Pair(c.a.toOffset(size), c.b.toOffset(size))).toList();
    oldSize = size;
    for (var i = 0; i < lines.length; i++) {
      final line = absoluteLines[i];
      final xHighlightLine = Pair(
        Point(xPosition, 0),
        Point(xPosition, size.height),
      );
      if (line.a.dx < xPosition && line.b.dx > xPosition) {
        final cross = intersection(line.toPointPair(), xHighlightLine);
        if (cross == null) return;
        var partPointLeft = partOf(
          Pair(line.a.toPoint(), cross),
          20,
        );
        var partPointRight = partOf(
          Pair(line.b.toPoint(), cross),
          20,
        );
        canvas.drawLine(
          Offset(partPointLeft.x, partPointLeft.y),
          Offset(cross.x, cross.y),
          _gradientPaint(Size(cross.x - partPointLeft.x, cross.y - partPointLeft.y), Offset(partPointLeft.x, partPointLeft.y), true),
        );
        canvas.drawLine(
          Offset(partPointRight.x, partPointRight.y),
          Offset(cross.x, cross.y),
          _gradientPaint(Size(partPointRight.x - cross.x, partPointRight.y - cross.y), Offset(cross.x, cross.y)),
        );
        canvas.drawCircle(
          Offset(cross.x, cross.y),
          5,
          Paint()..color = Colors.cyanAccent,
        );
      }
    }
  }
}
