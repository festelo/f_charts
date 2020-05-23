

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:quiver_hashcode/hashcode.dart';

class RelativeOffset {
  Size viewportSize;
  double dx;
  double dy;

  RelativeOffset(this.dx, this.dy, {this.viewportSize = const Size(1, 1)});

  RelativeOffset.fromOffset(Offset relativeOffset,
      {this.viewportSize})
      : dx = relativeOffset.dx,
        dy = relativeOffset.dy;

  RelativeOffset reverseY() => copy()..dy = viewportSize.height - dy;

  RelativeOffset reverseX() => copy()..dx = viewportSize.width - dx;

  RelativeOffset operator +(Object other) { 
    if (other is RelativeOffset) {
      final ro = other.copy()..scaleTo(viewportSize);
      return copy()
        ..dx = dx + ro.dx
        ..dy = dy + ro.dy;
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
      final ro = other.copy()..scaleTo(viewportSize);
      return copy()
        ..dx = dx - ro.dx
        ..dy = dy - ro.dy;
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
      final ro = other.copy()..scaleTo(viewportSize);
      return copy()
        ..dx = dx * ro.dx
        ..dy = dy * ro.dy;
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
      final ro = other.copy()..scaleTo(viewportSize);
      return copy()
        ..dx = dx / ro.dx
        ..dy = dy / ro.dy;
    } else if (other is num) {
      return copy()
        ..dx = dx / other
        ..dy = dy / other;
    } else {
      throw Exception('RelativeOffset or num expected');
    }
  }

  Offset toOffset(Size size) {
    final scaled = copy()..scaleTo(size);
    return Offset(scaled.dx, scaled.dy);
  }

  void scaleTo(Size viewportSize) {
    dx = (dx / viewportSize.width) * viewportSize.width;
    dy = (dy / viewportSize.height) * viewportSize.height;
    viewportSize = viewportSize;
  }
  
  @override
  bool operator ==(Object other) => other is RelativeOffset && 
    dx == other.dx &&
    dy == other.dy &&
    viewportSize == other.viewportSize;

  @override
  int get hashCode => hash3(dx, dy, viewportSize);

  RelativeOffset copy() =>
      RelativeOffset(dx, dy, viewportSize: viewportSize);

  @override
  String toString() => '($dx; $dy) at (${viewportSize.height}; ${viewportSize.width})';
}

class Pair<T> {
  final T a;
  final T b;
  Pair(this.a, this.b);
  
  @override
  bool operator ==(Object other) => other is Pair<T> && 
    a == other.a &&
    b == other.b;

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