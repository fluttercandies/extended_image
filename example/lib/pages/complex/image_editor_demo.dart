import 'dart:async';

import 'package:example/assets.dart';
import 'package:example/common/image_picker/image_picker.dart';
import 'package:example/common/utils/crop_editor_helper.dart';
import 'package:example/common/widget/change_notifier_builder.dart';
import 'package:example/common/widget/common_widget.dart';
import 'package:extended_image/extended_image.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ruler_picker/flutter_ruler_picker.dart';

import 'package:oktoast/oktoast.dart';
// ignore: implementation_imports
import 'package:oktoast/src/core/toast.dart';
import 'package:url_launcher/url_launcher.dart';

///
///  create by zmtzawqlp on 2019/8/22
///
@FFRoute(
  name: 'fluttercandies://imageeditor',
  routeName: 'ImageEditor',
  description: 'Crop,rotate and flip with image editor.',
  exts: <String, dynamic>{
    'group': 'Complex',
    'order': 1,
  },
)
class ImageEditorDemo extends StatefulWidget {
  @override
  _ImageEditorDemoState createState() => _ImageEditorDemoState();
}

class _ImageEditorDemoState extends State<ImageEditorDemo> {
  // final GlobalKey<ExtendedImageEditorState> editorKey =
  //     GlobalKey<ExtendedImageEditorState>();
  final GlobalKey<PopupMenuButtonState<EditorCropLayerPainter>> popupMenuKey =
      GlobalKey<PopupMenuButtonState<EditorCropLayerPainter>>();
  final List<AspectRatioItem> _aspectRatios = <AspectRatioItem>[
    AspectRatioItem(text: 'custom', value: CropAspectRatios.custom),
    AspectRatioItem(text: 'original', value: CropAspectRatios.original),
    AspectRatioItem(text: '1*1', value: CropAspectRatios.ratio1_1),
    AspectRatioItem(text: '4*3', value: CropAspectRatios.ratio4_3),
    AspectRatioItem(text: '3*4', value: CropAspectRatios.ratio3_4),
    AspectRatioItem(text: '16*9', value: CropAspectRatios.ratio16_9),
    AspectRatioItem(text: '9*16', value: CropAspectRatios.ratio9_16)
  ];

  EdgeInsets cropRectPadding = const EdgeInsets.all(20.0);
  double maxScale = 8.0;

  late ValueNotifier<AspectRatioItem> _aspectRatio;

  bool _cropping = false;
  late ValueNotifier<EditorCropLayerPainter> _cropLayerPainter;
  final ImageEditorController _editorController = ImageEditorController();
  final MyRulerPickerController _rulerPickerController =
      MyRulerPickerController(value: 0.0);

