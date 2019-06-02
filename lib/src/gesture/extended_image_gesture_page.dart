import 'package:flutter/material.dart';

class ExtendedImageGesturePage extends StatefulWidget {
  final Widget child;
  ExtendedImageGesturePage({this.child});
  @override
  ExtendedImageGesturePageState createState() =>
      ExtendedImageGesturePageState();
}

class ExtendedImageGesturePageState extends State<ExtendedImageGesturePage> {
  bool _absorbing = true;
  bool get absorbing => _absorbing;

  void startGesture() {
    if (mounted) {
      setState(() {
        _absorbing = true;
      });
    }
  }

  void _endGesture() {
    if (mounted) {
      setState(() {
        _absorbing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragUpdate: (b) {
        //print("ddddd");
      },
      child: Container(
        child: AbsorbPointer(
          absorbing: absorbing,
          child: widget.child,
        ),
      ),
    );
  }
}
