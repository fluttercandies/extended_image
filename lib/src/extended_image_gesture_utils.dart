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

enum InPageView {
  ///image is not in pageview
  none,

  ///image is in horizontal pageview
  horizontal,

  ///image is in vertical pageview
  vertical
}

abstract class ExtendedImageGestureState {
  GestureDetails get gestureDetails;
  set gestureDetails(GestureDetails value);

  ImageGestureConfig get imageGestureConfig;
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

  GestureState _gestureState = GestureState.move;
  GestureState get gestureState => _gestureState;

  GestureDetails(
      {this.offset, this.totalScale, GestureDetails gestureDetails}) {
    if (gestureDetails != null) {
      _computeVerticalBoundary = gestureDetails._computeVerticalBoundary;
      _computeHorizontalBoundary = gestureDetails._computeHorizontalBoundary;

      if (totalScale == gestureDetails.totalScale) {
        _gestureState = GestureState.move;
      } else {
        _gestureState = GestureState.zoom;
      }
    }
  }

  Offset _getCenter(Rect destinationRect) {
    //return destinationRect.center * scale + offset;
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
    Offset center = _getCenter(destinationRect);
    Rect result = _getDestinationRect(destinationRect, center);

    if (_computeHorizontalBoundary) {
      //move right
      if (result.left >= layoutRect.left) {
        result = Rect.fromLTWH(0.0, result.top, result.width, result.height);

        ///fix offset
        offset = _getFixedOffset(destinationRect, result.center);
        _boundary.left = true;
      }

      ///move left
      if (result.right <= layoutRect.right) {
        result = Rect.fromLTWH(layoutRect.right - result.width, result.top,
            result.width, result.height);

        ///fix offset
        offset = _getFixedOffset(destinationRect, result.center);
        _boundary.right = true;
      }
    }

    if (_computeVerticalBoundary) {
      //move down
      if (result.bottom <= layoutRect.bottom) {
        result = Rect.fromLTWH(result.left, layoutRect.bottom - result.height,
            result.width, result.height);

        ///fix offset
        offset = _getFixedOffset(destinationRect, result.center);
        _boundary.bottom = true;
      }

      //move up
      if (result.top >= layoutRect.top) {
        result = Rect.fromLTWH(
            result.left, layoutRect.top, result.width, result.height);

        ///fix offset
        offset = _getFixedOffset(destinationRect, result.center);
        _boundary.top = true;
      }
    }

    _computeHorizontalBoundary =
        result.left <= layoutRect.left && result.right >= layoutRect.right;

    _computeVerticalBoundary =
        result.top <= layoutRect.top && result.bottom >= layoutRect.bottom;
    return result;
  }

  bool movePage(Offset delta) {
    return (delta.dx < 0 && boundary.right) ||
        (delta.dx > 0 && boundary.left) ||
        (delta.dy < 0 && boundary.bottom) ||
        (delta.dy > 0 && boundary.top) ||
        totalScale <= 1.0;
  }
}

class ImageGestureConfig {
  final double minScale;
  final double maxScale;
  final double speed;
  final bool cacheGesture;
  final InPageView inPageView;
  final double inertialSpeed;
  final double initialScale;
  ImageGestureConfig(
      {this.minScale: 0.8,
      this.maxScale: 5.0,
      this.speed: 1.0,
      this.cacheGesture: false,
      this.inertialSpeed: 100.0,
      this.initialScale: 1.0,
      this.inPageView: InPageView.none});
}

//Round the scale to three points after comma to prevent shaking
double roundAfter(double number, int position) {
  double shift = pow(10, position).toDouble();
  return (number * shift).roundToDouble() / shift;
}

enum GestureState {
  zoom,
  move,
}

const double minMagnitude = 400.0;
const double velocity = minMagnitude / 1000.0;

class GestureInertiaAnimation {
  AnimationController _controller;
  Animation<Offset> _animation;

  GestureInertiaAnimation(
      TickerProvider vsync, GestureOffsetAnimationCallBack callback) {
    _controller = AnimationController(vsync: vsync);
    _controller.addListener(() {
      //print(_animation.value);
      callback?.call(_animation.value);
    });
  }

  void animation(Offset begin, Offset end) {
    _animation = _controller.drive(Tween<Offset>(begin: begin, end: end));
    _controller
      ..value = 0.0
      ..fling(velocity: velocity);
  }

  void dispose() {
    _controller.dispose();
  }

  void stop() {
    _controller.stop();
  }
}

///gesture
