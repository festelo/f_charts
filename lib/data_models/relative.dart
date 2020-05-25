import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:quiver_hashcode/hashcode.dart';

class RelativeOffset {
  double dx;
  double dy;

  static const max = 1;
  static const min = 0;

  RelativeOffset(this.dx, this.dy);

  RelativeOffset.fromOffset(Offset relativeOffset, Size viewportSize)
      : dx = relativeOffset.dx / viewportSize.width,
        dy = relativeOffset.dy / viewportSize.height;

  factory RelativeOffset.withViewport(double dx, double dy, Size viewportSize) {
    return RelativeOffset(dx / viewportSize.width, dy / viewportSize.height);
  }

  RelativeOffset reverseY() => copy()..dy = 1 - dy;

  RelativeOffset reverseX() => copy()..dx = 1 - dx;

  RelativeOffset operator +(Object other) {
    if (other is RelativeOffset) {
      return copy()
        ..dx = dx + other.dx
        ..dy = dy + other.dy;
    } else if (other is num) {
      return copy()
        ..dx = dx + other
        ..dy = dy + other;
    } else {
      throw Exception('RelativeOffset or num expected');
    }
  }

  RelativeOffset operator -(Object other) {
    if (other is RelativeOffset) {
      return copy()
        ..dx = dx - other.dx
        ..dy = dy - other.dy;
    } else if (other is num) {
      return copy()
        ..dx = dx - other
        ..dy = dy - other;
    } else {
      throw Exception('RelativeOffset or num expected');
    }
  }

  RelativeOffset operator *(Object other) {
    if (other is RelativeOffset) {
      return copy()
        ..dx = dx * other.dx
        ..dy = dy * other.dy;
    } else if (other is num) {
      return copy()
        ..dx = dx * other
        ..dy = dy * other;
    } else {
      throw Exception('RelativeOffset or num expected');
    }
  }

  RelativeOffset operator /(Object other) {
    if (other is RelativeOffset) {
      return copy()
        ..dx = dx / other.dx
        ..dy = dy / other.dy;
    } else if (other is num) {
      return copy()
        ..dx = dx / other
        ..dy = dy / other;
    } else {
      throw Exception('RelativeOffset or num expected');
    }
  }

  RelativeOffset copy() => RelativeOffset(dx, dy);

  Offset toOffset(Size size) {
    final pointX = dx * size.width;
    final pointY = dy * size.height;
    return Offset(pointX, pointY);
  }

  @override
  bool operator ==(Object other) =>
      other is RelativeOffset && dx == other.dx && dy == other.dy;

  @override
  int get hashCode => hash2(dx, dy);

  @override
  String toString() => '(${dx.toStringAsFixed(2)}; ${dy.toStringAsFixed(2)})';
}

class Pair<T> {
  final T a;
  final T b;
  Pair(this.a, this.b);

  @override
  bool operator ==(Object other) =>
      other is Pair<T> && a == other.a && b == other.b;

  @override
  int get hashCode => hash2(a, b);

  @override
  String toString() => 'Pair($a, $b)';
}

class RelativeLine {
  final RelativeOffset a;
  final RelativeOffset b;
  final double width;
  final Color color;
  RelativeLine(this.a, this.b, {this.width = 1, this.color = Colors.black});
}

class RelativePoint {
  final RelativeOffset offset;
  final double radius;
  final Color color;
  RelativePoint(this.offset, {this.radius = 5, this.color = Colors.black});
}

class RelativeText {
  final RelativeOffset offset;
  final TextPainter painter;
  RelativeText(this.offset, this.painter);
}
