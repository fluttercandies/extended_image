import 'package:example/main.dart';
import 'package:extended_image/extended_image.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/material.dart';

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
  final GlobalKey<ExtendedImageGestureState> customGestureKey =
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
                  customGestureKey.currentState!.reset();
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
          const Divider(height: 1),
          SizedBox(
            height: 220,
            child: ExtendedImageGestureWidget(
              extendedImageGestureKey: customGestureKey,
              childSize: const Size(240, 160),
              fit: BoxFit.contain,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  color: Color(0xFFEDE7F6),
                  border: Border.fromBorderSide(
                    BorderSide(color: Colors.deepPurple),
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(Icons.widgets, size: 48, color: Colors.deepPurple),
                      SizedBox(height: 8),
                      Text(
                        'Custom Widget',
                        style: TextStyle(
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('Zoom and pan without image bytes'),
                    ],
                  ),
                ),
              ),
              initGestureConfigHandler: (ExtendedImageState state) {
                return GestureConfig(
                  minScale: 0.9,
                  animationMinScale: 0.7,
                  maxScale: 4.0,
                  animationMaxScale: 4.5,
                  initialScale: 1.0,
                  initialAlignment: InitialAlignment.center,
                  reverseMousePointerScrollDirection: true,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
