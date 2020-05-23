import 'dart:math';

import 'package:f_charts/extensions.dart';
import 'package:f_charts/model/base.dart';
import 'package:f_charts/model/stuff.dart';
import 'package:f_charts/utils.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';

List<Pair<RelativeOffset>> _findSeriesIntersactions(
  List<RelativeOffset> from,
  List<RelativeOffset> to, {
  bool reverse = false,
}) {
  List<Pair<RelativeOffset>> values = [];
  for (var i = 1; i < from.length; i++) {
    var fromLine = Pair(from[i - 1], from[i]);
    for (final toOffset in to) {
      final xPosition = toOffset.dx;
      if (!(fromLine.a.dx <= xPosition && fromLine.b.dx >= xPosition)) continue;
      final xLine = Pair(
        Point(xPosition, 0),
        Point(xPosition, toOffset.viewportSize.height),
      );
      final targetLine =
          Pair(Point(fromLine.a.dx, fromLine.a.dy), Point(fromLine.b.dx, fromLine.b.dy));
      final cross = intersection(targetLine, xLine);
      if (reverse) {
        values.add(
          Pair(
            toOffset,
            RelativeOffset(
                cross.x.toDouble(), cross.y.toDouble(), toOffset.viewportSize),
          ),
        );
      } else {
        values.add(
          Pair(
            RelativeOffset(
                cross.x.toDouble(), cross.y.toDouble(), toOffset.viewportSize),
            toOffset,
          ),
        );
      }
    }
  }
  return values;
}

typedef AnimatableBuilder = Animatable<RelativeOffset> Function(
    RelativeOffset from, RelativeOffset to);

class AnimatedSeries {
  final List<Animatable<RelativeOffset>> offsetAnimatables;
  final ChartSeries to;
  final ChartSeries from;

  AnimatedSeries({
    @required this.to,
    @required this.from,
    @required this.offsetAnimatables,
  });

  factory AnimatedSeries.custom({
    @required AnimatableBuilder builder,
    @required ChartBounds bounds,
    @required ChartSeries from,
    @required ChartSeries to,
  }) {
    final fromOffsets =
        from.entities.map((e) => e.toRelativeOffset(bounds)).toList();
    final toOffsets =
        to?.entities?.map((e) => e.toRelativeOffset(bounds))?.toList() ?? [];
    final directIntersactions = _findSeriesIntersactions(fromOffsets, toOffsets);
    final reverseIntersactions = _findSeriesIntersactions(toOffsets, fromOffsets, reverse: true);
    final offsets = {
      ...directIntersactions, 
      ...reverseIntersactions
    }.toList();
    offsets.sort((a, b) => a.a.dx.compareTo(b.a.dx));
    var values = offsets.map((e) => builder(e.a, e.b)).toList();
    
    return AnimatedSeries(from: from, to: to, offsetAnimatables: values);
  }

  factory AnimatedSeries.tween({
    @required ChartBounds bounds,
    @required ChartSeries from,
    @required ChartSeries to,
  }) {
    return AnimatedSeries.custom(
      builder: (a, b) => Tween(begin: a, end: b),
      bounds: bounds,
      from: from,
      to: to,
    );
  }

  factory AnimatedSeries.curve({
    @required ChartBounds bounds,
    @required ChartSeries from,
    @required ChartSeries to,
    Curve curve = Curves.easeInCubic
  }) {
    return AnimatedSeries.custom(
      builder: (a, b) => Tween(begin: a, end: b).chain(
        CurveTween(curve: curve),
      ),
      bounds: bounds,
      from: from,
      to: to,
    );
  }

  List<RelativeOffset> points(Animation<double> animation) {
    return offsetAnimatables.map((e) => e.evaluate(animation)).toList();
  }
}
