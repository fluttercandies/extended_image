import 'dart:math';

import 'package:extended_image/src/extended_image.dart';
import 'package:extended_image/src/extended_image_gesture_utils.dart';
import 'package:extended_image/src/extended_image_page_view.dart';
import 'package:extended_image/src/extended_image_utils.dart';
import 'package:extended_image/src/extended_raw_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui show Image;

///https://github.com/flutter/flutter/blob/master/examples/layers/widgets/gestures.dart

/// zoom image
class ExtendedImageGesture extends StatefulWidget {
  final ExtendedImage extendedImage;
//  final PageView pageView;
//  final ScrollPhysics physics;
  final ExtendedImageState extendedImageState;
  final ExtendedImagePageViewState extendedImagePageViewState;
  ExtendedImageGesture(this.extendedImage, this.extendedImageState,
      this.extendedImagePageViewState);
  @override
  _ExtendedImageGestureState createState() => _ExtendedImageGestureState();
}

class _ExtendedImageGestureState extends State<ExtendedImageGesture>
    with SingleTickerProviderStateMixin, ExtendedImageGestureState {
  ///details for gesture
  GestureDetails _gestureDetails;
  Offset _normalizedOffset;
  double _startingScale;
  Offset _startingOffset;
  AnimationController _controller;
  Animation<Offset> _animation;

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
    _controller = AnimationController(vsync: this);
    _controller.addListener(() {
      setState(() {
        _gestureDetails = GestureDetails(
            offset: _animation.value,
            scale: _gestureDetails.scale,
            gestureDetails: _gestureDetails);
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _controller.stop();
    _normalizedOffset =
        (details.focalPoint - _gestureDetails.offset) / _gestureDetails.scale;
    _startingScale = _gestureDetails.scale;
    _startingOffset = details.focalPoint;
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    //print(details);
    double scale = (_startingScale * details.scale * _gestureConfig.speed)
        .clamp(_gestureConfig.minScale, _gestureConfig.maxScale);
    scale = _roundAfter(scale, 3);
    //no more zoom
    if (details.scale != 1.0 &&
        ((_gestureDetails.scale == _gestureConfig.minScale &&
                scale <= _gestureDetails.scale) ||
            (_gestureDetails.scale == _gestureConfig.maxScale &&
                scale >= _gestureDetails.scale))) {
      return;
    }

    //scale = _roundAfter(scale, 3);
    var offset =
        ((details.scale == 1.0 ? details.focalPoint : _startingOffset) -
            _normalizedOffset * scale);

    //print(offset.direction);
    //var offset = (details.focalPoint - _normalizedOffset * scale);

//    if (scale <= 1.0) {
//      zeroOffset = null;
//      offset = Offset.zero;
//    } else {
//      if (zeroOffset == null && _gestureDetails.scale < 1.0)
//        zeroOffset = offset;
////      else
////        {
////        zeroOffset = null;
////      }
//      //print(zeroOffset);
//
//      ///zoom from zero so that the zoom will not strange
//      if (zeroOffset != null) offset = offset - zeroOffset;
//    }

    //offset = Offset(offset.dx, offset.dy / scale);

    if (offset != _gestureDetails.offset || scale != _gestureDetails.scale) {
      setState(() {
        _gestureDetails = GestureDetails(
          offset: offset,
          scale: scale,
          gestureDetails: _gestureDetails,
        );
      });
    }
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
      //onScaleEnd: _handleScaleEnd,
      onDoubleTap: _handleScaleReset,
      child: image,
    );

    if (_gestureConfig.inPageView != InPageView.none) {
      image = Listener(
        child: image,
        onPointerDown: (_) {
          //print(widget.extendedImageState.imageStreamKey);
          widget.extendedImagePageViewState?.extendedImageGestureState = this;
        },
      );
    }
    return image;
  }

  @override
  // TODO: implement gestureDetails
  GestureDetails get gestureDetails => _gestureDetails;
  @override
  void set gestureDetails(GestureDetails value) {
    // TODO: implement gestureDetails
    setState(() {
      _gestureDetails = value;
    });
  }
}

Map<Object, GestureDetails> _gestureDetailsCache =
    Map<Object, GestureDetails>();

void clearGestureDetailsCache() {
  _gestureDetailsCache.clear();
}
