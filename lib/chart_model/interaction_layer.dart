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

class ChartInteractionLayer extends Layer {
  double xPosition;
  final ChartTheme theme;
  final List<RelativeLine> lines;
  final List<RelativePoint> points;

  final void Function() pointPressed;

  Size cachedSize;
  List<Pair<Offset>> cachedAbsoluteLines;
  List<Offset> cachedAbsolutePoints;

  void recalculateCache(Size size) {
    cachedAbsoluteLines = lines.map((c) => Pair(c.a.toOffset(size), c.b.toOffset(size))).toList();
    cachedAbsolutePoints = points.map((c) => c.offset.toOffset(size)).toList();
    cachedSize = size;
  }

  List<Pair<Offset>> retrieveAbsoluteLines(Size size) {
    if (size != cachedSize) {
      recalculateCache(size);
    }
    return cachedAbsoluteLines;
  }

  List<Pair<Offset>> retrieveAbsolutePoints(Size size) {
    if (size != cachedSize) {
      recalculateCache(size);
    }
    return cachedAbsoluteLines;
  }

  ChartInteractionLayer({
    this.theme,
    this.pointPressed,
    List<RelativeLine> lines,
    List<RelativePoint> points
  }) : assert(theme != null),
    lines = lines ?? [],
    points = points ?? [];

  factory ChartInteractionLayer.calculate(ChartData data, ChartTheme theme, {
    void Function() pointPressed
  }) {
    final bounds = data.getBounds();
    final layer = ChartInteractionLayer(theme: theme, pointPressed: pointPressed);

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
      placeLine(ao, bo);
      placePoint(ao);
    }
    placePoint(bo ?? series.entities[0].toRelativeOffset(bounds));
  }

  void placeLine(RelativeOffset a, RelativeOffset b) {
    lines.add(RelativeLine(a, b));
  }

  void placePoint(RelativeOffset o) {
    points.add(RelativePoint(o, radius: theme.point.radius));
  }

  @override
  bool hitTest(Offset position) {
    if (pointPressed == null || cachedAbsolutePoints == null || cachedAbsolutePoints.isEmpty) 
      return super.hitTest(position);

    for (final o in cachedAbsolutePoints) {
      final diff = o - position;
      if (diff.dx < 20 && diff.dy < 20 && diff.dx > -20 && diff.dy > -20) {
        pointPressed();
        return true;
      }
    }

    return false;
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

  void _drawXHightlight(Canvas canvas, Size size) {
    final absoluteLines = retrieveAbsoluteLines(size);
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
          Offset(partPointLeft.x.toDouble(), partPointLeft.y.toDouble()),
          Offset(cross.x.toDouble(), cross.y.toDouble()),
          _gradientPaint(
            Size(
              (cross.x - partPointLeft.x).toDouble(), 
              (cross.y - partPointLeft.y).toDouble()
            ), 
            Offset(partPointLeft.x.toDouble(), partPointLeft.y.toDouble()), 
            true
          ),
        );
        canvas.drawLine(
          Offset(partPointRight.x.toDouble(), partPointRight.y.toDouble()),
          Offset(cross.x.toDouble(), cross.y.toDouble()),
          _gradientPaint(
            Size(
              (partPointRight.x - cross.x).toDouble(), 
              (partPointRight.y - cross.y).toDouble()
            ), 
            Offset(cross.x.toDouble(), cross.y.toDouble())
          ),
        );
        canvas.drawCircle(
          Offset(cross.x.toDouble(), cross.y.toDouble()),
          5,
          Paint()..color = Colors.cyanAccent,
        );
      }
    }
  }
}
