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
  Offset _offset;

  ///top-left
  Offset get offset => _offset;

  double _scale;
  double get scale => _scale;

  Rect previousRect;

  Rect rect;
  GestureDetails(this._offset, this._scale);

  void test() {}
  @override
  String toString() {
    // TODO: implement toString
    return "offset:$_offset,scale:$_scale";
  }
}

class GestureConfig {
  final double minScale;
  final double maxScale;
  final double speed;
  final bool cacheGesture;
  GestureConfig(
      {this.minScale: 0.3,
      this.maxScale: 5.0,
      this.speed: 1.0,
      this.cacheGesture: false});
}

enum ExtendedImageMode {
  //just show image
  None,
  //support be to zoom,scroll
  Gesture,
}
