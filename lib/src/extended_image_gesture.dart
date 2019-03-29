import 'dart:math';

import 'package:extended_image/src/extended_image.dart';
import 'package:extended_image/src/extended_image_utils.dart';
import 'package:extended_image/src/extended_raw_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui show Image;

/// zoom image
class ExtendedImageGesture extends StatefulWidget {
  final ExtendedImage extendedImage;
  final PageView pageView;
  final ScrollPhysics physics;
  final ExtendedImageState extendedImageState;
  ExtendedImageGesture(
      this.extendedImage, this.extendedImageState, this.pageView, this.physics);
  @override
  _ExtendedImageGestureState createState() => _ExtendedImageGestureState();
}

class _ExtendedImageGestureState extends State<ExtendedImageGesture>
    with SingleTickerProviderStateMixin {
  ///details for gesture
  GestureDetails _gestureDetails;
  Offset _normalizedOffset;
  double _startingScale;
  Offset _startingOffset;
  AnimationController _controller;
  Animation<Offset> _animation;

  ImageGestureConfig _gestureConfig;
  ScrollPosition get position => widget.pageView?.controller.position;
  Map<Type, GestureRecognizerFactory> _gestureRecognizers =
      const <Type, GestureRecognizerFactory>{};
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
    if (widget.pageView != null) {
      switch (widget.pageView.scrollDirection) {
        case Axis.vertical:
          _gestureRecognizers = <Type, GestureRecognizerFactory>{
            VerticalDragGestureRecognizer: GestureRecognizerFactoryWithHandlers<
                VerticalDragGestureRecognizer>(
              () => VerticalDragGestureRecognizer(),
              (VerticalDragGestureRecognizer instance) {
                instance
                  ..onDown = _handleDragDown
                  ..onStart = _handleDragStart
                  ..onUpdate = _handleDragUpdate
                  ..onEnd = _handleDragEnd
                  ..onCancel = _handleDragCancel
                  ..minFlingDistance = widget.physics?.minFlingDistance
                  ..minFlingVelocity = widget.physics?.minFlingVelocity
                  ..maxFlingVelocity = widget.physics?.maxFlingVelocity;
              },
            ),
          };
          break;
        case Axis.horizontal:
          _gestureRecognizers = <Type, GestureRecognizerFactory>{
            HorizontalDragGestureRecognizer:
                GestureRecognizerFactoryWithHandlers<
                    HorizontalDragGestureRecognizer>(
              () => HorizontalDragGestureRecognizer(),
              (HorizontalDragGestureRecognizer instance) {
                instance
                  ..onDown = _handleDragDown
                  ..onStart = _handleDragStart
                  ..onUpdate = _handleDragUpdate
                  ..onEnd = _handleDragEnd
                  ..onCancel = _handleDragCancel
                  ..minFlingDistance = widget.physics?.minFlingDistance
                  ..minFlingVelocity = widget.physics?.minFlingVelocity
                  ..maxFlingVelocity = widget.physics?.maxFlingVelocity;
              },
            ),
          };
          break;
      }
    } else {
      _gestureRecognizers = const <Type, GestureRecognizerFactory>{};
    }

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
    zeroOffset = null;
  }

  Offset zeroOffset;
  void _handleScaleUpdate(ScaleUpdateDetails details) {
    double scale = (_startingScale * details.scale * _gestureConfig.speed)
        .clamp(_gestureConfig.minScale, _gestureConfig.maxScale);

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

    if (scale <= 1.0) {
      zeroOffset = null;
      offset = Offset.zero;
    } else {
      if (zeroOffset == null && _gestureDetails.scale < 1.0)
        zeroOffset = offset;
//      else
//        {
//        zeroOffset = null;
//      }
      //print(zeroOffset);

      ///zoom from zero so that the zoom will not strange
      if (zeroOffset != null) offset = offset - zeroOffset;
    }
    print(offset);

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

  Drag _drag;
  ScrollHoldController _hold;

  void _handleDragDown(DragDownDetails details) {
    _controller.stop();
    assert(_drag == null);
    assert(_hold == null);
    _hold = position.hold(_disposeHold);
  }

  void _handleDragStart(DragStartDetails details) {
    // It's possible for _hold to become null between _handleDragDown and
    // _handleDragStart, for example if some user code calls jumpTo or otherwise
    // triggers a new activity to begin.
    assert(_drag == null);
    _drag = position.drag(details, _disposeDrag);
    assert(_drag != null);
    assert(_hold == null);
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    // _drag might be null if the drag activity ended and called _disposeDrag.
    assert(_hold == null || _drag == null);
    var delta = details.delta;

    bool movePage = (delta.dx < 0 && _gestureDetails.boundary.right) ||
        (delta.dx > 0 && _gestureDetails.boundary.left) ||
        (delta.dy < 0 && _gestureDetails.boundary.bottom) ||
        (delta.dy > 0 && _gestureDetails.boundary.top) ||
        _gestureDetails.scale <= 1.0;

    if (movePage) {
      _drag?.update(details);
    } else {
      setState(() {
        _gestureDetails = GestureDetails(
            offset: _gestureDetails.offset + details.delta,
            scale: _gestureDetails.scale,
            gestureDetails: _gestureDetails
            //computeBoundary: _gestureDetails.scale > 1.0
            );
      });
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    // _drag might be null if the drag activity ended and called _disposeDrag.
    assert(_hold == null || _drag == null);

    var temp = details;
    if (_gestureDetails.computeHorizontalBoundary ||
        _gestureDetails.computeVerticalBoundary) {
      //final double magnitude = details.velocity.pixelsPerSecond.distance;
      //if (magnitude < _kMinFlingVelocity) return;
      //final Offset direction = details.velocity.pixelsPerSecond / magnitude;

//      var primaryVelocity = details.primaryVelocity / 100.0;
//      var end = _gestureDetails.offset;
//      if (details.velocity.pixelsPerSecond.dx == primaryVelocity) {
//        end = Offset(primaryVelocity, 0.0);
//      } else {
//        end = Offset(0.0, primaryVelocity);
//      }

      temp = DragEndDetails(primaryVelocity: 0.0);
//      _animation = _controller.drive(Tween<Offset>(
//          begin: _gestureDetails.offset, end: _gestureDetails.offset + end));
//      _controller
//        ..value = 0.0
//        ..fling(velocity: magnitude / 1000.0);
    }
    _drag?.end(temp);

    assert(_drag == null);
  }

  void _handleDragCancel() {
    // _hold might be null if the drag started.
    // _drag might be null if the drag activity ended and called _disposeDrag.
    assert(_hold == null || _drag == null);
    _hold?.cancel();
    _drag?.cancel();
    assert(_hold == null);
    assert(_drag == null);
  }

  void _disposeHold() {
    _hold = null;
  }

  void _disposeDrag() {
    _drag = null;
  }

  void _handleScaleReset() {
    setState(() {
      zeroOffset = null;
      _gestureDetails = GestureDetails(offset: Offset.zero, scale: 1.0);
    });
  }

  //Round the scale to three points after comma to prevent shaking
  double _roundAfter(double number, int position) {
    double shift = pow(10, position).toDouble();
    return (number * shift).roundToDouble() / shift;
  }

//  bool get listenVerticalDragUpdate {
//    return (widget.extendedImage.imageGestureConfig.inPageView ==
//            InPageView.vertical &&
//        widget.pageView != null);
//  }
//
//  bool get listenHorizontalDragUpdate {
//    return (widget.extendedImage.imageGestureConfig.inPageView ==
//            InPageView.horizontal &&
//        widget.pageView != null);
//  }

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
//      onHorizontalDragUpdate:
//          listenHorizontalDragUpdate ? _handleHorizontalDragUpdate : null,
//      onVerticalDragUpdate:
//          listenVerticalDragUpdate ? _handleVerticalDragUpdate : null,
      child: image,
    );

    if (widget.pageView != null) {
      image = RawGestureDetector(
        gestures: _gestureRecognizers,
        behavior: HitTestBehavior.opaque,
        child: image,
      );
    }

    return image;
  }
}

Map<Object, GestureDetails> _gestureDetailsCache =
    Map<Object, GestureDetails>();

void clearGestureDetailsCache() {
  _gestureDetailsCache.clear();
}

typedef Rebuild = GestureDetails Function();
