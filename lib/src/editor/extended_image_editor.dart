import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:extended_image/src/extended_image_utils.dart';
import 'package:extended_image/src/image/extended_raw_image.dart';
import 'package:extended_image_library/extended_image_library.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../extended_image.dart';
import 'extended_image_crop_layer.dart';

import 'extended_image_editor_utils.dart';

///
///  create by zmtzawqlp on 2019/8/22
///

class ExtendedImageEditor extends StatefulWidget {
  ExtendedImageEditor({this.extendedImageState, Key key})
      : assert(extendedImageState.imageWidget.fit == BoxFit.contain,
            'Make sure the image is all painted to crop,the fit of image must be BoxFit.contain'),
        assert(extendedImageState.imageWidget.image is ExtendedImageProvider,
            'Make sure the image provider is ExtendedImageProvider, we will get raw image data from it'),
        super(key: key);
  final ExtendedImageState extendedImageState;
  @override
  ExtendedImageEditorState createState() => ExtendedImageEditorState();
}

class ExtendedImageEditorState extends State<ExtendedImageEditor> {
  EditActionDetails _editActionDetails;
  EditorConfig _editorConfig;
  double _startingScale;
  Offset _startingOffset;
  final GlobalKey<ExtendedImageCropLayerState> _layerKey =
      GlobalKey<ExtendedImageCropLayerState>();
  @override
  void initState() {
    _initGestureConfig();

    super.initState();
  }

  void _initGestureConfig() {
    final double initialScale = _editorConfig?.initialScale;
    final double cropAspectRatio = _editorConfig?.cropAspectRatio;
    _editorConfig = widget
            ?.extendedImageState?.imageWidget?.initEditorConfigHandler
            ?.call(widget.extendedImageState) ??
        EditorConfig();
    if (cropAspectRatio != _editorConfig.cropAspectRatio) {
      _editActionDetails = null;
    }

    if (_editActionDetails == null ||
        initialScale != _editorConfig.initialScale) {
      _editActionDetails = EditActionDetails()
        ..delta = Offset.zero
        ..totalScale = _editorConfig.initialScale
        ..preTotalScale = _editorConfig.initialScale
        ..cropRectPadding = _editorConfig.cropRectPadding;
    }

    if (widget.extendedImageState?.extendedImageInfo?.image != null) {
      _editActionDetails.originalAspectRatio =
          widget.extendedImageState.extendedImageInfo.image.width /
              widget.extendedImageState.extendedImageInfo.image.height;
    }
    _editActionDetails.cropAspectRatio = _editorConfig.cropAspectRatio;
    if (_editorConfig.cropAspectRatio != null &&
        _editorConfig.cropAspectRatio <= 0) {
      _editActionDetails.cropAspectRatio =
          _editActionDetails.originalAspectRatio;
    }
  }

