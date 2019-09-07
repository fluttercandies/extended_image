import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../../extended_image.dart';
import 'extended_image_crop_layer.dart';
import 'dart:ui' as ui;

import 'extended_image_editor_utils.dart';

///
///  create by zmtzawqlp on 2019/8/22
///

class ExtendedImageEditor extends StatefulWidget {
  final ExtendedImageState extendedImageState;
  ExtendedImageEditor({this.extendedImageState, Key key}) : super(key: key);
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
    double initialScale = _editorConfig?.initialScale;
    _editorConfig = widget.extendedImageState.imageWidget.initEidtorConfigHandler
            ?.call(widget.extendedImageState) ??
        EditActionDetails();
    if (_editActionDetails == null ||
        initialScale != _editorConfig.initialScale) {
      _editActionDetails = EditActionDetails()
        ..delta = Offset.zero
        ..totalScale = _editorConfig.initialScale
        ..preTotalScale = _editorConfig.initialScale
        ..cropRectPadding = _editorConfig.cropRectPadding;
    }
  }

  @override
  void didUpdateWidget(ExtendedImageEditor oldWidget) {
    _initGestureConfig();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    var extendedImage = widget.extendedImageState.imageWidget;
    Widget image = ExtendedRawImage(
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
      matchTextDirection: extendedImage.matchTextDirection,
      invertColors: widget.extendedImageState.invertColors,
      filterQuality: extendedImage.filterQuality,
      editActionDetails: _editActionDetails,
    );

    Widget result = GestureDetector(
        onScaleStart: _handleScaleStart,
        onScaleUpdate: _handleScaleUpdate,
        onScaleEnd: _handleScaleEnd,
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
                var layoutRect = Offset.zero &
                    Size(constraints.maxWidth, constraints.maxHeight);
                var padding = _editorConfig.cropRectPadding;
                if (padding != null) {
                  layoutRect = padding.deflateRect(layoutRect);
                }
                if (_editActionDetails.cropRect == null) {
                  var destinationRect = getDestinationRect(
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
                  var cropRect =
                      _editActionDetails.getRectWithScale(destinationRect);

                  _editActionDetails.cropRect = cropRect;
                }

                return ExtendedImageCropLayer(
                  key: _layerKey,
                  layoutRect: layoutRect,
                  editActionDetails: _editActionDetails,
                  editorConfig: _editorConfig,
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

  void _handleScaleStart(ScaleStartDetails details) {
    _layerKey.currentState.pointerDown(true);
    _startingOffset = details.focalPoint;
    _editActionDetails.screenFocalPoint = details.focalPoint;
    _startingScale = _editActionDetails.totalScale;
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    _layerKey.currentState.pointerDown(true);
    var totalScale = (_startingScale * details.scale)
        .clamp(_editorConfig.minScale, _editorConfig.maxScale);
    var delta = (details.focalPoint - _startingOffset);
    var scaleDelta = totalScale / _editActionDetails.preTotalScale;
    _startingOffset = details.focalPoint;
    //no more zoom
    if (details.scale != 1.0 &&
        ((_editActionDetails.totalScale == _editorConfig.minScale &&
                totalScale <= _editActionDetails.totalScale) ||
            (_editActionDetails.totalScale == _editorConfig.maxScale &&
                totalScale >= _editActionDetails.totalScale))) {
      return;
    }

    totalScale = totalScale.clamp(_editorConfig.minScale, _editorConfig.maxScale);

    if (mounted && (scaleDelta != 1.0 || delta != Offset.zero)) {
      setState(() {
        _editActionDetails.totalScale = totalScale;
        _editActionDetails.delta = delta;
      });
    }
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    // var rect = _gestureDetails.preDestinationRect
    //     .expandToInclude(_gestureDetails.editRect);
    // if (rect != _gestureDetails.preDestinationRect) {
    //   setState(() {

    //   });
    // }
  }

  Rect getCropRect() {
    if (widget.extendedImageState?.extendedImageInfo?.image == null) {
      return null;
    }

    var imageScreenRect = _editActionDetails.screenDestinationRect;
    var cropScreen =
        _editActionDetails.screenCropRect.shift(-imageScreenRect.topLeft);
    imageScreenRect = imageScreenRect.shift(-imageScreenRect.topLeft);

    var image = widget.extendedImageState.extendedImageInfo.image;
    var size = _editActionDetails.isHalfPi
        ? Size(image.height.toDouble(), image.width.toDouble())
        : Size(image.width.toDouble(), image.height.toDouble());
    var imageRect = Offset.zero & size;

    var ratioX = imageRect.width / imageScreenRect.width;
    var ratioY = imageRect.height / imageScreenRect.height;

    var cropImageRect = Rect.fromLTWH(
        cropScreen.left * ratioX,
        cropScreen.top * ratioY,
        cropScreen.width * ratioX,
        cropScreen.height * ratioY);
    return cropImageRect;
  }

  ui.Image get image => widget.extendedImageState.extendedImageInfo?.image;

  EditActionDetails get editAction => _editActionDetails;

  void rotate({bool right: true}) {
    setState(() {
      //_gestureDetails.editAction.cropRect = null;
      _editActionDetails.rotate(right ? pi / 2.0 : -pi / 2.0);
      var rect = _editActionDetails.cropRect;
      var center = rect.center;
      rect = Rect.fromLTWH(center.dx - rect.height / 2.0,
          center.dy - rect.width / 2.0, rect.height, rect.width);
      _editActionDetails.cropRect = rect;
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
