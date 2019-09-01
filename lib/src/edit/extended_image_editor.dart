import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../../extended_image.dart';
import 'extended_image_crop_layer.dart';
import 'dart:ui' as ui;

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
  GestureDetails _gestureDetails;
  GestureConfig _gestureConfig;
  Offset _normalizedOffset;
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
    _gestureConfig = widget
            .extendedImageState.imageWidget.initGestureConfigHandler
            ?.call(widget.extendedImageState) ??
        GestureConfig();
    _gestureDetails ??= GestureDetails(
      totalScale: _gestureConfig.initialScale,
      offset: Offset.zero,
    );
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
      gestureDetails: _gestureDetails,
    );

    return GestureDetector(
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
              child: ExtendedImageCropLayer(
                image: widget.extendedImageState.extendedImageInfo?.image,
                fit: extendedImage.fit,
                alignment: extendedImage.alignment,
                centerSlice: extendedImage.centerSlice,
                scale: widget.extendedImageState.extendedImageInfo?.scale,
                key: _layerKey,
              ),
              top: 0.0,
              left: 0.0,
              bottom: 0.0,
              right: 0.0,
            ),
          ],
        ));
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _normalizedOffset = (details.focalPoint - _gestureDetails.offset) /
        _gestureDetails.totalScale;
    _startingScale = _gestureDetails.totalScale;
    _startingOffset = details.focalPoint;
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    double scale = clampScale(
        (_startingScale * details.scale * _gestureConfig.speed),
        _gestureConfig.animationMinScale,
        _gestureConfig.animationMaxScale);

    //Round the scale to three points after comma to prevent shaking
    //scale = roundAfter(scale, 3);
    //no more zoom
    if (details.scale != 1.0 &&
        ((_gestureDetails.totalScale == _gestureConfig.animationMinScale &&
                scale <= _gestureDetails.totalScale) ||
            (_gestureDetails.totalScale == _gestureConfig.animationMaxScale &&
                scale >= _gestureDetails.totalScale))) {
      return;
    }

    var offset =
        ((details.scale == 1.0 ? details.focalPoint : _startingOffset) -
            _normalizedOffset * scale);

    if (mounted &&
        (offset != _gestureDetails.offset ||
            scale != _gestureDetails.totalScale)) {
      setState(() {
        _gestureDetails = GestureDetails(
            offset: offset,
            totalScale: scale,
            gestureDetails: _gestureDetails,
            zooming: details.scale != 1.0);
      });
    }
  }

  void _handleScaleEnd(ScaleEndDetails details) {}

  Rect crop() {
    if (widget.extendedImageState?.extendedImageInfo?.image == null) {
      return null;
    }
    var rect = _gestureDetails.preDestinationRect;

    var imageScreenRect = rect.shift(-rect.topLeft);

    var cropScreen = _layerKey.currentState.editRect
        .shift(_gestureDetails.layoutRect.topLeft)
        .shift(-rect.topLeft);
    var image = widget.extendedImageState.extendedImageInfo.image;
    var imageRect =
        Offset.zero & Size(image.width.toDouble(), image.height.toDouble());

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
}
