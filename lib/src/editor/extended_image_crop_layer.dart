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

class ExtendedImageCropLayerState extends State<ExtendedImageCropLayer> {
  Rect get _layoutRect => widget.layoutRect;

  Rect get cropRect => widget.editActionDetails.cropRect;
  set cropRect(value) => widget.editActionDetails.cropRect = value;

  Timer _timer;
  bool _pointerDown = false;

  @override
  void initState() {
    _pointerDown = false;
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(ExtendedImageCropLayer oldWidget) {
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
    final double gWidth = widget.editorConfig.cornerAndLineHitTestSize;

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
                  moveEnd();
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
                  moveEnd();
                },
              ),
            ),
          ),
          //bottom right
          Positioned(
            top: cropRect.bottom - gWidth,
            left: cropRect.left - gWidth,
            child: Container(
              height: gWidth * 2,
              width: gWidth * 2,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onPanUpdate: (details) {
                  moveUpdate(_moveType.bottomRight, details.delta);
                },
                onPanEnd: (_) {
                  moveEnd();
                },
              ),
            ),
          ),
          // bottom left
          Positioned(
            top: cropRect.bottom - gWidth,
            left: cropRect.right - gWidth,
            child: Container(
              height: gWidth * 2,
              width: gWidth * 2,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onPanUpdate: (details) {
                  moveUpdate(_moveType.bottomLeft, details.delta);
                },
                onPanEnd: (_) {
                  moveEnd();
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
                  moveEnd();
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
                  moveEnd();
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
                  moveEnd();
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
                  moveEnd();
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

    result = Rect.fromPoints(
        Offset(max(result.left, _layoutRect.left),
            max(result.top, _layoutRect.top)),
        Offset(min(result.right, _layoutRect.right),
            min(result.bottom, _layoutRect.bottom)));

    var rect = widget.editActionDetails.layerDestinationRect;

    result = Rect.fromPoints(
        Offset(max(result.left, rect.left), max(result.top, rect.top)),
        Offset(min(result.right, rect.right), min(result.bottom, rect.bottom)));
    if (result != cropRect && mounted) {
      setState(() {
        cropRect = result;
      });
    }
  }

  void moveEnd() {
    startTimer();
  }

  void startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      _timer?.cancel();
      //move to center
      setState(() {
        var centerCropRect = getDestinationRect(
            rect: _layoutRect, inputSize: cropRect.size, fit: BoxFit.contain);
        //cropRect = centerCropRect;

        var newScreenCropRect =
            centerCropRect.shift(widget.editActionDetails.layoutTopLeft);

        var oldScreenCropRect = widget.editActionDetails.screenCropRect;

        var oldScreenDestinationRect =
            widget.editActionDetails.screenDestinationRect;

        var offset = newScreenCropRect.center - oldScreenCropRect.center;

        var scale = newScreenCropRect.width / oldScreenCropRect.width;

        var newScreenDestinationRect = Rect.fromCenter(
          center: oldScreenDestinationRect.center + offset,
          width: oldScreenDestinationRect.width * scale,
          height: oldScreenDestinationRect.height * scale,
        );

        var totalScale = widget.editActionDetails.rawDestinationRect.width /
            newScreenCropRect.width;

        cropRect = centerCropRect;

        widget.editActionDetails.screenDestinationRect =
            newScreenDestinationRect;
        widget.editActionDetails.totalScale = totalScale;
        widget.editActionDetails.preTotalScale = totalScale;
      });
    });
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
