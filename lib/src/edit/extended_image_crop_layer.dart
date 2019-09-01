import 'dart:math';

import 'package:extended_image/src/image/extended_render_image.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

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
  final ui.Image image;
  final double scale;
  final BoxFit fit;
  final Alignment alignment;
  final Rect centerSlice;
  ExtendedImageCropLayer(
      {@required this.image,
      this.scale = 1.0,
      this.fit,
      this.alignment = Alignment.center,
      this.centerSlice,
      Key key})
      : super(key: key);
  @override
  ExtendedImageCropLayerState createState() => ExtendedImageCropLayerState();
}

class ExtendedImageCropLayerState extends State<ExtendedImageCropLayer> {
  Rect _editRect;
  Rect get editRect => _editRect;
  final double gWidth = 15.0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(ExtendedImageCropLayer oldWidget) {
    if (oldWidget.image != widget.image ||
        oldWidget.scale != widget.scale ||
        oldWidget.fit != widget.fit ||
        oldWidget.alignment != widget.alignment ||
        oldWidget.centerSlice != widget.centerSlice) {
      _editRect = null;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, con) {
        var layoutRect = Offset.zero & Size(con.maxWidth, con.maxHeight);
        if (_editRect == null) {
          _editRect = getDestinationRect(
              rect: layoutRect,
              image: widget.image,
              fit: widget.fit,
              alignment: widget.alignment,
              centerSlice: widget.centerSlice,
              scale: widget.scale,
              flipHorizontally: false);
          _editRect = Rect.fromLTRB(_editRect.left + 20.0, _editRect.top + 20.0,
              _editRect.right - 20.0, _editRect.bottom - 20.0);
        }
        return CustomPaint(
          painter: ExtendedImageCropLayerPainter(editRect: _editRect),
          child: Stack(
            children: <Widget>[
              //top left
              Positioned(
                top: _editRect.top - gWidth,
                left: _editRect.left - gWidth,
                child: Container(
                  height: gWidth * 2,
                  width: gWidth * 2,
                  child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onPanUpdate: (details) {
                        moveUpdate(
                            _moveType.topLeft, details.delta, layoutRect);
                      }),
                ),
              ),
              //top right
              Positioned(
                top: _editRect.top - gWidth,
                right: layoutRect.right - _editRect.right - gWidth,
                child: Container(
                  height: gWidth * 2,
                  width: gWidth * 2,
                  child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onPanUpdate: (details) {
                        moveUpdate(
                            _moveType.topRight, details.delta, layoutRect);
                      }),
                ),
              ),
              //bottom right
              Positioned(
                bottom: layoutRect.bottom - _editRect.bottom - gWidth,
                right: layoutRect.right - _editRect.right - gWidth,
                child: Container(
                  height: gWidth * 2,
                  width: gWidth * 2,
                  child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onPanUpdate: (details) {
                        moveUpdate(
                            _moveType.bottomRight, details.delta, layoutRect);
                      }),
                ),
              ),
              // bottom left
              Positioned(
                bottom: layoutRect.bottom - _editRect.bottom - gWidth,
                left: _editRect.left - gWidth,
                child: Container(
                  height: gWidth * 2,
                  width: gWidth * 2,
                  child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onPanUpdate: (details) {
                        moveUpdate(
                            _moveType.bottomLeft, details.delta, layoutRect);
                      }),
                ),
              ),
              // top
              Positioned(
                top: _editRect.top - gWidth,
                left: _editRect.left + gWidth,
                child: Container(
                  height: gWidth * 2,
                  width: _editRect.width - gWidth * 2,
                  child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onVerticalDragUpdate: (details) {
                        moveUpdate(_moveType.top, details.delta, layoutRect);
                      }),
                ),
              ),
              //left
              Positioned(
                top: _editRect.top + gWidth,
                left: _editRect.left - gWidth,
                child: Container(
                  height: _editRect.height - gWidth * 2,
                  width: gWidth * 2,
                  child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onHorizontalDragUpdate: (details) {
                        moveUpdate(_moveType.left, details.delta, layoutRect);
                      }),
                ),
              ),
              //bottom
              Positioned(
                top: _editRect.bottom - gWidth,
                left: _editRect.left + gWidth,
                child: Container(
                  height: gWidth * 2,
                  width: _editRect.width - gWidth * 2,
                  child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onVerticalDragUpdate: (details) {
                        moveUpdate(_moveType.bottom, details.delta, layoutRect);
                      }),
                ),
              ),
              //right
              Positioned(
                top: _editRect.top + gWidth,
                left: _editRect.right - gWidth,
                child: Container(
                  height: _editRect.height - gWidth * 2,
                  width: gWidth * 2,
                  child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onHorizontalDragUpdate: (details) {
                        moveUpdate(_moveType.right, details.delta, layoutRect);
                      }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void moveUpdate(_moveType moveType, Offset delta, Rect layoutRect) {
    Rect editRect = _editRect;
    switch (moveType) {
      case _moveType.topLeft:
      case _moveType.top:
      case _moveType.left:
        var topLeft = _editRect.topLeft + delta;
        topLeft = Offset(min(topLeft.dx, _editRect.right - gWidth * 4),
            min(topLeft.dy, _editRect.bottom - gWidth * 4));
        editRect = Rect.fromPoints(topLeft, _editRect.bottomRight);
        break;
      case _moveType.topRight:
        var topRight = _editRect.topRight + delta;
        topRight = Offset(max(topRight.dx, _editRect.left + gWidth * 4),
            min(topRight.dy, _editRect.bottom - gWidth * 4));
        editRect = Rect.fromPoints(topRight, _editRect.bottomLeft);
        break;
      case _moveType.bottomRight:
      case _moveType.right:
      case _moveType.bottom:
        var bottomRight = _editRect.bottomRight + delta;
        bottomRight = Offset(max(bottomRight.dx, _editRect.left + gWidth * 4),
            max(bottomRight.dy, _editRect.top + gWidth * 4));
        editRect = Rect.fromPoints(_editRect.topLeft, bottomRight);
        break;
      case _moveType.bottomLeft:
        var bottomLeft = _editRect.bottomLeft + delta;
        bottomLeft = Offset(min(bottomLeft.dx, _editRect.right - gWidth * 4),
            max(bottomLeft.dy, _editRect.top + gWidth * 4));
        editRect = Rect.fromPoints(bottomLeft, _editRect.topRight);
        break;
      default:
    }

    editRect = Rect.fromPoints(
        Offset(max(editRect.left, layoutRect.left),
            max(editRect.top, layoutRect.top)),
        Offset(min(editRect.right, layoutRect.right),
            min(editRect.bottom, layoutRect.bottom)));

    if (editRect != _editRect && mounted) {
      setState(() {
        _editRect = editRect;
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
