import 'package:f_charts/chart_controller.dart';
import 'package:f_charts/layers/_.dart';
import 'package:f_charts/widget_models/_.dart';
import 'package:flutter/material.dart';

class ChartPaint extends CustomPainter {
  final EdgeInsets chartPadding;
  final List<Layer> layers;

  ChartPaint({
    this.layers,
    this.chartPadding = const EdgeInsets.all(50),
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final layer in layers) {
      if (layer.shouldDraw()) layer.draw(canvas, size);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class ChartDrawBox extends StatelessWidget {
  final ChartController controller;
  ChartDrawBox(this.controller);

  Widget gestureDetector(BuildContext context) {
    void Function(DragDownDetails) onHorizontalDragDown;
    void Function(DragEndDetails) onHorizontalDragEnd;
    void Function(DragUpdateDetails) onHorizontalDragUpdate;

    if (controller.interactionMode == ChartInteractionMode.pointer) {
      onHorizontalDragDown = (d) {
        if (controller.state.isSwitching) return;
        if (controller.tap(d.localPosition)) return;
        controller.setXPointerPosition(d.localPosition.dx);
      };

      onHorizontalDragEnd = (d) {
        if (controller.state.isSwitching) return;
        controller.setXPointerPosition(null);
      };

      onHorizontalDragUpdate = (d) {
        if (controller.state.isSwitching) return;
        controller.setXPointerPosition(d.localPosition.dx);
      };
    } else if (controller.interactionMode == ChartInteractionMode.gesture) {
      onHorizontalDragDown = (d) {
        if (controller.state.isSwitching) return;
        if (controller.tap(d.localPosition)) return;
        controller.startDragging();
      };

      onHorizontalDragEnd = (d) {
        if (!controller.state.isDragging) return;
        controller.endDrag(context.size);
      };

      onHorizontalDragUpdate = (d) {
        if (!controller.state.isDragging) return;
        controller.addDraggingOffset(d.delta);
      };
    }

    return GestureDetector(
      onHorizontalDragDown: onHorizontalDragDown,
      onHorizontalDragEnd: onHorizontalDragEnd,
      onHorizontalDragUpdate: onHorizontalDragUpdate,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      foregroundPainter: ChartPaint(layers: controller.layers),
      child: gestureDetector(context),
    );
  }
}
