import 'dart:math';

import 'package:extended_image/src/extended_image_typedef.dart';
import 'package:flutter/material.dart';

///
///  extended_image_gesture_utils.dart
///  create by zmtzawqlp on 2019/4/3
///

///gesture

///whether gesture rect is out size
bool outRect(Rect rect, Rect destinationRect) {
  return destinationRect.top < rect.top ||
      destinationRect.left < rect.left ||
      destinationRect.right > rect.right ||
      destinationRect.bottom > rect.bottom;
}

class Boundary {
  bool left;
  bool right;
  bool bottom;
  bool top;
  Boundary(
      {this.left: false,
      this.right: false,
      this.top: false,
      this.bottom: false});

  @override
  String toString() {
    // TODO: implement toString
    return "left:$left,right:$right,top:$top,bottom:$bottom";
  }
}

//enum InPageView {
//  ///image is not in pageview
//  none,
//
//  ///image is in horizontal pageview
//  horizontal,
//
//  ///image is in vertical pageview
//  vertical
//}

abstract class ExtendedImageGestureState {
  GestureDetails get gestureDetails;
  set gestureDetails(GestureDetails value);

  GestureConfig get imageGestureConfig;

  Offset get pointerDownPosition;

  void handleDoubleTap({double scale, Offset doubleTapPosition});
}

class GestureDetails {
  ///scale center delta
  Offset offset;

  ///total scale of image
  final double totalScale;

  bool _computeVerticalBoundary = false;
  bool get computeVerticalBoundary => _computeVerticalBoundary;

  ///whether
  bool _computeHorizontalBoundary = false;
  bool get computeHorizontalBoundary => _computeHorizontalBoundary;

  Boundary _boundary = Boundary();
  Boundary get boundary => _boundary;

  GestureState _gestureState = GestureState.pan;
  GestureState get gestureState => _gestureState;

  //true: user zoom/pan
  //false: animation
  final bool userOffset;

  //pre
  Offset _center;

  Rect layoutRect;
  Rect destinationRect;

  GestureDetails(
      {this.offset,
      this.totalScale,
      GestureDetails gestureDetails,
      bool zooming: false,
      this.userOffset: true}) {
    if (gestureDetails != null) {
      _computeVerticalBoundary = gestureDetails._computeVerticalBoundary;
      _computeHorizontalBoundary = gestureDetails._computeHorizontalBoundary;
      _center = gestureDetails._center;
      layoutRect = gestureDetails.layoutRect;
      destinationRect = gestureDetails.destinationRect;

      ///zoom end will call twice
      /// zoom end
      /// zoom start
      /// zoom update
      /// zoom end
    }

    _gestureState = zooming ? GestureState.zoom : GestureState.pan;
  }

  Offset _getCenter(Rect destinationRect) {
    if (!userOffset && _center != null) {
      return _center;
    }

    if (totalScale > 1.0) {
      if (_computeHorizontalBoundary && _computeVerticalBoundary) {
        return destinationRect.center * totalScale + offset;
      } else if (_computeHorizontalBoundary) {
        //only scale Horizontal
        return Offset(destinationRect.center.dx * totalScale,
                destinationRect.center.dy) +
            Offset(offset.dx, 0.0);
      } else if (_computeVerticalBoundary) {
        //only scale Vertical
        return Offset(destinationRect.center.dx,
                destinationRect.center.dy * totalScale) +
            Offset(0.0, offset.dy);
      } else {
        return destinationRect.center;
      }
    } else {
      return destinationRect.center;
    }
  }

  Offset _getFixedOffset(Rect destinationRect, Offset center) {
    if (totalScale > 1.0) {
      if (_computeHorizontalBoundary && _computeVerticalBoundary) {
        return center - destinationRect.center * totalScale;
      } else if (_computeHorizontalBoundary) {
        //only scale Horizontal
        return center -
            Offset(destinationRect.center.dx * totalScale,
                destinationRect.center.dy);
      } else if (_computeVerticalBoundary) {
        //only scale Vertical
        return center -
            Offset(destinationRect.center.dx,
                destinationRect.center.dy * totalScale);
      } else {
        return center - destinationRect.center;
      }
    } else {
      return center - destinationRect.center;
    }
  }

  Rect _getDestinationRect(Rect destinationRect, Offset center) {
    final double width = destinationRect.width * totalScale;
    final double height = destinationRect.height * totalScale;

    return Rect.fromLTWH(
        center.dx - width / 2.0, center.dy - height / 2.0, width, height);
  }

  Rect calculateFinalDestinationRect(Rect layoutRect, Rect destinationRect) {
    var temp = offset;
    _innerCalculateFinalDestinationRect(layoutRect, destinationRect);
    offset = temp;
    return _innerCalculateFinalDestinationRect(layoutRect, destinationRect);
  }

