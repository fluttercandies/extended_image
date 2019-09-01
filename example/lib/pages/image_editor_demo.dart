import 'package:example/main.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:image/image.dart';
import 'package:image/image.dart' as image;
import 'dart:ui' as ui;

import 'package:image_picker_saver/image_picker_saver.dart';
import 'package:oktoast/oktoast.dart';

///
///  create by zmtzawqlp on 2019/8/22
///
@FFRoute(
    name: "fluttercandies://imageeditor",
    routeName: "image editor",
    description: "crop/rotate image")
class ImageEditorDemo extends StatelessWidget {
  final GlobalKey<ExtendedImageEditorState> editorKey =
      GlobalKey<ExtendedImageEditorState>();
  @override
  Widget build(BuildContext context) {
    return Material(
        child: Column(children: <Widget>[
      AppBar(
        title: Text("image editor demo"),
        actions: <Widget>[
          FlatButton(
            child: Text("Save Crop"),
            onPressed: () {
              _saveCrop();
            },
          )
        ],
      ),
      Expanded(
          child: ExtendedImage.network(
        imageTestUrl,
        fit: BoxFit.contain,
        mode: ExtendedImageMode.Eidt,
        extendedImageEditorKey: editorKey,
        initGestureConfigHandler: (state) {
          return GestureConfig(
              minScale: 1.0,
              animationMinScale: 0.7,
              maxScale: 3.0,
              animationMaxScale: 3.5,
              speed: 1.0,
              inertialSpeed: 100.0,
              initialScale: 1.0,
              inPageView: false);
        },
      ))
    ]));
  }

  void _saveCrop() async {
    var cropRect = editorKey.currentState.crop();
    ui.Image imageData = editorKey.currentState.image;
    if (cropRect.topLeft < Offset.zero ||
        cropRect.size >
            Size(imageData.width.toDouble(), imageData.height.toDouble())) {
      cropRect = Offset.zero &
          Size(imageData.width.toDouble(), imageData.height.toDouble());
      return;
    }

    var data = await imageData.toByteData(format: ui.ImageByteFormat.png);
    image.Image src = decodePng(data.buffer.asUint8List());
    var cropData = copyCrop(src, cropRect.left.toInt(), cropRect.top.toInt(),
        cropRect.width.toInt(), cropRect.height.toInt());

    var fileFath =
        await ImagePickerSaver.saveFile(fileData: encodePng(cropData));

    showToast("$fileFath");
  }
}
