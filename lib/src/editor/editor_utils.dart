import 'dart:math';
import 'package:extended_image/src/typedef.dart';
import 'package:flutter/material.dart';

import '../utils.dart';

class EditActionDetails {
  double _rotateRadian = 0.0;
  bool _flipX = false;
  bool _flipY = false;
  bool _computeHorizontalBoundary = false;
  bool _computeVerticalBoundary = false;
  Rect? _layoutRect;
  Rect? _screenDestinationRect;
  Rect? _rawDestinationRect;

  /// #235
  /// when we reach edge, we should not allow to zoom out.
  bool _reachCropRectEdge = false;

  double totalScale = 1.0;
  double preTotalScale = 1.0;
  late Offset delta;
  Offset? screenFocalPoint;
  EdgeInsets? cropRectPadding;
  Rect? cropRect;

  /// aspect ratio of image
  double? originalAspectRatio;

  ///  aspect ratio of crop rect
  double? _cropAspectRatio;
  double? get cropAspectRatio {
    if (_cropAspectRatio != null) {
      return isHalfPi ? 1.0 / _cropAspectRatio! : _cropAspectRatio;
    }
    return null;
  }

  set cropAspectRatio(double? value) {
    _cropAspectRatio = value;
  }

  ///image
  Rect? get screenDestinationRect => _screenDestinationRect;

  void setScreenDestinationRect(Rect value) {
    _screenDestinationRect = value;
  }

  bool get flipX => _flipX;

  bool get flipY => _flipY;

  double get rotateRadian => _rotateRadian;

  bool get hasRotateAngle => !isTwoPi;

  bool get hasEditAction => hasRotateAngle || _flipX || _flipY;

  bool get needCrop => screenCropRect != screenDestinationRect;

  double get rotateAngle => (rotateRadian ~/ (pi / 2)) * 90.0;

  bool get needFlip => _flipX || _flipY;

  bool get isHalfPi => (_rotateRadian % pi) != 0;

  bool get isPi => !isHalfPi && !isTwoPi;

  bool get isTwoPi => (_rotateRadian % (2 * pi)) == 0;

  /// destination rect base on layer
  Rect? get layerDestinationRect =>
      screenDestinationRect?.shift(-layoutTopLeft!);

  Offset? get layoutTopLeft => _layoutRect?.topLeft;

  Rect? get rawDestinationRect => _rawDestinationRect;

  Rect? get screenCropRect => cropRect?.shift(layoutTopLeft!);

  bool get reachCropRectEdge => _reachCropRectEdge;

  void rotate(double angle, Rect layoutRect, BoxFit? fit) {
    if (cropRect == null) {
      return;
    }
    _rotateRadian += angle;
    _rotateRadian %= 2 * pi;
    if (_flipX && _flipY && isPi) {
      _flipX = _flipY = false;
      _rotateRadian = 0.0;
    }

    // _cropRect = rotateRect(_cropRect, _cropRect.center, -angle);
    // screenDestinationRect =
    //     rotateRect(screenDestinationRect, screenCropRect.center, -angle);

    /// take care of boundary
    final Rect newCropRect = getDestinationRect(
      rect: layoutRect,
      inputSize: Size(cropRect!.height, cropRect!.width),
      fit: fit,
    );

    final double scale = newCropRect.width / cropRect!.height;

    Rect newScreenDestinationRect =
        rotateRect(screenDestinationRect!, screenCropRect!.center, angle);

    final Offset topLeft = screenCropRect!.center -
        (screenCropRect!.center - newScreenDestinationRect.topLeft) * scale;
    final Offset bottomRight = screenCropRect!.center +
        -(screenCropRect!.center - newScreenDestinationRect.bottomRight) *
            scale;

    newScreenDestinationRect = Rect.fromPoints(topLeft, bottomRight);

    cropRect = newCropRect;
    _screenDestinationRect = newScreenDestinationRect;
    totalScale *= scale;
    preTotalScale = totalScale;
  }

