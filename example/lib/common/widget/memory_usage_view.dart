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
    VMHelper().addListener(_updateMemoryUsage);
  }

  @override
  void didChangeDependencies() {
    final FlutterView view = View.of(context);
    _top = view.physicalSize.height / view.devicePixelRatio / 2 - 80;
    _left = view.physicalSize.width / view.devicePixelRatio / 2 - 40;
    super.didChangeDependencies();
  }

  void _updateMemoryUsage() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    VMHelper().removeListener(_updateMemoryUsage);
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
      child: GestureDetector(
        onPanUpdate: (DragUpdateDetails dragUpdateDetails) {
          setState(() {
            _top += dragUpdateDetails.delta.dy;
            _left += dragUpdateDetails.delta.dx;
          });
        },
        child: DefaultTextStyle(
          style: TextStyle(
              fontSize: 10, color: Colors.white.withValues(alpha: 0.68)),
          child: Container(
            decoration: ShapeDecoration(
              color: Colors.black.withValues(alpha: 0.8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              shadows: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            padding: const EdgeInsets.all(8.0),
            child: IntrinsicWidth(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  const Text('Used: '),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    ByteUtil.toByteString(main.heapUsage!),
                    style: const TextStyle(
                      color: Colors.red,
                      height: 1.4,
                      fontSize: 16,
                    ),
                  ),
                  Divider(
                    color: Colors.white.withValues(alpha: 0.1),
                    thickness: 1,
                  ),
                  const Text('Capacity: '),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    ByteUtil.toByteString(main.heapCapacity!),
                    style: const TextStyle(
                      color: Colors.blue,
                      height: 1.4,
                      fontSize: 16,
                    ),
                  ),
                  Divider(
                    color: Colors.white.withValues(alpha: 0.1),
                    thickness: 1,
                  ),
                  const Text('External: '),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    ByteUtil.toByteString(main.externalUsage!),
                    style: const TextStyle(
                      color: Colors.green,
                      height: 1.4,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
