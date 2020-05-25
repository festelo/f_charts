import 'dart:math';
import 'dart:ui';

import 'package:f_charts/chart_models/_.dart';
import 'package:f_charts/data_models/_.dart';
import 'package:f_charts/utils.dart';
import 'package:f_charts/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

import 'layer.dart';

class ChartInteractionLayer extends Layer {
  double xPositionAbs;
  final ChartTheme theme;
  final Map<ChartSeries, List<RelativeLine>> seriesLines;
  final Map<ChartSeries, List<RelativePoint>> seriesPoints;
  final ChartState state;

  final void Function() pointPressed;

  Size cachedSize;

  Map<ChartSeries, List<Pair<Offset>>> cachedSeriesLinesAbs;
  Map<ChartSeries, List<Offset>> cachedSeriesPointsAbs;

  void recalculateCache(Size size) {
    cachedSeriesLinesAbs = seriesLines.map(
      (key, value) => MapEntry(
        key,
        value.map((c) => Pair(c.a.toOffset(size), c.b.toOffset(size))).toList(),
      ),
    );
    cachedSeriesPointsAbs = seriesPoints.map(
      (key, value) => MapEntry(
        key,
        value.map((c) => c.offset.toOffset(size)).toList(),
      ),
    );
    cachedSize = size;
  }

  List<Pair<Offset>> retrieveAbsoluteLines(ChartSeries seriers, Size size) {
    if (size != cachedSize) {
      recalculateCache(size);
    }
    return cachedSeriesLinesAbs[seriers];
  }

  List<Offset> retrieveAbsolutePoints(ChartSeries seriers, Size size) {
    if (size != cachedSize) {
      recalculateCache(size);
    }
    return cachedSeriesPointsAbs[seriers];
  }

  ChartInteractionLayer({
    @required this.theme,
    @required this.state,
    this.pointPressed,
    Map<ChartSeries, List<RelativeLine>> seriesLines,
    Map<ChartSeries, List<RelativePoint>> seriesPoints,
  })  : assert(theme != null),
        seriesLines = seriesLines ?? {},
        seriesPoints = seriesPoints ?? {};

