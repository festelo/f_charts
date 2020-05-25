import 'dart:async';

import 'package:f_charts/layers/_.dart';
import 'package:f_charts/chart_models/_.dart';
import 'package:f_charts/data_models/_.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class Chart extends StatefulWidget {
  final ChartData chartData;
  final VoidCallback pointPressed;
  final ChartTheme theme;

  Chart({this.chartData, this.theme = const ChartTheme(), this.pointPressed});
  @override
  _ChartState createState() => _ChartState();
}

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
      layer.draw(canvas, size);
    }
  }

  @override
  bool hitTest(Offset position) {
    var hitted = false;
    for (final l in layers) {
      if (l.hitTest(position)) hitted = true;
    }
    return hitted;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class _ChartState extends State<Chart> with SingleTickerProviderStateMixin {
  Offset offset = Offset(0, 0);

  AnimationController moveAnimationController;
  MoveAnimation moveAnimation;
  ChartMoveLayer moveLayer;

  ChartDrawBaseLayer baseLayer;
  ChartInteractionLayer interactionLayer;
  ChartDecorationLayer decorationLayer;

  @override
  void initState() {
    super.initState();
    initLayers();
    moveAnimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    moveAnimationController.addListener(() {
      setState(() {});
    });
  }

  @override
  void didUpdateWidget(Chart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.chartData != widget.chartData) {
      startAnimation(oldWidget.chartData, widget.chartData);
      return;
    }
  }

  @override
  void dispose() {
    super.dispose();
    moveAnimationController?.dispose();
  }

  Future<void> startAnimation(ChartData from, ChartData to) async {
    moveAnimation = MoveAnimation.between(from, to);
    moveLayer = ChartMoveLayer(
      animation: moveAnimation,
      parent: moveAnimationController,
      theme: widget.theme,
    );
    await moveAnimationController.forward(from: 0);
    initLayers();
    setState(() {});
  }

  void initLayers() {
    baseLayer = ChartDrawBaseLayer.calculate(widget.chartData, widget.theme);
    interactionLayer = ChartInteractionLayer.calculate(
      widget.chartData,
      widget.theme,
      pointPressed: widget.pointPressed,
    );
    decorationLayer =
        ChartDecorationLayer.calculate(widget.chartData, widget.theme);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border.all(width: 1)),
      padding: EdgeInsets.all(20),
      child: GestureDetector(
        child: CustomPaint(
          size: Size.infinite,
          foregroundPainter: ChartPaint(
            layers: [
              decorationLayer,
              if (!moveAnimationController.isAnimating) baseLayer,
              interactionLayer,
              if (moveAnimationController.isAnimating) moveLayer
            ],
          ),
          child: GestureDetector(
            onHorizontalDragDown: (d) {
              setState(() {
                interactionLayer.xPosition = d.localPosition.dx;
              });
            },
            onHorizontalDragEnd: (d) {
              setState(() {
                interactionLayer.xPosition = null;
              });
            },
            onHorizontalDragUpdate: (d) {
              setState(() {
                interactionLayer.xPosition = d.localPosition.dx;
              });
            },
          ),
        ),
      ),
    );
  }
}
