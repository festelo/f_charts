import 'dart:ui';

import 'package:f_charts/model/base.dart';
import 'package:f_charts/extensions.dart';
import 'package:flutter/animation.dart';

class AnimatedViewport {
  static Animatable<Size> tween(ChartBounds boundsFrom, ChartBounds boundsTo) => Tween(
    begin: Size(boundsFrom.maxAbscissaStep, boundsFrom.maxOrdinateStep),
    end: Size(boundsTo.maxAbscissaStep, boundsTo.maxOrdinateStep),
  );
}