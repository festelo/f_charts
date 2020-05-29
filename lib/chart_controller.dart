import 'package:f_charts/widget_models/_.dart';
import 'package:f_charts/data_models/_.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

import 'layers/_.dart';

class ChartController implements Listenable {
  final ObserverList<VoidCallback> _listeners = ObserverList<VoidCallback>();
  final ChartState state;
  final ChartTheme theme;
  final ChartMapper mapper;
  final ChartMarkersPointer markersPointer;

  final PointPressedCallback pointPressed;

  ChartController(
      this.theme, this.mapper, this.markersPointer, TickerProvider vsync,
      {ChartState state = null, this.pointPressed})
      : state = state ?? ChartState(),
        moveAnimationController = AnimationController(
          vsync: vsync,
          duration: Duration(milliseconds: 500),
        );

  ChartMoveLayer _moveLayer;
  ChartDrawBaseLayer _baseLayer;
  ChartInteractionLayer _interactionLayer;
  ChartDecorationLayer _decorationLayer;

  List<Layer> get layers => [
        _decorationLayer,
        _moveLayer,
        _baseLayer,
        _interactionLayer,
      ].where((e) => e != null).toList();

  AnimationController moveAnimationController;

  void initLayers(ChartData data) {
    _baseLayer = ChartDrawBaseLayer.calculate(data, theme, state, mapper);
    _interactionLayer = ChartInteractionLayer.calculate(
      data,
      theme,
      state,
      mapper,
      pointPressed: pointPressed,
    );
    _decorationLayer = ChartDecorationLayer.calculate(
      data: data,
      theme: theme,
      markersPointer: markersPointer,
      mapper: mapper,
    );
  }

  void setXPosition(double value) {
    _interactionLayer.xPositionAbs = value;
    notifyListeners();
  }

  Future<void> move(ChartData from, ChartData to) async {
    state.isMoving = true;
    final moveAnimation = MoveAnimation.between(from, to, mapper);
    _moveLayer = ChartMoveLayer(
      animation: moveAnimation,
      parent: moveAnimationController,
      theme: theme,
    );
    await moveAnimationController.forward(from: 0);
    state.isMoving = false;
    initLayers(to);
    notifyListeners();
  }

  @override
  void addListener(listener) {
    _listeners.add(listener);
    moveAnimationController.addListener(listener);
  }

  @override
  void removeListener(listener) {
    _listeners.remove(listener);
    moveAnimationController.removeListener(listener);
  }

  void notifyListeners() {
    for (final listener in _listeners) {
      try {
        listener();
      } catch (e) {
        print(e);
      }
    }
  }

  void dispose() {
    moveAnimationController?.dispose();
  }
}
