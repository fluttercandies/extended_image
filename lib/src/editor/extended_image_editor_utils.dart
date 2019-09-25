import 'dart:math';
import 'package:extended_image/src/extended_image_typedef.dart';
import 'package:flutter/material.dart';

class EditActionDetails {
  double _rotateAngle = 0.0;
  bool _flipX = false;
  bool _flipY = false;
  bool _computeHorizontalBoundary = false;
  bool _computeVerticalBoundary = false;
  Rect _layoutRect;
  Rect _screenDestinationRect;
  Rect _rawDestinationRect;

  double totalScale = 1.0;
  double preTotalScale = 1.0;
  Offset delta;
  Offset screenFocalPoint;
  EdgeInsets cropRectPadding;
  Rect cropRect;

  /// aspect ratio of image
  double originalAspectRatio;

  ///  aspect ratio of crop rect
  double _cropAspectRatio;
  double get cropAspectRatio {
    if (_cropAspectRatio != null) {
      return isHalfPi ? 1.0 / _cropAspectRatio : _cropAspectRatio;
    }
    return null;
  }

  set cropAspectRatio(value) {
    _cropAspectRatio = value;
  }

  ///image
  Rect get screenDestinationRect => _screenDestinationRect;
  set screenDestinationRect(value) => _screenDestinationRect = value;

  bool get flipX => _flipX;

  bool get flipY => _flipY;

  double get rotateAngle => _rotateAngle;

  bool get hasRotateAngle => !isTwoPi;

  bool get hasEditAction => hasRotateAngle || _flipX || _flipY;

  bool get isHalfPi => (_rotateAngle % (pi)) != 0;

  bool get isPi => !isHalfPi && !isTwoPi;

  bool get isTwoPi => (_rotateAngle % (2 * pi)) == 0;

  /// destination rect base on layer
  Rect get layerDestinationRect => screenDestinationRect?.shift(-layoutTopLeft);

  Offset get layoutTopLeft => _layoutRect?.topLeft;

  Rect get rawDestinationRect => _rawDestinationRect;

  Rect get screenCropRect => cropRect?.shift(layoutTopLeft);

  void rotate(double angle, Rect layoutRect) {
    _rotateAngle += angle;
    _rotateAngle %= (2 * pi);
    if (_flipX && _flipY && isPi) {
      _flipX = _flipY = false;
      _rotateAngle = 0.0;
    }

    // _cropRect = rotateRect(_cropRect, _cropRect.center, -angle);
    // screenDestinationRect =
    //     rotateRect(screenDestinationRect, screenCropRect.center, -angle);

    /// take care of boundary
    var newCropRect = getDestinationRect(
        rect: layoutRect,
        inputSize: Size(cropRect.height, cropRect.width),
        fit: BoxFit.contain);

    var scale = newCropRect.width / cropRect.height;

    var newScreenDestinationRect =
        rotateRect(screenDestinationRect, screenCropRect.center, angle);

    var topLeft = screenCropRect.center -
        (screenCropRect.center - newScreenDestinationRect.topLeft) * scale;
    var bottomRight = screenCropRect.center +
        -(screenCropRect.center - newScreenDestinationRect.bottomRight) * scale;

    newScreenDestinationRect = Rect.fromPoints(topLeft, bottomRight);

    cropRect = newCropRect;
    _screenDestinationRect = newScreenDestinationRect;
    totalScale *= scale;
    preTotalScale = totalScale;
  }

  void flip() {
    var flipOrigin = screenCropRect?.center;
    if (isHalfPi) {
      _flipX = !_flipX;
      // _screenDestinationRect = Rect.fromLTRB(
      //     screenDestinationRect.left,
      //     2 * flipOrigin.dy - screenDestinationRect.bottom,
      //     screenDestinationRect.right,
      //     2 * flipOrigin.dy - screenDestinationRect.top);
    } else {
      _flipY = !_flipY;
    }
    _screenDestinationRect = Rect.fromLTRB(
        2 * flipOrigin.dx - screenDestinationRect.right,
        screenDestinationRect.top,
        2 * flipOrigin.dx - screenDestinationRect.left,
        screenDestinationRect.bottom);

    if (_flipX && _flipY && isPi) {
      _flipX = _flipY = false;
      _rotateAngle = 0.0;
    }
  }

