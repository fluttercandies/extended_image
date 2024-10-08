import 'dart:math';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';

class EditActionDetails {
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

  double rotateRadian = 0.0;

  double rotationY = 0.0;

  bool get hasRotateAngle => !isTwoPi;

  bool get hasEditAction => hasRotateAngle || rotationY != 0;

  bool get needCrop => screenCropRect != screenDestinationRect;

  double get rotateAngle => (rotateRadian ~/ (pi / 2)) * 90.0;

  bool get needFlip => rotationY != 0;

  // TODO
  bool get flipY => rotationY != 0;
  bool get flipX => false;

  bool get isHalfPi => (rotateRadian % pi) != 0;

  bool get isPi => !isHalfPi && !isTwoPi;

  bool get isTwoPi => (rotateRadian % (2 * pi)) == 0;

  /// destination rect base on layer
  Rect? get layerDestinationRect =>
      screenDestinationRect?.shift(-layoutTopLeft!);

  Offset? get layoutTopLeft => _layoutRect?.topLeft;

  Rect? get rawDestinationRect => _rawDestinationRect;

  Rect? get screenCropRect => cropRect?.shift(layoutTopLeft!);

  bool get reachCropRectEdge => _reachCropRectEdge;

  void rotate(double rotation, Rect layoutRect, BoxFit? fit) {
    if (cropRect == null) {
      return;
    }
    rotateRadian += rotation;
    rotateRadian %= 2 * pi;
    // if (_flipX && _flipY && isPi) {
    //   _flipX = _flipY = false;
    //   rotateRadian = 0.0;
    // }

    // _cropRect = rotateRect(_cropRect, _cropRect.center, -angle);
    // screenDestinationRect =
    //     rotateRect(screenDestinationRect, screenCropRect.center, -angle);

    /// take care of boundary
    // TODO
    // final Rect newCropRect = getDestinationRect(
    //   rect: layoutRect,
    //   inputSize: Size(cropRect!.height, cropRect!.width),
    //   fit: fit,
    // );

    // final double scale = newCropRect.width / cropRect!.height;

    // Rect newScreenDestinationRect =
    //     rotateRect(screenDestinationRect!, screenCropRect!.center, rotation);

    // final Offset topLeft = screenCropRect!.center -
    //     (screenCropRect!.center - newScreenDestinationRect.topLeft) * scale;
    // final Offset bottomRight = screenCropRect!.center +
    //     -(screenCropRect!.center - newScreenDestinationRect.bottomRight) *
    //         scale;

    // newScreenDestinationRect = Rect.fromPoints(topLeft, bottomRight);

    // cropRect = newCropRect;
    // _screenDestinationRect = newScreenDestinationRect;
    // totalScale *= scale;
    // preTotalScale = totalScale;
  }

  void flip() {
    if (screenCropRect == null) {
      return;
    }
    // final Offset flipOrigin = screenCropRect!.center;
    // if (isHalfPi) {
    //   _flipX = !_flipX;
    //   // _screenDestinationRect = Rect.fromLTRB(
    //   //     screenDestinationRect.left,
    //   //     2 * flipOrigin.dy - screenDestinationRect.bottom,
    //   //     screenDestinationRect.right,
    //   //     2 * flipOrigin.dy - screenDestinationRect.top);
    // } else {
    //   _flipY = !_flipY;
    // }
    // _screenDestinationRect = Rect.fromLTRB(
    //     2 * flipOrigin.dx - screenDestinationRect!.right,
    //     screenDestinationRect!.top,
    //     2 * flipOrigin.dx - screenDestinationRect!.left,
    //     screenDestinationRect!.bottom);

    // if (rotateRadian >= 0 && rotateRadian <= pi / 2) {
    //   // 0° 到 90° 之间
    //   _flipY = !_flipY;
    // } else if (rotateRadian > pi / 2 && rotateRadian <= pi) {
    //   // 90° 到 180° 之间
    //   _flipX = !_flipX; // 垂直翻转
    // } else if (rotateRadian > pi && rotateRadian <= 3 * pi / 2) {
    //   // 180° 到 270° 之间
    //   _flipY = !_flipY; // 水平翻转
    // } else if (rotateRadian > 3 * pi / 2 && rotateRadian < 2 * pi) {
    //   // 270° 到 360° 之间
    //   _flipX = !_flipX; // 垂直翻转
    // }
    // _flipY = !_flipY;
    // if (_flipX && _flipY && isPi) {
    //   _flipX = _flipY = false;
    //   rotateRadian = 0.0;
    // }
    if (rotationY == 0.0) {
      rotationY = pi;
    } else {
      rotationY = 0.0;
    }

    rotateRadian = -rotateRadian;

    rotateRadian = (rotateRadian + 2 * pi) % (2 * pi);
  }

