import 'package:example/main.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:flutter_candies_demo_library/flutter_candies_demo_library.dart';

@FFRoute(
    name: 'fluttercandies://zoomimage',
    routeName: 'image zoom',
    description: 'show how to zoom/pan image')
class ZoomImageDemo extends StatelessWidget {
  final GlobalKey<ExtendedImageGestureState> gestureKey =
      GlobalKey<ExtendedImageGestureState>();
  @override
  Widget build(BuildContext context) {
    return Material(
        child: Column(children: <Widget>[
      AppBar(
        title: const Text('zoom/pan image demo'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.restore),
            onPressed: () {
              gestureKey.currentState.reset();
              //you can also change zoom manual
              //gestureKey.currentState.gestureDetails=GestureDetails();
            },
          )
        ],
      ),
      Expanded(
        child: LayoutBuilder(builder: (_, BoxConstraints c) {
          final Size size = Size(c.maxWidth, c.maxHeight);
          return ExtendedImage.network(
            imageTestUrl,
            fit: BoxFit.contain,
            //enableLoadState: false,
            mode: ExtendedImageMode.gesture,
            extendedImageGestureKey: gestureKey,
            initGestureConfigHandler: (ExtendedImageState state) {
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
                maxScale: 4.0,
                animationMaxScale: 4.5,
                speed: 1.0,
                inertialSpeed: 100.0,
                initialScale: initialScale,
                inPageView: false,
                initialAlignment: InitialAlignment.center,
              );
            },
          );
        }),
      )
    ]));
  }
}
