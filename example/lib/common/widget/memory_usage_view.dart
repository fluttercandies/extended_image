import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:example/common/utils/vm_helper.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vm_service/vm_service.dart';

class MemoryUsageView extends StatefulWidget {
  @override
  _MemoryUsageViewState createState() => _MemoryUsageViewState();
}

class _MemoryUsageViewState extends State<MemoryUsageView> {
  int start = 0;
  int end = 0;
  late Timer _timer;
  @override
  void initState() {
    super.initState();

    VMHelper().startConnect().whenComplete(() {
      setState(() {
        _timer = Timer.periodic(const Duration(seconds: 2), (Timer timer) {
          VMHelper().updateMemoryUsage().whenComplete(() {
            setState(() {
              end = VMHelper().count - 1;
            });
          });
        });
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    VMHelper().clear();
    super.dispose();
  }

  void update() {}

  @override
  Widget build(BuildContext context) {
    if (VMHelper().serviceClient == null) {
      return Container();
    }
    final MemoryUsage main = VMHelper().mainMemoryUsage;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        DefaultTextStyle(
          style: const TextStyle(fontSize: 12, color: Colors.black),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Text.rich(TextSpan(children: <InlineSpan>[
                    const TextSpan(text: 'HeapUsage: '),
                    TextSpan(
                        text: ByteUtil.toByteString(main.heapUsage!),
                        style: const TextStyle(
                          color: Colors.red,
                        )),
                  ])),
                ),
                Expanded(
                  child: Text.rich(TextSpan(children: <InlineSpan>[
                    const TextSpan(text: 'HeapCapacity: '),
                    TextSpan(
                        text: ByteUtil.toByteString(main.heapCapacity!),
                        style: const TextStyle(
                          color: Colors.blue,
                        )),
                  ])),
                ),
                Expanded(
                  child: Text.rich(TextSpan(children: <InlineSpan>[
                    const TextSpan(text: 'ExternalUsage: '),
                    TextSpan(
                        text: ByteUtil.toByteString(main.externalUsage!),
                        style: const TextStyle(
                          color: Colors.green,
                        )),
                  ])),
                ),
              ],
            ),
          ),
        ),
        Container(
          padding:
              const EdgeInsets.only(left: 30, right: 30, top: 5, bottom: 5),
          width: window.physicalSize.width,
          height: 200,
          child: LineChart(
            sampleData1(),
            swapAnimationDuration: const Duration(milliseconds: 250),
          ),
        ),
      ],
    );
  }

  LineChartData sampleData1() {
    final DateTime now = DateTime.now();
    final List<LineChartBarData> data = linesBarData1(now);

    return LineChartData(
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
        ),
        touchCallback: (LineTouchResponse touchResponse) {},
        handleBuiltInTouches: true,
      ),
      gridData: FlGridData(
        show: false,
      ),
      titlesData: FlTitlesData(
        bottomTitles: SideTitles(
          showTitles: true,
          getTextStyles: (double value) => const TextStyle(
            color: Color(0xff72719b),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          margin: 10,
          getTitles: (double value) {
            final int millisecondsSinceEpoch = value.toInt();
            final DateTime dateTime =
                DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch);

            return DateFormat('HH:mm').format(dateTime);
          },
          interval: const Duration(minutes: 1).inMilliseconds.toDouble(),
        ),
        leftTitles: SideTitles(
          showTitles: true,
          getTextStyles: (double value) => const TextStyle(
            color: Color(0xff75729e),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          interval: 100,
          getTitles: (double value) {
            return value.toInt().toString() + 'M';
          },
          margin: 20,
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: const Border(
          bottom: BorderSide(
            color: Color(0xff4e4965),
            width: 2,
          ),
          left: BorderSide(
            color: Color(0xff4e4965),
            width: 2,
          ),
          right: BorderSide(
            color: Colors.transparent,
          ),
          top: BorderSide(
            color: Colors.transparent,
          ),
        ),
      ),
      minX: now
          .subtract(const Duration(minutes: 1))
          .millisecondsSinceEpoch
          .toDouble(),
      maxX: now.millisecondsSinceEpoch.toDouble(),
      minY: 0,
      maxY: max(500, maxY ?? 0),
      lineBarsData: data,
    );
  }

  double? minY;
  double? maxY;
  List<LineChartBarData> linesBarData1(DateTime now) {
    final List<FlSpot> data1 = <FlSpot>[];
    final List<FlSpot> data2 = <FlSpot>[];
    final List<FlSpot> data3 = <FlSpot>[];
    for (final MyMemoryUsage item in VMHelper().mainHistoryMemoryInfo) {
      data1.add(FlSpot(item.dataTime.millisecondsSinceEpoch.toDouble(),
          item.todouble(item.heapUsage)));
      data2.add(FlSpot(item.dataTime.millisecondsSinceEpoch.toDouble(),
          item.todouble(item.heapCapacity)));
      data3.add(FlSpot(item.dataTime.millisecondsSinceEpoch.toDouble(),
          item.todouble(item.externalUsage)));

      final double minValue =
          min(min(item.heapUsage, item.heapCapacity), item.externalUsage);

      final double maxValue =
          max(max(item.heapUsage, item.heapCapacity), item.externalUsage);

      minY = min(maxY ?? minValue.toDouble(), minValue.toDouble());
      maxY = max(maxY ?? maxValue.toDouble(), maxValue.toDouble());
    }

    return <LineChartBarData>[
      getLineChartBarData(data1, Colors.red),
      getLineChartBarData(data2, Colors.blue),
      getLineChartBarData(data3, Colors.green),
    ];
  }

  LineChartBarData getLineChartBarData(List<FlSpot> spots, Color color) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      colors: <Color>[
        color,
      ],
      barWidth: 2,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: false,
      ),
      belowBarData: BarAreaData(
        show: false,
      ),
    );
  }
}
