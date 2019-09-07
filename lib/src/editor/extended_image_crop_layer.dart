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
  final Rect layoutRect;
  ExtendedImageCropLayer({this.editActionDetails, this.layoutRect, Key key})
      : super(key: key);
  @override
  ExtendedImageCropLayerState createState() => ExtendedImageCropLayerState();
}

class ExtendedImageCropLayerState extends State<ExtendedImageCropLayer> {
//  Rect get _cropRect => widget.gestureDetails.editAction.cropRect
//      ?.shift(-widget.gestureDetails.layoutRect?.topLeft);
//
//  set _cropRect(Rect value) => widget.gestureDetails.editAction.cropRect =
//      value?.shift(widget.gestureDetails.layoutRect?.topLeft);
//
  Rect get _layoutRect => widget.layoutRect;

  Rect get cropRect => widget.editActionDetails.cropRect;
  set cropRect(value) => widget.editActionDetails.cropRect = value;

  final double gWidth = 15.0;
  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(ExtendedImageCropLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    if (cropRect == null) return Container();

    Widget result = CustomPaint(
      painter: ExtendedImageCropLayerPainter(editRect: cropRect),
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
                  }),
            ),
          ),
          //top right
          Positioned(
            top: cropRect.top - gWidth,
            right: _layoutRect.right - cropRect.right - gWidth,
            child: Container(
              height: gWidth * 2,
              width: gWidth * 2,
              child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onPanUpdate: (details) {
                    moveUpdate(_moveType.topRight, details.delta);
                  }),
            ),
          ),
          //bottom right
          Positioned(
            bottom: _layoutRect.bottom - cropRect.bottom - gWidth,
            right: _layoutRect.right - cropRect.right - gWidth,
            child: Container(
              height: gWidth * 2,
              width: gWidth * 2,
              child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onPanUpdate: (details) {
                    moveUpdate(_moveType.bottomRight, details.delta);
                  }),
            ),
          ),
          // bottom left
          Positioned(
            bottom: _layoutRect.bottom - cropRect.bottom - gWidth,
            left: cropRect.left - gWidth,
            child: Container(
              height: gWidth * 2,
              width: gWidth * 2,
              child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onPanUpdate: (details) {
                    moveUpdate(_moveType.bottomLeft, details.delta);
                  }),
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
                  }),
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
                  }),
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
                  }),
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
                  }),
            ),
          ),
        ],
      ),
    );

    return result;
  }

  void moveUpdate(_moveType moveType, Offset delta) {
    Rect result = cropRect;
    switch (moveType) {
      case _moveType.topLeft:
      case _moveType.top:
      case _moveType.left:
        var topLeft = result.topLeft + delta;
        topLeft = Offset(min(topLeft.dx, result.right - gWidth * 4),
            min(topLeft.dy, result.bottom - gWidth * 4));
        result = Rect.fromPoints(topLeft, result.bottomRight);
        break;
      case _moveType.topRight:
        var topRight = result.topRight + delta;
        topRight = Offset(max(topRight.dx, result.left + gWidth * 4),
            min(topRight.dy, result.bottom - gWidth * 4));
        result = Rect.fromPoints(topRight, result.bottomLeft);
        break;
      case _moveType.bottomRight:
      case _moveType.right:
      case _moveType.bottom:
        var bottomRight = result.bottomRight + delta;
        bottomRight = Offset(max(bottomRight.dx, result.left + gWidth * 4),
            max(bottomRight.dy, result.top + gWidth * 4));
        result = Rect.fromPoints(result.topLeft, bottomRight);
        break;
      case _moveType.bottomLeft:
        var bottomLeft = result.bottomLeft + delta;
        bottomLeft = Offset(min(bottomLeft.dx, result.right - gWidth * 4),
            max(bottomLeft.dy, result.top + gWidth * 4));
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
}

class ExtendedImageCropLayerPainter extends CustomPainter {
  final Rect editRect;
  ExtendedImageCropLayerPainter({@required this.editRect});
  @override
  void paint(Canvas canvas, Size size) {
    var rect = Offset.zero & size;
    var linePainter = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    canvas.saveLayer(rect, Paint());
    canvas.drawRect(
        rect,
        Paint()
          ..style = PaintingStyle.fill
          ..color = Colors.white.withOpacity(0.8));
    canvas.drawRect(editRect, Paint()..blendMode = BlendMode.clear);

    canvas.restore();

    canvas.drawRect(editRect, linePainter);

    canvas.drawLine(
        Offset((editRect.right - editRect.left) / 3.0 + editRect.left,
            editRect.top),
        Offset((editRect.right - editRect.left) / 3.0 + editRect.left,
            editRect.bottom),
        linePainter);

    canvas.drawLine(
        Offset((editRect.right - editRect.left) / 3.0 * 2.0 + editRect.left,
            editRect.top),
        Offset((editRect.right - editRect.left) / 3.0 * 2.0 + editRect.left,
            editRect.bottom),
        linePainter);

    canvas.drawLine(
        Offset(
          editRect.left,
          (editRect.bottom - editRect.top) / 3.0 + editRect.top,
        ),
        Offset(
          editRect.right,
          (editRect.bottom - editRect.top) / 3.0 + editRect.top,
        ),
        linePainter);

    canvas.drawLine(
        Offset(editRect.left,
            (editRect.bottom - editRect.top) / 3.0 * 2.0 + editRect.top),
        Offset(
          editRect.right,
          (editRect.bottom - editRect.top) / 3.0 * 2.0 + editRect.top,
        ),
        linePainter);

    var rectPainter = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;
    final double rectWidth = 30.0;
    final double rectHeight = 5.0;
    canvas.drawPath(
        Path()
          ..moveTo(editRect.left, editRect.top)
          ..lineTo(editRect.left + rectWidth, editRect.top)
          ..lineTo(editRect.left + rectWidth, editRect.top + rectHeight)
          ..lineTo(editRect.left + rectHeight, editRect.top + rectHeight)
          ..lineTo(editRect.left + rectHeight, editRect.top + rectWidth)
          ..lineTo(editRect.left, editRect.top + rectWidth),
        rectPainter);

    canvas.drawPath(
        Path()
          ..moveTo(editRect.left, editRect.bottom)
          ..lineTo(editRect.left + rectWidth, editRect.bottom)
          ..lineTo(editRect.left + rectWidth, editRect.bottom - rectHeight)
          ..lineTo(editRect.left + rectHeight, editRect.bottom - rectHeight)
          ..lineTo(editRect.left + rectHeight, editRect.bottom - rectWidth)
          ..lineTo(editRect.left, editRect.bottom - rectWidth),
        rectPainter);

    canvas.drawPath(
        Path()
          ..moveTo(editRect.right, editRect.top)
          ..lineTo(editRect.right - rectWidth, editRect.top)
          ..lineTo(editRect.right - rectWidth, editRect.top + rectHeight)
          ..lineTo(editRect.right - rectHeight, editRect.top + rectHeight)
          ..lineTo(editRect.right - rectHeight, editRect.top + rectWidth)
          ..lineTo(editRect.right, editRect.top + rectWidth),
        rectPainter);

    canvas.drawPath(
        Path()
          ..moveTo(editRect.right, editRect.bottom)
          ..lineTo(editRect.right - rectWidth, editRect.bottom)
          ..lineTo(editRect.right - rectWidth, editRect.bottom - rectHeight)
          ..lineTo(editRect.right - rectHeight, editRect.bottom - rectHeight)
          ..lineTo(editRect.right - rectHeight, editRect.bottom - rectWidth)
          ..lineTo(editRect.right, editRect.bottom - rectWidth),
        rectPainter);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return editRect != (oldDelegate as ExtendedImageCropLayerPainter).editRect;
  }
}