  ///screen image rect to paint rect
  Rect paintRect(Rect rect) {
    if (!hasEditAction) return rect;

    var flipOrigin = screenCropRect?.center;
    if (hasRotateAngle) {
      rect = rotateRect(rect, flipOrigin, -_rotateAngle);
    }
    if (flipOrigin != null && flipOrigin != rect.center) {
      if (flipY) {
        rect = Rect.fromLTRB(2 * flipOrigin.dx - rect.right, rect.top,
            2 * flipOrigin.dx - rect.left, rect.bottom);
      }

      if (flipX) {
        rect = Rect.fromLTRB(rect.left, 2 * flipOrigin.dy - rect.bottom,
            rect.right, 2 * flipOrigin.dy - rect.top);
      }
    }

    return rect;
  }

  @override
  int get hashCode => hashValues(_rotateAngle, _flipX, _flipY, cropRect,
      _layoutRect, _rawDestinationRect, _cropAspectRatio, cropRectPadding);

  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) return false;
    final EditActionDetails typedOther = other;
    return _rotateAngle == typedOther.rotateAngle &&
        _flipX == typedOther.flipX &&
        _flipY == typedOther.flipY &&
        cropRect == typedOther.cropRect &&
        _layoutRect == typedOther._layoutRect &&
        _rawDestinationRect == typedOther._rawDestinationRect &&
        _cropAspectRatio == typedOther._cropAspectRatio &&
        cropRectPadding != typedOther.cropRectPadding;
  }

  void initRect(Rect layoutRect, Rect destinationRect) {
    if (_layoutRect != layoutRect) {
      _layoutRect = layoutRect;
      _screenDestinationRect = null;
    }

    if (_rawDestinationRect != destinationRect) {
      _rawDestinationRect = destinationRect;
      _screenDestinationRect = null;
    }
  }

  Rect getFinalDestinationRect() {
    if (screenDestinationRect != null) {
      /// scale
      final double scaleDelta = totalScale / preTotalScale;
      if (scaleDelta != 1.0) {
        Offset focalPoint = screenFocalPoint ?? _screenDestinationRect.center;
        focalPoint = Offset(
            focalPoint.dx.clamp(
                _screenDestinationRect.left, _screenDestinationRect.right),
            focalPoint.dy.clamp(
                _screenDestinationRect.top, _screenDestinationRect.bottom));

        _screenDestinationRect = Rect.fromLTWH(
            focalPoint.dx -
                (focalPoint.dx - _screenDestinationRect.left) * scaleDelta,
            focalPoint.dy -
                (focalPoint.dy - _screenDestinationRect.top) * scaleDelta,
            _screenDestinationRect.width * scaleDelta,
            _screenDestinationRect.height * scaleDelta);
        preTotalScale = totalScale;
        delta = Offset.zero;
      }

      /// move
      else {
        if (_screenDestinationRect != screenCropRect) {
          _screenDestinationRect = _screenDestinationRect.shift(delta);
        }
        //we have shift offset, we should clear delta.
        delta = Offset.zero;
      }

      _screenDestinationRect =
          computeBoundary(_screenDestinationRect, screenCropRect);

      ///make sure that crop rect is all in image rect.
      if (screenCropRect != null) {
        Rect rect = screenCropRect.expandToInclude(_screenDestinationRect);
        if (rect != _screenDestinationRect) {
          var topSame = rect.top == screenCropRect.top;
          var leftSame = rect.left == screenCropRect.left;
          var bottomSame = rect.bottom == screenCropRect.bottom;
          var rightSame = rect.right == screenCropRect.right;

          ///make sure that image rect keep  same aspect ratio
          if (topSame && bottomSame) {
            rect = Rect.fromCenter(
                center: rect.center,
                width: rect.height /
                    _screenDestinationRect.height *
                    _screenDestinationRect.width,
                height: rect.height);
          } else if (leftSame && rightSame) {
            rect = Rect.fromCenter(
              center: rect.center,
              width: rect.width,
              height: rect.width /
                  _screenDestinationRect.width *
                  _screenDestinationRect.height,
            );
          }
          totalScale = totalScale / (rect.width / _screenDestinationRect.width);
          preTotalScale = totalScale;
          _screenDestinationRect = rect;
        }
      }
    } else {
      // if (cropRect != null) {
      //   _screenDestinationRect = cropRect.shift(layoutTopLeft);
      // } else {
      _screenDestinationRect = getRectWithScale(_rawDestinationRect);
      //}
    }
    return _screenDestinationRect;
  }

  Rect getRectWithScale(Rect rect) {
    final double width = rect.width * totalScale;
    final double height = rect.height * totalScale;
    var center = rect.center;
    return Rect.fromLTWH(
        center.dx - width / 2.0, center.dy - height / 2.0, width, height);
  }

  Rect computeBoundary(Rect result, Rect layoutRect) {
    if (_computeHorizontalBoundary) {
      //move right
      if (result.left >= layoutRect.left) {
        result = Rect.fromLTWH(
            layoutRect.left, result.top, result.width, result.height);
      }

      ///move left
      if (result.right <= layoutRect.right) {
        result = Rect.fromLTWH(layoutRect.right - result.width, result.top,
            result.width, result.height);
      }
    }

    if (_computeVerticalBoundary) {
      //move down
      if (result.bottom <= layoutRect.bottom) {
        result = Rect.fromLTWH(result.left, layoutRect.bottom - result.height,
            result.width, result.height);
      }

      //move up
      if (result.top >= layoutRect.top) {
        result = Rect.fromLTWH(
            result.left, layoutRect.top, result.width, result.height);
      }
    }

    _computeHorizontalBoundary =
        result.left <= layoutRect.left && result.right >= layoutRect.right;

    _computeVerticalBoundary =
        result.top <= layoutRect.top && result.bottom >= layoutRect.bottom;
    return result;
  }
}

