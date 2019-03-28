import 'package:flutter/material.dart';
import 'dart:ui' as ui show Image;

enum LoadState {
  //loading
  loading,
  //completed
  completed,
  //failed
  failed
}

typedef LoadStateChanged = Widget Function(ExtendedImageState state);

///[rect] is render size
///if return true, it will not paint original image,
typedef BeforePaintImage = bool Function(
    Canvas canvas, Rect rect, ui.Image image, Paint paint);

typedef AfterPaintImage = void Function(
    Canvas canvas, Rect rect, ui.Image image, Paint paint);

abstract class ExtendedImageState {
  void reLoadImage();
  ImageInfo get extendedImageInfo;
  LoadState get extendedImageLoadState;

  ///return widget which from LoadStateChanged fucntion  immediately
  bool returnLoadStateChangedWidget;

  ImageProvider get imageProvider;

  bool get invertColors;

  Object get imageStreamKey;
}

///clear all of image in memory
void clearMemoryImageCache() {
  PaintingBinding.instance.imageCache.clear();
}

/// get ImageCache
ImageCache getMemoryImageCache() {
  return PaintingBinding.instance.imageCache;
}

class GestureDetails {
  ///scale center delta
  Offset offset;

  final double scale;

//  final PageView pageView;
//  ///layout rect
  Rect rect;
//
//  ///raw rect for image.
//  Rect destinationRect;

  bool _computeHorizontalBoundary = false;
  bool _computeVerticalBoundary = false;
  Offset _center;
  Boundary boundary = Boundary();

//  bool get reachHorizontalBoundary {
//    if (delta != null && delta.dx != 0.0) {
//      return (delta.dx < 0 && boundary == Boundary.Right) ||
//          (delta.dx > 0 && boundary == Boundary.Left);
//    }
//    return false;
//  }

  bool _zooming = false;

  GestureDetails({this.offset, this.scale, GestureDetails gestureDetails}) {
    if (scale <= 1.0) {
      offset = Offset.zero;
    }

    if (gestureDetails != null) {
      _computeVerticalBoundary = gestureDetails._computeVerticalBoundary;
      _computeHorizontalBoundary = gestureDetails._computeHorizontalBoundary;
      _center = gestureDetails._center;
      boundary = gestureDetails.boundary;
      //keep offset when zoom in/out
//      if (scale > 1 && scale != gestureDetails.scale) {
//        offset = gestureDetails.offset;
//      }
      _zooming = scale != gestureDetails.scale;
    }
  }

  Offset _getCenter(Rect destinationRect) {
    //return destinationRect.center * scale + offset;

    return destinationRect.center * (scale > 1.0 ? scale : 1.0) + offset;
  }

  Rect _getDestinationRect(Rect destinationRect, Offset center) {
    final double width = destinationRect.width * scale;
    final double height = destinationRect.height * scale;

    return Rect.fromLTWH(
        center.dx - width / 2.0, center.dy - height / 2.0, width, height);
  }

  Rect calculateFinalDestinationRect(Rect layoutRect, Rect destinationRect) {
    Offset center = _getCenter(destinationRect);

    if (_zooming && _center != null) {
      center = _center;
    }

    Rect result = _getDestinationRect(destinationRect, center);

    Offset delta = Offset.zero;

    if (this._center != null) {
      delta = center - this._center;
    }

    boundary = Boundary();
    if (delta != Offset.zero) {
      if (_computeHorizontalBoundary) {
        //move right
        if (delta.dx > 0 && result.left >= layoutRect.left) {
          result = Rect.fromLTWH(0.0, result.top, result.width, result.height);

          offset = result.center - destinationRect.center * scale;
          boundary.left = true;
        }

        ///move left
        if (delta.dx < 0 && result.right <= layoutRect.right) {
          result = Rect.fromLTWH(layoutRect.right - result.width, result.top,
              result.width, result.height);

          offset = result.center - destinationRect.center * scale;
          boundary.right = true;
        }
      }

      if (_computeVerticalBoundary) {
        //move down
        if (delta.dy < 0 && result.bottom <= layoutRect.bottom) {
          result = Rect.fromLTWH(result.left, layoutRect.bottom - result.height,
              result.width, result.height);

          offset = result.center - destinationRect.center * scale;
          boundary.bottom = true;
        }

        //move up
        if (delta.dy > 0 && result.top >= layoutRect.top) {
          result = Rect.fromLTWH(
              result.left, layoutRect.top, result.width, result.height);

          offset = result.center - destinationRect.center * scale;
          boundary.top = true;
        }
      }
    }

    _computeHorizontalBoundary =
        result.left <= layoutRect.left && result.right >= layoutRect.right;

    _computeVerticalBoundary =
        result.top <= layoutRect.top && result.bottom >= layoutRect.bottom;

    //print("$_computeHorizontalBoundary");
    print(boundary);
    this._center = _getCenter(destinationRect);

    return result;
  }
}

class ImageGestureConfig {
  final double minScale;
  final double maxScale;
  final double speed;
  final bool cacheGesture;
  final InPageView inPageView;
  ImageGestureConfig(
      {this.minScale: 1.0,
      this.maxScale: 5.0,
      this.speed: 1.0,
      this.cacheGesture: false,
      this.inPageView: InPageView.none});
}

enum ExtendedImageMode {
  //just show image
  None,
  //support be to zoom,scroll
  Gesture,
}

///gesture

///whether gesture rect is out size
bool outRect(Rect rect, Rect destinationRect) {
  return destinationRect.top < rect.top ||
      destinationRect.left < rect.left ||
      destinationRect.right > rect.right ||
      destinationRect.bottom > rect.bottom;
}

/////
//bool containRect(Rect rect, Rect destinationRect) {
//  return destinationRect.top < rect.top ||
//      destinationRect.left < rect.left ||
//      destinationRect.right > rect.right ||
//      destinationRect.bottom > rect.bottom;
//}

bool testRect(Rect layoutRect, Rect destinationRect) {
  return destinationRect.contains(layoutRect.topLeft) &&
      destinationRect.contains(layoutRect.topRight) &&
      destinationRect.contains(layoutRect.bottomLeft) &&
      destinationRect.contains(layoutRect.bottomRight);
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

///gesture

///get type from T
Type typeOf<T>() => T;
