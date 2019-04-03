import 'package:flutter/material.dart';

enum LoadState {
  //loading
  loading,
  //completed
  completed,
  //failed
  failed
}

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

enum ExtendedImageMode {
  //just show image
  None,
  //support be to zoom,scroll
  Gesture,
}

///get type from T
Type typeOf<T>() => T;
