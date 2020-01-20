import 'dart:async';

import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter_circular_chart/flutter_circular_chart.dart';
import 'package:intl/intl.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    return MaterialApp(
      theme: ThemeData(
          brightness: Brightness.dark,
          textTheme: TextTheme(
            display1: TextStyle(color: Colors.black38, fontSize: 30),
          ),
          fontFamily: 'Arial'),
      home: Scaffold(
        body: Center(
          child: Clock(),
        ),
      ),
    );
  }
}

class Clock extends StatefulWidget {
  Clock({Key key}) : super(key: key);

  @override
  _ClockState createState() => _ClockState();
}

class _ClockState extends State<Clock> {
  BinaryTime _now = BinaryTime();

  @override
  void initState() {
    Timer.periodic(Duration(seconds: 1), (v) {
      setState(() {
        _now = BinaryTime();
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double widgetSize = (MediaQuery.of(context).size.width / 5) - 10;
    int hour = (int.parse(_now.hourTens, radix: 2) * 10) +
        int.parse(_now.hourOnes, radix: 2);
    return Container(
        padding: EdgeInsets.all(0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            HourWidget(hour: hour, size: widgetSize),
            AnimeWidget(binaryInteger: _now.minuteTens, size: widgetSize),
            GridWidget(binaryInteger: _now.minuteOnes, size: widgetSize),
            AnimeWidget(binaryInteger: _now.secondTens, size: widgetSize),
            GridWidget(binaryInteger: _now.secondOnes, size: widgetSize)
          ],
        ));
  }
}

class AnimeWidget extends StatelessWidget {
  final List<String> animations = [
    'zero',
    'one',
    'two',
    'three',
    'four',
    'five'
  ];

  String binaryInteger;

  double size;

  AnimeWidget({this.binaryInteger, this.size}) {}

  @override
  Widget build(BuildContext context) {
    int animeIndex = int.parse(binaryInteger, radix: 2);
    return Container(
      padding: EdgeInsets.all(1.0),
      width: this.size,
      child: AspectRatio(
          aspectRatio: 1,
          child: Padding(
              padding: EdgeInsets.only(top: 20),
              child: FlareActor("assets/star.flr",
                  animation: this.animations.elementAt(animeIndex),
                  alignment: Alignment.center,
                  fit: BoxFit.contain))),
    );
  }
}

class GridWidget extends StatelessWidget {
  List<List<int>> dots = [
    [],
    [4],
    [1, 7],
    [0, 4, 8],
    [0, 2, 6, 8],
    [0, 2, 4, 6, 8],
    [0, 2, 3, 5, 6, 8],
    [0, 2, 3, 4, 5, 6, 8],
    [0, 1, 2, 3, 5, 6, 7, 8],
    [0, 1, 2, 3, 4, 5, 6, 7, 8]
  ];

  String binaryInteger;
  double size;

  GridWidget({this.binaryInteger, this.size}) {}

  @override
  Widget build(BuildContext context) {
    List<int> timeSlice = dots.elementAt(int.parse(binaryInteger, radix: 2));
    return Container(
        width: this.size,
        height: this.size + 20,
        child: AspectRatio(
            aspectRatio: 1,
            child: GridView.count(
              crossAxisCount: 3,
              children: List.generate(9, (index) {
                return Center(
                    child: GridColumn(num: index, timeSlice: timeSlice));
              }),
            )));
  }
}

class GridColumn extends StatelessWidget {
  int num;
  List<int> timeSlice;

  GridColumn({this.num, this.timeSlice}) {}

  @override
  Widget build(BuildContext context) {
    bool isActive = this.timeSlice.contains(this.num);
    return Container(
      padding: EdgeInsets.all(1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          AnimatedContainer(
            duration: Duration(milliseconds: 475),
            curve: Curves.ease,
            height: 20,
            width: 20,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                color: isActive ? Colors.white : Colors.black38),
            margin: EdgeInsets.all(4),
          )
        ],
      ),
    );
  }
}

class BinaryTime {
  List<String> binaryIntegers;

  BinaryTime() {
    DateTime now = DateTime.now();
    String hhmmss = DateFormat("jms").format(now).replaceAll(':', '');

    binaryIntegers = hhmmss
        .split('')
        .map((str) => int.parse(str).toRadixString(2).padLeft(4, '0'))
        .toList();
  }

  get hourTens => binaryIntegers[0];

  get hourOnes => binaryIntegers[1];

  get minuteTens => binaryIntegers[2];

  get minuteOnes => binaryIntegers[3];

  get secondTens => binaryIntegers[4];

  get secondOnes => binaryIntegers[5];
}

class HourWidget extends StatelessWidget {
  int hour;
  double size;

  HourWidget({this.hour, this.size}) {}

  @override
  Widget build(BuildContext context) {
    final GlobalKey<AnimatedCircularChartState> _chartKey =
        new GlobalKey<AnimatedCircularChartState>();

    double percent = (100 * this.hour) / 12;
    return Container(
      padding: EdgeInsets.all(1.0),
      width: this.size,
      child: new AnimatedCircularChart(
        key: _chartKey,
        size: Size(this.size, this.size),
        initialChartData: <CircularStackEntry>[
          new CircularStackEntry(
            <CircularSegmentEntry>[
              new CircularSegmentEntry(
                percent,
                Colors.white,
                rankKey: 'completed',
              ),
              new CircularSegmentEntry(
                100 - percent,
                Colors.blueGrey[600],
                rankKey: 'remaining',
              ),
            ],
            rankKey: 'progress',
          ),
        ],
        chartType: CircularChartType.Radial,
        edgeStyle: SegmentEdgeStyle.round,
        percentageValues: true,
      ),
    );
  }
}
