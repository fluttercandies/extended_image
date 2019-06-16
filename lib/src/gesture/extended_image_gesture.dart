import 'package:extended_image/src/extended_image.dart';
import 'package:extended_image/src/gesture/extended_image_gesture_utils.dart';
import 'package:extended_image/src/gesture/extended_image_gesture_page_view.dart';
import 'package:extended_image/src/extended_image_utils.dart';
import 'package:extended_image/src/image/extended_raw_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'extended_image_slide_page.dart';

/// scale idea from https://github.com/flutter/flutter/blob/master/examples/layers/widgets/gestures.dart
/// zoom image
class ExtendedImageGesture extends StatefulWidget {
  final ExtendedImage extendedImage;
  final ExtendedImageState extendedImageState;
  final ExtendedImageGesturePageViewState extendedImagePageViewState;
  final ExtendedImageSlidePageState extendedImageSlidePageState;
  ExtendedImageGesture(ExtendedImageState extendedImageState,
      this.extendedImagePageViewState, this.extendedImageSlidePageState)
      : extendedImage = extendedImageState.imageWidget,
        extendedImageState = extendedImageState;
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
  Offset _pointerDownPosition;
  GestureAnimation _gestureAnimation;
  GestureConfig _gestureConfig;

  @override
  void initState() {
    // TODO: implement initState
    _initGestureConfig();
    super.initState();
  }

  void _initGestureConfig() {
    _gestureAnimation?.stop();
    _gestureAnimation?.dispose();

    _gestureConfig = widget.extendedImage.initGestureConfigHandler
            ?.call(widget.extendedImageState) ??
        GestureConfig();

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
      if (mounted) {
        setState(() {
          _gestureDetails = GestureDetails(
              offset: value,
              totalScale: _gestureDetails.totalScale,
              gestureDetails: _gestureDetails);
        });
      }
    }, scaleCallBack: (double scale) {
      if (mounted) {
        setState(() {
          _gestureDetails = GestureDetails(
              offset: _gestureDetails.offset,
              totalScale: scale,
              gestureDetails: _gestureDetails,
              zooming: true,
              userOffset: false);
        });
      }
    });
  }

  @override
  void didUpdateWidget(ExtendedImageGesture oldWidget) {
    // TODO: implement didUpdateWidget
    _initGestureConfig();
    super.didUpdateWidget(oldWidget);
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

  Offset _updateSlidePageStartingOffset;
  Offset _updateSlidePageImageStartingOffset;

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    ///whether gesture page
    if (widget.extendedImageSlidePageState != null &&
        details.scale == 1.0 &&
        _gestureDetails.userOffset &&
        _gestureDetails.gestureState == GestureState.pan) {
      var offsetDelta = (details.focalPoint - _startingOffset);
      //print(offsetDelta);
      bool updateGesture = false;
      if (!widget.extendedImageSlidePageState.isSliding) {
        if (offsetDelta.dx != 0 &&
            offsetDelta.dx.abs() > offsetDelta.dy.abs()) {
          if (_gestureDetails.computeHorizontalBoundary) {
            if (offsetDelta.dx > 0) {
              updateGesture = _gestureDetails.boundary.left;
            } else {
              updateGesture = _gestureDetails.boundary.right;
            }
          } else {
            updateGesture = true;
          }
        }
        if (offsetDelta.dy != 0 &&
            offsetDelta.dy.abs() > offsetDelta.dx.abs()) {
          if (_gestureDetails.computeVerticalBoundary) {
            if (offsetDelta.dy < 0) {
              updateGesture = _gestureDetails.boundary.bottom;
            } else {
              updateGesture = _gestureDetails.boundary.top;
            }
          } else {
            updateGesture = true;
          }
        }
      } else {
        updateGesture = true;
      }

      var delta = (details.focalPoint - _startingOffset).distance;
//      if (widget.extendedImageGesturePageState.widget.pageGestureAxis ==
//          PageGestureAxis.horizontal) {
//        delta = (details.focalPoint - _startingOffset).dx;
//      } else if (widget.extendedImageGesturePageState.widget.pageGestureAxis ==
//          PageGestureAxis.vertical) {
//        delta = (details.focalPoint - _startingOffset).dy;
//      }

//      if (widget.extendedImagePageViewState != null) {
//        if (widget.extendedImagePageViewState.widget.scrollDirection ==
//            Axis.horizontal) {
//        } else {}
//      }

      if (delta > minGesturePageDelta && updateGesture) {
        _updateSlidePageStartingOffset ??= details.focalPoint;
        _updateSlidePageImageStartingOffset ??= _gestureDetails.offset;
        widget.extendedImageSlidePageState.slide(
            details.focalPoint - _updateSlidePageStartingOffset,
            extendedImageGestureState: this);
      }
    }

    if (widget.extendedImageSlidePageState != null &&
        widget.extendedImageSlidePageState.isSliding) {
      return;
    }

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

  void _handleScaleEnd(ScaleEndDetails details) {
    if (widget.extendedImageSlidePageState != null &&
        widget.extendedImageSlidePageState.isSliding) {
      _updateSlidePageStartingOffset = null;
      // _updateSlidePageImageStartingOffset = null;
      widget.extendedImageSlidePageState.endSlide();
      return;
    }
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

  void _handleDoubleTap() {
    if (widget.extendedImage.onDoubleTap != null) {
      widget.extendedImage.onDoubleTap(this);
      return;
    }

    if (!mounted) return;

    setState(() {
      _gestureDetails = GestureDetails(
        offset: Offset.zero,
        totalScale: _gestureConfig.initialScale,
      );
    });
  }

  void _handlePointerDown(PointerDownEvent pointerDownEvent) {
    _pointerDownPosition = pointerDownEvent.position;

    _gestureAnimation.stop();

    widget.extendedImagePageViewState?.extendedImageGestureState = this;
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
      onDoubleTap: _handleDoubleTap,
      child: image,
    );

    image = Listener(
      child: image,
      onPointerDown: _handlePointerDown,
    );

    if (widget.extendedImageSlidePageState != null &&
        widget.extendedImageSlidePageState.widget.slideType ==
            SlideType.onlyImage) {
      var extendedImageSlidePageState = widget.extendedImageSlidePageState;
      image = Transform.translate(
        offset: extendedImageSlidePageState.offset,
        child: Transform.scale(
          scale: extendedImageSlidePageState.scale,
          child: image,
        ),
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

  @override
  void handleDoubleTap({double scale, Offset doubleTapPosition}) {
    doubleTapPosition ??= _pointerDownPosition;
    scale ??= _gestureConfig.initialScale;
    // TODO: implement onDoubleTap
    _handleScaleStart(ScaleStartDetails(focalPoint: doubleTapPosition));
    _handleScaleUpdate(ScaleUpdateDetails(
        focalPoint: doubleTapPosition, scale: scale / _startingScale));
  }

  @override
  // TODO: implement pointerDownPosition
  Offset get pointerDownPosition => _pointerDownPosition;

  @override
  void slide() {
    if (mounted) {
      setState(() {
        _gestureDetails.slidePageOffset =
            widget.extendedImageSlidePageState?.offset;
      });
    }
  }
}

Map<Object, GestureDetails> _gestureDetailsCache =
    Map<Object, GestureDetails>();

///clear the gesture details
void clearGestureDetailsCache() {
  _gestureDetailsCache.clear();
}
