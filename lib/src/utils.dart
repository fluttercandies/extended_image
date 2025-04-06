import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'extended_image.dart';
import 'gesture/slide_page.dart';

enum LoadState {
  /// loading
  loading,

  /// completed
  completed,

  /// failed
  failed,
}

mixin ExtendedImageState {
  void reLoadImage();
  ImageInfo? get extendedImageInfo;
  LoadState get extendedImageLoadState;

  ///return widget which from LoadStateChanged function immediately
  late bool returnLoadStateChangedWidget;

  ImageProvider get imageProvider;

  bool get invertColors;

  Object? get imageStreamKey;

  ExtendedImage get imageWidget;

  Widget get completedWidget;

  ImageChunkEvent? get loadingProgress;

  int? get frameNumber;

  bool get wasSynchronouslyLoaded;

  ExtendedImageSlidePageState? get slidePageState;

  Object? get lastException;
  StackTrace? get lastStack;
}

enum ExtendedImageMode {
  /// just show image
  none,

  /// support be to zoom,scroll
  gesture,

  /// support be to crop,rotate,flip
  editor,
}

///get type from T
Type typeOf<T>() => T;

double clampScale(double scale, double min, double max) {
  return scale.clamp(min, max);
}

/// Returns a value indicating whether two instances of Double represent the same value.
///
/// [value] equal to [other] will return `true`, otherwise, `false`.
///
/// If [value] or [other] is not finite (`NaN` or infinity), throws an [UnsupportedError].
// bool doubleEqual(double value, double other) {
//   return doubleCompare(value, other) == 0;
// }

/// Compare two double-precision values.
/// Returns an integer that indicates whether [value] is less than, equal to, or greater than [other].
///
/// [value] less than [other] will return `-1`
/// [value] equal to [other] will return `0`
/// [value] greater than [other] will return `1`
///
/// If [value] or [other] is not finite (`NaN` or infinity), throws an [UnsupportedError].
// int doubleCompare(double value, double other,
//     {double precision = precisionErrorTolerance}) {
//   if (value.isNaN || other.isNaN) {
//     throw UnsupportedError('Compared with Infinity or NaN');
//   }
//   final double n = value - other;
//   if (n.abs() < precision) {
//     return 0;
//   }
//   return n < 0 ? -1 : 1;
// }

extension DoubleExtension on double {
  bool get isZero => abs() < precisionErrorTolerance;
  int compare(double other, {double precision = precisionErrorTolerance}) {
    if (isNaN || other.isNaN) {
      throw UnsupportedError('Compared with Infinity or NaN');
    }
    final double n = this - other;
    if (n.abs() < precision) {
      return 0;
    }
    return n < 0 ? -1 : 1;
  }

  bool greaterThan(double other, {double precision = precisionErrorTolerance}) {
    return compare(other, precision: precision) > 0;
  }

  bool lessThan(double other, {double precision = precisionErrorTolerance}) {
    return compare(other, precision: precision) < 0;
  }

  bool equalTo(double other, {double precision = precisionErrorTolerance}) {
    return compare(other, precision: precision) == 0;
  }

  bool greaterThanOrEqualTo(
    double other, {
    double precision = precisionErrorTolerance,
  }) {
    return compare(other, precision: precision) >= 0;
  }

  bool lessThanOrEqualTo(
    double other, {
    double precision = precisionErrorTolerance,
  }) {
    return compare(other, precision: precision) <= 0;
  }
}

extension DoubleExtensionNullable on double? {
  bool equalTo(double? other, {double precision = precisionErrorTolerance}) {
    if (this == null && other == null) {
      return true;
    }
    if (this == null || other == null) {
      return false;
    }
    return this!.compare(other, precision: precision) == 0;
  }
}

extension RectExtension on Rect {
  bool beyond(Rect other) {
    return left.lessThan(other.left) ||
        right.greaterThan(other.right) ||
        top.lessThan(other.top) ||
        bottom.greaterThan(other.bottom);
  }

  bool topIsSame(Rect other) => top.equalTo(other.top);
  bool leftIsSame(Rect other) => left.equalTo(other.left);
  bool rightIsSame(Rect other) => right.equalTo(other.right);
  bool bottomIsSame(Rect other) => bottom.equalTo(other.bottom);

  bool isSame(Rect other) =>
      topIsSame(other) &&
      leftIsSame(other) &&
      rightIsSame(other) &&
      bottomIsSame(other);

  bool containsOffset(Offset offset) {
    return offset.dx >= left &&
        offset.dx <= right &&
        offset.dy >= top &&
        offset.dy <= bottom;
  }

  bool containsRect(Rect rect) {
    return left.lessThanOrEqualTo(rect.left) &&
        right.greaterThanOrEqualTo(rect.right) &&
        top.lessThanOrEqualTo(rect.top) &&
        bottom.greaterThanOrEqualTo(rect.bottom);
  }
}

extension RectExtensionNullable on Rect? {
  bool isSame(Rect? other) {
    if (this == null && other == null) {
      return true;
    }
    if (this == null || other == null) {
      return false;
    }
    return this!.isSame(other);
  }
}

extension OffsetExtension on Offset {
  bool isSame(Offset other) => dx.equalTo(other.dx) && dy.equalTo(other.dy);
}

extension OffsetExtensionNullable on Offset? {
  bool isSame(Offset? other) {
    if (this == null && other == null) {
      return true;
    }
    if (this == null || other == null) {
      return false;
    }
    return this!.isSame(other);
  }
}

extension DebounceThrottlingE on Function {
  VoidFunction debounce([Duration duration = const Duration(seconds: 1)]) {
    Timer? _debounce;
    return () {
      if (_debounce?.isActive ?? false) {
        _debounce!.cancel();
      }
      _debounce = Timer(duration, () {
        this.call();
      });
    };
  }

  VoidFunction throttle([Duration duration = const Duration(seconds: 1)]) {
    Timer? _throttle;
    return () {
      if (_throttle?.isActive ?? false) {
        return;
      }
      this.call();
      _throttle = Timer(duration, () {});
    };
  }
}

typedef VoidFunction = void Function();
