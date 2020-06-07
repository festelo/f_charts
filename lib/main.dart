import 'package:f_charts/chart.dart';
import 'package:f_charts/widget_models/_.dart';
import 'package:f_charts/data_models/_.dart';
import 'package:flutter/material.dart';

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
  var dataIndexes = [0, 0, 0];

  @override
  void initState() {
    super.initState();
  }

  List<ChartData<int, int>> get data => [
        ChartData([
          ChartSeries(color: Colors.red, name: 'First series', entities: [
            ChartEntity(0, 1),
            ChartEntity(1, 2),
            ChartEntity(3, 1),
            ChartEntity(4, 0),
          ]),
          ChartSeries(color: Colors.orange, name: 'Second series', entities: [
            ChartEntity(1, 1),
            ChartEntity(3, 5),
            ChartEntity(4, 10),
          ]),
        ]),
        ChartData([
          ChartSeries(color: Colors.red, name: 'First series', entities: [
            ChartEntity(0, 3),
            ChartEntity(1, 0),
            ChartEntity(4, 5),
          ]),
          ChartSeries(color: Colors.orange, name: 'Second series', entities: [
            ChartEntity(1, 1),
            ChartEntity(2, 3),
            ChartEntity(3, 1),
            ChartEntity(10, 2),
          ]),
        ]),
      ];

  Widget chartWithLabel(
    BuildContext context,
    String title,
    int dataIndexNumber,
    ChartInteractionMode mode,
  ) {
    return Stack(
      children: [
        Chart(
          theme: ChartTheme(),
          mapper: ChartMapper(IntMapper(), IntMapper()),
          markersPointer:
              ChartMarkersPointer(IntMarkersPointer(1), IntMarkersPointer(2)),
          chartData: data[dataIndexes[dataIndexNumber]],
          interactionMode: mode,
          swiped: (a) {
            setState(() {
              dataIndexes[dataIndexNumber] = (dataIndexes[dataIndexNumber] + 1) % data.length;
            });
            return true;
          },
          pointPressed: (_) => setState(() => dataIndexes[dataIndexNumber] =
              (dataIndexes[dataIndexNumber] + 1) % data.length),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              child: Text(
                title,
                style: Theme.of(context).textTheme.headline6,
              )),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        Expanded(
          flex: 1,
          child: chartWithLabel(context, 'pointer mode', 0, ChartInteractionMode.pointer),
        ),
        Expanded(
          flex: 1,
          child: chartWithLabel(context, 'gesture mode', 1, ChartInteractionMode.gesture),
        ),
        Expanded(
          flex: 1,
          child: chartWithLabel(context, 'hybrid mode', 2, ChartInteractionMode.hybrid),
        ),
      ]),
    );
  }
}
