import 'package:flutter/material.dart';

///
///  create by zhoumaotuo on 2019/8/22
///

class ExtendedImageEditorLayer extends StatefulWidget {
  final Rect editRect;
  ExtendedImageEditorLayer({@required this.editRect});
  @override
  _ExtendedImageEditorLayerState createState() =>
      _ExtendedImageEditorLayerState();
}

class _ExtendedImageEditorLayerState extends State<ExtendedImageEditorLayer> {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ExtendedImageEditorLayerPainter(editRect: widget.editRect),
    );
  }
}

class ExtendedImageEditorLayerPainter extends CustomPainter {
  final Rect editRect;
  ExtendedImageEditorLayerPainter({@required this.editRect});
  @override
  void paint(Canvas canvas, Size size) {
    var rect = Offset.zero & size;
    canvas.saveLayer(rect, Paint());
    canvas.drawRect(
        rect,
        Paint()
          ..style = PaintingStyle.fill
          ..color = Colors.black.withOpacity(0.8));
    canvas.drawRect(editRect, Paint()..blendMode = BlendMode.clear);
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return editRect !=
        (oldDelegate as ExtendedImageEditorLayerPainter).editRect;
  }
}