  @override
  void didUpdateWidget(ExtendedImageEditor oldWidget) {
    _initGestureConfig();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final ExtendedImage extendedImage = widget.extendedImageState.imageWidget;
    final Widget image = ExtendedRawImage(
      image: widget.extendedImageState.extendedImageInfo?.image,
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
        behavior: HitTestBehavior.translucent,
        child: Stack(
          overflow: Overflow.clip,
          children: <Widget>[
            Positioned(
              child: image,
              top: 0.0,
              left: 0.0,
              bottom: 0.0,
              right: 0.0,
            ),
            Positioned(
              child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                Rect layoutRect = Offset.zero &
                    Size(constraints.maxWidth, constraints.maxHeight);
                final EdgeInsets padding = _editorConfig.cropRectPadding;
                if (padding != null) {
                  layoutRect = padding.deflateRect(layoutRect);
                }
                if (_editActionDetails.cropRect == null) {
                  final Rect destinationRect = getDestinationRect(
                      rect: layoutRect,
                      inputSize: Size(
                          widget
                              .extendedImageState.extendedImageInfo.image.width
                              .toDouble(),
                          widget
                              .extendedImageState.extendedImageInfo.image.height
                              .toDouble()),
                      flipHorizontally: false,
                      fit: widget.extendedImageState.imageWidget.fit,
                      centerSlice:
                          widget.extendedImageState.imageWidget.centerSlice,
                      alignment:
                          widget.extendedImageState.imageWidget.alignment,
                      scale: widget.extendedImageState.extendedImageInfo.scale);

                  Rect cropRect = _initCropRect(destinationRect);
                  if (_editorConfig.initCropRectType ==
                          InitCropRectType.layoutRect &&
                      _editorConfig.cropAspectRatio != null &&
                      _editorConfig.cropAspectRatio > 0) {
                    final Rect rect = _initCropRect(layoutRect);
                    _editActionDetails.totalScale = _editActionDetails
                        .preTotalScale = doubleCompare(
                                destinationRect.width, destinationRect.height) >
                            0
                        ? rect.height / cropRect.height
                        : rect.width / cropRect.width;
                    cropRect = rect;
                  }
                  _editActionDetails.cropRect = cropRect;
                }

                return ExtendedImageCropLayer(
                  key: _layerKey,
                  layoutRect: layoutRect,
                  editActionDetails: _editActionDetails,
                  editorConfig: _editorConfig,
                  fit: widget.extendedImageState.imageWidget.fit,
                );
              }),
              top: 0.0,
              left: 0.0,
              bottom: 0.0,
              right: 0.0,
            ),
          ],
        ));
    result = Listener(
      child: result,
      onPointerDown: (_) {
        _layerKey.currentState.pointerDown(true);
      },
      onPointerUp: (_) {
        _layerKey.currentState.pointerDown(false);
      },
      // onPointerCancel: (_) {
      //   pointerDown(false);
      // },
    );
    return result;
  }

  Rect _initCropRect(Rect rect) {
    Rect cropRect = _editActionDetails.getRectWithScale(rect);

    if (_editActionDetails.cropAspectRatio != null) {
      final double aspectRatio = _editActionDetails.cropAspectRatio;
      double width = cropRect.width / aspectRatio;
      final double height = min(cropRect.height, width);
      width = height * aspectRatio;
      cropRect = Rect.fromCenter(
          center: cropRect.center, width: width, height: height);
    }
    return cropRect;
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _layerKey.currentState.pointerDown(true);
    _startingOffset = details.focalPoint;
    _editActionDetails.screenFocalPoint = details.focalPoint;
    _startingScale = _editActionDetails.totalScale;
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    _layerKey.currentState.pointerDown(true);
    if (_layerKey.currentState.isAnimating || _layerKey.currentState.isMoving) {
      return;
    }
    double totalScale = _startingScale * details.scale;
    // min(_startingScale * details.scale, _editorConfig.maxScale);
    // totalScale=(_startingScale * details.scale).clamp(_editorConfig.minScale, _editorConfig.maxScale);
    final Offset delta = details.focalPoint - _startingOffset;
    final double scaleDelta = totalScale / _editActionDetails.preTotalScale;
    _startingOffset = details.focalPoint;

    //no more zoom
    if (details.scale != 1.0 &&
        (
            // (_editActionDetails.totalScale == _editorConfig.minScale &&
            //       totalScale <= _editActionDetails.totalScale) ||
            doubleEqual(
                    _editActionDetails.totalScale, _editorConfig.maxScale) &&
                doubleCompare(totalScale, _editActionDetails.totalScale) >=
                    0)) {
      return;
    }

    totalScale = min(totalScale, _editorConfig.maxScale);
    //  totalScale.clamp(_editorConfig.minScale, _editorConfig.maxScale);

    if (mounted && (scaleDelta != 1.0 || delta != Offset.zero)) {
      setState(() {
        _editActionDetails.totalScale = totalScale;

        ///if we have shift offset, we should clear delta.
        ///we should += delta in case miss delta
        _editActionDetails.delta += delta;
      });
    }
  }

  Rect getCropRect() {
    if (widget.extendedImageState?.extendedImageInfo?.image == null) {
      return null;
    }

    Rect cropScreen = _editActionDetails.screenCropRect;
    Rect imageScreenRect = _editActionDetails.screenDestinationRect;
    imageScreenRect = _editActionDetails.paintRect(imageScreenRect);
    cropScreen = _editActionDetails.paintRect(cropScreen);

    //move to zero
    cropScreen = cropScreen.shift(-imageScreenRect.topLeft);

    imageScreenRect = imageScreenRect.shift(-imageScreenRect.topLeft);

    final ui.Image image = widget.extendedImageState.extendedImageInfo.image;
    // var size = _editActionDetails.isHalfPi
    //     ? Size(image.height.toDouble(), image.width.toDouble())
    //     : Size(image.width.toDouble(), image.height.toDouble());
    final Rect imageRect =
        Offset.zero & Size(image.width.toDouble(), image.height.toDouble());

    final double ratioX = imageRect.width / imageScreenRect.width;
    final double ratioY = imageRect.height / imageScreenRect.height;

    final Rect cropImageRect = Rect.fromLTWH(
        cropScreen.left * ratioX,
        cropScreen.top * ratioY,
        cropScreen.width * ratioX,
        cropScreen.height * ratioY);
    return cropImageRect;
  }

  ui.Image get image => widget.extendedImageState.extendedImageInfo?.image;

  Uint8List get rawImageData =>
      (widget.extendedImageState?.imageWidget?.image as ExtendedImageProvider)
          .rawImageData;

  EditActionDetails get editAction => _editActionDetails;

  void rotate({bool right = true}) {
    setState(() {
      _editActionDetails.rotate(
          right ? pi / 2.0 : -pi / 2.0,
          _layerKey.currentState.layoutRect,
          widget.extendedImageState.imageWidget.fit);
    });
  }

  void flip() {
    setState(() {
      _editActionDetails.flip();
    });
  }

  void reset() {
    setState(() {
      _editorConfig = null;
      _editActionDetails = null;
      _initGestureConfig();
    });
  }
}
