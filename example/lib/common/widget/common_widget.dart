import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

class FlatButtonWithIcon extends TextButton {
  FlatButtonWithIcon({
    Key? key,
    required VoidCallback onPressed,
    Clip clipBehavior = Clip.none,
    FocusNode? focusNode,
    Color? textColor,
    required Widget icon,
    required Widget label,
  }) : super(
          key: key,
          onPressed: onPressed,
          clipBehavior: clipBehavior,
          focusNode: focusNode,
          style: textColor != null
              ? ButtonStyle(
                  textStyle: WidgetStateProperty.all<TextStyle>(
                  TextStyle(color: textColor),
                ))
              : null,
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

class AspectRatioItem {
  AspectRatioItem({this.value, this.text});
  final String? text;
  final double? value;
}

class AspectRatioWidget extends StatelessWidget {
  const AspectRatioWidget(
      {this.aspectRatioS, this.aspectRatio, this.isSelected = false});
  final String? aspectRatioS;
  final double? aspectRatio;
  final bool isSelected;
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(60, 60),
      painter: AspectRatioPainter(
        aspectRatio: aspectRatio,
        aspectRatioS: aspectRatioS,
        isSelected: isSelected,
        selectedColor: Theme.of(context).primaryColor,
      ),
    );
  }
}

class AspectRatioPainter extends CustomPainter {
  AspectRatioPainter({
    this.aspectRatioS,
    this.aspectRatio,
    this.isSelected = false,
    required this.selectedColor,
  });
  final String? aspectRatioS;
  final double? aspectRatio;
  final bool isSelected;
  final Color selectedColor;
  @override
  void paint(Canvas canvas, Size size) {
    final Color color = isSelected ? selectedColor : Colors.grey;
    final Rect rect = Offset.zero & size;
    //https://github.com/flutter/flutter/issues/49328
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(10)), paint);

    paint.color = Colors.white;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2.0;
    final double aspectRatioResult =
        (aspectRatio != null && aspectRatio! > 0.0) ? aspectRatio! : 1.0;
    canvas.drawRect(
      getDestinationRect(
          rect: const EdgeInsets.only(left: 10, right: 10, bottom: 20, top: 5)
              .deflateRect(rect),
          inputSize: Size(
            aspectRatioResult * size.width / 2,
            size.width / 2,
          ),
          fit: BoxFit.contain),
      paint,
    );

    final TextPainter textPainter = TextPainter(
        text: TextSpan(
            text: aspectRatioS,
            style: TextStyle(
              color:
                  color.computeLuminance() < 0.5 ? Colors.white : Colors.black,
              fontSize: 12.0,
            )),
        textDirection: TextDirection.ltr,
        maxLines: 1);
    textPainter.layout(maxWidth: rect.width);

    textPainter.paint(
      canvas,
      rect.bottomCenter -
          Offset(
            textPainter.width / 2.0,
            textPainter.height * 1.1,
          ),
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return oldDelegate is AspectRatioPainter &&
        (oldDelegate.isSelected != isSelected ||
            oldDelegate.aspectRatioS != aspectRatioS ||
            oldDelegate.aspectRatio != aspectRatio ||
            oldDelegate.selectedColor != selectedColor);
  }
}

class CommonCircularProgressIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      color: Colors.grey.withValues(alpha: 0.8),
      child: CircularProgressIndicator(
        strokeWidth: 2.0,
        valueColor:
            AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
      ),
    );
  }
}
