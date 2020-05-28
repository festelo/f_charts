import 'dart:math';

import 'package:f_charts/extensions.dart';
import 'package:f_charts/data_models/_.dart';
import 'package:f_charts/utils.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';

Map<RelativeOffset, RelativeOffset> _findPointsIntersactionWay(
  List<RelativeOffset> from,
  List<RelativeOffset> to,
) {
  if (from.isEmpty || to.isEmpty) return {};
  Map<RelativeOffset, RelativeOffset> pointsMap = {};

  for (var pointFromI = 0; pointFromI < from.length; pointFromI++) {
    final xPosition = from[pointFromI].dx;

    for (var pointToI = 1; pointToI < to.length; pointToI++) {
      var toLine = Pair(to[pointToI - 1], to[pointToI]);
      if (!(toLine.a.dx <= xPosition && toLine.b.dx >= xPosition)) continue;

      final xLine = Pair(
        Point(xPosition, RelativeOffset.min),
        Point(xPosition, RelativeOffset.max),
      );

      final targetLine = Pair(
        Point(toLine.a.dx, toLine.a.dy),
        Point(toLine.b.dx, toLine.b.dy),
      );

      final cross = intersection(targetLine, xLine);
      if (cross != null)
        pointsMap[from[pointFromI]] =
            RelativeOffset(cross.x.toDouble(), cross.y.toDouble());
    }
  }

  return pointsMap;
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
    @required ChartBoundsDoubled boundsFrom,
    @required ChartBoundsDoubled boundsTo,
    @required ChartSeries seriesFrom,
    @required ChartSeries seroesTo,
    @required ChartMapper mapper,
  }) {
    final fromOffsets = seriesFrom.entities
        .map((e) => e.toRelativeOffset(mapper, boundsFrom))
        .toList();
    final toOffsets = seroesTo?.entities
            ?.map((e) => e.toRelativeOffset(mapper, boundsTo))
            ?.toList() ??
        [];
    final directIntersactions =
        _findPointsIntersactionWay(fromOffsets, toOffsets);
    final reverseIntersactions =
        _findPointsIntersactionWay(toOffsets, fromOffsets).reverse();

    final allIntersactions = {...directIntersactions, ...reverseIntersactions};

    final allIntersactionsReversed = allIntersactions.reverse();

    for (var key in fromOffsets) {
      if (allIntersactions[key] != null) continue;
      allIntersactions[key] = allIntersactions.values.reduce(
        (a, b) => (key.dx - a.dx).abs() < (key.dx - b.dx).abs() ? a : b,
      );
    }

    final pairs =
        allIntersactions.entries.map((e) => Pair(e.key, e.value)).toList();

    for (var key in toOffsets) {
      if (allIntersactionsReversed[key] != null) continue;
      var nKey = allIntersactions.keys.reduce(
        (a, b) => (key.dx - a.dx).abs() < (key.dx - b.dx).abs() ? a : b,
      );
      pairs.add(Pair(nKey, key));
    }

    pairs.sort((a, b) {
      var compared = a.a.dx.compareTo(b.a.dx);
      if (compared == 0) return a.b.dx.compareTo(b.b.dx);
      return compared;
    });

    var values = pairs.map((e) => builder(e.a, e.b)).toList();

    return AnimatedSeries(
        from: seriesFrom, to: seroesTo, offsetAnimatables: values);
  }

  factory AnimatedSeries.tween({
    @required ChartBoundsDoubled boundsFrom,
    @required ChartBoundsDoubled boundsTo,
    @required ChartSeries seriesFrom,
    @required ChartSeries seriesTo,
    @required ChartMapper mapper,
  }) {
    return AnimatedSeries.custom(
      builder: (a, b) => Tween(begin: a, end: b),
      boundsFrom: boundsFrom,
      boundsTo: boundsTo,
      seriesFrom: seriesFrom,
      seroesTo: seriesTo,
      mapper: mapper,
    );
  }

  factory AnimatedSeries.curve({
    @required ChartBoundsDoubled boundsFrom,
    @required ChartBoundsDoubled boundsTo,
    @required ChartSeries seriesFrom,
    @required ChartSeries seriesTo,
    @required ChartMapper mapper,
    Curve curve = Curves.easeInOut,
  }) {
    return AnimatedSeries.custom(
      builder: (a, b) => Tween(begin: a, end: b).chain(
        CurveTween(curve: curve),
      ),
      boundsFrom: boundsFrom,
      boundsTo: boundsTo,
      seriesFrom: seriesFrom,
      seroesTo: seriesTo,
      mapper: mapper,
    );
  }

  factory AnimatedSeries.leftCornerInOut({
    @required ChartBoundsDoubled boundsFrom,
    @required ChartBoundsDoubled boundsTo,
    @required ChartSeries seriesFrom,
    @required ChartSeries seriesTo,
    @required ChartMapper mapper,
    Curve curve = Curves.easeInOut,
  }) {
    return AnimatedSeries.custom(
      builder: (a, b) => TweenSequence([
        TweenSequenceItem(
            tween: Tween(begin: a, end: RelativeOffset(0, 0)).chain(
              CurveTween(curve: curve),
            ),
            weight: 50),
        TweenSequenceItem(
            tween: Tween(begin: RelativeOffset(0, 0), end: b).chain(
              CurveTween(curve: curve),
            ),
            weight: 50),
      ]),
      boundsFrom: boundsFrom,
      boundsTo: boundsTo,
      seriesFrom: seriesFrom,
      seroesTo: seriesTo,
      mapper: mapper,
    );
  }

  List<RelativeOffset> points(Animation<double> animation) {
    return offsetAnimatables.map((e) => e.evaluate(animation)).toList();
  }
}