  /// screen image rect to paint rect
  Rect paintRect(Rect rect) {
    if (!hasEditAction || screenCropRect == null) {
      return rect;
    }

    final Offset flipOrigin = screenCropRect!.center;
    if (hasRotateAngle) {
      rect = rotateRect(rect, flipOrigin, -rotateRadian);
    }

    // if (flipY) {
    //   rect = Rect.fromLTRB(
    //     2 * flipOrigin.dx - rect.right,
    //     rect.top,
    //     2 * flipOrigin.dx - rect.left,
    //     rect.bottom,
    //   );
    // }

    // if (flipX) {
    //   rect = Rect.fromLTRB(
    //     rect.left,
    //     2 * flipOrigin.dy - rect.bottom,
    //     rect.right,
    //     2 * flipOrigin.dy - rect.top,
    //   );
    // }

    return rect;
  }

  Rect transformRect(Rect rect, Matrix4 matrix) {
    // 获取矩形的四个角点
    final List<Offset> corners = <Offset>[
      rect.topLeft,
      rect.topRight,
      rect.bottomRight,
      rect.bottomLeft,
    ];

    // 变换角点
    final List<Offset> transformedCorners = corners.map((Offset corner) {
      // 将 Offset 转换为 Vector4，并应用矩阵变换
      final Vector4 v =
          matrix.transform(Vector4(corner.dx, corner.dy, 0.0, 1.0));
      return Offset(v.x, v.y);
    }).toList();

    // 获取变换后的最小和最大点，生成新的 Rect
    final double minX = transformedCorners
        .map((Offset p) => p.dx)
        .reduce((double a, double b) => a < b ? a : b);
    final double minY = transformedCorners
        .map((Offset p) => p.dy)
        .reduce((double a, double b) => a < b ? a : b);
    final double maxX = transformedCorners
        .map((Offset p) => p.dx)
        .reduce((double a, double b) => a > b ? a : b);
    final double maxY = transformedCorners
        .map((Offset p) => p.dy)
        .reduce((double a, double b) => a > b ? a : b);

    return Rect.fromLTRB(minX, minY, maxX, maxY);
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

        if (focalPoint == _screenDestinationRect!.center) {
          _screenDestinationRect = Rect.fromCenter(
            center: focalPoint,
            width: _screenDestinationRect!.width * scaleDelta,
            height: _screenDestinationRect!.height * scaleDelta,
          );
        } else {
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
        }

        preTotalScale = totalScale;

        delta = Offset.zero;
      }

      /// move
      else {
        if (_screenDestinationRect != screenCropRect) {
          // final bool topSame =
          //     _screenDestinationRect!.topIsSame(screenCropRect!);
          // final bool leftSame =
          //     _screenDestinationRect!.leftIsSame(screenCropRect!);
          // final bool bottomSame =
          //     _screenDestinationRect!.bottomIsSame(screenCropRect!);
          // final bool rightSame =
          //     _screenDestinationRect!.rightIsSame(screenCropRect!);

          // if (topSame && bottomSame) {
          //   delta = Offset(delta.dx, 0.0);
          // } else if (leftSame && rightSame) {
          //   delta = Offset(0.0, delta.dy);
          // }

          _screenDestinationRect = _screenDestinationRect!.shift(delta);
        }
        //we have shift offset, we should clear delta.
        delta = Offset.zero;
      }