  @override
  void initState() {
    _aspectRatio = ValueNotifier<AspectRatioItem>(_aspectRatios.first);
    _cropLayerPainter =
        ValueNotifier<EditorCropLayerPainter>(const EditorCropLayerPainter());

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;
    late ImageProvider imageProvider;

    if (_memoryImage != null) {
      imageProvider = ExtendedMemoryImageProvider(
        _memoryImage!,
        cacheRawData: true,
      );
    } else {
      imageProvider = const ExtendedAssetImageProvider(
        Assets.assets_harley_quinn_webp,
        cacheRawData: true,
      );
    }
    final ToastTheme toastTheme = ToastTheme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('image editor demo'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.photo_library),
            onPressed: _getImage,
          ),
          IconButton(
            icon: const Icon(Icons.done),
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
      body: SafeArea(
        bottom: true,
        child: Column(
          children: <Widget>[
            Expanded(
              child: ExtendedImage(
                image: imageProvider,
                fit: BoxFit.contain,
                mode: ExtendedImageMode.editor,
                enableLoadState: true,
                // extendedImageEditorKey: editorKey,
                initEditorConfigHandler: (ExtendedImageState? state) {
                  return EditorConfig(
                    maxScale: maxScale,
                    cropRectPadding: cropRectPadding,
                    hitTestSize: 20.0,
                    cropLayerPainter: _cropLayerPainter.value,
                    initCropRectType: InitCropRectType.imageRect,
                    cropAspectRatio: _aspectRatio.value.value,
                    controller: _editorController,
                  );
                },
              ),
            ),
            const Divider(),
            ButtonTheme(
              minWidth: 0.0,
              padding: EdgeInsets.zero,
              child: Row(
                // mainAxisAlignment: MainAxisAlignment.spaceAround,
                // mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  FlatButtonWithIcon(
                    icon: const Icon(Icons.rounded_corner_sharp),
                    label: ValueListenableBuilder<EditorCropLayerPainter>(
                        valueListenable: _cropLayerPainter,
                        builder: (BuildContext context,
                            EditorCropLayerPainter value, Widget? child) {
                          return PopupMenuButton<EditorCropLayerPainter>(
                            key: popupMenuKey,
                            enabled: false,
                            offset: const Offset(100, -300),
                            child: const Text(
                              'Painter',
                              style: TextStyle(fontSize: 8.0),
                            ),
                            initialValue: _cropLayerPainter.value,
                            itemBuilder: (BuildContext context) {
                              return <PopupMenuEntry<EditorCropLayerPainter>>[
                                const PopupMenuItem<EditorCropLayerPainter>(
                                  child: Row(
                                    children: <Widget>[
                                      Icon(
                                        Icons.rounded_corner_sharp,
                                        color: Colors.blue,
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text('Default'),
                                    ],
                                  ),
                                  value: EditorCropLayerPainter(),
                                ),
                                const PopupMenuDivider(),
                                const PopupMenuItem<EditorCropLayerPainter>(
                                  child: Row(
                                    children: <Widget>[
                                      Icon(
                                        Icons.circle,
                                        color: Colors.blue,
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text('Custom'),
                                    ],
                                  ),
                                  value: CustomEditorCropLayerPainter(),
                                ),
                                const PopupMenuDivider(),
                                PopupMenuItem<EditorCropLayerPainter>(
                                  child: Row(
                                    children: <Widget>[
                                      Container(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 3),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.blue,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(25),
                                        ),
                                        width: 20,
                                        height: 20,
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      const Text('Circle'),
                                    ],
                                  ),
                                  value: const CircleEditorCropLayerPainter(),
                                ),
                              ];
                            },
                            onSelected: (EditorCropLayerPainter value) {
                              if (_cropLayerPainter.value != value) {
                                if (value is CircleEditorCropLayerPainter) {
                                  _aspectRatio.value = _aspectRatios[2];
                                }
                                _cropLayerPainter.value = value;
                                _editorController.updateConfig(
                                  _editorController.config.copyWith(
                                    cropLayerPainter: value,
                                    cropAspectRatio: _aspectRatio.value.value,
                                    // maxScale: 4,
                                    // cropRectPadding: const EdgeInsets.all(40),
                                  ),
                                );
                              }
                            },
                          );
                        }),
                    textColor: Colors.white,
                    onPressed: () {
                      popupMenuKey.currentState!.showButtonMenu();
                    },
                  ),
                  ChangeNotifierBuilder(
                    changeNotifier: _editorController,
                    builder: (BuildContext b) {
                      return ButtonTheme(
                        minWidth: 0.0,
                        padding: EdgeInsets.zero,
                        child: Row(children: <Widget>[
                          FlatButtonWithIcon(
                            icon: Icon(
                              Icons.undo,
                              color: _editorController.canUndo
                                  ? primaryColor
                                  : Colors.grey,
                            ),
                            label: Text(
                              'Undo',
                              style: TextStyle(
                                fontSize: 10.0,
                                color: _editorController.canUndo
                                    ? primaryColor
                                    : Colors.grey,
                              ),
                            ),
                            textColor: Colors.white,
                            onPressed: () {
                              _onUndoOrRedo(() {
                                _editorController.undo();
                              });
                            },
                          ),
                          FlatButtonWithIcon(
                            icon: Icon(
                              Icons.redo,
                              color: _editorController.canRedo
                                  ? primaryColor
                                  : Colors.grey,
                            ),
                            label: Text(
                              'Redo',
                              style: TextStyle(
                                fontSize: 10.0,
                                color: _editorController.canRedo
                                    ? primaryColor
                                    : Colors.grey,
                              ),
                            ),
                            textColor: Colors.white,
                            onPressed: () {
                              _onUndoOrRedo(() {
                                _editorController.redo();
                              });
                            },
                          ),
                        ]),
                      );
                    },
                  ),
                  const Spacer(),
                  FlatButtonWithIcon(
                    icon: const Icon(Icons.restore),
                    label: const Text(
                      'Reset',
                      style: TextStyle(fontSize: 10.0),
                    ),
                    textColor: Colors.white,
                    onPressed: () {
                      _rulerPickerController.value = 0;
                      _aspectRatio.value = _aspectRatios.first;
                      _cropLayerPainter.value = const EditorCropLayerPainter();
                      _editorController.reset();
                    },
                  ),
                ],
              ),
            ),
            ButtonTheme(
              minWidth: 0.0,
              padding: EdgeInsets.zero,
              child: Row(
                children: <Widget>[
                  FlatButtonWithIcon(
                    icon: const Icon(Icons.flip),
                    label: const Text(
                      'Flip',
                      style: TextStyle(fontSize: 10.0),
                    ),
                    textColor: Colors.white,
                    onPressed: () {
                      _editorController.flip(
                        animation: true,
                      );
                    },
                  ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (BuildContext c, BoxConstraints b) {
                        return RulerPicker(
                          controller: _rulerPickerController,
                          rulerScaleTextStyle: const TextStyle(
                            color: Color.fromARGB(255, 188, 194, 203),
                            fontSize: 10,
                          ),
                          marker: Transform.translate(
                            offset: const Offset(0, -5),
                            child: Container(
                              width: 2,
                              height: 44,
                              color: primaryColor,
                            ),
                          ),
                          onValueChanged: (num value) {
                            if (_rulerPickerController.value
                                    .toDouble()
                                    .equalTo(value.toDouble()) &&
                                !_onUndoOrRedoing) {
                              return;
                            }
                            HapticFeedback.vibrate();

                            showToastWidget(
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(toastTheme.radius),
                                  color: toastTheme.backgroundColor,
                                ),
                                padding: const EdgeInsets.all(5),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Text(
                                      '$value°',
                                      style: toastTheme.textStyle,
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        dismissAllToast();
                                        _editorController.rotate(
                                          degree: -_rulerPickerController.value
                                              as double,
                                        );
                                        _rulerPickerController.value = 0;
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          color: Colors.white,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.black,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              position: const ToastPosition(
                                align: Alignment.bottomCenter,
                                offset: -180,
                              ),
                              handleTouch: true,
                            );

                            _editorController.rotate(
                              degree: value.toDouble() -
                                  _rulerPickerController.value,
                            );

                            _rulerPickerController.setValueWithOutNotify(value);
                          },
                          width: b.maxWidth,
                          height: 50,
                          onBuildRulerScaleText:
                              (int index, num rulerScaleValue) {
                            return '$rulerScaleValue';
                          },
                          ranges: const <RulerRange>[
                            RulerRange(begin: -45, end: 45, scale: 1),
                          ],
                        );
                      },
                    ),
                  ),
                  FlatButtonWithIcon(
                    icon: const Icon(Icons.rotate_right),
                    label: const Text(
                      'Rotate Right',
                      style: TextStyle(fontSize: 8.0),
                    ),
                    textColor: Colors.white,
                    onPressed: () {
                      _editorController.rotate(
                        degree: 90,
                        animation: true,
                        rotateCropRect: true,
                        // duration: const Duration(
                        //   seconds: 10,
                        // ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Container(
              // color: Colors.black.withOpacity(0.2),
              height: 80,
              child: ValueListenableBuilder<AspectRatioItem>(
                valueListenable: _aspectRatio,
                builder: (BuildContext context, AspectRatioItem value,
                    Widget? child) {
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (_, int index) {
                      final AspectRatioItem item = _aspectRatios[index];
                      return GestureDetector(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: AspectRatioWidget(
                            aspectRatio: item.value,
                            aspectRatioS: item.text,
                            isSelected: item == _aspectRatio.value,
                          ),
                        ),
                        onTap: () {
                          if (_cropLayerPainter
                              is CircleEditorCropLayerPainter) {
                            if (item.value != CropAspectRatios.ratio1_1) {
                              showToast(
                                  'Circle crop only support 1:1 aspect ratio');
                              return;
                            }
                          }

                          _editorController.updateCropAspectRatio(item.value);
                          _aspectRatio.value = item;
                        },
                      );
                    },
                    itemCount: _aspectRatios.length,
                  );
                },
              ),
            ),
          ],
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
                        const Text(
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
                                  style: const TextStyle(
                                      color: Colors.blue,
                                      decorationStyle:
                                          TextDecorationStyle.solid,
                                      decorationColor: Colors.blue,
                                      decoration: TextDecoration.underline),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      launchUrl(Uri.parse(
                                          'https://github.com/brendan-duncan/image'));
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
                                  style: const TextStyle(
                                      color: Colors.blue,
                                      decorationStyle:
                                          TextDecorationStyle.solid,
                                      decorationColor: Colors.blue,
                                      decoration: TextDecoration.underline),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      launchUrl(Uri.parse(
                                          'https://github.com/fluttercandies/flutter_image_editor'));
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
                            OutlinedButton(
                              child: const Text(
                                'Dart',
                                style: TextStyle(
                                  color: Colors.blue,
                                ),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                                _cropImage(false);
                              },
                            ),
                            OutlinedButton(
                              child: const Text(
                                'Native',
                                style: TextStyle(
                                  color: Colors.blue,
                                ),
                              ),
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

  bool _onUndoOrRedoing = false;
  void _onUndoOrRedo(Function fn) {
    final double oldRotateDegrees = _editorController.rotateDegrees;
    final double? oldCropAspectRatio =
        _editorController.originalCropAspectRatio;
    _onUndoOrRedoing = true;
    fn();
    _onUndoOrRedoing = false;
    final double newRotateDegrees = _editorController.rotateDegrees;
    final double? newCropAspectRatio =
        _editorController.originalCropAspectRatio;
    if (oldRotateDegrees != newRotateDegrees &&
        !(newRotateDegrees - oldRotateDegrees).isZero &&
        (newRotateDegrees - oldRotateDegrees) % 90 != 0) {
      _rulerPickerController.value =
          _rulerPickerController.value + (newRotateDegrees - oldRotateDegrees);
    }

    if (oldCropAspectRatio != newCropAspectRatio) {
      if (newCropAspectRatio == null) {
        _aspectRatio.value = _aspectRatios.first;
      } else {
        _aspectRatio.value = _aspectRatios.firstWhere(
          (AspectRatioItem element) => element.value == newCropAspectRatio,
          orElse: () => _aspectRatios.first,
        );
      }
    }

    _cropLayerPainter.value = _editorController.config.cropLayerPainter;
  }

  Future<void> _cropImage(bool useNative) async {
    if (_cropping) {
      return;
    }
    String msg = '';
    try {
      _cropping = true;

      //await showBusyingDialog();

      late EditImageInfo imageInfo;

      /// native library
      if (useNative) {
        imageInfo = await cropImageDataWithNativeLibrary(_editorController);
      } else {
        ///delay due to cropImageDataWithDartLibrary is time consuming on main thread
        ///it will block showBusyingDialog
        ///if you don't want to block ui, use compute/isolate,but it costs more time.
        //await Future.delayed(Duration(milliseconds: 200));

        ///if you don't want to block ui, use compute/isolate,but it costs more time.
        imageInfo = await cropImageDataWithDartLibrary(_editorController);
      }
      final String? filePath = await ImageSaver.save(
          'extended_image_cropped_image.${imageInfo.imageType == ImageType.jpg ? 'jpg' : 'gif'}',
          imageInfo.data!);
      // var filePath = await ImagePickerSaver.saveFile(fileData: fileData);

      msg = 'save image : $filePath';

      showToastWidget(Container(
        color: Colors.black54,
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              msg,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(
              height: 10,
            ),
            Image.memory(
              imageInfo.data!,
              fit: BoxFit.contain,
            )
          ],
        ),
      ));
    } catch (e, stack) {
      msg = 'save failed: $e\n $stack';
      showToast(msg);
      print(msg);
    }

    //Navigator.of(context).pop();

    _cropping = false;
  }

  Uint8List? _memoryImage;
  Future<void> _getImage() async {
    _memoryImage = await pickImage(context);
    //when back to current page, may be editorKey.currentState is not ready.
    Future<void>.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        _rulerPickerController.value = 0;
        _editorController.reset();
      });
    });
  }
}

