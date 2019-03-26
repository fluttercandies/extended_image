import 'dart:math';

import 'package:extended_image/src/extended_image.dart';
import 'package:extended_image/src/extended_image_utils.dart';
import 'package:extended_image/src/extended_raw_image.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui show Image;

/// zoom image
class ExtendedImageGesture extends StatefulWidget {
  final ExtendedImage extendedImage;
  final PageView pageView;
  final ExtendedImageState extendedImageState;
  ExtendedImageGesture(
      this.extendedImage, this.extendedImageState, this.pageView);
  @override
  _ExtendedImageGestureState createState() => _ExtendedImageGestureState();
}

class _ExtendedImageGestureState extends State<ExtendedImageGesture> {
  ///details for gesture
  GestureDetails _gestureDetails;
  Offset _normalizedOffset;
  double _startingScale;
  Offset _startingOffset;

  ImageGestureConfig _gestureConfig;
  @override
  void initState() {
    // TODO: implement initState
    _gestureConfig =
        widget.extendedImage.imageGestureConfig ?? ImageGestureConfig();

    if (_gestureConfig.cacheGesture) {
      var cache =
          _gestureDetailsCache[widget.extendedImageState.imageStreamKey];
      if (cache != null) {
        _gestureDetails = cache;
      }
    }
    _gestureDetails ??= GestureDetails(
      scale: 1.0,
      offset: Offset.zero,
    );
    super.initState();
  }

  Offset _clampOffset(Offset offset, double scale) {
    //final Size size = context.size;
    print(offset);
    return offset;
    if (scale > 1.0) {
      return offset;
//      final Offset minOffset =
//          Offset(size.width, size.height) * (1.0 - _gestureDetails.scale);
//      return Offset(offset.dx.clamp(minOffset.dx, 0.0),
//          offset.dy.clamp(minOffset.dy, 0.0));
    } else {
      return Offset.zero;
    }
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _normalizedOffset =
        (details.focalPoint - _gestureDetails.offset) / _gestureDetails.scale;
    _startingScale = _gestureDetails.scale;
    _startingOffset = details.focalPoint;
  }

  Offset _offset = Offset.zero;
  void _handleScaleUpdate(ScaleUpdateDetails details) {
    double scale = (_startingScale * details.scale * _gestureConfig.speed)
        .clamp(_gestureConfig.minScale, _gestureConfig.maxScale);
    //scale = _roundAfter(scale, 3);
    setState(() {
      GestureDetails temp = _gestureDetails;
      var offset =
          _clampOffset(details.focalPoint - _normalizedOffset * scale, scale);

      _gestureDetails = GestureDetails(
          offset: offset,
          scale: scale,
          delta: offset - temp.offset,
          computeBoundary: details.scale == 1.0 && scale > 1.0)
        ..boundary = _gestureDetails.boundary;
    });
  }

  void _handleHorizontalDragUpdate(DragUpdateDetails details) {
    var delta = details.delta;
    if (delta.dx == 0.0) return;

    if (widget.pageView != null && delta.dx != 0.0) {
      bool movePageView = (delta.dx < 0 && _gestureDetails.boundary.right) ||
          (delta.dx > 0 && _gestureDetails.boundary.left);

      if (movePageView) {
        widget.pageView.controller.position.moveTo(
            widget.pageView.controller.offset -
                delta.dx * _gestureConfig.speed);
        return;
      }
    }

    setState(() {
      _gestureDetails = GestureDetails(
          offset: _clampOffset(
            _gestureDetails.offset + details.delta * _gestureConfig.speed,
            _gestureDetails.scale,
          ),
          scale: _gestureDetails.scale,
          delta: details.delta * _gestureConfig.speed,
          computeBoundary: _gestureDetails.scale > 1.0)
        ..boundary = _gestureDetails.boundary;
    });
  }

  void _handleVerticalDragUpdate(DragUpdateDetails details) {
    var delta = details.delta;
    if (delta.dy == 0.0) return;

    if (widget.pageView != null) {
      bool movePageView = (delta.dy < 0 && _gestureDetails.boundary.bottom) ||
          (delta.dy > 0 && _gestureDetails.boundary.top);

      if (movePageView) {
        widget.pageView.controller.position.moveTo(
            widget.pageView.controller.offset -
                delta.dy * _gestureConfig.speed);
        return;
      }
    }

    setState(() {
      _gestureDetails = GestureDetails(
          offset: _clampOffset(
            _gestureDetails.offset + details.delta * _gestureConfig.speed,
            _gestureDetails.scale,
          ),
          scale: _gestureDetails.scale,
          delta: details.delta * _gestureConfig.speed,
          computeBoundary: _gestureDetails.scale > 1.0)
        ..boundary = _gestureDetails.boundary;
    });
  }

  void _handleScaleReset() {
    setState(() {
      _gestureDetails = GestureDetails(offset: Offset.zero, scale: 1.0);
    });
  }

  //Round the scale to three points after comma to prevent shaking
  double _roundAfter(double number, int position) {
    double shift = pow(10, position).toDouble();
    return (number * shift).roundToDouble() / shift;
  }

  bool get listenVerticalDragUpdate {
    return (_gestureDetails.scale > 1.0 &&
        widget.extendedImage.imageGestureConfig.inPageView ==
            InPageView.vertical &&
        widget.pageView != null);
  }

  bool get listenHorizontalDragUpdate {
    return (_gestureDetails.scale > 1.0 &&
        widget.extendedImage.imageGestureConfig.inPageView ==
            InPageView.horizontal &&
        widget.pageView != null);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_gestureConfig.cacheGesture) {
      _gestureDetailsCache[widget.extendedImageState.imageStreamKey] =
          _gestureDetails;
    }

    Widget image = ExtendedRawImage(
      image: widget.extendedImageState.extendedImageInfo?.image,
      width: widget.extendedImage.width,
      height: widget.extendedImage.height,
      scale: widget.extendedImageState.extendedImageInfo?.scale ?? 1.0,
      color: widget.extendedImage.color,
      colorBlendMode: widget.extendedImage.colorBlendMode,
      fit: widget.extendedImage.fit,
      alignment: widget.extendedImage.alignment,
      repeat: widget.extendedImage.repeat,
      centerSlice: widget.extendedImage.centerSlice,
      matchTextDirection: widget.extendedImage.matchTextDirection,
      invertColors: widget.extendedImageState.invertColors,
      filterQuality: widget.extendedImage.filterQuality,
      beforePaintImage: widget.extendedImage.beforePaintImage,
      afterPaintImage: widget.extendedImage.afterPaintImage,
      gestureDetails: _gestureDetails,
    );

    image = GestureDetector(
      onScaleStart: _handleScaleStart,
      onScaleUpdate: _handleScaleUpdate,
      onDoubleTap: _handleScaleReset,
      onHorizontalDragUpdate:
          listenHorizontalDragUpdate ? _handleHorizontalDragUpdate : null,
      onVerticalDragUpdate:
          listenVerticalDragUpdate ? _handleVerticalDragUpdate : null,
      child: image,
    );
    return image;
  }
}

Map<Object, GestureDetails> _gestureDetailsCache =
    Map<Object, GestureDetails>();

void clearGestureDetailsCache() {
  _gestureDetailsCache.clear();
}
