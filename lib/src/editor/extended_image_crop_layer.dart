import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

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
  final EditActionDetails editActionDetails;
  final EditorConfig editorConfig;
  final Rect layoutRect;
  ExtendedImageCropLayer(
      {this.editActionDetails, this.layoutRect, this.editorConfig, Key key})
      : super(key: key);
  @override
  ExtendedImageCropLayerState createState() => ExtendedImageCropLayerState();
}

class ExtendedImageCropLayerState extends State<ExtendedImageCropLayer>
    with SingleTickerProviderStateMixin {
  Rect get layoutRect => widget.layoutRect;

  Rect get cropRect => widget.editActionDetails.cropRect;
  set cropRect(value) => widget.editActionDetails.cropRect = value;

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
    if (cropRect == null) return Container();
    final EditorConfig editConfig = widget.editorConfig;
    final Color cornerColor =
        widget.editorConfig.cornerColor ?? Theme.of(context).primaryColor;
    final Color maskColor = widget.editorConfig.eidtorMaskColorHandler
            ?.call(context, _pointerDown) ??
        defaultEidtorMaskColorHandler(context, _pointerDown);
    final double gWidth = widget.editorConfig.hitTestSize;

    Widget result = CustomPaint(
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
                onPanUpdate: (details) {
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
                onPanUpdate: (details) {
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
                onPanUpdate: (details) {
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
                onPanUpdate: (details) {
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
                onVerticalDragUpdate: (details) {
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
                onHorizontalDragUpdate: (details) {
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
                onVerticalDragUpdate: (details) {
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
                onHorizontalDragUpdate: (details) {
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
    if (isAnimating) return;

    ///only move by one type at the same time
    if (_currentMoveType != null && moveType != _currentMoveType) return;
    _currentMoveType = moveType;

    final Rect layerDestinationRect =
        widget.editActionDetails.layerDestinationRect;
    Rect result = cropRect;
    final double gWidth = widget.editorConfig.cornerSize.width;
    switch (moveType) {
      case _moveType.topLeft:
      case _moveType.top:
      case _moveType.left:
        var topLeft = result.topLeft + delta;
        topLeft = Offset(min(topLeft.dx, result.right - gWidth * 2),
            min(topLeft.dy, result.bottom - gWidth * 2));
        result = Rect.fromPoints(topLeft, result.bottomRight);
        break;
      case _moveType.topRight:
        var topRight = result.topRight + delta;
        topRight = Offset(max(topRight.dx, result.left + gWidth * 2),
            min(topRight.dy, result.bottom - gWidth * 2));
        result = Rect.fromPoints(topRight, result.bottomLeft);
        break;
      case _moveType.bottomRight:
      case _moveType.right:
      case _moveType.bottom:
        var bottomRight = result.bottomRight + delta;
        bottomRight = Offset(max(bottomRight.dx, result.left + gWidth * 2),
            max(bottomRight.dy, result.top + gWidth * 2));
        result = Rect.fromPoints(result.topLeft, bottomRight);
        break;
      case _moveType.bottomLeft:
        var bottomLeft = result.bottomLeft + delta;
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
    if (result.left < layoutRect.left ||
        result.right > layoutRect.right ||
        result.top < layoutRect.top ||
        result.bottom > layoutRect.bottom) {
      cropRect = result;
      var centerCropRect = getDestinationRect(
          rect: layoutRect, inputSize: result.size, fit: BoxFit.contain);
      var newScreenCropRect =
          centerCropRect.shift(widget.editActionDetails.layoutTopLeft);
      _doCropAutoCenterAnimation(newScreenCropRect: newScreenCropRect);
    } else {
      result = _doWithMaxSacle(result);

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
          var isTop = moveType == _moveType.top;
          result = _doAspectRatioV(
              minD, result, aspectRatio, layerDestinationRect,
              isTop: isTop);
          break;
        case _moveType.left:
        case _moveType.right:
          var isLeft = moveType == _moveType.left;
          result = _doAspectRatioH(
              minD, result, aspectRatio, layerDestinationRect,
              isLeft: isLeft);
          break;
        case _moveType.topLeft:
        case _moveType.topRight:
        case _moveType.bottomRight:
        case _moveType.bottomLeft:
          var dx = delta.dx.abs();
          var dy = delta.dy.abs();
          var width = result.width;
          var height = result.height;
          if (dx >= dy) {
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
    double height =
        max(minD, min(result.width / aspectRatio, layerDestinationRect.height));
    double width = height * aspectRatio;
    var left = isLeft ? result.right - width : result.left;
    var top = result.centerRight.dy - height / 2.0;
    result = Rect.fromLTWH(left, top, width, height);
    return result;
  }

  ///vertical
  Rect _doAspectRatioV(
      double minD, Rect result, double aspectRatio, Rect layerDestinationRect,
      {bool isTop}) {
    double width =
        max(minD, min(result.height * aspectRatio, layerDestinationRect.width));
    double height = width / aspectRatio;
    var top = isTop ? result.bottom - height : result.top;
    var left = result.topCenter.dx - width / 2.0;
    result = Rect.fromLTWH(left, top, width, height);
    return result;
  }

  Rect _doWithMaxSacle(Rect rect) {
    var centerCropRect = getDestinationRect(
        rect: layoutRect, inputSize: rect.size, fit: BoxFit.contain);
    var newScreenCropRect =
        centerCropRect.shift(widget.editActionDetails.layoutTopLeft);

    var oldScreenCropRect = widget.editActionDetails.screenCropRect;

    var scale = newScreenCropRect.width / oldScreenCropRect.width;

    var totalScale = widget.editActionDetails.totalScale * scale;
    if (totalScale > widget.editorConfig.maxScale) {
      if (rect.width > cropRect.width || rect.height > cropRect.height)
        return rect;
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
    if (isAnimating) return;
    _timer = Timer.periodic(widget.editorConfig.tickerDuration, (Timer timer) {
      _timer?.cancel();

      //move to center
      var oldScreenCropRect = widget.editActionDetails.screenCropRect;

      var centerCropRect = getDestinationRect(
          rect: layoutRect, inputSize: cropRect.size, fit: BoxFit.contain);
      var newScreenCropRect =
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
        var oldScreenCropRect = widget.editActionDetails.screenCropRect;
        var oldScreenDestinationRect =
            widget.editActionDetails.screenDestinationRect;

        newScreenCropRect ??= _rectAnimation.value;

        var scale = newScreenCropRect.width / oldScreenCropRect.width;

        var offset = newScreenCropRect.center - oldScreenCropRect.center;

        /// scale then move
        /// so we do scale frist, get the new center
        /// then move to new offset
        var newImageCenter = oldScreenCropRect.center +
            (oldScreenDestinationRect.center - oldScreenCropRect.center) *
                scale;
        var newScreenDestinationRect = Rect.fromCenter(
          center: newImageCenter + offset,
          width: oldScreenDestinationRect.width * scale,
          height: oldScreenDestinationRect.height * scale,
        );

        // var totalScale = newScreenDestinationRect.width /
        //     (widget.editActionDetails.rawDestinationRect.width *
        //     widget.editorConfig.initialScale);
        var totalScale = widget.editActionDetails.totalScale * scale;

        cropRect =
            newScreenCropRect.shift(-widget.editActionDetails.layoutTopLeft);

        widget.editActionDetails.screenDestinationRect =
            newScreenDestinationRect;
        widget.editActionDetails.totalScale = totalScale;
        widget.editActionDetails.preTotalScale = totalScale;
      });
    }
  }
}

class ExtendedImageCropLayerPainter extends CustomPainter {
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

  ExtendedImageCropLayerPainter(
      {@required this.cropRect,
      this.lineColor,
      this.cornerColor,
      this.cornerSize,
      this.lineHeight,
      this.maskColor,
      this.pointerDown});
  @override
  void paint(Canvas canvas, Size size) {
    var rect = Offset.zero & size;
    var linePainter = Paint()
      ..color = lineColor
      ..strokeWidth = lineHeight
      ..style = PaintingStyle.stroke;

    canvas.saveLayer(rect, Paint());
    canvas.drawRect(
        rect,
        Paint()
          ..style = PaintingStyle.fill
          ..color = maskColor);
    canvas.drawRect(cropRect, Paint()..blendMode = BlendMode.clear);

    canvas.restore();
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

    var cornerPainter = Paint()
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
    var delegate = oldDelegate as ExtendedImageCropLayerPainter;
    return cropRect != delegate.cropRect ||
        cornerSize != delegate.cornerSize ||
        lineColor != delegate.lineColor ||
        lineHeight != delegate.lineHeight ||
        maskColor != delegate.maskColor ||
        cornerColor != delegate.cornerColor ||
        pointerDown != delegate.pointerDown;
  }
}
