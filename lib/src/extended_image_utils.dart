import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'extended_image.dart';
import 'gesture/extended_image_slide_page.dart';

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

  ///return widget which from LoadStateChanged function immediately
  bool returnLoadStateChangedWidget;

  ImageProvider get imageProvider;

  bool get invertColors;

  Object get imageStreamKey;

  ExtendedImage get imageWidget;

  Widget get completedWidget;

  ImageChunkEvent get loadingProgress;

  int get frameNumber;

  bool get wasSynchronouslyLoaded;

  ExtendedImageSlidePageState get slidePageState;
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
  return scale.clamp(min, max) as double;
}

/// Returns a value indicating whether two instances of Double represent the same value.
///
/// [value] equal to [other] will return `true`, otherwise, `false`.
///
/// If [value] or [other] is not finite (`NaN` or infinity), throws an [UnsupportedError].
bool doubleEqual(double value, double other) {
  return doubleCompare(value, other) == 0;
}

/// Compare two double-precision values.
/// Returns an integer that indicates whether [value] is less than, equal to, or greater than [other].
///
/// [value] less than [other] will return `-1`
/// [value] equal to [other] will return `0`
/// [value] greater than [other] will return `1`
///
/// If [value] or [other] is not finite (`NaN` or infinity), throws an [UnsupportedError].
int doubleCompare(double value, double other,
    {double precision = precisionErrorTolerance}) {
  if (value.isNaN || other.isNaN) {
    throw UnsupportedError('Compared with Infinity or NaN');
  }
  final double n = value - other;
  if (n.abs() < precision) {
    return 0;
  }
  return n < 0 ? -1 : 1;
}
