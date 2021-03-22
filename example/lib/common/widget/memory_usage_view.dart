import 'dart:ui';

import 'package:example/common/utils/vm_helper.dart';
import 'package:flutter/material.dart';
import 'package:vm_service/vm_service.dart';

class MemoryUsageView extends StatefulWidget {
  @override
  _MemoryUsageViewState createState() => _MemoryUsageViewState();
}

class _MemoryUsageViewState extends State<MemoryUsageView> {
  double _top = 0;
  double _left = 0;
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
    final MemoryUsage main = VMHelper().mainMemoryUsage;

    return Positioned(
      top: _top,
      left: _left,
      child: DefaultTextStyle(
        style: const TextStyle(fontSize: 12, color: Colors.black),
        child: GestureDetector(
          onPanUpdate: (DragUpdateDetails dragUpdateDetails) {
            setState(() {
              _top += dragUpdateDetails.delta.dy;
              _left += dragUpdateDetails.delta.dx;
            });
          },
          child: Container(
            color: Colors.grey.withOpacity(0.2),
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text.rich(TextSpan(children: <InlineSpan>[
                  const TextSpan(text: 'HeapUsage: '),
                  TextSpan(
                      text: ByteUtil.toByteString(main.heapUsage!),
                      style: const TextStyle(
                        color: Colors.red,
                      )),
                ])),
                Text.rich(TextSpan(children: <InlineSpan>[
                  const TextSpan(text: 'HeapCapacity: '),
                  TextSpan(
                      text: ByteUtil.toByteString(main.heapCapacity!),
                      style: const TextStyle(
                        color: Colors.blue,
                      )),
                ])),
                Text.rich(TextSpan(children: <InlineSpan>[
                  const TextSpan(text: 'ExternalUsage: '),
                  TextSpan(
                      text: ByteUtil.toByteString(main.externalUsage!),
                      style: const TextStyle(
                        color: Colors.green,
                      )),
                ])),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
