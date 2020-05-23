

import 'dart:ui';

import 'package:f_charts/chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

class RelativeOffset {
  Size viewportSize;
  double dx;
  double dy;
  EdgeInsets padding;

  RelativeOffset(this.dx, this.dy, this.viewportSize, {this.padding});

  RelativeOffset.fromOffset(Offset relativeOffset, this.viewportSize,
      {this.padding})
      : dx = relativeOffset.dx,
        dy = relativeOffset.dy;

  RelativeOffset reverseY() => copy()..dy = viewportSize.height - dy;

  RelativeOffset reverseX() => copy()..dx = viewportSize.width - dx;

  RelativeOffset withPadding(EdgeInsets insets) => copy()..padding = insets;

  RelativeOffset operator +(Object other) { 
    if (other is RelativeOffset) {
      assert(other.viewportSize == this.viewportSize);
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
      assert(other.viewportSize == this.viewportSize);
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
      assert(other.viewportSize == this.viewportSize);
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
      assert(other.viewportSize == this.viewportSize);
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

  Offset toOffset(Size size) {
    if (padding == null) {
      var pointX = (dx / viewportSize.width) * size.width;
      var pointY = (dy / viewportSize.height) * size.height;
      return Offset(pointX, pointY);
    } else {
      var newSizeWidth = size.width / (size.width + padding.left + padding.right) * size.width;
      var newSizeHeight = size.height / (size.height + padding.top + padding.bottom) * size.height;
      var pointX = padding.left + (dx / viewportSize.width) * newSizeWidth;
      var pointY = padding.top + (dy / viewportSize.height) * newSizeHeight;
      return Offset(pointX, pointY);
    }
  }

  RelativeOffset copy() =>
      RelativeOffset(dx, dy, viewportSize, padding: padding);

  @override
  String toString() => '($dx; $dy) at (${viewportSize.height}; ${viewportSize.width})';
}

class Pair<T> {
  final T a;
  final T b;
  Pair(this.a, this.b);

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