  Rect _innerCalculateFinalDestinationRect(
      Rect layoutRect, Rect destinationRect) {
    Offset center = _getCenter(destinationRect);
    Rect result = _getDestinationRect(destinationRect, center);
    if (_computeHorizontalBoundary) {
      //move right
      if (result.left >= layoutRect.left) {
        result = Rect.fromLTWH(0.0, result.top, result.width, result.height);
        _boundary.left = true;
      }

      ///move left
      if (result.right <= layoutRect.right) {
        result = Rect.fromLTWH(layoutRect.right - result.width, result.top,
            result.width, result.height);
        _boundary.right = true;
      }
    }

    if (_computeVerticalBoundary) {
      //move down
      if (result.bottom <= layoutRect.bottom) {
        result = Rect.fromLTWH(result.left, layoutRect.bottom - result.height,
            result.width, result.height);
        _boundary.bottom = true;
      }

      //move up
      if (result.top >= layoutRect.top) {
        result = Rect.fromLTWH(
            result.left, layoutRect.top, result.width, result.height);
        _boundary.top = true;
      }
    }

    _computeHorizontalBoundary =
        result.left <= layoutRect.left && result.right >= layoutRect.right;

    _computeVerticalBoundary =
        result.top <= layoutRect.top && result.bottom >= layoutRect.bottom;

    ///fix offset
    offset = _getFixedOffset(destinationRect, result.center);
    _center = result.center;
    //offset = Offset(roundAfter(offset.dx, 4), roundAfter(offset.dy, 4));
    return result;
  }

  bool movePage(Offset delta) {
    bool canMoveHorizontal = delta.dx != 0 &&
        ((delta.dx < 0 && boundary.right) ||
            (delta.dx > 0 && boundary.left) ||
            !_computeHorizontalBoundary);

    bool canMoveVertical = delta.dy != 0 &&
        ((delta.dy < 0 && boundary.bottom) ||
            (delta.dy > 0 && boundary.top) ||
            !_computeVerticalBoundary);

    return canMoveHorizontal || canMoveVertical || totalScale <= 1.0;
  }

  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) return false;
    final GestureDetails typedOther = other;
    return totalScale == typedOther.totalScale && offset == typedOther.offset;
  }

  @override
  int get hashCode => hashValues(totalScale, offset);
}

class GestureConfig {
  //the min scale for zooming then animation back to minScale when scale end
  final double animationMinScale;
  //min scale
  final double minScale;

  //the max scale for zooming then animation back to maxScale when scale end
  final double animationMaxScale;
  //max scale
  final double maxScale;

  //speed for zoom/pan
  final double speed;

  ///save Gesture state (for example in page view, so that the state will not change when scroll back),
  ///remember clearGestureDetailsCache  at right time
  final bool cacheGesture;

  ///whether in page view
  final bool inPageView;

  /// final double magnitude = details.velocity.pixelsPerSecond.distance;
  ///final Offset direction = details.velocity.pixelsPerSecond / magnitude * _gestureConfig.inertialSpeed;
  final double inertialSpeed;

  //initial scale of image
  final double initialScale;
  GestureConfig(
      {double minScale,
      double maxScale,
      double speed,
      bool cacheGesture,
      double inertialSpeed,
      double initialScale,
      bool inPageView,
      double animationMinScale,
      double animationMaxScale})
      : minScale = minScale ??= 0.8,
        maxScale = maxScale ??= 5.0,
        speed = speed ??= 1.0,
        cacheGesture = cacheGesture ?? false,
        inertialSpeed = inertialSpeed ??= 100.0,
        initialScale = initialScale ??= 1.0,
        inPageView = inPageView ?? false,
        animationMinScale = animationMinScale ??= minScale * 0.8,
        animationMaxScale = animationMaxScale ??= maxScale * 1.2,
        assert(minScale <= maxScale),
        assert(animationMinScale <= animationMaxScale),
        assert(animationMinScale <= minScale),
        assert(animationMaxScale >= maxScale),
        assert(minScale <= initialScale && initialScale <= maxScale),
        assert(speed > 0),
        assert(inertialSpeed > 0);
}

double roundAfter(double number, int position) {
  double shift = pow(10, position).toDouble();
  return (number * shift).roundToDouble() / shift;
}

enum GestureState {
  ///zoom in/ zoom out
  zoom,

  /// horizontal and vertical move
  pan,
}

const double minMagnitude = 400.0;
const double velocity = minMagnitude / 1000.0;

class GestureAnimation {
  AnimationController _offsetController;
  Animation<Offset> _offsetAnimation;

  AnimationController _scaleController;
  Animation<double> _scaletAnimation;

  GestureAnimation(TickerProvider vsync,
      {GestureOffsetAnimationCallBack offsetCallBack,
      GestureScaleAnimationCallBack scaleCallBack}) {
    if (offsetCallBack != null) {
      _offsetController = AnimationController(vsync: vsync);
      _offsetController.addListener(() {
        //print(_animation.value);
        offsetCallBack(_offsetAnimation.value);
      });
    }

    if (scaleCallBack != null) {
      _scaleController = AnimationController(vsync: vsync);
      _scaleController.addListener(() {
        scaleCallBack(_scaletAnimation.value);
      });
    }
  }

  void animationOffset(Offset begin, Offset end) {
    _offsetAnimation =
        _offsetController.drive(Tween<Offset>(begin: begin, end: end));
    _offsetController
      ..value = 0.0
      ..fling(velocity: velocity);
  }

  void animationScale(double begin, double end, double velocity) {
    _scaletAnimation =
        _scaleController.drive(Tween<double>(begin: begin, end: end));
    _scaleController
      ..value = 0.0
      ..fling(velocity: velocity);
  }

  void dispose() {
    _offsetController?.dispose();
    _scaleController?.dispose();
  }

  void stop() {
    _offsetController?.stop();
//    if (_scaletAnimation != null) {
//      _scaleController.value = 1.0;
//    }
    _scaleController?.stop();
  }
}

///gesture
