import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../extended_image_utils.dart';
import 'extended_image_editor_utils.dart';

///
///  create by zhoumaotuo on 2019/8/22
///

enum _moveType {
  topLeft,
  topRight,
  bottomRight,
  bottomLeft,
  top,
  right,
  bottom,
  left
}

class ExtendedImageCropLayer extends StatefulWidget {
  const ExtendedImageCropLayer(
      {this.editActionDetails,
      this.layoutRect,
      this.editorConfig,
      Key key,
      this.fit})
      : super(key: key);

  final EditActionDetails editActionDetails;
  final EditorConfig editorConfig;
  final Rect layoutRect;
  final BoxFit fit;
  @override
  ExtendedImageCropLayerState createState() => ExtendedImageCropLayerState();
}

class ExtendedImageCropLayerState extends State<ExtendedImageCropLayer>
    with SingleTickerProviderStateMixin {
  Rect get layoutRect => widget.layoutRect;

  Rect get cropRect => widget.editActionDetails.cropRect;
  set cropRect(Rect value) => widget.editActionDetails.cropRect = value;

  bool get isAnimating => _rectTweenController?.isAnimating ?? false;
  bool get isMoving => _currentMoveType != null;

  Timer _timer;
  bool _pointerDown = false;
  Tween<Rect> _rectTween;
  Animation<Rect> _rectAnimation;
  AnimationController _rectTweenController;
  _moveType _currentMoveType;
  @override
  void initState() {
    _pointerDown = false;
    _rectTweenController = AnimationController(
        vsync: this, duration: widget.editorConfig.animationDuration)
      ..addListener(_doCropAutoCenterAnimation);
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _rectTweenController?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ExtendedImageCropLayer oldWidget) {
    if (widget.editorConfig.animationDuration !=
        oldWidget.editorConfig.animationDuration) {
      _rectTweenController?.stop();
      _rectTweenController?.dispose();
      _rectTweenController = AnimationController(
          vsync: this, duration: widget.editorConfig.animationDuration)
        ..addListener(_doCropAutoCenterAnimation);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    if (cropRect == null) {
      return Container();
    }
    final EditorConfig editConfig = widget.editorConfig;
    final Color cornerColor =
        widget.editorConfig.cornerColor ?? Theme.of(context).primaryColor;
    final Color maskColor = widget.editorConfig.editorMaskColorHandler
            ?.call(context, _pointerDown) ??
        defaultEditorMaskColorHandler(context, _pointerDown);
    final double gWidth = widget.editorConfig.hitTestSize;

    final Widget result = CustomPaint(
      painter: ExtendedImageCropLayerPainter(
          cropRect: cropRect,
          cornerColor: cornerColor,
          cornerSize: editConfig.cornerSize,
          lineColor: editConfig.lineColor ??
              Theme.of(context).scaffoldBackgroundColor.withOpacity(0.7),
          lineHeight: editConfig.lineHeight,
          maskColor: maskColor,
          pointerDown: _pointerDown),
      child: Stack(
        children: <Widget>[
          //top left
          Positioned(
            top: cropRect.top - gWidth,
            left: cropRect.left - gWidth,
            child: Container(
              height: gWidth * 2,
              width: gWidth * 2,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onPanUpdate: (DragUpdateDetails details) {
                  moveUpdate(_moveType.topLeft, details.delta);
                },
                onPanEnd: (_) {
                  _moveEnd(_moveType.topLeft);
                },
              ),
            ),
          ),
          //top right
          Positioned(
            top: cropRect.top - gWidth,
            left: cropRect.right - gWidth,
            child: Container(
              height: gWidth * 2,
              width: gWidth * 2,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onPanUpdate: (DragUpdateDetails details) {
                  moveUpdate(_moveType.topRight, details.delta);
                },
                onPanEnd: (_) {
                  _moveEnd(_moveType.topRight);
                },
              ),
            ),
          ),
          //bottom left
          Positioned(
            top: cropRect.bottom - gWidth,
            left: cropRect.left - gWidth,
            child: Container(
              height: gWidth * 2,
              width: gWidth * 2,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onPanUpdate: (DragUpdateDetails details) {
                  moveUpdate(_moveType.bottomLeft, details.delta);
                },
                onPanEnd: (_) {
                  _moveEnd(_moveType.bottomLeft);
                },
              ),
            ),
          ),
          // bottom right
          Positioned(
            top: cropRect.bottom - gWidth,
            left: cropRect.right - gWidth,
            child: Container(
              height: gWidth * 2,
              width: gWidth * 2,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onPanUpdate: (DragUpdateDetails details) {
                  moveUpdate(_moveType.bottomRight, details.delta);
                },
                onPanEnd: (_) {
                  _moveEnd(_moveType.bottomRight);
                },
              ),
            ),
          ),
          // top
          Positioned(
            top: cropRect.top - gWidth,
            left: cropRect.left + gWidth,
            child: Container(
              height: gWidth * 2,
              width: cropRect.width - gWidth * 2,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onVerticalDragUpdate: (DragUpdateDetails details) {
                  moveUpdate(_moveType.top, details.delta);
                },
                onVerticalDragEnd: (_) {
                  _moveEnd(_moveType.top);
                },
              ),
            ),
          ),
          //left
          Positioned(
            top: cropRect.top + gWidth,
            left: cropRect.left - gWidth,
            child: Container(
              height: cropRect.height - gWidth * 2,
              width: gWidth * 2,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onHorizontalDragUpdate: (DragUpdateDetails details) {
                  moveUpdate(_moveType.left, details.delta);
                },
                onHorizontalDragEnd: (_) {
                  _moveEnd(_moveType.left);
                },
              ),
            ),
          ),
          //bottom
          Positioned(
            top: cropRect.bottom - gWidth,
            left: cropRect.left + gWidth,
            child: Container(
              height: gWidth * 2,
              width: cropRect.width - gWidth * 2,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onVerticalDragUpdate: (DragUpdateDetails details) {
                  moveUpdate(_moveType.bottom, details.delta);
                },
                onVerticalDragEnd: (_) {
                  _moveEnd(_moveType.bottom);
                },
              ),
            ),
          ),
          //right
          Positioned(
            top: cropRect.top + gWidth,
            left: cropRect.right - gWidth,
            child: Container(
              height: cropRect.height - gWidth * 2,
              width: gWidth * 2,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onHorizontalDragUpdate: (DragUpdateDetails details) {
                  moveUpdate(_moveType.right, details.delta);
                },
                onHorizontalDragEnd: (_) {
                  _moveEnd(_moveType.right);
                },
              ),
            ),
          ),
        ],
      ),
    );

    return result;
  }

  void pointerDown(bool down) {
    if (mounted && _pointerDown != down) {
      setState(() {
        _pointerDown = down;
      });
    }
  }

  void moveUpdate(_moveType moveType, Offset delta) {
    if (isAnimating) {
      return;
    }

    ///only move by one type at the same time
    if (_currentMoveType != null && moveType != _currentMoveType) {
      return;
    }
    _currentMoveType = moveType;

    final Rect layerDestinationRect =
        widget.editActionDetails.layerDestinationRect;
    Rect result = cropRect;
    final double gWidth = widget.editorConfig.cornerSize.width;
    switch (moveType) {
      case _moveType.topLeft:
      case _moveType.top:
      case _moveType.left:
        Offset topLeft = result.topLeft + delta;
        topLeft = Offset(min(topLeft.dx, result.right - gWidth * 2),
            min(topLeft.dy, result.bottom - gWidth * 2));
        result = Rect.fromPoints(topLeft, result.bottomRight);
        break;
      case _moveType.topRight:
        Offset topRight = result.topRight + delta;
        topRight = Offset(max(topRight.dx, result.left + gWidth * 2),
            min(topRight.dy, result.bottom - gWidth * 2));
        result = Rect.fromPoints(topRight, result.bottomLeft);
        break;
      case _moveType.bottomRight:
      case _moveType.right:
      case _moveType.bottom:
        Offset bottomRight = result.bottomRight + delta;
        bottomRight = Offset(max(bottomRight.dx, result.left + gWidth * 2),
            max(bottomRight.dy, result.top + gWidth * 2));
        result = Rect.fromPoints(result.topLeft, bottomRight);
        break;
      case _moveType.bottomLeft:
        Offset bottomLeft = result.bottomLeft + delta;
        bottomLeft = Offset(min(bottomLeft.dx, result.right - gWidth * 2),
            max(bottomLeft.dy, result.top + gWidth * 2));
        result = Rect.fromPoints(bottomLeft, result.topRight);
        break;
      default:
    }

    // result = Rect.fromPoints(
    //     Offset(
    //         max(result.left, layoutRect.left), max(result.top, layoutRect.top)),
    //     Offset(min(result.right, layoutRect.right),
    //         min(result.bottom, layoutRect.bottom)));

    ///make sure crop rect doesn't out of image rect
    result = Rect.fromPoints(
        Offset(max(result.left, layerDestinationRect.left),
            max(result.top, layerDestinationRect.top)),
        Offset(min(result.right, layerDestinationRect.right),
            min(result.bottom, layerDestinationRect.bottom)));

    result = _handleAspectRatio(
        gWidth, moveType, result, layerDestinationRect, delta);

    ///move and scale image rect when crop rect is bigger than layout rect
    if (doubleCompare(result.left, layoutRect.left) < 0 ||
        doubleCompare(result.right, layoutRect.right) > 0 ||
        doubleCompare(result.top, layoutRect.top) < 0 ||
        doubleCompare(result.bottom, layoutRect.bottom) > 0) {
      cropRect = result;
      final Rect centerCropRect = getDestinationRect(
          rect: layoutRect, inputSize: result.size, fit: widget.fit);
      final Rect newScreenCropRect =
          centerCropRect.shift(widget.editActionDetails.layoutTopLeft);
      _doCropAutoCenterAnimation(newScreenCropRect: newScreenCropRect);
    } else {
      result = _doWithMaxScale(result);

      if (result != null && result != cropRect && mounted) {
        setState(() {
          cropRect = result;
        });
      }
    }
  }

  /// handle crop rect with aspectRatio
  Rect _handleAspectRatio(double gWidth, _moveType moveType, Rect result,
      Rect layerDestinationRect, Offset delta) {
    final double aspectRatio = widget.editActionDetails.cropAspectRatio;
    // do with aspect ratio
    if (aspectRatio != null) {
      final double minD = gWidth * 2;
      switch (moveType) {
        case _moveType.top:
        case _moveType.bottom:
          final bool isTop = moveType == _moveType.top;
          result = _doAspectRatioV(
              minD, result, aspectRatio, layerDestinationRect,
              isTop: isTop);
          break;
        case _moveType.left:
        case _moveType.right:
          final bool isLeft = moveType == _moveType.left;
          result = _doAspectRatioH(
              minD, result, aspectRatio, layerDestinationRect,
              isLeft: isLeft);
          break;
        case _moveType.topLeft:
        case _moveType.topRight:
        case _moveType.bottomRight:
        case _moveType.bottomLeft:
          final double dx = delta.dx.abs();
          final double dy = delta.dy.abs();
          double width = result.width;
          double height = result.height;
          if (doubleCompare(dx, dy) >= 0) {
            height = max(minD,
                min(result.width / aspectRatio, layerDestinationRect.height));
            width = height * aspectRatio;
          } else {
            width = max(minD,
                min(result.height * aspectRatio, layerDestinationRect.width));
            height = width / aspectRatio;
          }
          double top = result.top;
          double left = result.left;
          switch (moveType) {
            case _moveType.topLeft:
              top = result.bottom - height;
              left = result.right - width;
              break;
            case _moveType.topRight:
              top = result.bottom - height;
              left = result.left;
              break;
            case _moveType.bottomRight:
              top = result.top;
              left = result.left;
              break;
            case _moveType.bottomLeft:
              top = result.top;
              left = result.right - width;
              break;
            default:
          }
          result = Rect.fromLTWH(left, top, width, height);
          break;
        default:
      }
    }
    return result;
  }

  ///horizontal
  Rect _doAspectRatioH(
      double minD, Rect result, double aspectRatio, Rect layerDestinationRect,
      {bool isLeft}) {
    final double height =
        max(minD, min(result.width / aspectRatio, layerDestinationRect.height));
    final double width = height * aspectRatio;
    final double left = isLeft ? result.right - width : result.left;
    final double top = result.centerRight.dy - height / 2.0;
    result = Rect.fromLTWH(left, top, width, height);
    return result;
  }

  ///vertical
  Rect _doAspectRatioV(
      double minD, Rect result, double aspectRatio, Rect layerDestinationRect,
      {bool isTop}) {
    final double width =
        max(minD, min(result.height * aspectRatio, layerDestinationRect.width));
    final double height = width / aspectRatio;
    final double top = isTop ? result.bottom - height : result.top;
    final double left = result.topCenter.dx - width / 2.0;
    result = Rect.fromLTWH(left, top, width, height);
    return result;
  }

  Rect _doWithMaxScale(Rect rect) {
    final Rect centerCropRect = getDestinationRect(
        rect: layoutRect, inputSize: rect.size, fit: widget.fit);
    final Rect newScreenCropRect =
        centerCropRect.shift(widget.editActionDetails.layoutTopLeft);

    final Rect oldScreenCropRect = widget.editActionDetails.screenCropRect;

    final double scale = newScreenCropRect.width / oldScreenCropRect.width;

    final double totalScale = widget.editActionDetails.totalScale * scale;
    if (doubleCompare(totalScale, widget.editorConfig.maxScale) > 0) {
      if (doubleCompare(rect.width, cropRect.width) > 0 ||
          doubleCompare(rect.height, cropRect.height) > 0) {
        return rect;
      }
      return null;
    }

    return rect;
  }

  void _moveEnd(_moveType moveType) {
    if (_currentMoveType != null && moveType == _currentMoveType) {
      _currentMoveType = null;
      //if (widget.editorConfig.autoCenter)
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    if (isAnimating) {
      return;
    }
    _timer = Timer.periodic(widget.editorConfig.tickerDuration, (Timer timer) {
      _timer?.cancel();

      //move to center
      final Rect oldScreenCropRect = widget.editActionDetails.screenCropRect;

      final Rect centerCropRect = getDestinationRect(
          rect: layoutRect, inputSize: cropRect.size, fit: widget.fit);
      final Rect newScreenCropRect =
          centerCropRect.shift(widget.editActionDetails.layoutTopLeft);

      _rectTween = RectTween(begin: oldScreenCropRect, end: newScreenCropRect);
      _rectAnimation = _rectTweenController?.drive(_rectTween);
      _rectTweenController?.reset();
      _rectTweenController?.forward();
    });
  }

  void _doCropAutoCenterAnimation({Rect newScreenCropRect}) {
    if (mounted) {
      setState(() {
        final Rect oldScreenCropRect = widget.editActionDetails.screenCropRect;
        final Rect oldScreenDestinationRect =
            widget.editActionDetails.screenDestinationRect;

        newScreenCropRect ??= _rectAnimation.value;

        final double scale = newScreenCropRect.width / oldScreenCropRect.width;

        final Offset offset =
            newScreenCropRect.center - oldScreenCropRect.center;

        /// scale then move
        /// so we do scale first, get the new center
        /// then move to new offset
        final Offset newImageCenter = oldScreenCropRect.center +
            (oldScreenDestinationRect.center - oldScreenCropRect.center) *
                scale;
        final Rect newScreenDestinationRect = Rect.fromCenter(
          center: newImageCenter + offset,
          width: oldScreenDestinationRect.width * scale,
          height: oldScreenDestinationRect.height * scale,
        );

        // var totalScale = newScreenDestinationRect.width /
        //     (widget.editActionDetails.rawDestinationRect.width *
        //     widget.editorConfig.initialScale);
        final double totalScale = widget.editActionDetails.totalScale * scale;

        cropRect =
            newScreenCropRect.shift(-widget.editActionDetails.layoutTopLeft);

        widget.editActionDetails
            .setScreenDestinationRect(newScreenDestinationRect);
        widget.editActionDetails.totalScale = totalScale;
        widget.editActionDetails.preTotalScale = totalScale;
      });
    }
  }
}