  factory ChartInteractionLayer.calculate(
    ChartData data,
    ChartTheme theme,
    ChartState state, {
    void Function() pointPressed,
  }) {
    final bounds = data.getBounds();
    final layer = ChartInteractionLayer(
        theme: theme, pointPressed: pointPressed, state: state);

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
      placeLine(series, ao, bo);
      placePoint(series, ao);
    }
    placePoint(series, bo ?? series.entities[0].toRelativeOffset(bounds));
  }

  void placeLine(ChartSeries s, RelativeOffset a, RelativeOffset b) {
    if (seriesLines[s] == null) seriesLines[s] = [];
    seriesLines[s].add(RelativeLine(a, b));
  }

  void placePoint(ChartSeries s, RelativeOffset o) {
    if (seriesPoints[s] == null) seriesPoints[s] = [];
    seriesPoints[s].add(RelativePoint(o));
  }

  @override
  bool hitTest(Offset position) {
    if (pointPressed == null ||
        cachedSeriesPointsAbs == null ||
        cachedSeriesPointsAbs.isEmpty ||
        state.isMoving) return super.hitTest(position);

    for (final e in cachedSeriesPointsAbs.entries) {
      for (final o in e.value) {
        final diff = o - position;
        if (diff.dx < 20 && diff.dy < 20 && diff.dx > -20 && diff.dy > -20) {
          pointPressed();
          return true;
        }
      }
    }

    return false;
  }

  @override
  bool themeChangeAffected(ChartTheme theme) {
    return false;
  }

  @override
  bool shouldDraw() => !state.isMoving;

  @override
  void draw(Canvas canvas, Size size) {
    if (xPositionAbs == null) return;
    for (final series in seriesLines.keys) {
      final intersaction =
          getIntersactionWithSeries(series, xPositionAbs / size.width);
      if (intersaction != null) {
        drawIntersactionZeroMarker(canvas, size, series, intersaction);
        drawInterscationHighlight(canvas, size, series, intersaction);
      }
    }
    if (theme.xPointer != null) _drawXPointerLine(canvas, size);
  }

  void _drawXPointerLine(Canvas canvas, Size size) {
    canvas.drawLine(
      Offset(xPositionAbs, 0),
      Offset(xPositionAbs, size.height),
      Paint()
        ..strokeWidth = theme.xPointer.width
        ..color = theme.xPointer.color,
    );
  }

  Paint _gradientPaint(Size gradientSize, Offset offset, Color color,
      [bool reversed = false]) {
    return Paint()
      ..strokeWidth = 3
      ..shader = LinearGradient(
        colors: !reversed
            ? [color, color.withOpacity(0)]
            : [color.withOpacity(0), color],
      ).createShader(offset & gradientSize);
  }

  Tuple<RelativeOffset, RelativeLine> getIntersactionWithSeries(
    ChartSeries series,
    double xPosition,
  ) {
    final lines = seriesLines[series];
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final xHighlightLine = Pair(
        Point(xPosition, 0),
        Point(xPosition, RelativeOffset.max),
      );

      if (line.a.dx < xPosition && line.b.dx > xPosition) {
        final linePair =
            Pair(line.a.toRelativePoint(), line.b.toRelativePoint());
        final cross = intersection(linePair, xHighlightLine);
        if (cross == null) continue;
        return Tuple(
            RelativeOffset(cross.x.toDouble(), cross.y.toDouble()), line);
      }
    }
    return null;
  }

  void drawIntersactionZeroMarker(
    Canvas canvas,
    Size size,
    ChartSeries series,
    Tuple<RelativeOffset, RelativeLine> intersactionInfo,
  ) {
    final cross = intersactionInfo.a.toOffset(size);
    canvas.drawLine(
      Offset(0, cross.dy - 10),
      Offset(0, cross.dy + 10),
      Paint()
        ..strokeWidth = 3
        ..color = series.color,
    );

    final textStyle = TextStyle(
      color: series.color,
      fontSize: 12,
    );
    final textSpan = TextSpan(
      text: cross.toString(),
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
    textPainter.paint(canvas, Offset(5, cross.dy - 6));
  }

  void drawInterscationHighlight(
    Canvas canvas,
    Size size,
    ChartSeries series,
    Tuple<RelativeOffset, RelativeLine> intersactionInfo,
  ) {
    final cross = intersactionInfo.a.toOffset(size).toPoint();
    final relativeLine = intersactionInfo.b;
    final line = Pair(
      relativeLine.a.toOffset(size),
      relativeLine.b.toOffset(size),
    );

    var partPointLeft = partOf(
      Pair(line.a.toPoint(), cross),
      20,
    );
    var partPointRight = partOf(
      Pair(line.b.toPoint(), cross),
      20,
    );
    canvas.drawLine(
      Offset(
        partPointLeft.x.toDouble(),
        partPointLeft.y.toDouble(),
      ),
      Offset(cross.x.toDouble(), cross.y.toDouble()),
      _gradientPaint(
        Size(
          (cross.x - partPointLeft.x).toDouble(),
          (cross.y - partPointLeft.y).toDouble(),
        ),
        Offset(
          partPointLeft.x.toDouble(),
          partPointLeft.y.toDouble(),
        ),
        Colors.grey,
        true,
      ),
    );
    canvas.drawLine(
      Offset(partPointRight.x.toDouble(), partPointRight.y.toDouble()),
      Offset(cross.x.toDouble(), cross.y.toDouble()),
      _gradientPaint(
        Size(
          (partPointRight.x - cross.x).toDouble(),
          (partPointRight.y - cross.y).toDouble(),
        ),
        Offset(cross.x.toDouble(), cross.y.toDouble()),
        Colors.grey,
      ),
    );
    canvas.drawCircle(
      Offset(cross.x.toDouble(), cross.y.toDouble()),
      6,
      Paint()..color = Colors.grey,
    );
    canvas.drawCircle(
      Offset(cross.x.toDouble(), cross.y.toDouble()),
      5,
      Paint()..color = series.color,
    );
  }
}
