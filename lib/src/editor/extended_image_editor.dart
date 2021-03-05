import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:extended_image/src/extended_image.dart';
import 'package:extended_image/src/extended_image_utils.dart';
import 'package:extended_image/src/image/extended_raw_image.dart';
import 'package:extended_image_library/extended_image_library.dart';

import 'extended_image_crop_layer.dart';
import 'extended_image_editor_utils.dart';

///
///  create by zmtzawqlp on 2019/8/22
///

class ExtendedImageEditor extends StatefulWidget {
  ExtendedImageEditor({
    Key? key,
    required this.extendedImageState,
  })   : assert(
          extendedImageState.imageWidget.fit == BoxFit.contain,
          'Make sure the image is all painted to crop, '
          'the fit of image must be BoxFit.contain',
        ),
        assert(
          extendedImageState.imageWidget.image is ExtendedImageProvider,
          'Make sure the image provider is ExtendedImageProvider, '
          'we will get raw image data from it',
        ),
        super(key: key);

  final ExtendedImageState extendedImageState;

  @override
  ExtendedImageEditorState createState() => ExtendedImageEditorState();
}

class ExtendedImageEditorState extends State<ExtendedImageEditor> {
  final GlobalKey<ExtendedImageCropLayerState> _layerKey =
      GlobalKey<ExtendedImageCropLayerState>();

  EditActionDetails? _editActionDetails;

  EditActionDetails get editAction => _editActionDetails!;

  ui.Image? get image => widget.extendedImageState.extendedImageInfo?.image;

  Uint8List? get rawImageData =>
      // ignore: always_specify_types
      (widget.extendedImageState.imageWidget.image as ExtendedImageProvider)
          .rawImageData;

  late EditorConfig _editorConfig;
  late double _startingScale;
  late Offset _startingOffset;
  double _detailsScale = 1.0;

  @override
  void initState() {
    super.initState();
    _initGestureConfig();
  }

  void _initGestureConfig() {
    _editorConfig = widget
            .extendedImageState.imageWidget.initEditorConfigHandler
            ?.call(widget.extendedImageState) ??
        EditorConfig();
    final double? cropAspectRatio = _editorConfig.cropAspectRatio;
    if (cropAspectRatio != _editorConfig.cropAspectRatio) {
      _editActionDetails = null;
    }

    _editActionDetails ??= EditActionDetails()
      ..delta = Offset.zero
      ..totalScale = 1.0
      ..preTotalScale = 1.0
      ..cropRectPadding = _editorConfig.cropRectPadding;

    if (image != null) {
      editAction.originalAspectRatio = image!.width / image!.height;
    }
    editAction.cropAspectRatio = _editorConfig.cropAspectRatio;
    if (_editorConfig.cropAspectRatio != null &&
        _editorConfig.cropAspectRatio! <= 0) {
      editAction.cropAspectRatio = editAction.originalAspectRatio;
    }
  }

  @override
  void didUpdateWidget(ExtendedImageEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    _initGestureConfig();
  }

