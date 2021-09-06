import 'package:example/main.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';

@FFRoute(
  name: 'fluttercandies://zoomimage',
  routeName: 'ImageZoom',
  description: 'Zoom and Pan.',
  exts: <String, dynamic>{
    'group': 'Simple',
    'order': 4,
  },
)
class ZoomImageDemo extends StatelessWidget {
  // you can handle gesture detail by yourself with key
  final GlobalKey<ExtendedImageGestureState> gestureKey =
      GlobalKey<ExtendedImageGestureState>();
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: <Widget>[
          AppBar(
            title: const Text('zoom/pan image demo'),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.restore),
                onPressed: () {
                  gestureKey.currentState!.reset();
                  //you can also change zoom manual
                  //gestureKey.currentState.gestureDetails=GestureDetails();
                },
              )
            ],
          ),
          Expanded(
            child: ExtendedImage.network(
              imageTestUrl,
              fit: BoxFit.contain,
              mode: ExtendedImageMode.gesture,
              extendedImageGestureKey: gestureKey,
              initGestureConfigHandler: (ExtendedImageState state) {
                return GestureConfig(
                  minScale: 0.9,
                  animationMinScale: 0.7,
                  maxScale: 4.0,
                  animationMaxScale: 4.5,
                  speed: 1.0,
                  inertialSpeed: 100.0,
                  initialScale: 1.0,
                  inPageView: false,
                  initialAlignment: InitialAlignment.center,
                  reverseMousePointerScrollDirection: true,
                  gestureDetailsIsChanged: (GestureDetails? details) {
                    //print(details?.totalScale);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