class EditorConfig {
  /// max scale
  final double maxScale;

  /// initial scale of image
  /// it refer to initial image rect and crop rect
  /// it's not good to compute，make it 1.0 for now
  final double initialScale = 1.0;

  /// padding of crop rect to layout rect
  /// it's refer to initial image rect and crop rect
  final EdgeInsets cropRectPadding;

  /// size of corner shape
  final Size cornerSize;

  /// color of corner shape
  /// default: primaryColor
  final Color cornerColor;

  /// color of crop line
  /// default: scaffoldBackgroundColor.withOpacity(0.7)
  final Color lineColor;

  /// height of crop line
  final double lineHeight;

  /// eidtor mask color base on pointerDown
  /// default: scaffoldBackgroundColor.withOpacity(pointerdown ? 0.4 : 0.8)
  final EidtorMaskColorHandler eidtorMaskColorHandler;

  /// hit test region of corner and line
  final double hitTestSize;

  /// auto center animation duration
  final Duration animationDuration;

  /// duration to begin auto center animation after crop rect is changed
  final Duration tickerDuration;

  /// aspect ratio of crop rect
  /// default is custom
  final double cropAspectRatio;

  EditorConfig({
    double maxScale,
    //double initialScale,
    this.cropRectPadding = const EdgeInsets.all(20.0),
    this.cornerSize = const Size(30.0, 5.0),
    this.cornerColor,
    this.lineColor,
    this.lineHeight = 0.6,
    this.eidtorMaskColorHandler,
    this.hitTestSize = 20.0,
    this.animationDuration = const Duration(milliseconds: 200),
    this.tickerDuration = const Duration(milliseconds: 400),
    this.cropAspectRatio = CropAspectRatios.custom,
  })  : maxScale = maxScale ??= 5.0,
        // initialScale = initialScale ??= 1.0,
        // assert(minScale <= maxScale),
        // assert(minScale <= initialScale && initialScale <= maxScale),
        assert(lineHeight > 0.0),
        assert(hitTestSize >= 15.0),
        assert(animationDuration != null),
        assert(tickerDuration != null);
}

