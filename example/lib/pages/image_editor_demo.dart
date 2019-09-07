import 'package:example/main.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:image/image.dart';
import 'package:image/image.dart' as image;
import 'dart:ui' as ui;
import 'dart:math';
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
    return Scaffold(
      body: Column(children: <Widget>[
        AppBar(
          title: Text("image editor demo"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.done),
              onPressed: _save,
            ),
          ],
        ),
        Expanded(
            child: ExtendedImage.network(
          "https://photo.tuchong.com/4870004/f/298584322.jpg" ?? imageTestUrl,
          fit: BoxFit.contain,
          mode: ExtendedImageMode.Eidt,
          extendedImageEditorKey: editorKey,
          initEidtConfigHandler: (state) {
            return EditConfig(
                minScale: 0.0,
                maxScale: 3.0,
                initialScale: 0.9,);
          },
        )),
      ]),
      // floatingActionButton: FloatingActionButton(
      //     onPressed: (){},
      //     child: Icon(
      //       Icons.done,
      //       color: Colors.white,
      //     )),
      // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomAppBar(
        color: Colors.lightBlue,
        shape: CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.flip),
              color: Colors.white,
              onPressed: () {
                editorKey.currentState.flip();
              },
            ),
            IconButton(
              icon: Icon(Icons.rotate_left),
              color: Colors.white,
              onPressed: () {
                editorKey.currentState.rotate(right: false);
              },
            ),
            IconButton(
              icon: Icon(Icons.rotate_right),
              color: Colors.white,
              onPressed: () {
                editorKey.currentState.rotate(right: true);
              },
            ),
            IconButton(
              icon: Icon(Icons.restore),
              color: Colors.white,
              onPressed: () {
                editorKey.currentState.reset();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _save() async {
    var cropRect = editorKey.currentState.getCropRect();
    ui.Image imageData = editorKey.currentState.image;
    // if (cropRect.topLeft < Offset.zero ||
    //     cropRect.size >
    //         Size(imageData.width.toDouble(), imageData.height.toDouble())) {
    //   cropRect = Offset.zero &
    //       Size(imageData.width.toDouble(), imageData.height.toDouble());
    //   return;
    // }

    var data = await imageData.toByteData(format: ui.ImageByteFormat.png);
    image.Image src = decodePng(data.buffer.asUint8List());

    if (editorKey.currentState.editAction.hasEditAction) {
      var editAction = editorKey.currentState.editAction;
      src = copyFlip(src, flipX: editAction.flipX, flipY: editAction.flipY);
      if (editAction.hasRotateAngle) {
        double angle = (editAction.rotateAngle ~/ (pi / 2)) * 90.0;
        src = copyRotate(src, angle);
      }
    }

    var cropData = copyCrop(src, cropRect.left.toInt(), cropRect.top.toInt(),
        cropRect.width.toInt(), cropRect.height.toInt());

    var fileFath =
        await ImagePickerSaver.saveFile(fileData: encodePng(cropData));

    showToast("$fileFath");
  }
}

image.Image copyFlip(image.Image src,
    {bool flipX = false, bool flipY = false}) {
  if (!flipX && !flipY) return src;

  image.Image dst = image.Image(src.width, src.height,
      channels: src.channels, exif: src.exif, iccp: src.iccProfile);

  for (int yi = 0; yi < src.height; ++yi,) {
    for (int xi = 0; xi < src.width; ++xi,) {
      var sx = flipY ? src.width - 1 - xi : xi;
      var sy = flipX ? src.height - 1 - yi : yi;
      dst.setPixel(xi, yi, src.getPixel(sx, sy));
    }
  }

  return dst;
}