class ExtendedImageCropLayerPainter extends CustomPainter {
  ExtendedImageCropLayerPainter(
      {@required this.cropRect,
      this.lineColor,
      this.cornerColor,
      this.cornerSize,
      this.lineHeight,
      this.maskColor,
      this.pointerDown});

  final Rect cropRect;
  //size of corner shape
  final Size cornerSize;

  //color of corner shape
  //default theme primaryColor
  final Color cornerColor;

  // color of crop line
  final Color lineColor;

  //height of crop line
  final double lineHeight;

  //color of mask
  final Color maskColor;

  //whether pointer is down
  final bool pointerDown;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final Paint linePainter = Paint()
      ..color = lineColor
      ..strokeWidth = lineHeight
      ..style = PaintingStyle.stroke;

    // canvas.saveLayer(rect, Paint());
    // canvas.drawRect(
    //     rect,
    //     Paint()
    //       ..style = PaintingStyle.fill
    //       ..color = maskColor);
    //   canvas.drawRect(cropRect, Paint()..blendMode = BlendMode.clear);
    // canvas.restore();

    // draw mask rect instead use BlendMode.clear, web doesn't support now.
    //left
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

    final Paint cornerPainter = Paint()
      ..color = cornerColor
      ..style = PaintingStyle.fill;
    final double cornerWidth = cornerSize.width;
    final double cornerHeight = cornerSize.height;
    canvas.drawPath(
        Path()
          ..moveTo(cropRect.left, cropRect.top)
          ..lineTo(cropRect.left + cornerWidth, cropRect.top)
          ..lineTo(cropRect.left + cornerWidth, cropRect.top + cornerHeight)
          ..lineTo(cropRect.left + cornerHeight, cropRect.top + cornerHeight)
          ..lineTo(cropRect.left + cornerHeight, cropRect.top + cornerWidth)
          ..lineTo(cropRect.left, cropRect.top + cornerWidth),
        cornerPainter);

