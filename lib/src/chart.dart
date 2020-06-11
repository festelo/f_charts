import 'dart:async';

import 'package:f_charts/widgets.dart';
import 'package:f_charts/widget_models.dart';
import 'package:f_charts/data_models.dart';
import 'package:flutter/material.dart';

class Chart<T1, T2> extends StatefulWidget {
  final ChartData<T1, T2> chartData;
  final ChartMapper<T1, T2> mapper;
  final ChartMarkersPointer<T1, T2> markersPointer;
  final ChartTheme theme;
  final ChartGestureHandlerBuilder gestureHandlerBuilder;

  final PointPressedCallback pointPressed;
  final SwipedCallback swiped;

  Chart({
    @required this.chartData,
    @required this.mapper,
    this.theme = const ChartTheme(),
    this.pointPressed,
    this.markersPointer,
    this.swiped,
    this.gestureHandlerBuilder = const PointerHandlerBuilder(),
  }) : assert((theme.yMarkers != null || theme.xMarkers != null) &&
            markersPointer != null);
  @override
  _ChartState createState() => _ChartState();
}

class _ChartState extends State<Chart> with SingleTickerProviderStateMixin {
  ChartController chartController;
  ChartGestureHandler gestureHandler;

  @override
  void initState() {
    super.initState();
    chartController = ChartController(
      widget.chartData,
      widget.mapper,
      widget.markersPointer,
      this,
      theme: widget.theme,
      pointPressed: widget.pointPressed,
      swiped: widget.swiped,
    );
    gestureHandler = widget.gestureHandlerBuilder.build(chartController);
    chartController.initLayers();
    chartController.addListener(() {
      setState(() {});
    });
  }

  @override
  void didUpdateWidget(Chart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.chartData != widget.chartData) {
      startAnimation(widget.chartData);
    }
  }

  @override
  void dispose() {
    super.dispose();
    chartController?.dispose();
  }

  Future<void> startAnimation(ChartData to) async {
    await chartController.move(to);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border.all(width: 1)),
      child: ChartDrawBox(chartController, gestureHandler),
    );
  }
}