import 'dart:io';

import 'package:example/common/common_widget.dart';
import 'package:example/common/utils.dart';
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
import 'package:image_picker/image_picker.dart' as picker;

///
///  create by zmtzawqlp on 2019/8/22
///
@FFRoute(
    name: "fluttercandies://imageeditor",
    routeName: "image editor",
    description: "crop,rotate and flip with image editor")
class ImageEditorDemo extends StatefulWidget {
  @override
  _ImageEditorDemoState createState() => _ImageEditorDemoState();
}

class _ImageEditorDemoState extends State<ImageEditorDemo> {
  final GlobalKey<ExtendedImageEditorState> editorKey =
      GlobalKey<ExtendedImageEditorState>();
  List<AspectRatioItem> _aspectRatios = List<AspectRatioItem>()
    ..add(AspectRatioItem(aspectRatioS: "custom", aspectRatio: null))
    ..add(AspectRatioItem(aspectRatioS: "original", aspectRatio: -1.0))
    ..add(AspectRatioItem(
        aspectRatioS: "1*1", aspectRatio: CropAspectRatios.ratio1_1))
    ..add(AspectRatioItem(
        aspectRatioS: "4*3", aspectRatio: CropAspectRatios.ratio4_3))
    ..add(AspectRatioItem(
        aspectRatioS: "3*4", aspectRatio: CropAspectRatios.ratio3_4))
    ..add(AspectRatioItem(
        aspectRatioS: "16*9", aspectRatio: CropAspectRatios.ratio16_9))
    ..add(AspectRatioItem(
        aspectRatioS: "9*16", aspectRatio: CropAspectRatios.ratio9_16));
  AspectRatioItem _aspectRatio;
  @override
  void initState() {
    _aspectRatio = _aspectRatios.first;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: <Widget>[
        AppBar(
          title: Text("image editor demo"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.photo_library),
              onPressed: _getImage,
            ),
            IconButton(
              icon: Icon(Icons.done),
              onPressed: _save,
            ),
          ],
        ),
        Expanded(
            child: _fileImage != null
                ? ExtendedImage.file(
                    _fileImage,
                    fit: BoxFit.contain,
                    mode: ExtendedImageMode.editor,
                    enableLoadState: true,
                    extendedImageEditorKey: editorKey,
                    initEditorConfigHandler: (state) {
                      return EditorConfig(
                          maxScale: 8.0,
                          cropRectPadding: EdgeInsets.all(20.0),
                          hitTestSize: 20.0,
                          cropAspectRatio: _aspectRatio.aspectRatio);
                    },
                  )
                : ExtendedImage.network(
                    imageTestUrl,
                    fit: BoxFit.contain,
                    mode: ExtendedImageMode.editor,
                    extendedImageEditorKey: editorKey,
                    initEditorConfigHandler: (state) {
                      return EditorConfig(
                          maxScale: 8.0,
                          cropRectPadding: EdgeInsets.all(20.0),
                          hitTestSize: 20.0,
                          cropAspectRatio: _aspectRatio.aspectRatio);
                    },
                  )),
      ]),
      bottomNavigationBar: BottomAppBar(
        color: Colors.lightBlue,
        shape: CircularNotchedRectangle(),
        child: ButtonTheme(
          minWidth: 0.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              FlatButtonWithIcon(
                icon: Icon(Icons.crop),
                label: Text(
                  "Crop",
                  style: TextStyle(fontSize: 10.0),
                ),
                textColor: Colors.white,
                onPressed: () {
                  showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return Container(
                          height: 60.0,
                          color: Colors.lightBlue,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (_, index) {
                              var item = _aspectRatios[index];
                              return GestureDetector(
                                child: AspectRatioWidget(
                                  aspectRatio: item.aspectRatio,
                                  aspectRatioS: item.aspectRatioS,
                                  isSelected: item == _aspectRatio,
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  setState(() {
                                    _aspectRatio = item;
                                  });
                                },
                              );
                            },
                            itemCount: _aspectRatios.length,
                          ),
                        );
                      });
                },
              ),
              FlatButtonWithIcon(
                icon: Icon(Icons.flip),
                label: Text(
                  "Flip",
                  style: TextStyle(fontSize: 10.0),
                ),
                textColor: Colors.white,
                onPressed: () {
                  editorKey.currentState.flip();
                },
              ),
              FlatButtonWithIcon(
                icon: Icon(Icons.rotate_left),
                label: Text(
                  "Rotate Left",
                  style: TextStyle(fontSize: 8.0),
                ),
                textColor: Colors.white,
                onPressed: () {
                  editorKey.currentState.rotate(right: false);
                },
              ),
              FlatButtonWithIcon(
                icon: Icon(Icons.rotate_right),
                label: Text(
                  "Rotate Right",
                  style: TextStyle(fontSize: 8.0),
                ),
                textColor: Colors.white,
                onPressed: () {
                  editorKey.currentState.rotate(right: true);
                },
              ),
              FlatButtonWithIcon(
                icon: Icon(Icons.restore),
                label: Text(
                  "Reset",
                  style: TextStyle(fontSize: 10.0),
                ),
                textColor: Colors.white,
                onPressed: () {
                  editorKey.currentState.reset();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _save() async {
    try {
      var cropRect = editorKey.currentState.getCropRect();
      ui.Image imageData = editorKey.currentState.image;
  
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
      showToast("save image : $fileFath");
    } catch (e) {
      showToast("save faild: $e");
    }
  }

  File _fileImage;
  void _getImage() async {
    var image =
        await picker.ImagePicker.pickImage(source: picker.ImageSource.gallery);

    setState(() {
      _fileImage = image;
    });
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