    canvas.drawPath(
        Path()
          ..moveTo(cropRect.left, cropRect.bottom)
          ..lineTo(cropRect.left + cornerWidth, cropRect.bottom)
          ..lineTo(cropRect.left + cornerWidth, cropRect.bottom - cornerHeight)
          ..lineTo(cropRect.left + cornerHeight, cropRect.bottom - cornerHeight)
          ..lineTo(cropRect.left + cornerHeight, cropRect.bottom - cornerWidth)
          ..lineTo(cropRect.left, cropRect.bottom - cornerWidth),
        cornerPainter);

    canvas.drawPath(
        Path()
          ..moveTo(cropRect.right, cropRect.top)
          ..lineTo(cropRect.right - cornerWidth, cropRect.top)
          ..lineTo(cropRect.right - cornerWidth, cropRect.top + cornerHeight)
          ..lineTo(cropRect.right - cornerHeight, cropRect.top + cornerHeight)
          ..lineTo(cropRect.right - cornerHeight, cropRect.top + cornerWidth)
          ..lineTo(cropRect.right, cropRect.top + cornerWidth),
        cornerPainter);

    canvas.drawPath(
        Path()
          ..moveTo(cropRect.right, cropRect.bottom)
          ..lineTo(cropRect.right - cornerWidth, cropRect.bottom)
          ..lineTo(cropRect.right - cornerWidth, cropRect.bottom - cornerHeight)
          ..lineTo(
              cropRect.right - cornerHeight, cropRect.bottom - cornerHeight)
          ..lineTo(cropRect.right - cornerHeight, cropRect.bottom - cornerWidth)
          ..lineTo(cropRect.right, cropRect.bottom - cornerWidth),
        cornerPainter);
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
        cornerColor != delegate.cornerColor ||
        pointerDown != delegate.pointerDown;
  }
}