  void flip() {
    if (screenCropRect == null) {
      return;
    }
    final Offset flipOrigin = screenCropRect!.center;
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
        2 * flipOrigin.dx - screenDestinationRect!.right,
        screenDestinationRect!.top,
        2 * flipOrigin.dx - screenDestinationRect!.left,
        screenDestinationRect!.bottom);

    if (_flipX && _flipY && isPi) {
      _flipX = _flipY = false;
      _rotateRadian = 0.0;
    }
  }

  ///screen image rect to paint rect
  Rect paintRect(Rect rect) {
    if (!hasEditAction || screenCropRect == null) {
      return rect;
    }

    final Offset flipOrigin = screenCropRect!.center;
    if (hasRotateAngle) {
      rect = rotateRect(rect, flipOrigin, -_rotateRadian);
    }

    if (flipY) {
      rect = Rect.fromLTRB(
        2 * flipOrigin.dx - rect.right,
        rect.top,
        2 * flipOrigin.dx - rect.left,
        rect.bottom,
      );
    }

    if (flipX) {
      rect = Rect.fromLTRB(
        rect.left,
        2 * flipOrigin.dy - rect.bottom,
        rect.right,
        2 * flipOrigin.dy - rect.top,
      );
    }

    return rect;
  }

  // @override
  // int get hashCode => hashValues(_rotateRadian, _flipX, _flipY, cropRect,
  //     _layoutRect, _rawDestinationRect, _cropAspectRatio, cropRectPadding);

  // @override
  // bool operator ==(dynamic other) {
  //   if (other.runtimeType != runtimeType) {
  //     return false;
  //   }
  //   return other is EditActionDetails &&
  //       _rotateRadian == other.rotateRadian &&
  //       _flipX == other.flipX &&
  //       _flipY == other.flipY &&
  //       cropRect == other.cropRect &&
  //       _layoutRect == other._layoutRect &&
  //       _rawDestinationRect == other._rawDestinationRect &&
  //       _cropAspectRatio == other._cropAspectRatio &&
  //       cropRectPadding != other.cropRectPadding;
  // }

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
    _reachCropRectEdge = false;

    if (screenDestinationRect != null) {
      /// scale
      final double scaleDelta = totalScale / preTotalScale;
      if (scaleDelta != 1.0) {
        Offset focalPoint = screenFocalPoint ?? _screenDestinationRect!.center;
        focalPoint = Offset(
          focalPoint.dx
              .clamp(
                  _screenDestinationRect!.left, _screenDestinationRect!.right)
              .toDouble(),
          focalPoint.dy
              .clamp(
                  _screenDestinationRect!.top, _screenDestinationRect!.bottom)
              .toDouble(),
        );

        _screenDestinationRect = Rect.fromLTWH(
            focalPoint.dx -
                (focalPoint.dx - _screenDestinationRect!.left) * scaleDelta,
            focalPoint.dy -
                (focalPoint.dy - _screenDestinationRect!.top) * scaleDelta,
            _screenDestinationRect!.width * scaleDelta,
            _screenDestinationRect!.height * scaleDelta);
        preTotalScale = totalScale;
        delta = Offset.zero;
      }

      /// move
      else {
        if (_screenDestinationRect != screenCropRect) {
          final bool topSame =
              _screenDestinationRect!.topIsSame(screenCropRect!);
          final bool leftSame =
              _screenDestinationRect!.leftIsSame(screenCropRect!);
          final bool bottomSame =
              _screenDestinationRect!.bottomIsSame(screenCropRect!);
          final bool rightSame =
              _screenDestinationRect!.rightIsSame(screenCropRect!);

          if (topSame && bottomSame) {
            delta = Offset(delta.dx, 0.0);
          } else if (leftSame && rightSame) {
            delta = Offset(0.0, delta.dy);
          }

          _screenDestinationRect = _screenDestinationRect!.shift(delta);
        }
        //we have shift offset, we should clear delta.
        delta = Offset.zero;
      }

      _screenDestinationRect =
          computeBoundary(_screenDestinationRect!, screenCropRect!);

      // make sure that crop rect is all in image rect.
      if (screenCropRect != null) {
        Rect rect = screenCropRect!.expandToInclude(_screenDestinationRect!);
        if (rect != _screenDestinationRect) {
          final bool topSame = rect.topIsSame(screenCropRect!);
          final bool leftSame = rect.leftIsSame(screenCropRect!);
          final bool bottomSame = rect.bottomIsSame(screenCropRect!);
          final bool rightSame = rect.rightIsSame(screenCropRect!);

          // make sure that image rect keep same aspect ratio
          if (topSame && bottomSame) {
            rect = Rect.fromCenter(
                center: rect.center,
                width: rect.height /
                    _screenDestinationRect!.height *
                    _screenDestinationRect!.width,
                height: rect.height);
            _reachCropRectEdge = true;
          } else if (leftSame && rightSame) {
            rect = Rect.fromCenter(
              center: rect.center,
              width: rect.width,
              height: rect.width /
                  _screenDestinationRect!.width *
                  _screenDestinationRect!.height,
            );
            _reachCropRectEdge = true;
          }
          totalScale =
              totalScale / (rect.width / _screenDestinationRect!.width);
          // init totalScale
          if (_rawDestinationRect!.isSame(_rawDestinationRect!)) {
            totalScale = 1.0;
          }
          preTotalScale = totalScale;
          _screenDestinationRect = rect;
        }
      }
    } else {
      _screenDestinationRect = getRectWithScale(_rawDestinationRect!);
      _screenDestinationRect =
          computeBoundary(_screenDestinationRect!, screenCropRect!);
    }
    return _screenDestinationRect!;
  }

  Rect getRectWithScale(Rect rect) {
    final double width = rect.width * totalScale;
    final double height = rect.height * totalScale;
    final Offset center = rect.center;
    return Rect.fromLTWH(
        center.dx - width / 2.0, center.dy - height / 2.0, width, height);
  }

  Rect computeBoundary(Rect result, Rect layoutRect) {
    if (_computeHorizontalBoundary) {
      //move right
      if (result.left.greaterThanOrEqualTo(layoutRect.left)) {
        result = Rect.fromLTWH(
            layoutRect.left, result.top, result.width, result.height);
      }

      ///move left
      if (result.right.lessThanOrEqualTo(layoutRect.right)) {
        result = Rect.fromLTWH(layoutRect.right - result.width, result.top,
            result.width, result.height);
      }
    }

    if (_computeVerticalBoundary) {
      //move down
      if (result.bottom.lessThanOrEqualTo(layoutRect.bottom)) {
        result = Rect.fromLTWH(result.left, layoutRect.bottom - result.height,
            result.width, result.height);
      }

      //move up
      if (result.top.greaterThanOrEqualTo(layoutRect.top)) {
        result = Rect.fromLTWH(
            result.left, layoutRect.top, result.width, result.height);
      }
    }

    _computeHorizontalBoundary =
        result.left.lessThanOrEqualTo(layoutRect.left) &&
            result.right.greaterThanOrEqualTo(layoutRect.right);

    _computeVerticalBoundary = result.top.lessThanOrEqualTo(layoutRect.top) &&
        result.bottom.greaterThanOrEqualTo(layoutRect.bottom);
    return result;
  }
}

