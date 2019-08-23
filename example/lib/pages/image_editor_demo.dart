import 'package:example/main.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:ff_annotation_route/ff_annotation_route.dart';

///
///  create by zmtzawqlp on 2019/8/22
///
@FFRoute(
    name: "fluttercandies://imageeditor",
    routeName: "image editor",
    description: "crop/rotate image")
class ImageEditorDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
        child: Column(children: <Widget>[
      AppBar(
        title: Text("image editor demo"),
      ),
      Expanded(
        child: Container(
          padding: EdgeInsets.all(0.0),
          child: ExtendedImage.network(
            imageTestUrl,
            fit: BoxFit.contain,
            mode: ExtendedImageMode.Eidt,
            initGestureConfigHandler: (state) {
              return GestureConfig(
                  minScale: 0.9,
                  animationMinScale: 0.7,
                  maxScale: 3.0,
                  animationMaxScale: 3.5,
                  speed: 1.0,
                  inertialSpeed: 100.0,
                  initialScale: 1.0,
                  inPageView: false);
            },
          ),
        ),
      )
    ]));
  }
}
