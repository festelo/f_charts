import 'dart:math';

import 'dart:ui';

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
  double get x1 => this.a.x;
  double get x2 => this.b.x;
  double get y1 => this.a.y;
  double get y2 => this.b.y;
}

kek() {}