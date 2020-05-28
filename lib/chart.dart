import 'dart:async';

import 'package:f_charts/layers/_.dart';
import 'package:f_charts/widget_models/_.dart';
import 'package:f_charts/data_models/_.dart';
import 'package:flutter/material.dart';

import 'chart_controller.dart';

class Chart<T1, T2> extends StatefulWidget {
  final ChartData<T1, T2> chartData;
  final ChartMapper<T1, T2> mapper;
  final PointPressedCallback pointPressed;
  final ChartTheme theme;

  Chart({
    @required this.chartData,
    @required this.mapper,
    this.theme = const ChartTheme(),
    this.pointPressed,
  });
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
      if (layer.shouldDraw()) layer.draw(canvas, size);
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
  ChartController chartController;

  @override
  void initState() {
    super.initState();
    chartController = ChartController(
      widget.theme,
      widget.mapper,
      this,
      pointPressed: widget.pointPressed,
    );
    chartController.initLayers(widget.chartData);
    chartController.addListener(() {
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
    chartController?.dispose();
  }

  Future<void> startAnimation(ChartData from, ChartData to) async {
    await chartController.move(from, to);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border.all(width: 1)),
      padding: EdgeInsets.all(20),
      child: GestureDetector(
        child: CustomPaint(
          size: Size.infinite,
          foregroundPainter: ChartPaint(layers: chartController.layers),
          child: GestureDetector(
            onHorizontalDragDown: (d) {
              chartController.setXPosition(d.localPosition.dx);
            },
            onHorizontalDragEnd: (d) {
              chartController.setXPosition(null);
            },
            onHorizontalDragUpdate: (d) {
              chartController.setXPosition(d.localPosition.dx);
            },
          ),
        ),
      ),
    );
  }
}