class CustomEditorCropLayerPainter extends EditorCropLayerPainter {
  const CustomEditorCropLayerPainter();
  @override
  void paintCorners(
      Canvas canvas, Size size, ExtendedImageCropLayerPainter painter) {
    final Paint paint = Paint()
      ..color = painter.cornerColor
      ..style = PaintingStyle.fill;
    final Rect cropRect = painter.cropRect;
    const double radius = 6;
    canvas.drawCircle(Offset(cropRect.left, cropRect.top), radius, paint);
    canvas.drawCircle(Offset(cropRect.right, cropRect.top), radius, paint);
    canvas.drawCircle(Offset(cropRect.left, cropRect.bottom), radius, paint);
    canvas.drawCircle(Offset(cropRect.right, cropRect.bottom), radius, paint);
  }
}

class CircleEditorCropLayerPainter extends EditorCropLayerPainter {
  const CircleEditorCropLayerPainter();

  @override
  void paintCorners(
      Canvas canvas, Size size, ExtendedImageCropLayerPainter painter) {
    // do nothing
  }

  @override
  void paintMask(
      Canvas canvas, Rect rect, ExtendedImageCropLayerPainter painter) {
    final Rect cropRect = painter.cropRect;
    final Color maskColor = painter.maskColor;
    canvas.saveLayer(rect, Paint());
    canvas.drawRect(
        rect,
        Paint()
          ..style = PaintingStyle.fill
          ..color = maskColor);
    canvas.drawCircle(cropRect.center, cropRect.width / 2.0,
        Paint()..blendMode = BlendMode.clear);
    canvas.restore();
  }

  @override
  void paintLines(
      Canvas canvas, Size size, ExtendedImageCropLayerPainter painter) {
    final Rect cropRect = painter.cropRect;
    if (painter.pointerDown) {
      canvas.save();
      canvas.clipPath(Path()..addOval(cropRect));
      super.paintLines(canvas, size, painter);
      canvas.restore();
    }
  }
}

class MyRulerPickerController extends RulerPickerController {
  MyRulerPickerController({num value = 0}) : _value = value;
  @override
  num get value => _value;
  num _value;
  @override
  set value(num newValue) {
    if (_value == newValue) {
      return;
    }
    _value = newValue;
    notifyListeners();
  }

  void setValueWithOutNotify(num newValue) {
    _value = newValue;
  }
}
