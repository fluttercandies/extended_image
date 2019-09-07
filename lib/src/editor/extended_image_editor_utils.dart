import 'dart:math';

import 'dart:ui' as ui;

import 'package:extended_image/src/extended_image_typedef.dart';
import 'package:flutter/material.dart';

class EditActionDetails {
  double _rotateAngle = 0.0;
  bool _flipX = false;
  bool _flipY = false;
  bool _computeHorizontalBoundary = false;
  bool _computeVerticalBoundary = false;
  Rect _cropRect;
  Rect _layoutRect;
  Rect _screenDestinationRect;
  Rect _rawDestinationRect;

  double totalScale = 1.0;
  double preTotalScale = 1.0;
  Offset delta;
  Offset screenFocalPoint;
  EdgeInsets cropRectPadding;

  ///image
  Rect get screenDestinationRect => _screenDestinationRect;
  set screenDestinationRect(value) => _screenDestinationRect = value;

  bool get flipX => _flipX;

  Rect get rawDestinationRect => _rawDestinationRect;

  bool get flipY => _flipY;

  Rect get cropRect => _cropRect;
  set cropRect(value) => _cropRect = value;

  Rect get screenCropRect => _cropRect?.shift(layoutTopLeft);

  double get rotateAngle => _rotateAngle;

  bool get hasRotateAngle => !isTwoPi;

  bool get hasEditAction => hasRotateAngle || _flipX || _flipY;

  bool get isHalfPi => (_rotateAngle % (pi)) != 0;

  bool get isPi => !isHalfPi && !isTwoPi;

  bool get isTwoPi => (_rotateAngle % (2 * pi)) == 0;

  /// destination rect base on layer
  Rect get layerDestinationRect => screenDestinationRect?.shift(-layoutTopLeft);

  Offset get layoutTopLeft => _layoutRect?.topLeft;

  EditActionDetails();

  void rotate(double angle) {
    if (isHalfPi) {}
    _rotateAngle += angle;
    if (_flipX && _flipY && isPi) {
      _flipX = _flipY = false;
      _rotateAngle = 0.0;
    }
    if (isHalfPi) {}
  }

  void flip() {
    var flipOrigin = screenCropRect?.center;
    if (isHalfPi) {
      _flipX = !_flipX;
      _screenDestinationRect = Rect.fromLTRB(
          screenDestinationRect.left,
          2 * flipOrigin.dy - screenDestinationRect.bottom,
          screenDestinationRect.right,
          2 * flipOrigin.dy - screenDestinationRect.top);
    } else {
      _flipY = !_flipY;
      _screenDestinationRect = Rect.fromLTRB(
          2 * flipOrigin.dx - screenDestinationRect.right,
          screenDestinationRect.top,
          2 * flipOrigin.dx - screenDestinationRect.left,
          screenDestinationRect.bottom);
    }

    if (_flipX && _flipY && isPi) {
      _flipX = _flipY = false;
      _rotateAngle = 0.0;
    }
  }

  Rect paintRect(Rect rect, {Offset offset: Offset.zero}) {
    if (!hasEditAction) return rect;

    if (isHalfPi) {
      var center = rect.center;
      rect = Rect.fromLTWH(center.dx - rect.height / 2.0,
          center.dy - rect.width / 2.0, rect.height, rect.width);
    }

    var flipOrigin = screenCropRect?.center;
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

  Offset paintOffset(Offset offset) {
    if (!hasEditAction || screenCropRect == null) return offset;

    if (flipY) {
      offset = Offset(2 * screenCropRect.center.dx - offset.dx, offset.dy);
    }

    if (flipX) {
      offset = Offset(offset.dx, 2 * screenCropRect.center.dy - offset.dy);
    }

    return offset;
  }

  @override
  int get hashCode => hashValues(_rotateAngle, _flipX, _flipY, _cropRect,
      _layoutRect, _rawDestinationRect);

  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) return false;
    final EditActionDetails typedOther = other;
    return _rotateAngle == typedOther.rotateAngle &&
        _flipX == typedOther.flipX &&
        _flipY == typedOther.flipY &&
        _cropRect == typedOther.cropRect &&
        _layoutRect == typedOther._layoutRect &&
        _rawDestinationRect == typedOther._rawDestinationRect;
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
        Offset focalPoint = screenFocalPoint ?? screenDestinationRect.center;
        focalPoint = Offset(
            focalPoint.dx
                .clamp(screenDestinationRect.left, screenDestinationRect.right),
            focalPoint.dy.clamp(
                screenDestinationRect.top, screenDestinationRect.bottom));

