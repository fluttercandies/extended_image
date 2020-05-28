import 'package:extended_image/src/gesture/extended_image_gesture_utils.dart';
import 'package:extended_image/src/gesture/extended_image_gesture_page_view.dart';
import 'package:extended_image/src/extended_image_utils.dart';
import 'package:extended_image/src/image/extended_raw_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../extended_image_typedef.dart';
import 'extended_image_slide_page.dart';

bool _defaultCanScaleImage(GestureDetails details) => true;

/// scale idea from https://github.com/flutter/flutter/blob/master/examples/layers/widgets/gestures.dart
/// zoom image
class ExtendedImageGesture extends StatefulWidget {
  const ExtendedImageGesture(
    this.extendedImageState, {
    this.imageBuilder,
    CanScaleImage canScaleImage,
    Key key,
  })  : canScaleImage = canScaleImage ?? _defaultCanScaleImage,
        super(key: key);
  final ExtendedImageState extendedImageState;
  final ImageBuilderForGesture imageBuilder;
  final CanScaleImage canScaleImage;
  @override
  ExtendedImageGestureState createState() => ExtendedImageGestureState();
}

class ExtendedImageGestureState extends State<ExtendedImageGesture>
    with TickerProviderStateMixin {
  ///details for gesture
  GestureDetails _gestureDetails;
  Offset _normalizedOffset;
  double _startingScale;
  Offset _startingOffset;
  Offset _pointerDownPosition;
  GestureAnimation _gestureAnimation;
  GestureConfig _gestureConfig;
  ExtendedImageGesturePageViewState _pageViewState;
  ExtendedImageSlidePageState get extendedImageSlidePageState =>
      widget.extendedImageState.slidePageState;
  @override
  void initState() {
    _initGestureConfig();
    super.initState();
  }

  void _initGestureConfig() {
    final double initialScale = _gestureConfig?.initialScale;
    final InitialAlignment initialAlignment = _gestureConfig?.initialAlignment;
    _gestureConfig = widget
            .extendedImageState.imageWidget.initGestureConfigHandler
            ?.call(widget.extendedImageState) ??
        GestureConfig();

    if (_gestureDetails == null ||
        initialScale != _gestureConfig.initialScale ||
        initialAlignment != _gestureConfig.initialAlignment) {
      _gestureDetails = GestureDetails(
        totalScale: _gestureConfig.initialScale,
        offset: Offset.zero,
      )..initialAlignment = _gestureConfig.initialAlignment;
    }

    if (_gestureConfig.cacheGesture) {
      final GestureDetails cache =
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
              actionType: ActionType.zoom,
              userOffset: false);
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    _pageViewState = null;
    if (_gestureConfig.inPageView) {
      _pageViewState =
          context.findAncestorStateOfType<ExtendedImageGesturePageViewState>();
    }
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(ExtendedImageGesture oldWidget) {
    _initGestureConfig();
    _pageViewState = null;
    if (_gestureConfig.inPageView) {
      _pageViewState =
          context.findAncestorStateOfType<ExtendedImageGesturePageViewState>();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    super.dispose();
    _gestureAnimation?.stop();
    _gestureAnimation?.dispose();
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _gestureAnimation.stop();
    _normalizedOffset = (details.focalPoint - _gestureDetails.offset) /
        _gestureDetails.totalScale;
    _startingScale = _gestureDetails.totalScale;
    _startingOffset = details.focalPoint;
  }

  Offset _updateSlidePagePreOffset;
  //Offset _updateSlidePageImageStartingOffset;

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    ///whether gesture page
    if (extendedImageSlidePageState != null &&
        details.scale == 1.0 &&
        _gestureDetails.userOffset &&
        _gestureDetails.actionType == ActionType.pan) {
      final Offset offsetDelta = details.focalPoint - _startingOffset;
      //print(offsetDelta);
      bool updateGesture = false;
      if (!extendedImageSlidePageState.isSliding) {
        if (offsetDelta.dx != 0 &&
            doubleCompare(offsetDelta.dx.abs(), offsetDelta.dy.abs()) > 0) {
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
            doubleCompare(offsetDelta.dy.abs(), offsetDelta.dx.abs()) > 0) {
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

      final double delta = (details.focalPoint - _startingOffset).distance;
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

      if (doubleCompare(delta, minGesturePageDelta) > 0 && updateGesture) {
        _updateSlidePagePreOffset ??= details.focalPoint;
        //_updateSlidePageImageStartingOffset ??= _gestureDetails.offset;
        extendedImageSlidePageState.slide(
            details.focalPoint - _updateSlidePagePreOffset,
            extendedImageGestureState: this);
        _updateSlidePagePreOffset = details.focalPoint;
      }
    }

    if (extendedImageSlidePageState != null &&
        extendedImageSlidePageState.isSliding) {
      return;
    }

    final double scale = widget.canScaleImage(_gestureDetails)
        ? clampScale(_startingScale * details.scale * _gestureConfig.speed,
            _gestureConfig.animationMinScale, _gestureConfig.animationMaxScale)
        : _gestureDetails.totalScale;

    //Round the scale to three points after comma to prevent shaking
    //scale = roundAfter(scale, 3);
    //no more zoom
    if (details.scale != 1.0 &&
        ((doubleEqual(_gestureDetails.totalScale,
                    _gestureConfig.animationMinScale) &&
                doubleCompare(scale, _gestureDetails.totalScale) <= 0) ||
            (doubleEqual(_gestureDetails.totalScale,
                    _gestureConfig.animationMaxScale) &&
                doubleCompare(scale, _gestureDetails.totalScale) >= 0))) {
      return;
    }

    final Offset offset =
        (details.scale == 1.0 ? details.focalPoint : _startingOffset) -
            _normalizedOffset * scale;

    if (mounted &&
        (offset != _gestureDetails.offset ||
            scale != _gestureDetails.totalScale)) {
      setState(() {
        _gestureDetails = GestureDetails(
            offset: offset,
            totalScale: scale,
            gestureDetails: _gestureDetails,
            actionType:
                details.scale != 1.0 ? ActionType.zoom : ActionType.pan);
      });
    }
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    if (extendedImageSlidePageState != null &&
        extendedImageSlidePageState.isSliding) {
      _updateSlidePagePreOffset = null;
      // _updateSlidePageImageStartingOffset = null;
      extendedImageSlidePageState.endSlide(details);
      return;
    }
    //animate back to maxScale if gesture exceeded the maxScale specified
    if (doubleCompare(_gestureDetails.totalScale, _gestureConfig.maxScale) >
        0) {
      final double velocity =
          (_gestureDetails.totalScale - _gestureConfig.maxScale) /
              _gestureConfig.maxScale;

      _gestureAnimation.animationScale(
          _gestureDetails.totalScale, _gestureConfig.maxScale, velocity);
      return;
    }

    //animate back to minScale if gesture fell smaller than the minScale specified
    if (doubleCompare(_gestureDetails.totalScale, _gestureConfig.minScale) <
        0) {
      final double velocity =
          (_gestureConfig.minScale - _gestureDetails.totalScale) /
              _gestureConfig.minScale;

      _gestureAnimation.animationScale(
          _gestureDetails.totalScale, _gestureConfig.minScale, velocity);
      return;
    }

    if (_gestureDetails.actionType == ActionType.pan) {
      // get magnitude from gesture velocity
      final double magnitude = details.velocity.pixelsPerSecond.distance;

      // do a significant magnitude
      if (doubleCompare(magnitude, minMagnitude) >= 0) {
        final Offset direction = details.velocity.pixelsPerSecond /
            magnitude *
            _gestureConfig.inertialSpeed;

        _gestureAnimation.animationOffset(
            _gestureDetails.offset, _gestureDetails.offset + direction);
      }
    }
  }

  void _handleDoubleTap() {
    if (widget.extendedImageState.imageWidget.onDoubleTap != null) {
      widget.extendedImageState.imageWidget.onDoubleTap(this);
      return;
    }

    if (!mounted) {
      return;
    }

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

    _pageViewState?.extendedImageGestureState = this;
  }

  @override
  Widget build(BuildContext context) {
    if (_gestureConfig.cacheGesture) {
      _gestureDetailsCache[widget.extendedImageState.imageStreamKey] =
          _gestureDetails;
    }

    Widget image = ExtendedRawImage(
      image: widget.extendedImageState.extendedImageInfo?.image,
      width: widget.extendedImageState.imageWidget.width,
      height: widget.extendedImageState.imageWidget.height,
      scale: widget.extendedImageState.extendedImageInfo?.scale ?? 1.0,
      color: widget.extendedImageState.imageWidget.color,
      colorBlendMode: widget.extendedImageState.imageWidget.colorBlendMode,
      fit: widget.extendedImageState.imageWidget.fit,
      alignment: widget.extendedImageState.imageWidget.alignment,
      repeat: widget.extendedImageState.imageWidget.repeat,
      centerSlice: widget.extendedImageState.imageWidget.centerSlice,
      matchTextDirection:
          widget.extendedImageState.imageWidget.matchTextDirection,
      invertColors: widget.extendedImageState.invertColors,
      filterQuality: widget.extendedImageState.imageWidget.filterQuality,
      beforePaintImage: widget.extendedImageState.imageWidget.beforePaintImage,
      afterPaintImage: widget.extendedImageState.imageWidget.afterPaintImage,
      gestureDetails: _gestureDetails,
    );

    if (extendedImageSlidePageState != null) {
      image = widget.extendedImageState.imageWidget?.heroBuilderForSlidingPage
              ?.call(image) ??
          image;
      if (extendedImageSlidePageState.widget.slideType == SlideType.onlyImage) {
        image = Transform.translate(
          offset: extendedImageSlidePageState.offset,
          child: Transform.scale(
            scale: extendedImageSlidePageState.scale,
            child: image,
          ),
        );
      }
    }

    image = widget.imageBuilder?.call(image) ?? image;

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

    return image;
  }

  GestureDetails get gestureDetails => _gestureDetails;
  set gestureDetails(GestureDetails value) {
    if (mounted) {
      setState(() {
        _gestureDetails = value;
      });
    }
  }

  GestureConfig get imageGestureConfig => _gestureConfig;

  void handleDoubleTap({double scale, Offset doubleTapPosition}) {
    doubleTapPosition ??= _pointerDownPosition;
    scale ??= _gestureConfig.initialScale;
    //scale = scale.clamp(_gestureConfig.minScale, _gestureConfig.maxScale);
    _handleScaleStart(ScaleStartDetails(focalPoint: doubleTapPosition));
    _handleScaleUpdate(ScaleUpdateDetails(
        focalPoint: doubleTapPosition, scale: scale / _startingScale));
    if (scale < _gestureConfig.minScale || scale > _gestureConfig.maxScale) {
      _handleScaleEnd(ScaleEndDetails());
    }
  }

  Offset get pointerDownPosition => _pointerDownPosition;

  void slide() {
    if (mounted) {
      setState(() {
        _gestureDetails.slidePageOffset = extendedImageSlidePageState?.offset;
      });
    }
  }

  void reset() {
    if (mounted) {
      setState(() {
        _gestureConfig = widget
                .extendedImageState.imageWidget.initGestureConfigHandler
                ?.call(widget.extendedImageState) ??
            GestureConfig();

        _gestureDetails = GestureDetails(
          totalScale: _gestureConfig.initialScale,
          offset: Offset.zero,
        )..initialAlignment = _gestureConfig.initialAlignment;
      });
    }
  }
}

Map<Object, GestureDetails> _gestureDetailsCache = <Object, GestureDetails>{};

///clear the gesture details
void clearGestureDetailsCache() {
  _gestureDetailsCache.clear();
}
