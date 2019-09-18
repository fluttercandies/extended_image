import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

class FlatButtonWithIcon extends FlatButton with MaterialButtonWithIconMixin {
  FlatButtonWithIcon({
    Key key,
    @required VoidCallback onPressed,
    ValueChanged<bool> onHighlightChanged,
    ButtonTextTheme textTheme,
    Color textColor,
    Color disabledTextColor,
    Color color,
    Color disabledColor,
    Color focusColor,
    Color hoverColor,
    Color highlightColor,
    Color splashColor,
    Brightness colorBrightness,
    EdgeInsetsGeometry padding,
    ShapeBorder shape,
    Clip clipBehavior = Clip.none,
    FocusNode focusNode,
    MaterialTapTargetSize materialTapTargetSize,
    @required Widget icon,
    @required Widget label,
  })  : assert(icon != null),
        assert(label != null),
        super(
          key: key,
          onPressed: onPressed,
          onHighlightChanged: onHighlightChanged,
          textTheme: textTheme,
          textColor: textColor,
          disabledTextColor: disabledTextColor,
          color: color,
          disabledColor: disabledColor,
          focusColor: focusColor,
          hoverColor: hoverColor,
          highlightColor: highlightColor,
          splashColor: splashColor,
          colorBrightness: colorBrightness,
          padding: padding,
          shape: shape,
          clipBehavior: clipBehavior,
          focusNode: focusNode,
          materialTapTargetSize: materialTapTargetSize,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              icon,
              const SizedBox(height: 5.0),
              label,
            ],
          ),
        );
}

class AspectRatioWidget extends StatelessWidget {
  final String aspectRatioS;
  final double aspectRatio;
  final bool isSelected;
  AspectRatioWidget(
      {this.aspectRatioS, this.aspectRatio, this.isSelected: false});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60.0,
      height: 60.0,
      child: CustomPaint(
        painter: AspectRatioPainter(
            aspectRatio: aspectRatio,
            aspectRatioS: aspectRatioS,
            isSelected: isSelected),
      ),
    );
  }
}

class AspectRatioPainter extends CustomPainter {
  final String aspectRatioS;
  final double aspectRatio;
  final bool isSelected;
  AspectRatioPainter(
      {this.aspectRatioS, this.aspectRatio, this.isSelected: false});

  @override
  void paint(Canvas canvas, Size size) {
    final Color color = isSelected ? Colors.black : Colors.white;
    var rect = (Offset.zero & size);
    Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke;
    final double aspectRatioResult =
        (aspectRatio != null && aspectRatio > 0.0) ? aspectRatio : 1.0;
    canvas.drawRect(
        getDestinationRect(
            rect: EdgeInsets.all(10.0).deflateRect(rect),
            inputSize: Size(aspectRatioResult * 100, 100.0),
            fit: BoxFit.contain),
        paint);

    TextPainter textPainter = TextPainter(
        text: TextSpan(
            text: aspectRatioS,
            style: TextStyle(
              color: color,
              fontSize: 10.0,
            )),
        textDirection: TextDirection.ltr,
        maxLines: 1);
    textPainter.layout(maxWidth: rect.width);

    textPainter.paint(
        canvas,
        rect.center -
            Offset(textPainter.width / 2.0, textPainter.height / 2.0));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    var oldOne = oldDelegate as AspectRatioPainter;
    return oldOne.isSelected != isSelected ||
        oldOne.aspectRatioS != aspectRatioS ||
        oldOne.aspectRatio != aspectRatio;
  }
}