class EditorConfig {
  EditorConfig({
    this.maxScale = 5.0,
    this.cropRectPadding = const EdgeInsets.all(20.0),
    this.cornerSize = const Size(30.0, 5.0),
    this.cornerColor,
    this.lineColor,
    this.lineHeight = 0.6,
    this.editorMaskColorHandler,
    this.hitTestSize = 20.0,
    this.animationDuration = const Duration(milliseconds: 200),
    this.tickerDuration = const Duration(milliseconds: 400),
    this.cropAspectRatio = CropAspectRatios.custom,
    this.initialCropAspectRatio = CropAspectRatios.custom,
    this.initCropRectType = InitCropRectType.imageRect,
    this.cropLayerPainter = const EditorCropLayerPainter(),
    this.speed = 1.0,
    this.hitTestBehavior = HitTestBehavior.deferToChild,
    this.editActionDetailsIsChanged,
    this.reverseMousePointerScrollDirection = false,
  })  : assert(lineHeight > 0.0),
        assert(hitTestSize >= 0.0),
        assert(maxScale > 0.0),
        assert(speed > 0.0);

  /// Call when EditActionDetails is changed
  final EditActionDetailsIsChanged? editActionDetailsIsChanged;

  /// How to behave during hit tests.
  final HitTestBehavior hitTestBehavior;

