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

  final PointPressedCallback<T1, T2> pointPressed;
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
  _ChartState createState() => _ChartState<T1, T2>();
}

class _ChartState<T1, T2> extends State<Chart<T1, T2>> with SingleTickerProviderStateMixin {
  ChartController chartController;
  ChartGestureHandler gestureHandler;

  @override
  void initState() {
    super.initState();
    chartController = ChartController<T1, T2>(
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
  void didUpdateWidget(Chart<T1, T2> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.chartData != widget.chartData) {
      startAnimation(widget.chartData);
    }
    if (oldWidget.theme != widget.theme) {
      chartController.theme = widget.theme;
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
    return ChartDrawBox(chartController, gestureHandler);
  }
}