class CropAspectRatios {
  /// no aspect ratio for crop
  static const double custom = null;

  /// the same as aspect ratio of image
  /// [cropAspectRatio] is not more than 0.0, it's original
  static const double original = 0.0;

  /// ratio of width and height is 1 : 1
  static const double ratio1_1 = 1.0;

  /// ratio of width and height is 3 : 4
  static const double ratio3_4 = 3.0 / 4.0;

  /// ratio of width and height is 4 : 3
  static const double ratio4_3 = 4.0 / 3.0;

  /// ratio of width and height is 9 : 16
  static const double ratio9_16 = 9.0 / 16.0;

  /// ratio of width and height is 16 : 9
  static const double ratio16_9 = 16.0 / 9.0;
}

Rect getDestinationRect({
  @required Rect rect,
  @required Size inputSize,
  double scale = 1.0,
  BoxFit fit,
  Alignment alignment = Alignment.center,
  Rect centerSlice,
  bool flipHorizontally = false,
}) {
  Size outputSize = rect.size;

  Offset sliceBorder;
  if (centerSlice != null) {
    sliceBorder = Offset(centerSlice.left + inputSize.width - centerSlice.right,
        centerSlice.top + inputSize.height - centerSlice.bottom);
    outputSize -= sliceBorder;
    inputSize -= sliceBorder;
  }
  fit ??= centerSlice == null ? BoxFit.scaleDown : BoxFit.fill;
  assert(centerSlice == null || (fit != BoxFit.none && fit != BoxFit.cover));
  final FittedSizes fittedSizes =
      applyBoxFit(fit, inputSize / scale, outputSize);
  final Size sourceSize = fittedSizes.source * scale;
  Size destinationSize = fittedSizes.destination;
  if (centerSlice != null) {
    outputSize += sliceBorder;
    destinationSize += sliceBorder;
    // We don't have the ability to draw a subset of the image at the same time
    // as we apply a nine-patch stretch.
    assert(sourceSize == inputSize,
        'centerSlice was used with a BoxFit that does not guarantee that the image is fully visible.');
  }

  final double halfWidthDelta =
      (outputSize.width - destinationSize.width) / 2.0;
  final double halfHeightDelta =
      (outputSize.height - destinationSize.height) / 2.0;
  final double dx = halfWidthDelta +
      (flipHorizontally ? -alignment.x : alignment.x) * halfWidthDelta;
  final double dy = halfHeightDelta + alignment.y * halfHeightDelta;
  final Offset destinationPosition = rect.topLeft.translate(dx, dy);
  Rect destinationRect = destinationPosition & destinationSize;
  return destinationRect;
}

Color defaultEidtorMaskColorHandler(BuildContext context, bool pointerdown) {
  return Theme.of(context)
      .scaffoldBackgroundColor
      .withOpacity(pointerdown ? 0.4 : 0.8);
}

Offset rotateOffset(Offset input, Offset center, double angle) {
  var x = input.dx;
  var y = input.dy;
  var rx0 = center.dx;
  var ry0 = center.dy;
  var x0 = (x - rx0) * cos(angle) - (y - ry0) * sin(angle) + rx0;
  var y0 = (x - rx0) * sin(angle) + (y - ry0) * cos(angle) + ry0;
  return Offset(x0, y0);
}

Rect rotateRect(Rect rect, Offset center, double angle) {
  var leftTop = rotateOffset(rect.topLeft, center, angle);
  var bottomRight = rotateOffset(rect.bottomRight, center, angle);
  return Rect.fromPoints(leftTop, bottomRight);
}
