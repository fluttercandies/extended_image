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

//  ///layout rect
//  Rect rect;
//
//  ///raw rect for image.
//  Rect destinationRect;

  ///
  final Offset delta;

  final bool computeBoundary;

  Boundary boundary = Boundary();

//  bool get reachHorizontalBoundary {
//    if (delta != null && delta.dx != 0.0) {
//      return (delta.dx < 0 && boundary == Boundary.Right) ||
//          (delta.dx > 0 && boundary == Boundary.Left);
//    }
//    return false;
//  }

  GestureDetails(
      {this.offset, this.scale, this.delta, this.computeBoundary: false});
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

///handle gesture rect
Rect hanldeGesture(
    GestureDetails gestureDetails, Rect layoutRect, Rect destinationRect) {
  ///keep center when scale <=1.0
  final Offset center = destinationRect.center *
          (gestureDetails.scale > 1.0 ? gestureDetails.scale : 1.0) +
      gestureDetails.offset;

  var temp = destinationRect;
  final double width = destinationRect.width * gestureDetails.scale;
  final double height = destinationRect.height * gestureDetails.scale;

  destinationRect = Rect.fromLTWH(
      center.dx - width / 2.0, center.dy - height / 2.0, width, height);

  final Offset delta = gestureDetails.delta;
  gestureDetails.boundary = Boundary();
  if (delta != null && gestureDetails.computeBoundary) {
    //move right
    if (delta.dx > 0 && destinationRect.left > layoutRect.left) {
      destinationRect = Rect.fromLTWH(0.0, destinationRect.top,
          destinationRect.width, destinationRect.height);

      gestureDetails.offset =
          destinationRect.center - temp.center * gestureDetails.scale;
      gestureDetails.boundary.left = true;
    }

    ///move left
    if (delta.dx < 0 && destinationRect.right < layoutRect.right) {
      destinationRect = Rect.fromLTWH(layoutRect.right - destinationRect.width,
          destinationRect.top, destinationRect.width, destinationRect.height);
      gestureDetails.offset =
          destinationRect.center - temp.center * gestureDetails.scale;
      gestureDetails.boundary.right = true;
    }

    //move down
    if (delta.dy < 0 && destinationRect.bottom < layoutRect.bottom) {
      destinationRect = Rect.fromLTWH(
          destinationRect.left,
          layoutRect.bottom - destinationRect.height,
          destinationRect.width,
          destinationRect.height);

      gestureDetails.offset =
          destinationRect.center - temp.center * gestureDetails.scale;
      gestureDetails.boundary.bottom = true;
    }

    //move up
    if (delta.dy > 0 && destinationRect.top > layoutRect.top) {
      destinationRect = Rect.fromLTWH(destinationRect.left, layoutRect.top,
          destinationRect.width, destinationRect.height);

      gestureDetails.offset =
          destinationRect.center - temp.center * gestureDetails.scale;
      gestureDetails.boundary.top = true;
    }
  }
  //print(gestureDetails.boundary);
  return destinationRect;
}

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
