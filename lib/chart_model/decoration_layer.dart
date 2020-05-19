import 'dart:ui';

import 'package:f_charts/chart_model/layer.dart';
import 'package:f_charts/model/base.dart';
import 'package:f_charts/model/stuff.dart';

import 'theme.dart';

class ChartDecorationLayer implements Layer {
  final List<RelativeLine> yAxisMarkers;
  RelativeLine _xAxisLine;
  RelativeLine _yAxisLine;

  final ChartTheme theme;

  ChartDecorationLayer({
    List<RelativeLine> yAxisMarkers,
    this.theme,
  })  : assert(theme != null),
        yAxisMarkers = yAxisMarkers ?? [];

  factory ChartDecorationLayer.calculate(ChartData data, ChartTheme theme) {
    final layer = ChartDecorationLayer(theme: theme);
    layer.placeXAxisLine();
    layer.placeYAxisLine();
    layer.placeYMarkers();
    return layer;
  }

  void placeXAxisLine() {
    if (theme.xAxis == null) {
      _xAxisLine = null;
    } else {
      _xAxisLine = RelativeLine(
        RelativeOffset(0, 1, Size(1, 1)),
        RelativeOffset(1, 1, Size(1, 1)),
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
        RelativeOffset(0, 0, Size(1, 1)),
        RelativeOffset(0, 1, Size(1, 1)),
        color: theme.yAxis.color,
        width: theme.yAxis.width,
      );
    }
  }

  void placeYMarkers() {
    if (theme.yMarker == null || theme.yMarkersCount == 0) {
      yAxisMarkers.clear();
    } else {
      var viewportSize = Size(1, theme.yMarkersCount.toDouble());
      for (var i = 0.0; i < theme.yMarkersCount; i++) {
        yAxisMarkers.add(RelativeLine(
          RelativeOffset(0, i, viewportSize),
          RelativeOffset(1, i, viewportSize),
          color: theme.yMarker.color,
          width: theme.yMarker.width,
        ));
      }
    }
  }

  @override
  bool themeChangeAffected(ChartTheme theme) {
    return theme.yMarker != this.theme.yMarker ||
        theme.yMarkersCount != this.theme.yMarkersCount ||
        theme.xAxis != this.theme.xAxis ||
        theme.yAxis != this.theme.yAxis;
  }

  @override
  void draw(Canvas canvas, Size size) {
    for (final l in yAxisMarkers) {
      canvas.drawLine(
        l.a.toOffset(size),
        l.b.toOffset(size),
        Paint()
          ..color = l.color
          ..strokeWidth = l.width,
      );
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