        _screenDestinationRect = Rect.fromLTWH(
            focalPoint.dx -
                (focalPoint.dx - screenDestinationRect.left) * scaleDelta,
            focalPoint.dy -
                (focalPoint.dy - screenDestinationRect.top) * scaleDelta,
            screenDestinationRect.width * scaleDelta,
            screenDestinationRect.height * scaleDelta);
        preTotalScale = totalScale;
      }

      /// move
      else {
        _screenDestinationRect = screenDestinationRect.shift(delta);
        delta = Offset.zero;
      }
      //computeBoundary(screenDestinationRect, screenCropRect);
      _screenDestinationRect =
          computeBoundary(screenDestinationRect, screenCropRect);

      ///make sure edit rect is in crop rect
      if (screenCropRect != null) {
        _screenDestinationRect =
            screenCropRect.expandToInclude(screenDestinationRect);
      }
    } else {
      if (cropRect != null) {
        _screenDestinationRect = cropRect.shift(layoutTopLeft);
      } else {
        _screenDestinationRect = getRectWithScale(_rawDestinationRect);
      }
    }

    return screenDestinationRect;
  }

  Rect getRectWithScale(Rect rect, {Offset center}) {
    final double width = rect.width * totalScale;
    final double height = rect.height * totalScale;
    center ??= rect.center;
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
  /// min scale
  final double minScale;

  /// max scale
  final double maxScale;

  /// initial scale of image
  /// it refer to initial image rect and crop rect
  final double initialScale;

  /// padding of crop rect to layout rect
  /// it refer to initial image rect and crop rect
  final EdgeInsets cropRectPadding;

  /// size of corner shape
  final Size cornerSize;

  /// color of corner shape
  /// default theme primaryColor
  final Color cornerColor;

  /// color of crop line
  final Color lineColor;

  /// height of crop line
  final double lineHeight;

  /// eidtor mask color base on pointerDown
  final EidtorMaskColorHandler eidtorMaskColorHandler;

  /// hit test region of corner and line
  final double hitTestSize;

  /// auto adjust crop rect to layout center when crop rect is changed
  final bool autoCenter;

  /// auto center animation duration
  final Duration animationDuration;

  /// duration to begin auto center animation after crop rect is changed
  final Duration tickerDuration;

  EditorConfig(
      {double minScale,
      double maxScale,
      double initialScale,
      this.cropRectPadding = const EdgeInsets.all(15.0),
      this.cornerSize = const Size(30.0, 5.0),
      this.cornerColor,
      this.lineColor,
      this.lineHeight = 0.6,
      this.eidtorMaskColorHandler,
      this.hitTestSize: 20.0,
      this.autoCenter = true,
      this.animationDuration = const Duration(milliseconds: 200),
      this.tickerDuration = const Duration(milliseconds: 400)})
      : minScale = minScale ??= 0.8,
        maxScale = maxScale ??= 5.0,
        initialScale = initialScale ??= 1.0,
        assert(minScale <= maxScale),
        assert(minScale <= initialScale && initialScale <= maxScale),
        assert(lineHeight > 0.0),
        assert(hitTestSize >= 15.0),
        assert(autoCenter != null),
        assert(animationDuration != null),
        assert(tickerDuration != null);
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
