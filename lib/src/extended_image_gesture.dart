import 'package:extended_image/src/extended_image.dart';
import 'package:extended_image/src/extended_image_gesture_utils.dart';
import 'package:extended_image/src/extended_image_gesture_page_view.dart';
import 'package:extended_image/src/extended_image_utils.dart';
import 'package:extended_image/src/extended_raw_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

///https://github.com/flutter/flutter/blob/master/examples/layers/widgets/gestures.dart

/// zoom image
class ExtendedImageGesture extends StatefulWidget {
  final ExtendedImage extendedImage;
//  final PageView pageView;
//  final ScrollPhysics physics;
  final ExtendedImageState extendedImageState;
  final ExtendedImageGesturePageViewState extendedImagePageViewState;
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
  GestureInertiaAnimation _gestureInertiaAnimation;

  ImageGestureConfig _gestureConfig;
  @override
  void initState() {
    // TODO: implement initState
    _gestureConfig = widget.extendedImage.imageGestureConfig;

    if (_gestureConfig == null && widget.extendedImagePageViewState != null) {
      _gestureConfig =
          widget.extendedImagePageViewState.widget.imageGestureConfig;
    }
    _gestureConfig ??= ImageGestureConfig();

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

    _gestureInertiaAnimation = GestureInertiaAnimation(this, (Offset value) {
      setState(() {
        _gestureDetails = GestureDetails(
            offset: value,
            totalScale: _gestureDetails.totalScale,
            gestureDetails: _gestureDetails);
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _gestureInertiaAnimation.dispose();
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _gestureInertiaAnimation.stop();
    _normalizedOffset = (details.focalPoint - _gestureDetails.offset) /
        _gestureDetails.totalScale;
    _startingScale = _gestureDetails.totalScale;
    _startingOffset = details.focalPoint;
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    double scale = (_startingScale * details.scale * _gestureConfig.speed)
        .clamp(_gestureConfig.minScale, _gestureConfig.maxScale);
    scale = roundAfter(scale, 3);
    //no more zoom
    if (details.scale != 1.0 &&
        ((_gestureDetails.totalScale == _gestureConfig.minScale &&
                scale <= _gestureDetails.totalScale) ||
            (_gestureDetails.totalScale == _gestureConfig.maxScale &&
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
        );
      });
    }
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    if (_gestureDetails.gestureState == GestureState.move) {
      // get magnitude from gesture velocity
      final double magnitude = details.velocity.pixelsPerSecond.distance;

      // do a significant magnitude
      if (magnitude >= minMagnitude) {
        final Offset direction = details.velocity.pixelsPerSecond /
            magnitude *
            _gestureConfig.inertialSpeed;

        _gestureInertiaAnimation.animation(
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

  @override
  Widget build(BuildContext context) {
    if (_gestureConfig.cacheGesture) {
      _gestureDetailsCache[widget.extendedImageState.imageStreamKey] =
          _gestureDetails;
    }

    if (_gestureDetails.totalScale == 1.0) {
      int i = 1;
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
          _gestureInertiaAnimation.stop();
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
  ImageGestureConfig get imageGestureConfig => _gestureConfig;
}

Map<Object, GestureDetails> _gestureDetailsCache =
    Map<Object, GestureDetails>();

void clearGestureDetailsCache() {
  _gestureDetailsCache.clear();
}
