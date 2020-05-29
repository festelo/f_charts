import 'dart:ui';

import 'package:f_charts/chart.dart';
import 'package:f_charts/widget_models/_.dart';
import 'package:f_charts/data_models/_.dart';
import 'package:flutter/cupertino.dart';

import 'layer.dart';

class ChartDecorationLayer extends Layer {
  final List<RelativeLine> axisMarkers;
  final List<CombinedText> axisTextMarkers;
  RelativeLine _xAxisLine;
  RelativeLine _yAxisLine;

  final ChartTheme theme;

  ChartDecorationLayer({
    List<RelativeLine> axisMarkers,
    List<CombinedText> axisTextMarkers,
    @required this.theme,
  })  : assert(theme != null),
        axisMarkers = axisMarkers ?? [],
        axisTextMarkers = axisTextMarkers ?? [];

  factory ChartDecorationLayer.calculate({
    @required ChartData data,
    @required ChartTheme theme,
    @required ChartMarkersPointer markersPointer,
    @required ChartMapper mapper,
  }) {
    final layer = ChartDecorationLayer(theme: theme);
    layer.placeXAxisLine();
    layer.placeYAxisLine();
    final bounds = mapper.getBounds(data);
    layer.placeYMarkers(bounds, mapper, markersPointer);
    layer.placeXMarkers(bounds, mapper, markersPointer);
    return layer;
  }

  void placeXAxisLine() {
    if (theme.xAxis == null) {
      _xAxisLine = null;
    } else {
      _xAxisLine = RelativeLine(
        RelativeOffset(0, 1),
        RelativeOffset(1, 1),
        color: theme.xAxis.color,
        width: theme.xAxis.width,
      );
    }
  }

  void placeYAxisLine() {
    if (theme.yAxis == null) {
      _yAxisLine = null;
    } else {
      _yAxisLine = RelativeLine(
        RelativeOffset(0, 0),
        RelativeOffset(0, 1),
        color: theme.yAxis.color,
        width: theme.yAxis.width,
      );
    }
  }

  void placeYMarkers(
    ChartBounds bounds,
    ChartMapper mapper,
    ChartMarkersPointer markersPointer,
  ) {
    if (theme.yMarkers == null) {
      return;
    }
    final points = markersPointer.ordinate
        .getPoints(bounds.minOrdinate, bounds.maxOrdinate);
    final min = mapper.ordinateMapper.toDouble(bounds.minOrdinate);
    final max = mapper.ordinateMapper.toDouble(bounds.maxOrdinate);
    for (final p in points) {
      final i = 1 - (mapper.ordinateMapper.toDouble(p) - min) / max;
      if (theme.yMarkers.line != null)
        axisMarkers.add(RelativeLine(
          RelativeOffset(0, i),
          RelativeOffset(1, i),
          color: theme.yMarkers.line.color,
          width: theme.yMarkers.line.width,
        ));
      if (theme.yMarkers.text != null) {
        var painter = TextPainter(
          textDirection: TextDirection.ltr,
          text: TextSpan(
            style: theme.yMarkers.text,
            text: mapper.ordinateMapper.getString(p),
          ),
        )..layout();
        axisTextMarkers.add(
          CombinedText(
            CombinedOffset()
              ..absoluteX = -painter.width - 5
              ..relativeY = i
              ..absoluteY = -painter.height / 2,
            painter,
          ),
        );
      }
    }
  }

  void placeXMarkers(
    ChartBounds bounds,
    ChartMapper mapper,
    ChartMarkersPointer markersPointer,
  ) {
    if (theme.xMarkers == null) {
      return;
    }
    final points = markersPointer.abscissa
        .getPoints(bounds.minAbscissa, bounds.maxAbscissa);
    final min = mapper.abscissaMapper.toDouble(bounds.minAbscissa);
    final max = mapper.abscissaMapper.toDouble(bounds.maxAbscissa);
    for (final p in points) {
      final i = (mapper.abscissaMapper.toDouble(p) - min) / max;
      if (theme.xMarkers.line != null)
        axisMarkers.add(RelativeLine(
          RelativeOffset(i, 0),
          RelativeOffset(i, 1),
          color: theme.xMarkers.line.color,
          width: theme.xMarkers.line.width,
        ));
      if (theme.xMarkers.text != null) {
        var painter = TextPainter(
          textDirection: TextDirection.ltr,
          text: TextSpan(
            style: theme.xMarkers.text,
            text: mapper.abscissaMapper.getString(p),
          ),
        )..layout();
        axisTextMarkers.add(
          CombinedText(
            CombinedOffset()
              ..relativeY = 1
              ..relativeX = i
              ..absoluteX = -painter.width / 2,
            painter,
          ),
        );
      }
    }
  }

  @override
  bool themeChangeAffected(ChartTheme theme) {
    return theme.xMarkers != this.theme.xMarkers ||
        theme.yMarkers != this.theme.yMarkers ||
        theme.xAxis != this.theme.xAxis ||
        theme.yAxis != this.theme.yAxis;
  }

  @override
  void draw(Canvas canvas, Size size) {
    for (final l in axisMarkers) {
      canvas.drawLine(
        l.a.toOffset(size),
        l.b.toOffset(size),
        Paint()
          ..color = l.color
          ..strokeWidth = l.width,
      );
    }

    for (final t in axisTextMarkers) {
      t.painter.paint(canvas, t.offset.toAbsolute(size));
    }

    if (_xAxisLine != null) {
      canvas.drawLine(
        _xAxisLine.a.toOffset(size),
        _xAxisLine.b.toOffset(size),
        Paint()
          ..strokeWidth = _xAxisLine.width
          ..color = _xAxisLine.color,
      );
    }

    if (_yAxisLine != null) {
      canvas.drawLine(
        _yAxisLine.a.toOffset(size),
        _yAxisLine.b.toOffset(size),
        Paint()
          ..strokeWidth = _yAxisLine.width
          ..color = _yAxisLine.color,
      );
    }
  }
}
