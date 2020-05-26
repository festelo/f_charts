import 'dart:math';
import 'dart:ui';

import 'package:f_charts/chart_models/_.dart';
import 'package:f_charts/data_models/_.dart';
import 'package:f_charts/utils.dart';
import 'package:f_charts/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

import 'layer.dart';

typedef PointPressedCallback<T1, T2> = Function(ChartEntity<T1, T2> entity);

class IntersactionInfo<TE extends ChartEntity> {
  final Pair<Offset> line;
  final Offset offset;
  final Pair<TE> entities;
  final TE nearestEntity;
  final double deltaToNearest;
  IntersactionInfo({
    @required this.line,
    @required this.offset,
    @required this.entities,
    @required this.nearestEntity,
    @required this.deltaToNearest,
  });
}

class ChartInteractionLayer<T1, T2, TE extends ChartEntity<T1, T2>>
    extends Layer {
  double xPositionAbs;
  final ChartTheme theme;
  final Map<ChartSeries<T1, T2, TE>, List<RelativeLine>> seriesLines;
  final Map<TE, RelativePoint> entityPoints;
  final ChartState state;

  final void Function(TE e) pointPressed;

  Size cachedSize;

  Map<TE, Offset> cachedEntityPointsAbs;

  void recalculateCache(Size size) {
    if (size == cachedSize) return;
    cachedEntityPointsAbs = entityPoints.map(
      (key, value) => MapEntry(
        key,
        value.offset.toOffset(size),
      ),
    );
    cachedSize = size;
  }

  Pair<Offset> retrieveAbsoluteLine(ChartEntity a, ChartEntity b) {
    return Pair(cachedEntityPointsAbs[a], cachedEntityPointsAbs[b]);
  }

  Offset retrieveAbsolutePoint(ChartEntity entity) {
    return cachedEntityPointsAbs[entity];
  }

  ChartInteractionLayer({
    @required this.theme,
    @required this.state,
    this.pointPressed,
    Map<ChartSeries<T1, T2, TE>, List<RelativeLine>> seriesLines,
    Map<TE, RelativePoint> entityPoints,
  })  : assert(theme != null),
        seriesLines = seriesLines ?? {},
        entityPoints = entityPoints ?? {};

  factory ChartInteractionLayer.calculate(
    ChartData<T1, T2, TE> data,
    ChartTheme theme,
    ChartState state, {
    PointPressedCallback pointPressed,
  }) {
    final bounds = data.getBounds();
    final layer = ChartInteractionLayer<T1, T2, TE>(
        theme: theme, pointPressed: pointPressed, state: state);

    for (final s in data.series) {
      layer._placeSeries(s, bounds);
    }
    return layer;
  }

  void _placeSeries(
    ChartSeries<T1, T2, TE> series,
    ChartBounds<T1, T2> bounds,
  ) {
    if (series.entities.isEmpty) return;
    RelativeOffset bo;
    TE b;

    for (var i = 1; i < series.entities.length; i++) {
      var a = series.entities[i - 1];
      b = series.entities[i];
      final ao = a.toRelativeOffset(bounds);
      bo = b.toRelativeOffset(bounds);
      placeLine(series, ao, bo);
      placePoint(a, ao);
    }
    if (b == null) b = series.entities[0];
    if (bo == null) bo = b.toRelativeOffset(bounds);
    placePoint(b, bo);
  }

  void placeLine(ChartSeries<T1, T2, TE> s, RelativeOffset a, RelativeOffset b) {
    if (seriesLines[s] == null) seriesLines[s] = [];
    seriesLines[s].add(RelativeLine(a, b));
  }

  void placePoint(TE e, RelativeOffset o) {
    entityPoints[e] = RelativePoint(o);
  }

  @override
  bool hitTest(Offset position) {
    if (pointPressed == null ||
        cachedEntityPointsAbs == null ||
        cachedEntityPointsAbs.isEmpty ||
        state.isMoving) return super.hitTest(position);

    for (final e in cachedEntityPointsAbs.entries) {
      final diff = e.value - position;
      if (diff.dx < 20 && diff.dy < 20 && diff.dx > -20 && diff.dy > -20) {
        pointPressed(e.key);
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
  bool shouldDraw() => !state.isMoving;

  @override
  void draw(Canvas canvas, Size size) {
    if (xPositionAbs == null) return;
    recalculateCache(size);
    for (final series in seriesLines.keys) {
      final intersaction = getIntersactionWithSeries(
        series,
        size,
        xPositionAbs,
      );
      if (intersaction != null) {
        drawInterscationHighlight(canvas, size, series, intersaction);
        drawIntersactionZeroMarker(canvas, size, series, intersaction);
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
      {bool reversed = false, bool bidirectional = false}) {
    List<Color> colors;
    if (bidirectional) {
      colors = [
        color.withOpacity(0), 
        color,
        color.withOpacity(0), 
      ];
    } else {
      colors = [
        color.withOpacity(0), 
        color,
      ];
      if (!reversed) colors = colors.reversed.toList();
    }
    return Paint()
      ..strokeWidth = 3
      ..shader = LinearGradient(
        colors: colors,
      ).createShader(offset & gradientSize);
  }

  IntersactionInfo getIntersactionWithSeries(
    ChartSeries<T1, T2, TE> series,
    Size size,
    double xPosition,
  ) {
    for (var i = 1; i < series.entities.length; i++) {
      final a = series.entities[i-1];
      final b = series.entities[i];
      final line = retrieveAbsoluteLine(a, b);
      final xHighlightLine = Pair(
        Point(xPosition, 0),
        Point(xPosition, RelativeOffset.max),
      );

      if (line.a.dx < xPosition && line.b.dx > xPosition) {
        final linePair = Pair(line.a, line.b);
        final cross = intersection(linePair.toPointPair(), xHighlightLine);
        if (cross == null) continue;
        var deltaA = (xPosition - line.a.dx).abs();
        var deltaB = (xPosition - line.b.dx).abs();
        var nearestDelta = min(deltaA, deltaB);
        return IntersactionInfo<TE>(
          line: line, 
          offset: Offset(cross.x.toDouble(), cross.y.toDouble()), 
          entities: Pair(series.entities[i-1], series.entities[i]), 
          nearestEntity: nearestDelta == deltaA ? a : b,
          deltaToNearest: nearestDelta
        );
      }
    }
    
    var first = series.entities[0];
    var firstPoint = retrieveAbsolutePoint(first);
    var deltaFirst = (xPosition - firstPoint.dx).abs();
    if (deltaFirst < 10) {
      return IntersactionInfo<TE>(
        line: retrieveAbsoluteLine(first, series.entities[1]),
        offset: firstPoint,
        entities: Pair(first, series.entities[1]),
        deltaToNearest: deltaFirst,
        nearestEntity: first
      );
    }

    var last = series.entities[series.entities.length-1];
    var lastPoint = retrieveAbsolutePoint(last);
    var deltaLast = (xPosition - lastPoint.dx).abs();
    if (deltaLast < 10) {
      return IntersactionInfo<TE>(
        line: retrieveAbsoluteLine(series.entities[series.entities.length-2], last),
        offset: lastPoint,
        entities: Pair(series.entities[series.entities.length-2], last),
        deltaToNearest: deltaLast,
        nearestEntity: last
      );
    }
    return null;
  }

  void _drawZeroMarker(Canvas canvas, Size size, Offset cross, Color color, String text, {bool inactive = false}) {
    var linePaint = _gradientPaint(Size(1, 20), Offset(0, 0), color, bidirectional: true);
    canvas.drawLine(
      Offset(0, cross.dy - 10),
      Offset(0, cross.dy + 10),
      linePaint,
    );
    final textStyle = TextStyle(
      color: color,
      fontSize: 16,
      fontWeight: FontWeight.bold
    );
    final textSpan = TextSpan(
      text: text,
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
    textPainter.paint(canvas, Offset(-5 - textPainter.width, cross.dy - 12));
  }

  void _drawPointHighlight(Canvas canvas, Offset cross, Color color) {
    canvas.drawCircle(
      cross,
      6,
      Paint()..color = Colors.grey,
    );
    canvas.drawCircle(
      cross,
      5,
      Paint()..color = color,
    );
  }

  void drawIntersactionZeroMarker(
    Canvas canvas,
    Size size,
    ChartSeries series,
    IntersactionInfo intersactionInfo,
  ) {
    final cross = intersactionInfo.offset;
    final entity = intersactionInfo.nearestEntity;
    final entityPoint = retrieveAbsolutePoint(entity);
    if (intersactionInfo.deltaToNearest < 10) {
      _drawZeroMarker(canvas, size, entityPoint, series.color, entity.ordinate.toString());
      _drawPointHighlight(canvas, entityPoint, series.color);
    } else {
      _drawZeroMarker(canvas, size, cross, Color.alphaBlend(series.color.withOpacity(0.4), Colors.grey), '?');
    }
  }

  void drawInterscationHighlight(
    Canvas canvas,
    Size size,
    ChartSeries series,
    IntersactionInfo intersactionInfo,
  ) {
    final offset = intersactionInfo.offset;
    final cross = intersactionInfo.offset.toPoint();
    final line = intersactionInfo.line;

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
        reversed: true,
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
  }
}
