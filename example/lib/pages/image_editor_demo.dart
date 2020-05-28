import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:example/common/common_widget.dart';
import 'package:example/common/crop_editor_helper.dart';
import 'package:example/common/image_picker/image_picker.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:flutter_candies_demo_library/flutter_candies_demo_library.dart';
import 'package:oktoast/oktoast.dart';
import 'package:url_launcher/url_launcher.dart';

///
///  create by zmtzawqlp on 2019/8/22
///
@FFRoute(
    name: 'fluttercandies://imageeditor',
    routeName: 'image editor',
    description: 'crop,rotate and flip with image editor')
class ImageEditorDemo extends StatefulWidget {
  @override
  _ImageEditorDemoState createState() => _ImageEditorDemoState();
}

class _ImageEditorDemoState extends State<ImageEditorDemo> {
  final GlobalKey<ExtendedImageEditorState> editorKey =
      GlobalKey<ExtendedImageEditorState>();
  final List<AspectRatioItem> _aspectRatios = <AspectRatioItem>[
    AspectRatioItem(text: 'custom', value: CropAspectRatios.custom),
    AspectRatioItem(text: 'original', value: CropAspectRatios.original),
    AspectRatioItem(text: '1*1', value: CropAspectRatios.ratio1_1),
    AspectRatioItem(text: '4*3', value: CropAspectRatios.ratio4_3),
    AspectRatioItem(text: '3*4', value: CropAspectRatios.ratio3_4),
    AspectRatioItem(text: '16*9', value: CropAspectRatios.ratio16_9),
    AspectRatioItem(text: '9*16', value: CropAspectRatios.ratio9_16)
  ];
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
        title: const Text('image editor demo'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.photo_library),
            onPressed: _getImage,
          ),
          IconButton(
            icon: Icon(Icons.done),
            onPressed: () {
              if (kIsWeb) {
                _cropImage(false);
              } else {
                _showCropDialog(context);
              }
            },
          ),
        ],
      ),
      body: Center(
        child: _memoryImage != null
            ? ExtendedImage.memory(
                _memoryImage,
                fit: BoxFit.contain,
                mode: ExtendedImageMode.editor,
                enableLoadState: true,
                extendedImageEditorKey: editorKey,
                initEditorConfigHandler: (ExtendedImageState state) {
                  return EditorConfig(
                      maxScale: 8.0,
                      cropRectPadding: const EdgeInsets.all(20.0),
                      hitTestSize: 20.0,
                      initCropRectType: InitCropRectType.imageRect,
                      cropAspectRatio: _aspectRatio.value);
                },
              )
            : ExtendedImage.asset(
                'assets/image.jpg',
                fit: BoxFit.contain,
                mode: ExtendedImageMode.editor,
                enableLoadState: true,
                extendedImageEditorKey: editorKey,
                initEditorConfigHandler: (ExtendedImageState state) {
                  return EditorConfig(
                      maxScale: 8.0,
                      cropRectPadding: const EdgeInsets.all(20.0),
                      hitTestSize: 20.0,
                      initCropRectType: InitCropRectType.imageRect,
                      cropAspectRatio: _aspectRatio.value);
                },
              ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.lightBlue,
        shape: const CircularNotchedRectangle(),
        child: ButtonTheme(
          minWidth: 0.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              FlatButtonWithIcon(
                icon: Icon(Icons.crop),
                label: const Text(
                  'Crop',
                  style: TextStyle(fontSize: 10.0),
                ),
                textColor: Colors.white,
                onPressed: () {
                  showDialog<void>(
                      context: context,
                      builder: (BuildContext context) {
                        return Column(
                          children: <Widget>[
                            const Expanded(
                              child: SizedBox(),
                            ),
                            SizedBox(
                              height: ScreenUtil.instance.setWidth(200.0),
                              child: ListView.builder(
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.all(20.0),
                                itemBuilder: (_, int index) {
                                  final AspectRatioItem item =
                                      _aspectRatios[index];
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
                            ),
                          ],
                        );
                      });
                },
              ),
              FlatButtonWithIcon(
                icon: Icon(Icons.flip),
                label: const Text(
                  'Flip',
                  style: TextStyle(fontSize: 10.0),
                ),
                textColor: Colors.white,
                onPressed: () {
                  editorKey.currentState.flip();
                },
              ),
              FlatButtonWithIcon(
                icon: Icon(Icons.rotate_left),
                label: const Text(
                  'Rotate Left',
                  style: TextStyle(fontSize: 8.0),
                ),
                textColor: Colors.white,
                onPressed: () {
                  editorKey.currentState.rotate(right: false);
                },
              ),
              FlatButtonWithIcon(
                icon: Icon(Icons.rotate_right),
                label: const Text(
                  'Rotate Right',
                  style: TextStyle(fontSize: 8.0),
                ),
                textColor: Colors.white,
                onPressed: () {
                  editorKey.currentState.rotate(right: true);
                },
              ),
              FlatButtonWithIcon(
                icon: Icon(Icons.restore),
                label: const Text(
                  'Reset',
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
    showDialog<void>(
        context: context,
        builder: (BuildContext content) {
          return Column(
            children: <Widget>[
              Expanded(
                child: Container(),
              ),
              Container(
                  margin: const EdgeInsets.all(20.0),
                  child: Material(
                      child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'select library to crop',
                          style: TextStyle(
                              fontSize: 24.0, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        Text.rich(TextSpan(children: <TextSpan>[
                          TextSpan(
                            children: <TextSpan>[
                              TextSpan(
                                  text: 'Image',
                                  style: TextStyle(
                                      color: Colors.blue,
                                      decorationStyle:
                                          TextDecorationStyle.solid,
                                      decorationColor: Colors.blue,
                                      decoration: TextDecoration.underline),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      launch(
                                          'https://github.com/brendan-duncan/image');
                                    }),
                              const TextSpan(
                                  text:
                                      '(Dart library) for decoding/encoding image formats, and image processing. It\'s stable.')
                            ],
                          ),
                          const TextSpan(text: '\n\n'),
                          TextSpan(
                            children: <TextSpan>[
                              TextSpan(
                                  text: 'ImageEditor',
                                  style: TextStyle(
                                      color: Colors.blue,
                                      decorationStyle:
                                          TextDecorationStyle.solid,
                                      decorationColor: Colors.blue,
                                      decoration: TextDecoration.underline),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      launch(
                                          'https://github.com/fluttercandies/flutter_image_editor');
                                    }),
                              const TextSpan(
                                  text:
                                      '(Native library) support android/ios, crop flip rotate. It\'s faster.')
                            ],
                          )
                        ])),
                        const SizedBox(
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

  Future<void> _cropImage(bool useNative) async {
    if (_cropping) {
      return;
    }
    String msg = '';
    try {
      _cropping = true;

      //await showBusyingDialog();

      Uint8List fileData;

      /// native library
      if (useNative) {
        fileData =
            Uint8List.fromList(await cropImageDataWithNativeLibrary(state: editorKey.currentState));
      } else {
        ///delay due to cropImageDataWithDartLibrary is time consuming on main thread
        ///it will block showBusyingDialog
        ///if you don't want to block ui, use compute/isolate,but it costs more time.
        //await Future.delayed(Duration(milliseconds: 200));

        ///if you don't want to block ui, use compute/isolate,but it costs more time.
        fileData =
             Uint8List.fromList(await cropImageDataWithDartLibrary(state: editorKey.currentState));
      }
      final String fileFath =
          await ImageSaver.save('extended_image_cropped_image.jpg', fileData);
      // var fileFath = await ImagePickerSaver.saveFile(fileData: fileData);

      msg = 'save image : $fileFath';
    } catch (e, stack) {
      msg = 'save faild: $e\n $stack';
      print(msg);
    }

    //Navigator.of(context).pop();
    showToast(msg);
    _cropping = false;
  }

  Uint8List _memoryImage;
  Future<void> _getImage() async {
    _memoryImage = await pickImage(context);
    setState(() {
      editorKey.currentState.reset();
    });
  }
}
