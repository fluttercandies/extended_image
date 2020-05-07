import 'package:flutter/rendering.dart';

class ExtendedImageBorderPainter extends CustomPainter {
  ExtendedImageBorderPainter({this.border, this.shape, this.borderRadius});

  /// The shape to fill the background [color], [gradient], and [image] into and
  /// to cast as the [boxShadow].
  ///
  /// If this is [BoxShape.circle] then [borderRadius] is ignored.
  ///
  /// The [shape] cannot be interpolated; animating between two [BoxDecoration]s
  /// with different [shape]s will result in a discontinuity in the rendering.
  /// To interpolate between two shapes, consider using [ShapeDecoration] and
  /// different [ShapeBorder]s; in particular, [CircleBorder] instead of
  /// [BoxShape.circle] and [RoundedRectangleBorder] instead of
  /// [BoxShape.rectangle].
  final BoxShape shape;

  /// A border to draw above the background [color], [gradient], or [image].
  ///
  /// Follows the [shape] and [borderRadius].
  ///
  /// Use [Border] objects to describe borders that do not depend on the reading
  /// direction.
  ///
  /// Use [BoxBorder] objects to describe borders that should flip their left
  /// and right edges based on whether the text is being read left-to-right or
  /// right-to-left.
  final BoxBorder border;

  /// If non-null, the corners of this box are rounded by this [BorderRadius].
  ///
  /// Applies only to boxes with rectangular shapes; ignored if [shape] is not
  /// [BoxShape.rectangle].
  final BorderRadius borderRadius;
  @override
  void paint(Canvas canvas, Size size) {
    final Rect outputRect = Rect.fromLTWH(0.0, 0.0, size.width, size.height);

//    Path clipPath;
//    switch (shape) {
//      case BoxShape.circle:
//        clipPath = Path()..addOval(outputRect);
//        break;
//      case BoxShape.rectangle:
//        if (borderRadius != null)
//          clipPath = Path()
//            ..addRRect(
//                borderRadius.resolve(TextDirection.ltr).toRRect(outputRect));
//        break;
//    }
//    if (clipPath != null) {
//      canvas.save();
//      canvas.clipPath(clipPath);
//    }
//
//    if (clipPath != null) canvas.restore();

    switch (shape) {
      case BoxShape.circle:
        border.paint(canvas, outputRect, shape: shape);
        break;
      case BoxShape.rectangle:
        border.paint(canvas, outputRect,
            shape: shape, borderRadius: borderRadius);
        break;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    final ExtendedImageBorderPainter old = oldDelegate as ExtendedImageBorderPainter;

    return borderRadius != old.borderRadius ||
        border != old.border ||
        shape != old.shape;
  }
}