      // _screenDestinationRect =
      //     computeBoundary(_screenDestinationRect!, screenCropRect!);

      // // make sure that crop rect is all in image rect.
      // if (screenCropRect != null) {
      //   Rect rect = screenCropRect!.expandToInclude(_screenDestinationRect!);
      //   if (rect != _screenDestinationRect) {
      //     final bool topSame = rect.topIsSame(screenCropRect!);
      //     final bool leftSame = rect.leftIsSame(screenCropRect!);
      //     final bool bottomSame = rect.bottomIsSame(screenCropRect!);
      //     final bool rightSame = rect.rightIsSame(screenCropRect!);

      //     // make sure that image rect keep same aspect ratio
      //     if (topSame && bottomSame) {
      //       rect = Rect.fromCenter(
      //           center: rect.center,
      //           width: rect.height /
      //               _screenDestinationRect!.height *
      //               _screenDestinationRect!.width,
      //           height: rect.height);
      //       _reachCropRectEdge = true;
      //     } else if (leftSame && rightSame) {
      //       rect = Rect.fromCenter(
      //         center: rect.center,
      //         width: rect.width,
      //         height: rect.width /
      //             _screenDestinationRect!.width *
      //             _screenDestinationRect!.height,
      //       );
      //       _reachCropRectEdge = true;
      //     }
      //     totalScale =
      //         totalScale / (rect.width / _screenDestinationRect!.width);
      //     // init totalScale
      //     if (_rawDestinationRect!.isSame(_rawDestinationRect!)) {
      //       totalScale = 1.0;
      //     }
      //     preTotalScale = totalScale;
      //     _screenDestinationRect = rect;
      //   }
      // }
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

  /// The path of the processed image, displayed on the screen
  ///
  Path getImagePath() {
    final Rect rect = _screenDestinationRect!;

    final Matrix4 result = getTransform();
    final List<Offset> corners = <Offset>[
      rect.topLeft,
      rect.topRight,
      rect.bottomRight,
      rect.bottomLeft,
    ];
    final List<Offset> rotatedCorners = corners.map((Offset corner) {
      final Vector4 cornerVector = Vector4(corner.dx, corner.dy, 0.0, 1.0);
      final Vector4 newCornerVector = result.transform(cornerVector);
      return Offset(newCornerVector.x, newCornerVector.y);
    }).toList();

    return Path()
      ..moveTo(rotatedCorners[0].dx, rotatedCorners[0].dy)
      ..lineTo(rotatedCorners[1].dx, rotatedCorners[1].dy)
      ..lineTo(rotatedCorners[2].dx, rotatedCorners[2].dy)
      ..lineTo(rotatedCorners[3].dx, rotatedCorners[3].dy)
      ..close();
  }

  Offset _rotateOffset(Offset point, double radians) {
    return Offset(
      point.dx * cos(radians) - point.dy * sin(radians),
      point.dx * sin(radians) + point.dy * cos(radians),
    );
  }