  /// Max scale
  final double maxScale;

  /// Padding of crop rect to layout rect
  /// it's refer to initial image rect and crop rect
  final EdgeInsets cropRectPadding;

  /// Size of corner shape
  final Size cornerSize;

  /// Color of corner shape
  /// default: primaryColor
  final Color? cornerColor;

  /// Color of crop line
  /// default: scaffoldBackgroundColor.withOpacity(0.7)
  final Color? lineColor;

  /// Height of crop line
  final double lineHeight;

  /// Editor mask color base on pointerDown
  /// default: scaffoldBackgroundColor.withOpacity(pointerDown ? 0.4 : 0.8)
  final EditorMaskColorHandler? editorMaskColorHandler;

  /// Hit test region of corner and line
  final double hitTestSize;

  /// Auto center animation duration
  final Duration animationDuration;

  /// Duration to begin auto center animation after crop rect is changed
  final Duration tickerDuration;

  /// Aspect ratio of crop rect
  /// default is custom
  ///
  /// Typically the aspect ratio will not be changed during the editing process,
  /// but it might be relevant with states (e.g. [ExtendedImageState]).
  final double? cropAspectRatio;

  /// Initial Aspect ratio of crop rect
  /// default is custom
  ///
  /// The argument only affects the initial aspect ratio,
  /// users can set it based on the desire despite of [cropAspectRatio].
  final double? initialCropAspectRatio;

  /// Init crop rect base on initial image rect or image layout rect
  final InitCropRectType initCropRectType;

  /// Custom crop layer
  final EditorCropLayerPainter cropLayerPainter;

  /// Speed for zoom/pan
  final double speed;

  /// reverse mouse pointer scroll deirection
  /// false: zoom int => down, zoom out => up
  /// true: zoom int => up, zoom out => down
  /// default is false
  final bool reverseMousePointerScrollDirection;
}

