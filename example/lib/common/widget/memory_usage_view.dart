import 'dart:async';

import 'package:example/common/utils/vm_helper.dart';
import 'package:flutter/material.dart';

class MemoryUsageView extends StatefulWidget {
  @override
  _MemoryUsageViewState createState() => _MemoryUsageViewState();
}

class _MemoryUsageViewState extends State<MemoryUsageView> {
  int start = 0;
  int end = 0;
  Timer _timer;
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
    super.dispose();
  }

  void update() {}

  @override
  Widget build(BuildContext context) {
    if (VMHelper().serviceClient == null) {
      return Container();
    }
    return Column(
      children: <Widget>[
        for (IsolateRef key in VMHelper().memoryInfo.keys)
          IntrinsicHeight(
            child: Row(
              children: <Widget>[
                Text.rich(
                  TextSpan(
                    children: <InlineSpan>[
                      const TextSpan(text: 'IsolateName: '),
                      TextSpan(text: key.name),
                      const TextSpan(text: '\nHeapUsage: '),
                      TextSpan(
                        text: ByteUtil.toByteString(
                            VMHelper().memoryInfo[key].heapUsage),
                      ),
                      const TextSpan(text: '\nHeapCapacity: '),
                      TextSpan(
                        text: ByteUtil.toByteString(
                            VMHelper().memoryInfo[key].heapCapacity),
                      ),
                      const TextSpan(text: '\nExternalUsage: '),
                      TextSpan(
                        text: ByteUtil.toByteString(
                            VMHelper().memoryInfo[key].externalUsage),
                      ),
                    ],
                  ),
                ),
                Expanded(
                    child: Container(
                  height: 200,
                  padding: const EdgeInsets.all(8.0),
                  child: CustomPaint(
                    painter: MemoryUsageViewPainter(
                      start,
                      end,
                      VMHelper().historyMemoryInfo[key],
                    ),
                  ),
                )),
              ],
            ),
          )
      ],
    );
  }
}

class MemoryUsageViewPainter extends CustomPainter {
  MemoryUsageViewPainter(this.start, this.end, this.memoryUsages);
  final int end;
  final int start;
  final List<List<int>> memoryUsages;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
        Offset.zero & size,
        Paint()
          ..color = Colors.green.withOpacity(0.3)
          ..style = PaintingStyle.fill);
    drawLine(
      canvas,
      size,
      memoryUsages[0].getRange(start, end).toList(),
      Colors.red,
    );
    drawLine(
      canvas,
      size,
      memoryUsages[1].getRange(start, end).toList(),
      Colors.blue,
    );
    drawLine(
      canvas,
      size,
      memoryUsages[2].getRange(start, end).toList(),
      Colors.green,
    );
  }

  void drawLine(Canvas canvas, Size size, List<int> data, Color color) {
    if (data.isEmpty) {
      return;
    }
    final int max = data
        .reduce((int value, int element) => value > element ? value : element);
    final int min = data
        .reduce((int value, int element) => value < element ? value : element);

    final double x = size.width / 30;
    final Path path = Path();

    for (int i = 0; i < data.length; i++) {
      if (i == 0) {
        path.moveTo(x * i, getY(min, max, size.height, data[i]));
      } else {
        path.lineTo(x * i, getY(min, max, size.height, data[i]));
      }
    }
    path.fillType = PathFillType.nonZero;

    canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1);
  }

  double getY(int min, int max, double height, int value) {
    if (min == max) {
      return height / 2.0;
    }
    return (value - min) * height / (max - min);
  }

  @override
  bool shouldRepaint(covariant MemoryUsageViewPainter oldDelegate) {
    return oldDelegate.start != start || oldDelegate.end != end;
  }
}