  Rect rotateRect(Rect rect, Offset center, double angle) {
    final Offset leftTop = rotateOffset(rect.topLeft, center, angle);
    final Offset bottomRight = rotateOffset(rect.bottomRight, center, angle);
    return Rect.fromPoints(leftTop, bottomRight);
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

  Matrix4 getTransform({Offset? center}) {
    final Offset origin =
        center ?? screenCropRect?.center ?? _screenDestinationRect!.center;
    final Matrix4 result = Matrix4.identity();

    result.translate(
      origin.dx,
      origin.dy,
    );
    if (rotationY != 0) {
      result.multiply(Matrix4.rotationY(rotationY));
    }
    if (hasRotateAngle) {
      result.multiply(Matrix4.rotationZ(rotateRadian));
    }

    result.translate(-origin.dx, -origin.dy);

    return result;
  }

  // The copyWith method allows you to create a modified copy of an instance.
  EditActionDetails copyWith({
    bool? computeHorizontalBoundary,
    bool? computeVerticalBoundary,
    Rect? layoutRect,
    Rect? screenDestinationRect,
    Rect? rawDestinationRect,
    bool? reachCropRectEdge,
    double? totalScale,
    double? preTotalScale,
    Offset? delta,
    Offset? screenFocalPoint,
    EdgeInsets? cropRectPadding,
    Rect? cropRect,
    double? originalAspectRatio,
    double? cropAspectRatio,
    double? rotateRadian,
    double? rotationY,
  }) {
    return EditActionDetails()
      .._computeHorizontalBoundary =
          computeHorizontalBoundary ?? _computeHorizontalBoundary
      .._computeVerticalBoundary =
          computeVerticalBoundary ?? _computeVerticalBoundary
      .._layoutRect = layoutRect ?? _layoutRect
      .._screenDestinationRect = screenDestinationRect ?? _screenDestinationRect
      .._rawDestinationRect = rawDestinationRect ?? _rawDestinationRect
      .._reachCropRectEdge = reachCropRectEdge ?? _reachCropRectEdge
      ..totalScale = totalScale ?? this.totalScale
      ..preTotalScale = preTotalScale ?? this.preTotalScale
      ..delta = delta ?? this.delta
      ..screenFocalPoint = screenFocalPoint ?? this.screenFocalPoint
      ..cropRectPadding = cropRectPadding ?? this.cropRectPadding
      ..cropRect = cropRect ?? this.cropRect
      ..originalAspectRatio = originalAspectRatio ?? this.originalAspectRatio
      .._cropAspectRatio = cropAspectRatio ?? _cropAspectRatio
      ..rotateRadian = rotateRadian ?? this.rotateRadian
      ..rotationY = rotationY ?? this.rotationY;
  }

  double reverseRotateRadian(double rotateRadian) {
    return rotationY == 0 ? rotateRadian : -rotateRadian;
  }

  void updateRotateRadian(double rotateRadian, double totalScale) {
    this.rotateRadian = rotateRadian;
    final Rect rect = _screenDestinationRect!;

    final Matrix4 result = getTransform();

    final List<Offset> rectVertices = <Offset>[
      screenCropRect!.topLeft,
      screenCropRect!.topRight,
      screenCropRect!.bottomRight,
      screenCropRect!.bottomLeft,
    ].map((Offset element) {
      final Vector4 cornerVector = Vector4(element.dx, element.dy, 0.0, 1.0);
      final Vector4 newCornerVector = result.transform(cornerVector);
      return Offset(newCornerVector.x, newCornerVector.y);
    }).toList();

    final double scaleDelta = _scaleToFit(rectVertices, rect, rect.center);

    if (scaleDelta > 0) {
      screenFocalPoint = _screenDestinationRect!.center;
      preTotalScale = this.totalScale;
      this.totalScale = max(this.totalScale * scaleDelta, totalScale);
    } else {
      this.totalScale = totalScale;
    }
  }

  double _scaleToFit(List<Offset> rectVertices, Rect rect, Offset center) {
    double scaleDelta = 0.0;

    int contains = 0;
    for (final Offset element in rectVertices) {
      if (_screenDestinationRect!.containsOffset(element)) {
        contains++;
        continue;
      }
      final double x = (element.dx - center.dx).abs();
      final double y = (element.dy - center.dy).abs();
      final double halfWidth = rect.width / 2;
      final double halfHeight = rect.height / 2;
      if (x > halfWidth || y > halfHeight) {
        scaleDelta = max(scaleDelta, max(x / halfWidth, y / halfHeight));
      }
    }
    if (contains == 4) {
      return -1;
    }
    return scaleDelta;
  }

  void updateDelta(Offset delta) {
    double dx = delta.dx;
    final double dy = delta.dy;
    if (rotationY == pi) {
      dx = -dx;
    }
    final double transformedDx =
        dx * cos(rotateRadian) + dy * sin(rotateRadian);
    final double transformedDy =
        dy * cos(rotateRadian) - dx * sin(rotateRadian);

    Offset offset = Offset(transformedDx, transformedDy);
    Rect rect = _screenDestinationRect!.shift(offset);

    final Matrix4 result = getTransform();

    final List<Offset> rectVertices = <Offset>[
      screenCropRect!.topLeft,
      screenCropRect!.topRight,
      screenCropRect!.bottomRight,
      screenCropRect!.bottomLeft,
    ].map((Offset element) {
      final Vector4 cornerVector = Vector4(element.dx, element.dy, 0.0, 1.0);
      final Vector4 newCornerVector = result.transform(cornerVector);
      return Offset(newCornerVector.x, newCornerVector.y);
    }).toList();

    for (final Offset element in rectVertices) {
      if (rect.containsOffset(element)) {
        continue;
      }

      // find nearest point on rect
      final double nearestX = element.dx.clamp(rect.left, rect.right);
      final double nearestY = element.dy.clamp(rect.top, rect.bottom);

      final Offset nearestOffset = Offset(nearestX, nearestY);

      if (nearestOffset != element) {
        offset -= nearestOffset - element;
        rect = _screenDestinationRect = _screenDestinationRect!.shift(offset);
        // clear
        offset = Offset.zero;
      }
    }

    this.delta += offset;
  }

  void updateScale(double totalScale) {
    final double scaleDelta = totalScale / preTotalScale;
    if (scaleDelta == 1.0) {
      return;
    }
    final Matrix4 result = getTransform();

    final List<Offset> rectVertices = <Offset>[
      screenCropRect!.topLeft,
      screenCropRect!.topRight,
      screenCropRect!.bottomRight,
      screenCropRect!.bottomLeft,
    ].map((Offset element) {
      final Vector4 cornerVector = Vector4(element.dx, element.dy, 0.0, 1.0);
      final Vector4 newCornerVector = result.transform(cornerVector);
      return Offset(newCornerVector.x, newCornerVector.y);
    }).toList();

    Offset focalPoint = screenFocalPoint ?? _screenDestinationRect!.center;

    focalPoint = Offset(
      focalPoint.dx
          .clamp(_screenDestinationRect!.left, _screenDestinationRect!.right)
          .toDouble(),
      focalPoint.dy
          .clamp(_screenDestinationRect!.top, _screenDestinationRect!.bottom)
          .toDouble(),
    );

    Rect rect = Rect.fromLTWH(
        focalPoint.dx -
            (focalPoint.dx - _screenDestinationRect!.left) * scaleDelta,
        focalPoint.dy -
            (focalPoint.dy - _screenDestinationRect!.top) * scaleDelta,
        _screenDestinationRect!.width * scaleDelta,
        _screenDestinationRect!.height * scaleDelta);
    bool fixed = false;
    for (final Offset element in rectVertices) {
      if (rect.containsOffset(element)) {
        continue;
      }
      // find nearest point on rect
      final double nearestX = element.dx.clamp(rect.left, rect.right);
      final double nearestY = element.dy.clamp(rect.top, rect.bottom);

      final Offset nearestOffset = Offset(nearestX, nearestY);

      if (nearestOffset != element) {
        fixed = true;
        rect = rect.shift(-(nearestOffset - element));
      }
    }

    for (final Offset element in rectVertices) {
      if (!rect.containsOffset(element)) {
        return;
      }
    }
    if (fixed == true) {
      _screenDestinationRect = rect;
      // scale has already apply
      preTotalScale = totalScale;
    }

    this.totalScale = totalScale;
  }
}
