import 'package:example/main.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

class ZoomImageDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
        child: Column(children: <Widget>[
      AppBar(
        title: Text("zoom/pan image demo"),
      ),
      Expanded(
        child: ExtendedImage.network(
          "https://photo.tuchong.com/1842013/f/122948519.jpg",
          fit: BoxFit.contain,
          //enableLoadState: false,
          mode: ExtendedImageMode.Gesture,
          gestureConfig: GestureConfig(
              minScale: 0.9,
              animationMinScale: 0.7,
              maxScale: 3.0,
              animationMaxScale: 3.5,
              speed: 1.0,
              inertialSpeed: 100.0,
              initialScale: 1.0,
              inPageView: InPageView.none),
        ),
      )
    ]));
  }
}
