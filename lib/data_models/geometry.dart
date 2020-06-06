import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:quiver_hashcode/hashcode.dart';

abstract class ChartOffset {
  Offset toAbsolute(Size viewportSize);
}

class CombinedOffset implements ChartOffset {
  double relativeX = 0;
  double relativeY = 0;
  double absoluteX = 0;
  double absoluteY = 0;
  CombinedOffset();

  RelativeOffset toRelative(Size viewportSize) {
    return RelativeOffset.fromOffset(
      toAbsolute(viewportSize),
      viewportSize,
    );
  }

  Offset toAbsolute(Size viewportSize) {
    return Offset(
      absoluteX + relativeX * viewportSize.width,
      absoluteY + relativeY * viewportSize.height,
    );
  }
}

class RelativeOffset implements ChartOffset {
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

  Offset toAbsolute(Size size) {
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

class ChartLine {
  final ChartOffset a;
  final ChartOffset b;
  final double width;
  final Color color;
  ChartLine(this.a, this.b, {this.width = 1, this.color = Colors.black});
}

class ChartPoint {
  final ChartOffset offset;
  final double radius;
  final Color color;
  ChartPoint(this.offset, {this.radius = 5, this.color = Colors.black});
}

class ChartText {
  final ChartOffset offset;
  final TextPainter painter;
  ChartText(this.offset, this.painter);
}
