import 'package:flutter/material.dart';

import 'extended_image.dart';

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

  ExtendedImage get imageWidget;
}

enum ExtendedImageMode {
  //just show image
  none,
  //support be to zoom,scroll
  gesture,
  //support be to crop,rotate,flip
  editor
}

///get type from T
Type typeOf<T>() => T;

double clampScale(double scale, double min, double max) {
  return scale.clamp(min, max);
}
