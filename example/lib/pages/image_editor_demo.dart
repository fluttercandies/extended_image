import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:example/common/common_widget.dart';
import 'package:example/common/crop_editor_helper.dart';
import 'package:example/common/utils.dart';
import 'package:example/main.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:image_picker_saver/image_picker_saver.dart';
import 'package:oktoast/oktoast.dart';
import 'package:image_picker/image_picker.dart' as picker;
import 'package:url_launcher/url_launcher.dart';

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
    ..add(AspectRatioItem(text: "custom", value: CropAspectRatios.custom))
    ..add(AspectRatioItem(text: "original", value: CropAspectRatios.original))
    ..add(AspectRatioItem(text: "1*1", value: CropAspectRatios.ratio1_1))
    ..add(AspectRatioItem(text: "4*3", value: CropAspectRatios.ratio4_3))
    ..add(AspectRatioItem(text: "3*4", value: CropAspectRatios.ratio3_4))
    ..add(AspectRatioItem(text: "16*9", value: CropAspectRatios.ratio16_9))
    ..add(AspectRatioItem(text: "9*16", value: CropAspectRatios.ratio9_16));
  AspectRatioItem _aspectRatio;
  bool _cropping = false;
  @override
  void initState() {
    _aspectRatio = _aspectRatios.first;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("image editor demo"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.photo_library),
            onPressed: _getImage,
          ),
          IconButton(
            icon: Icon(Icons.done),
            onPressed: () {
              _showCropDialog(context);
            },
          ),
        ],
      ),
      body: Center(
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
                      initCropRectType: InitCropRectType.imageRect,
                      cropAspectRatio: _aspectRatio.value);
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
                      initCropRectType: InitCropRectType.imageRect,
                      cropAspectRatio: _aspectRatio.value);
                },
              ),
      ),
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
                          child: GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3),
                            padding: EdgeInsets.all(20.0),
                            itemBuilder: (_, index) {
                              var item = _aspectRatios[index];
                              return GestureDetector(
                                child: AspectRatioWidget(
                                  aspectRatio: item.value,
                                  aspectRatioS: item.text,
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

  void _showCropDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext content) {
          return Column(
            children: <Widget>[
              Expanded(
                child: Container(),
              ),
              Container(
                  margin: EdgeInsets.all(20.0),
                  child: Material(
                      child: Padding(
                    padding: EdgeInsets.all(15.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "select library to crop",
                          style: TextStyle(
                              fontSize: 24.0, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        Text.rich(TextSpan(children: <TextSpan>[
                          TextSpan(
                            children: <TextSpan>[
                              TextSpan(
                                  text: "Image",
                                  style: TextStyle(
                                      color: Colors.blue,
                                      decorationStyle:
                                          TextDecorationStyle.solid,
                                      decorationColor: Colors.blue,
                                      decoration: TextDecoration.underline),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      launch(
                                          "https://github.com/brendan-duncan/image");
                                    }),
                              TextSpan(
                                  text:
                                      "(Dart library) for decoding/encoding image formats, and image processing. It's stable.")
                            ],
                          ),
                          TextSpan(text: "\n\n"),
                          TextSpan(
                            children: <TextSpan>[
                              TextSpan(
                                  text: "ImageEditor",
                                  style: TextStyle(
                                      color: Colors.blue,
                                      decorationStyle:
                                          TextDecorationStyle.solid,
                                      decorationColor: Colors.blue,
                                      decoration: TextDecoration.underline),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      launch(
                                          "https://github.com/fluttercandies/flutter_image_editor");
                                    }),
                              TextSpan(
                                  text:
                                      "(Native library) support android/ios, crop flip rotate. It's faster.")
                            ],
                          )
                        ])),
                        SizedBox(
                          height: 20.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            OutlineButton(
                              child: Text(
                                'Dart',
                                style: TextStyle(
                                  color: Colors.blue,
                                ),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                                _cropImage(false);
                              },
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0)),
                            ),
                            OutlineButton(
                              child: Text(
                                'Native',
                                style: TextStyle(
                                  color: Colors.blue,
                                ),
                              ),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0)),
                              onPressed: () {
                                Navigator.of(context).pop();
                                _cropImage(true);
                              },
                            ),
                          ],
                        )
                      ],
                    ),
                  ))),
              Expanded(
                child: Container(),
              )
            ],
          );
        });
  }

  void _cropImage(bool useNative) async {
    if (_cropping) return;
    var msg = "";
    try {
      _cropping = true;

      showBusyingDialog();

      Uint8List fileData;

      /// native library
      if (useNative) {
        fileData =
            await cropImageDataWithNativeLibrary(state: editorKey.currentState);
      } else {
        ///delay due to cropImageDataWithDartLibrary is time consuming on main thread
        ///it will block showBusyingDialog
        ///if you don't want to block ui, use compute/isolate,but it costs more time.
        //await Future.delayed(Duration(milliseconds: 200));

        ///if you don't want to block ui, use compute/isolate,but it costs more time.
        fileData =
            await cropImageDataWithDartLibrary(state: editorKey.currentState);
      }

      var fileFath = await ImagePickerSaver.saveFile(fileData: fileData);

      msg = "save image : $fileFath";
    } catch (e) {
      msg = "save faild: $e";
      print(msg);
    }

    Navigator.of(context).pop();
    showToast(msg);
    _cropping = false;
  }

  File _fileImage;
  void _getImage() async {
    var image =
        await picker.ImagePicker.pickImage(source: picker.ImageSource.gallery);

    setState(() {
      editorKey.currentState.reset();
      _fileImage = image;
    });
  }

  Future showBusyingDialog() async {
    var primaryColor = Theme.of(context).primaryColor;
    return showDialog(
        context: context,
        barrierDismissible: false,
        child: Material(
          color: Colors.transparent,
          child: Container(
            height: double.infinity,
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircularProgressIndicator(
                  strokeWidth: 2.0,
                  valueColor: AlwaysStoppedAnimation(primaryColor),
                ),
                SizedBox(
                  width: 10.0,
                ),
                Text(
                  "cropping...",
                  style: TextStyle(color: primaryColor),
                )
              ],
            ),
          ),
        ));
  }
}
