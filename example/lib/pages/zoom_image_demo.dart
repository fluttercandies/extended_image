import 'package:example/common/utils.dart';
import 'package:example/main.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:ff_annotation_route/ff_annotation_route.dart';

@FFRoute(
    name: "fluttercandies://zoomimage",
    routeName: "image zoom",
    description: "show how to zoom/pan image")
class ZoomImageDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
        child: Column(children: <Widget>[
      AppBar(
        title: Text("zoom/pan image demo"),
      ),
      Expanded(
        child: LayoutBuilder(builder: (_, c) {
          Size size = Size(c.maxWidth, c.maxHeight);
          return ExtendedImage.network(
            imageTestUrl,
            fit: BoxFit.contain,
            //enableLoadState: false,
            mode: ExtendedImageMode.gesture,
            initGestureConfigHandler: (state) {
              double initialScale = 1.0;

              if (state.extendedImageInfo != null &&
                  state.extendedImageInfo.image != null) {
                initialScale = initScale(
                    size: size,
                    initialScale: initialScale,
                    imageSize: Size(
                        state.extendedImageInfo.image.width.toDouble(),
                        state.extendedImageInfo.image.height.toDouble()));
              }
              return GestureConfig(
                  minScale: 0.9,
                  animationMinScale: 0.7,
                  maxScale: 3.0,
                  animationMaxScale: 3.5,
                  speed: 1.0,
                  inertialSpeed: 100.0,
                  initialScale: initialScale,
                  inPageView: false);
            },
          );
        }),
      )
    ]));
  }
}
