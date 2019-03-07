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
typedef BeforePaintImage = void Function(
    {@required Canvas canvas, @required Rect rect, @required ui.Image image});

typedef AfterPaintImage = void Function(
    {@required Canvas canvas, @required Rect rect, @required ui.Image image});

abstract class ExtendedImageState {
  void reLoadImage();
  ImageInfo get ExtendedImageInfo;
  LoadState get ExtendedImageLoadState;

  ///return widget which from LoadStateChanged fucntion  immediately
  bool returnLoadStateChangedWidget;
}

void clearMemoryImageCache() {
  PaintingBinding.instance.imageCache.clear();
}

ImageCache getMemoryImageCache() {
  return PaintingBinding.instance.imageCache;
}
