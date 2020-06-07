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
        if (controller.tap(d.localPosition)) return;
        controller.setXPointerPosition(d.localPosition.dx);
      };

      onHorizontalDragEnd = (d) {
        controller.setXPointerPosition(null);
      };

      onHorizontalDragUpdate = (d) {
        controller.setXPointerPosition(d.localPosition.dx);
      };
    } else if (controller.interactionMode == ChartInteractionMode.gesture) {
      onHorizontalDragDown = (d) {
        if (controller.tap(d.localPosition)) return;
      };

      onHorizontalDragEnd = (d) {
        controller.endDrag(context.size);
      };

      onHorizontalDragUpdate = (d) {
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