  @override
  Widget build(BuildContext context) {
    final ExtendedImage extendedImage = widget.extendedImageState.imageWidget;
    final Widget child = ExtendedRawImage(
      image: image,
      width: extendedImage.width,
      height: extendedImage.height,
      scale: widget.extendedImageState.extendedImageInfo?.scale ?? 1.0,
      color: extendedImage.color,
      colorBlendMode: extendedImage.colorBlendMode,
      fit: extendedImage.fit,
      alignment: extendedImage.alignment,
      repeat: extendedImage.repeat,
      centerSlice: extendedImage.centerSlice,
      //matchTextDirection: extendedImage.matchTextDirection,
      //don't support TextDirection for editor
      matchTextDirection: false,
      invertColors: widget.extendedImageState.invertColors,
      filterQuality: extendedImage.filterQuality,
      editActionDetails: _editActionDetails,
    );

    Widget result = GestureDetector(
      onScaleStart: _handleScaleStart,
      onScaleUpdate: _handleScaleUpdate,
      behavior: _editorConfig.hitTestBehavior,
      child: Stack(
        children: <Widget>[
          Positioned.fill(child: child),
          Positioned.fill(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                Rect layoutRect = Offset.zero &
                    Size(constraints.maxWidth, constraints.maxHeight);
                final EdgeInsets? padding = _editorConfig.cropRectPadding;
                if (padding != null) {
                  layoutRect = padding.deflateRect(layoutRect);
                }
                if (editAction.cropRect == null) {
                  final Rect destinationRect = getDestinationRect(
                    rect: layoutRect,
                    inputSize: Size(
                      image!.width.toDouble(),
                      image!.height.toDouble(),
                    ),
                    flipHorizontally: false,
                    fit: widget.extendedImageState.imageWidget.fit,
                    centerSlice:
                        widget.extendedImageState.imageWidget.centerSlice,
                    alignment: widget.extendedImageState.imageWidget.alignment,
                    scale: widget.extendedImageState.extendedImageInfo!.scale,
                  );

                  Rect cropRect = _initCropRect(destinationRect);
                  if (_editorConfig.initCropRectType ==
                          InitCropRectType.layoutRect &&
                      _editorConfig.cropAspectRatio != null &&
                      _editorConfig.cropAspectRatio! > 0) {
                    final Rect rect = _initCropRect(layoutRect);
                    editAction.totalScale = editAction
                        .preTotalScale = doubleCompare(
                                destinationRect.width, destinationRect.height) >
                            0
                        ? rect.height / cropRect.height
                        : rect.width / cropRect.width;
                    cropRect = rect;
                  }
                  editAction.cropRect = cropRect;
                }

                return ExtendedImageCropLayer(
                  key: _layerKey,
                  layoutRect: layoutRect,
                  editActionDetails: editAction,
                  editorConfig: _editorConfig,
                  fit: widget.extendedImageState.imageWidget.fit,
                );
              },
            ),
          ),
        ],
      ),
    );
    result = Listener(
      behavior: _editorConfig.hitTestBehavior,
      onPointerDown: (_) {
        _layerKey.currentState?.pointerDown(true);
      },
      onPointerUp: (_) {
        _layerKey.currentState?.pointerDown(false);
      },
      onPointerSignal: _handlePointerSignal,
      // onPointerCancel: (_) {
      //   pointerDown(false);
      // },
      child: result,
    );
    return result;
  }

  Rect _initCropRect(Rect rect) {
    Rect cropRect = editAction.getRectWithScale(rect);

    if (editAction.cropAspectRatio != null) {
      final double aspectRatio = editAction.cropAspectRatio!;
      double width = cropRect.width / aspectRatio;
      final double height = min(cropRect.height, width);
      width = height * aspectRatio;
      cropRect = Rect.fromCenter(
        center: cropRect.center,
        width: width,
        height: height,
      );
    }
    return cropRect;
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _layerKey.currentState?.pointerDown(true);
    _startingOffset = details.focalPoint;
    editAction.screenFocalPoint = details.focalPoint;
    _startingScale = editAction.totalScale;
    _detailsScale = 1.0;
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    _layerKey.currentState?.pointerDown(true);
    if (_layerKey.currentState!.isAnimating ||
        _layerKey.currentState!.isMoving) {
      return;
    }
    double totalScale = _startingScale * details.scale * _editorConfig.speed;
    final Offset delta =
        details.focalPoint * _editorConfig.speed - _startingOffset;
    final double scaleDelta = details.scale / _detailsScale;
    final bool zoomOut = scaleDelta < 1;
    final bool zoomIn = scaleDelta > 1;

    _detailsScale = details.scale;

    _startingOffset = details.focalPoint;
    //no more zoom
    if ((editAction.reachCropRectEdge && zoomOut) ||
        doubleEqual(editAction.totalScale, _editorConfig.maxScale) && zoomIn) {
      //correct _startingScale
      //details.scale was not calculated at the moment
      _startingScale = editAction.totalScale / details.scale;
      return;
    }

    totalScale = min(totalScale, _editorConfig.maxScale);

    if (mounted && (scaleDelta != 1.0 || delta != Offset.zero)) {
      setState(() {
        editAction.totalScale = totalScale;

        ///if we have shift offset, we should clear delta.
        ///we should += delta in case miss delta
        editAction.delta += delta;
        _editorConfig.editActionDetailsIsChanged?.call(_editActionDetails);
      });
    }
  }

  void _handlePointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent && event.kind == PointerDeviceKind.mouse) {
      _handleScaleStart(ScaleStartDetails(focalPoint: event.position));
      final double dy = event.scrollDelta.dy;
      final double dx = event.scrollDelta.dx;
      _handleScaleUpdate(
        ScaleUpdateDetails(
          focalPoint: event.position,
          scale: 1.0 +
              (dy.abs() > dx.abs() ? dy : dx) * _editorConfig.speed / 1000.0,
        ),
      );
    }
  }

  Rect? getCropRect() {
    if (widget.extendedImageState.extendedImageInfo?.image == null) {
      return null;
    }

    Rect cropScreen = editAction.screenCropRect!;
    Rect imageScreenRect = editAction.screenDestinationRect!;
    imageScreenRect = editAction.paintRect(imageScreenRect);
    cropScreen = editAction.paintRect(cropScreen);

    //move to zero
    cropScreen = cropScreen.shift(-imageScreenRect.topLeft);

    imageScreenRect = imageScreenRect.shift(-imageScreenRect.topLeft);

    final ui.Image _image = image!;
    // var size = _editActionDetails.isHalfPi
    //     ? Size(image.height.toDouble(), image.width.toDouble())
    //     : Size(image.width.toDouble(), image.height.toDouble());
    final Rect imageRect =
        Offset.zero & Size(_image.width.toDouble(), _image.height.toDouble());

    final double ratioX = imageRect.width / imageScreenRect.width;
    final double ratioY = imageRect.height / imageScreenRect.height;

    final Rect cropImageRect = Rect.fromLTWH(
      cropScreen.left * ratioX,
      cropScreen.top * ratioY,
      cropScreen.width * ratioX,
      cropScreen.height * ratioY,
    );
    return cropImageRect;
  }

  void rotate({bool right = true}) {
    setState(() {
      editAction.rotate(
        right ? pi / 2.0 : -pi / 2.0,
        _layerKey.currentState!.layoutRect,
        widget.extendedImageState.imageWidget.fit,
      );
      _editorConfig.editActionDetailsIsChanged?.call(_editActionDetails);
    });
  }

  void flip() {
    setState(() {
      editAction.flip();
      _editorConfig.editActionDetailsIsChanged?.call(_editActionDetails);
    });
  }

  void reset() {
    setState(() {
      _editActionDetails = null;
      _initGestureConfig();
      _editorConfig.editActionDetailsIsChanged?.call(_editActionDetails);
    });
  }
}
