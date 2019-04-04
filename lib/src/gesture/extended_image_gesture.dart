import 'package:extended_image/src/extended_image.dart';
import 'package:extended_image/src/gesture/extended_image_gesture_utils.dart';
import 'package:extended_image/src/gesture/extended_image_gesture_page_view.dart';
import 'package:extended_image/src/extended_image_utils.dart';
import 'package:extended_image/src/image/extended_raw_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// scale idea from https://github.com/flutter/flutter/blob/master/examples/layers/widgets/gestures.dart
/// zoom image
class ExtendedImageGesture extends StatefulWidget {
  final ExtendedImage extendedImage;
  final ExtendedImageState extendedImageState;
  final ExtendedImageGesturePageViewState extendedImagePageViewState;
  ExtendedImageGesture(this.extendedImage, this.extendedImageState,
      this.extendedImagePageViewState);
  @override
  _ExtendedImageGestureState createState() => _ExtendedImageGestureState();
}

class _ExtendedImageGestureState extends State<ExtendedImageGesture>
    with TickerProviderStateMixin, ExtendedImageGestureState {
  ///details for gesture
  GestureDetails _gestureDetails;
  Offset _normalizedOffset;
  double _startingScale;
  Offset _startingOffset;
  GestureAnimation _gestureAnimation;

  GestureConfig _gestureConfig;
  @override
  void initState() {
    // TODO: implement initState
    _gestureConfig = widget.extendedImage.gestureConfig;

    if (_gestureConfig.cacheGesture) {
      var cache =
          _gestureDetailsCache[widget.extendedImageState.imageStreamKey];
      if (cache != null) {
        _gestureDetails = cache;
      }
    }
    _gestureDetails ??= GestureDetails(
      totalScale: _gestureConfig.initialScale,
      offset: Offset.zero,
    );

    _gestureAnimation = GestureAnimation(this, offsetCallBack: (Offset value) {
      setState(() {
        _gestureDetails = GestureDetails(
            offset: value,
            totalScale: _gestureDetails.totalScale,
            gestureDetails: _gestureDetails);
      });
    }, scaleCallBack: (double scale) {
      setState(() {
        _gestureDetails = GestureDetails(
            offset: _gestureDetails.offset,
            totalScale: scale,
            gestureDetails: _gestureDetails,
            zooming: true,
            userOffset: false);
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _gestureAnimation.dispose();
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _gestureAnimation.stop();
    _normalizedOffset = (details.focalPoint - _gestureDetails.offset) /
        _gestureDetails.totalScale;
    _startingScale = _gestureDetails.totalScale;
    _startingOffset = details.focalPoint;
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    double scale = _clampScale(
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

    if (offset != _gestureDetails.offset ||
        scale != _gestureDetails.totalScale) {
      setState(() {
        _gestureDetails = GestureDetails(
            offset: offset,
            totalScale: scale,
            gestureDetails: _gestureDetails,
            zooming: details.scale != 1.0);
      });
    }
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    //animate back to maxScale if gesture exceeded the maxScale specified
    if (_gestureDetails.totalScale > _gestureConfig.maxScale) {
      final double velocity =
          (_gestureDetails.totalScale - _gestureConfig.maxScale) /
              _gestureConfig.maxScale;

      _gestureAnimation.animationScale(
          _gestureDetails.totalScale, _gestureConfig.maxScale, velocity);
      return;
    }

    //animate back to minScale if gesture fell smaller than the minScale specified
    if (_gestureDetails.totalScale < _gestureConfig.minScale) {
      final double velocity =
          (_gestureConfig.minScale - _gestureDetails.totalScale) /
              _gestureConfig.minScale;

      _gestureAnimation.animationScale(
          _gestureDetails.totalScale, _gestureConfig.minScale, velocity);
      return;
    }

    if (_gestureDetails.gestureState == GestureState.pan) {
      // get magnitude from gesture velocity
      final double magnitude = details.velocity.pixelsPerSecond.distance;

      // do a significant magnitude
      if (magnitude >= minMagnitude) {
        final Offset direction = details.velocity.pixelsPerSecond /
            magnitude *
            _gestureConfig.inertialSpeed;

        _gestureAnimation.animationOffset(
            _gestureDetails.offset, _gestureDetails.offset + direction);
      }
    }
  }

  void _handleScaleReset() {
    setState(() {
      _gestureDetails = GestureDetails(
        offset: Offset.zero,
        totalScale: _gestureConfig.initialScale,
      );
    });
  }

  double _clampScale(double scale, double min, double max) {
    return scale.clamp(min, max);
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
      onScaleEnd: _handleScaleEnd,
      onDoubleTap: _handleScaleReset,
      child: image,
    );

    if (_gestureConfig.inPageView != InPageView.none) {
      image = Listener(
        child: image,
        onPointerDown: (_) {
          _gestureAnimation.stop();
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
  set gestureDetails(GestureDetails value) {
    // TODO: implement gestureDetails\
    if (mounted) {
      setState(() {
        _gestureDetails = value;
      });
    }
  }

  @override
  // TODO: implement imageGestureConfig
  GestureConfig get imageGestureConfig => _gestureConfig;
}

Map<Object, GestureDetails> _gestureDetailsCache =
    Map<Object, GestureDetails>();

void clearGestureDetailsCache() {
  _gestureDetailsCache.clear();
}
