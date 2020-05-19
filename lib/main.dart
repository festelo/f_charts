import 'dart:async';

import 'package:f_charts/chart.dart';
import 'package:flutter/material.dart';

import 'model/base.dart';
import 'model/impl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var dataNum = 0;

  @override
  void initState() {
    super.initState();
  }

  var data = [
    ChartData([
      ChartSeries(color: Colors.red, entities: [
        DateIntChartEntity(DateTime.now().add(Duration(days: 0)), 1),
        DateIntChartEntity(DateTime.now().add(Duration(days: 1)), 3),
        DateIntChartEntity(DateTime.now().add(Duration(days: 3)), 2),
        DateIntChartEntity(DateTime.now().add(Duration(days: 5)), 4),
      ]),
      ChartSeries(color: Colors.orange, entities: [
        DateIntChartEntity(DateTime.now().add(Duration(days: 0)), 1),
        DateIntChartEntity(DateTime.now().add(Duration(days: 1)), 5),
        DateIntChartEntity(DateTime.now().add(Duration(days: 3)), 2),
        DateIntChartEntity(DateTime.now().add(Duration(days: 4)), 1),
      ]),
    ]),
    ChartData([
      ChartSeries(color: Colors.red, entities: [
        DateIntChartEntity(DateTime.now().add(Duration(days: 0)), 5),
        DateIntChartEntity(DateTime.now().add(Duration(days: 1)), 2),
        DateIntChartEntity(DateTime.now().add(Duration(days: 3)), 6),
        DateIntChartEntity(DateTime.now().add(Duration(days: 5)), 2),
      ]),
      ChartSeries(color: Colors.orange, entities: [
        DateIntChartEntity(DateTime.now().add(Duration(days: 0)), 1),
        DateIntChartEntity(DateTime.now().add(Duration(days: 1)), 5),
        DateIntChartEntity(DateTime.now().add(Duration(days: 3)), 2),
        DateIntChartEntity(DateTime.now().add(Duration(days: 4)), 1),
      ]),
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Chart(
          chartData: data[dataNum],
          pointPressed: () => setState(() => 
            dataNum = (dataNum+1) % data.length),
        ),
      ),
    );
  }
}
