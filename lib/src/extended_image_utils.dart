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
  final Offset offset;

  final double scale;

//  ///layout rect
//  Rect rect;
//
//  ///raw rect for image.
//  Rect destinationRect;

  ///
  final Offset delta;

  GestureDetails({this.offset, this.scale, this.delta});
}

class ImageGestureHandler {
  final double minScale;
  final double maxScale;
  final double speed;
  final bool cacheGesture;
  ImageGestureHandler(
      {this.minScale: 0.9,
      this.maxScale: 5.0,
      this.speed: 1.0,
      this.cacheGesture: false});
}

Rect hanldeGesture(
    GestureDetails gestureDetails, Rect layoutRect, Rect destinationRect) {
  final Offset center = destinationRect.size.center(destinationRect.topLeft) *
          gestureDetails.scale +
      gestureDetails.offset;

  final double width = destinationRect.width * gestureDetails.scale;
  final double height = destinationRect.height * gestureDetails.scale;

  return Rect.fromLTWH(
      center.dx - width / 2.0, center.dy - height / 2.0, width, height);
}

bool outRect(Rect rect, Rect destinationRect) {
  return destinationRect.top < rect.top ||
      destinationRect.left < rect.left ||
      destinationRect.right > rect.right ||
      destinationRect.bottom > rect.bottom;
}

enum ExtendedImageMode {
  //just show image
  None,
  //support be to zoom,scroll
  Gesture,
}