class CropAspectRatios {
  /// no aspect ratio for crop
  static const double? custom = null;

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
  required Rect rect,
  required Size inputSize,
  double scale = 1.0,
  BoxFit? fit,
  Alignment alignment = Alignment.center,
  Rect? centerSlice,
  bool flipHorizontally = false,
}) {
  Size outputSize = rect.size;

  late Offset sliceBorder;
  if (centerSlice != null) {
    sliceBorder = Offset(centerSlice.left + inputSize.width - centerSlice.right,
        centerSlice.top + inputSize.height - centerSlice.bottom);
    outputSize = outputSize - sliceBorder as Size;
    inputSize = inputSize - sliceBorder as Size;
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
  final Rect destinationRect = destinationPosition & destinationSize;

  // final Rect sourceRect =
  //     centerSlice ?? alignment.inscribe(sourceSize, Offset.zero & inputSize);

  return destinationRect;
}

Color defaultEditorMaskColorHandler(BuildContext context, bool pointerDown) {
  return Theme.of(context)
      .scaffoldBackgroundColor
      .withOpacity(pointerDown ? 0.4 : 0.8);
}

Offset rotateOffset(Offset input, Offset center, double angle) {
  final double x = input.dx;
  final double y = input.dy;
  final double rx0 = center.dx;
  final double ry0 = center.dy;
  final double x0 = (x - rx0) * cos(angle) - (y - ry0) * sin(angle) + rx0;
  final double y0 = (x - rx0) * sin(angle) + (y - ry0) * cos(angle) + ry0;
  return Offset(x0, y0);
}

Rect rotateRect(Rect rect, Offset center, double angle) {
  final Offset leftTop = rotateOffset(rect.topLeft, center, angle);
  final Offset bottomRight = rotateOffset(rect.bottomRight, center, angle);
  return Rect.fromPoints(leftTop, bottomRight);
}

enum InitCropRectType {
  //init crop rect base on initial image rect
  imageRect,
  //init crop rect base on image layout rect
  layoutRect
}

class EditorCropLayerPainter {
  const EditorCropLayerPainter();
  void paint(Canvas canvas, Size size, ExtendedImageCropLayerPainter painter) {
    paintMask(canvas, size, painter);
    paintLines(canvas, size, painter);
    paintCorners(canvas, size, painter);
  }

  /// draw crop layer corners
  void paintCorners(
      Canvas canvas, Size size, ExtendedImageCropLayerPainter painter) {
    final Rect cropRect = painter.cropRect;
    final Size cornerSize = painter.cornerSize;
    final double cornerWidth = cornerSize.width;
    final double cornerHeight = cornerSize.height;
    final Paint paint = Paint()
      ..color = painter.cornerColor
      ..style = PaintingStyle.fill;

    canvas.drawPath(
        Path()
          ..moveTo(cropRect.left, cropRect.top)
          ..lineTo(cropRect.left + cornerWidth, cropRect.top)
          ..lineTo(cropRect.left + cornerWidth, cropRect.top + cornerHeight)
          ..lineTo(cropRect.left + cornerHeight, cropRect.top + cornerHeight)
          ..lineTo(cropRect.left + cornerHeight, cropRect.top + cornerWidth)
          ..lineTo(cropRect.left, cropRect.top + cornerWidth),
        paint);

    canvas.drawPath(
        Path()
          ..moveTo(cropRect.left, cropRect.bottom)
          ..lineTo(cropRect.left + cornerWidth, cropRect.bottom)
          ..lineTo(cropRect.left + cornerWidth, cropRect.bottom - cornerHeight)
          ..lineTo(cropRect.left + cornerHeight, cropRect.bottom - cornerHeight)
          ..lineTo(cropRect.left + cornerHeight, cropRect.bottom - cornerWidth)
          ..lineTo(cropRect.left, cropRect.bottom - cornerWidth),
        paint);

    canvas.drawPath(
        Path()
          ..moveTo(cropRect.right, cropRect.top)
          ..lineTo(cropRect.right - cornerWidth, cropRect.top)
          ..lineTo(cropRect.right - cornerWidth, cropRect.top + cornerHeight)
          ..lineTo(cropRect.right - cornerHeight, cropRect.top + cornerHeight)
          ..lineTo(cropRect.right - cornerHeight, cropRect.top + cornerWidth)
          ..lineTo(cropRect.right, cropRect.top + cornerWidth),
        paint);

    canvas.drawPath(
        Path()
          ..moveTo(cropRect.right, cropRect.bottom)
          ..lineTo(cropRect.right - cornerWidth, cropRect.bottom)
          ..lineTo(cropRect.right - cornerWidth, cropRect.bottom - cornerHeight)
          ..lineTo(
              cropRect.right - cornerHeight, cropRect.bottom - cornerHeight)
          ..lineTo(cropRect.right - cornerHeight, cropRect.bottom - cornerWidth)
          ..lineTo(cropRect.right, cropRect.bottom - cornerWidth),
        paint);
  }

  /// draw crop layer lines
  void paintMask(
      Canvas canvas, Size size, ExtendedImageCropLayerPainter painter) {
    final Rect rect = Offset.zero & size;
    final Rect cropRect = painter.cropRect;
    final Color maskColor = painter.maskColor;
    // canvas.saveLayer(rect, Paint());
    // canvas.drawRect(
    //     rect,
    //     Paint()
    //       ..style = PaintingStyle.fill
    //       ..color = maskColor);
    //   canvas.drawRect(cropRect, Paint()..blendMode = BlendMode.clear);
    // canvas.restore();

    // draw mask rect instead use BlendMode.clear, --web-renderer html doesn't support now.
    // left
    canvas.drawRect(
        Offset.zero & Size(cropRect.left, rect.height),
        Paint()
          ..style = PaintingStyle.fill
          ..color = maskColor);
    //top
    canvas.drawRect(
        Offset(cropRect.left, 0.0) & Size(cropRect.width, cropRect.top),
        Paint()
          ..style = PaintingStyle.fill
          ..color = maskColor);
    //right
    canvas.drawRect(
        Offset(cropRect.right, 0.0) &
            Size(rect.width - cropRect.right, rect.height),
        Paint()
          ..style = PaintingStyle.fill
          ..color = maskColor);
    //bottom
    canvas.drawRect(
        Offset(cropRect.left, cropRect.bottom) &
            Size(cropRect.width, rect.height - cropRect.bottom),
        Paint()
          ..style = PaintingStyle.fill
          ..color = maskColor);
  }

  /// draw crop layer lines
  void paintLines(
      Canvas canvas, Size size, ExtendedImageCropLayerPainter painter) {
    final Color lineColor = painter.lineColor;
    final double lineHeight = painter.lineHeight;
    final Rect cropRect = painter.cropRect;
    final bool pointerDown = painter.pointerDown;
    final Paint linePainter = Paint()
      ..color = lineColor
      ..strokeWidth = lineHeight
      ..style = PaintingStyle.stroke;
    canvas.drawRect(cropRect, linePainter);

    if (pointerDown) {
      canvas.drawLine(
          Offset((cropRect.right - cropRect.left) / 3.0 + cropRect.left,
              cropRect.top),
          Offset((cropRect.right - cropRect.left) / 3.0 + cropRect.left,
              cropRect.bottom),
          linePainter);

      canvas.drawLine(
          Offset((cropRect.right - cropRect.left) / 3.0 * 2.0 + cropRect.left,
              cropRect.top),
          Offset((cropRect.right - cropRect.left) / 3.0 * 2.0 + cropRect.left,
              cropRect.bottom),
          linePainter);

      canvas.drawLine(
          Offset(
            cropRect.left,
            (cropRect.bottom - cropRect.top) / 3.0 + cropRect.top,
          ),
          Offset(
            cropRect.right,
            (cropRect.bottom - cropRect.top) / 3.0 + cropRect.top,
          ),
          linePainter);

      canvas.drawLine(
          Offset(cropRect.left,
              (cropRect.bottom - cropRect.top) / 3.0 * 2.0 + cropRect.top),
          Offset(
            cropRect.right,
            (cropRect.bottom - cropRect.top) / 3.0 * 2.0 + cropRect.top,
          ),
          linePainter);
    }
  }
}

class ExtendedImageCropLayerPainter extends CustomPainter {
  ExtendedImageCropLayerPainter({
    required this.cropRect,
    required this.cropLayerPainter,
    required this.lineColor,
    required this.cornerColor,
    required this.cornerSize,
    required this.lineHeight,
    required this.maskColor,
    required this.pointerDown,
  });

  /// The rect of crop layer
  final Rect cropRect;

  /// The size of corner shape
  final Size cornerSize;

  // The color of corner shape
  // default theme primaryColor
  final Color cornerColor;

  /// The color of crop line
  final Color lineColor;

  /// The height of crop line
  final double lineHeight;

  /// The color of mask
  final Color maskColor;

  /// Whether pointer is down
  final bool pointerDown;

  /// The crop Layer painter for Editor
  final EditorCropLayerPainter cropLayerPainter;

  @override
  void paint(Canvas canvas, Size size) {
    cropLayerPainter.paint(canvas, size, this);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    if (oldDelegate.runtimeType != runtimeType) {
      return true;
    }
    final ExtendedImageCropLayerPainter delegate =
        oldDelegate as ExtendedImageCropLayerPainter;
    return cropRect != delegate.cropRect ||
        cornerSize != delegate.cornerSize ||
        lineColor != delegate.lineColor ||
        lineHeight != delegate.lineHeight ||
        maskColor != delegate.maskColor ||
        cropLayerPainter != delegate.cropLayerPainter ||
        cornerColor != delegate.cornerColor ||
        pointerDown != delegate.pointerDown;
  }
}
