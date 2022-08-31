import 'dart:math';
import 'dart:ui';

import 'package:example/common/utils/vm_helper.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MemoryUsageChart extends StatefulWidget {
  @override
  _MemoryUsageChartState createState() => _MemoryUsageChartState();
}

class _MemoryUsageChartState extends State<MemoryUsageChart> {
  @override
  void initState() {
    super.initState();
    VMHelper().addListener(updateMemoryUsage);
  }

  void updateMemoryUsage() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    VMHelper().removeListener(updateMemoryUsage);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (VMHelper().serviceClient == null) {
      return Container();
    }
    return Container(
      padding: const EdgeInsets.only(left: 30, right: 30, top: 20, bottom: 5),
      width: window.physicalSize.width,
      height: 150,
      child: LineChart(
        getData(),
        swapAnimationDuration: const Duration(milliseconds: 250),
      ),
    );
  }

  LineChartData getData() {
    final DateTime now = DateTime.now();
    final List<LineChartBarData> data = getLineData(now);

    return LineChartData(
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
        ),
        handleBuiltInTouches: true,
      ),
      gridData: FlGridData(
        show: false,
      ),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
            sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (double value, _) {
            final int millisecondsSinceEpoch = value.toInt();
            final DateTime dateTime =
                DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch);

            return Padding(
              padding: const EdgeInsets.all(0.0),
              child: Text(
                DateFormat('HH:mm').format(dateTime),
                style: const TextStyle(
                  color: Color(0xff72719b),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            );
          },
          interval: const Duration(minutes: 1).inMilliseconds.toDouble(),
        )),
        leftTitles: AxisTitles(
            sideTitles: SideTitles(
          showTitles: true,
          interval: 100,
          getTitlesWidget: (double value, _) {
            return Padding(
              padding: const EdgeInsets.all(0.0),
              child: Text(
                value.toInt().toString() + 'M',
                style: const TextStyle(
                  color: Color(0xff75729e),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            );
          },
        )),
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
      maxY: max(300, maxY ?? 0),
      lineBarsData: data,
    );
  }

  double? minY;
  double? maxY;
  List<LineChartBarData> getLineData(DateTime now) {
    final List<FlSpot> data1 = <FlSpot>[];
    final List<FlSpot> data2 = <FlSpot>[];
    final List<FlSpot> data3 = <FlSpot>[];
    for (final MyMemoryUsage item in VMHelper().mainHistoryMemoryInfo) {
      data1.add(FlSpot(item.dataTime.millisecondsSinceEpoch.toDouble(),
          item.toDouble(item.heapUsage)));
      data2.add(FlSpot(item.dataTime.millisecondsSinceEpoch.toDouble(),
          item.toDouble(item.heapCapacity)));
      data3.add(FlSpot(item.dataTime.millisecondsSinceEpoch.toDouble(),
          item.toDouble(item.externalUsage)));

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
      color: color,
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
