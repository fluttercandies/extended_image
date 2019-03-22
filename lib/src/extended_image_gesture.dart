import 'package:extended_image/src/extended_image.dart';
import 'package:extended_image/src/extended_image_utils.dart';
import 'package:extended_image/src/extended_raw_image.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui show Image;

/// zoom image
class ExtendedImageGesture extends StatefulWidget {
  final ExtendedImage extendedImage;
  final ExtendedImageState extendedImageState;
  ExtendedImageGesture(this.extendedImage, this.extendedImageState);
  @override
  _ExtendedImageGestureState createState() => _ExtendedImageGestureState();
}

class _ExtendedImageGestureState extends State<ExtendedImageGesture> {
  Offset _startingFocalPoint;

  Offset _previousOffset;
  Offset _offset = Offset.zero;
  GestureDetails _previousGestureDetails;

  double _previousZoom;
  double _scale = 1.0;

  GestureConfig _gestureConfig;
  @override
  void initState() {
    // TODO: implement initState
    _gestureConfig = widget.extendedImage.gestureConfig ?? GestureConfig();

    if (_gestureConfig.cacheGesture) {
      var cache =
          _gestureDetailsCache[widget.extendedImageState.imageStreamKey];
      if (cache != null) {
        _scale = cache.scale;
        _offset = cache.offset;
      }
    }

    super.initState();
  }

  void _handleScaleStart(ScaleStartDetails details) {
    setState(() {
      _startingFocalPoint = details.focalPoint;
      _previousOffset = _offset;
      _previousZoom = _scale;
    });
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      _scale = (_previousZoom * details.scale * _gestureConfig.speed)
          .clamp(_gestureConfig.minScale, _gestureConfig.maxScale);

      // Ensure that item under the focal point stays in the same place despite zooming
      final Offset normalizedOffset =
          (_startingFocalPoint - _previousOffset) / _previousZoom;
      _offset = details.focalPoint - normalizedOffset * _scale;
      //offset = details.focalPoint;
      //print("_handleScaleUpdate$_offset");
    });
  }

  void _handleScaleReset() {
    setState(() {
      _scale = 1.0;
      _offset = Offset.zero;
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
//    final Offset center = size.center(Offset.zero) * zoom + offset;
//    final double radius = size.width / 2.0 * zoom;
    _previousGestureDetails = GestureDetails(_offset, _scale);
    if (_gestureConfig.cacheGesture) {
      _gestureDetailsCache[widget.extendedImageState.imageStreamKey] =
          _previousGestureDetails;
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
      gestureDetails: _previousGestureDetails,
    );

    image = GestureDetector(
      onScaleStart: _handleScaleStart,
      onScaleUpdate: _handleScaleUpdate,
      onDoubleTap: _handleScaleReset,
//      onHorizontalDragStart: (_) {},
//      onHorizontalDragUpdate: (_) {},
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
