import 'dart:math';

import 'dart:ui';

import 'package:f_charts/model/base.dart';

import 'model/stuff.dart';

extension OffsetExtenstions on Offset {
  Point toPoint() {
    return Point(this.dx, this.dy);
  }
}

extension OffsetPairExtenstions on Pair<Offset> {
  Pair<Point> toPointPair() {
    return Pair<Point>(this.a.toPoint(), this.b.toPoint());
  }
}
extension PointPairExtenstions on Pair<Point> {
  num get x1 => this.a.x;
  num get x2 => this.b.x;
  num get y1 => this.a.y;
  num get y2 => this.b.y;
}

extension ChartBoundsExtensions<T1, T2> on ChartBounds<T1, T2> {
  double get maxOrdinateStep {
    return this.maxOrdinate.stepValue(this.minOrdinate.value);
  }
  double get maxAbscissaStep {
    return this.maxAbscissa.stepValue(this.minAbscissa.value);
  }
}

extension ChartSeriesExtensions<T1, T2> on ChartEntity<Measure<T1>, Measure<T2>> {
  RelativeOffset toRelativeOffset(ChartBounds<T1, T2> bounds) {
    return RelativeOffset(
      this.abscissa.stepValue(bounds.minAbscissa.value),
      this.ordinate.stepValue(bounds.minOrdinate.value), 
      viewportSize: Size(bounds.maxAbscissaStep, bounds.maxOrdinateStep)
    ).reverseY();
  }
}

kek() {}