import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

/// This class is responsible for painting the crop layer in the editor.
/// It includes methods to paint the mask, grid lines, and corner markers
/// around the crop area.
class EditorCropLayerPainter {
  const EditorCropLayerPainter();

  /// Paint the entire crop layer, including mask, lines, and corners
  /// The rect may be bigger than size, when we roate crop rect.
  /// Adjust the rect to ensure the mask covers the whole area after rotation
  void paint(
    Canvas canvas,
    Size size,
    ExtendedImageCropLayerPainter painter,
    Rect rect,
  ) {
    // Draw the mask layer
    paintMask(canvas, rect, painter);

    // Draw the grid lines
    paintLines(canvas, size, painter);

    // Draw the corners of the crop area
    paintCorners(canvas, size, painter);
  }

  /// Draw corners of the crop area
  void paintCorners(
    Canvas canvas,
    Size size,
    ExtendedImageCropLayerPainter painter,
  ) {
    final Rect cropRect = painter.cropRect;
    final Size cornerSize = painter.cornerSize;
    final double cornerWidth = cornerSize.width;
    final double cornerHeight = cornerSize.height;
    final Paint paint =
        Paint()
          ..color = painter.cornerColor
          ..style = PaintingStyle.fill;

    // Draw top-left corner
    canvas.drawPath(
      Path()
        ..moveTo(cropRect.left, cropRect.top)
        ..lineTo(cropRect.left + cornerWidth, cropRect.top)
        ..lineTo(cropRect.left + cornerWidth, cropRect.top + cornerHeight)
        ..lineTo(cropRect.left + cornerHeight, cropRect.top + cornerHeight)
        ..lineTo(cropRect.left + cornerHeight, cropRect.top + cornerWidth)
        ..lineTo(cropRect.left, cropRect.top + cornerWidth),
      paint,
    );

    // Draw bottom-left corner
    canvas.drawPath(
      Path()
        ..moveTo(cropRect.left, cropRect.bottom)
        ..lineTo(cropRect.left + cornerWidth, cropRect.bottom)
        ..lineTo(cropRect.left + cornerWidth, cropRect.bottom - cornerHeight)
        ..lineTo(cropRect.left + cornerHeight, cropRect.bottom - cornerHeight)
        ..lineTo(cropRect.left + cornerHeight, cropRect.bottom - cornerWidth)
        ..lineTo(cropRect.left, cropRect.bottom - cornerWidth),
      paint,
    );

    // Draw top-right corner
    canvas.drawPath(
      Path()
        ..moveTo(cropRect.right, cropRect.top)
        ..lineTo(cropRect.right - cornerWidth, cropRect.top)
        ..lineTo(cropRect.right - cornerWidth, cropRect.top + cornerHeight)
        ..lineTo(cropRect.right - cornerHeight, cropRect.top + cornerHeight)
        ..lineTo(cropRect.right - cornerHeight, cropRect.top + cornerWidth)
        ..lineTo(cropRect.right, cropRect.top + cornerWidth),
      paint,
    );

    // Draw bottom-right corner
    canvas.drawPath(
      Path()
        ..moveTo(cropRect.right, cropRect.bottom)
        ..lineTo(cropRect.right - cornerWidth, cropRect.bottom)
        ..lineTo(cropRect.right - cornerWidth, cropRect.bottom - cornerHeight)
        ..lineTo(cropRect.right - cornerHeight, cropRect.bottom - cornerHeight)
        ..lineTo(cropRect.right - cornerHeight, cropRect.bottom - cornerWidth)
        ..lineTo(cropRect.right, cropRect.bottom - cornerWidth),
      paint,
    );
  }

  /// Draw the mask over the crop area
  void paintMask(
    Canvas canvas,
    Rect rect,
    ExtendedImageCropLayerPainter painter,
  ) {
    final Rect cropRect = painter.cropRect;
    final Color maskColor = painter.maskColor;

    // Save the current layer for later restoration
    canvas.saveLayer(rect, Paint());

    // Clip the crop area and draw the mask outside the crop area
    canvas.clipRect(cropRect, clipOp: ClipOp.difference);
    canvas.drawRect(
      rect,
      Paint()
        ..style = PaintingStyle.fill
        ..color = maskColor,
    );

    // Restore the canvas layer
    canvas.restore();
  }

  /// Draw grid lines inside the crop area
  void paintLines(
    Canvas canvas,
    Size size,
    ExtendedImageCropLayerPainter painter,
  ) {
    final Color lineColor = painter.lineColor;
    final double lineHeight = painter.lineHeight;
    final Rect cropRect = painter.cropRect;
    final bool pointerDown = painter.pointerDown;
    final Paint linePainter =
        Paint()
          ..color = lineColor
          ..strokeWidth = lineHeight
          ..style = PaintingStyle.stroke;

    // Draw the crop rectangle's border
    canvas.drawRect(cropRect, linePainter);

    // If pointer is down, draw additional grid lines inside the crop area
    if (pointerDown) {
      // Vertical lines
      canvas.drawLine(
        Offset(
          (cropRect.right - cropRect.left) / 3.0 + cropRect.left,
          cropRect.top,
        ),
        Offset(
          (cropRect.right - cropRect.left) / 3.0 + cropRect.left,
          cropRect.bottom,
        ),
        linePainter,
      );

      canvas.drawLine(
        Offset(
          (cropRect.right - cropRect.left) / 3.0 * 2.0 + cropRect.left,
          cropRect.top,
        ),
        Offset(
          (cropRect.right - cropRect.left) / 3.0 * 2.0 + cropRect.left,
          cropRect.bottom,
        ),
        linePainter,
      );

      // Horizontal lines
      canvas.drawLine(
        Offset(
          cropRect.left,
          (cropRect.bottom - cropRect.top) / 3.0 + cropRect.top,
        ),
        Offset(
          cropRect.right,
          (cropRect.bottom - cropRect.top) / 3.0 + cropRect.top,
        ),
        linePainter,
      );

      canvas.drawLine(
        Offset(
          cropRect.left,
          (cropRect.bottom - cropRect.top) / 3.0 * 2.0 + cropRect.top,
        ),
        Offset(
          cropRect.right,
          (cropRect.bottom - cropRect.top) / 3.0 * 2.0 + cropRect.top,
        ),
        linePainter,
      );
    }
  }
}

/// This class extends [CustomPainter] and is responsible for managing
/// the state of the crop layer, including rotation, crop area dimensions,
/// and visual attributes like line color, corner size, and mask color.
class ExtendedImageCropLayerPainter extends CustomPainter {
  ExtendedImageCropLayerPainter({
    required this.cropRect,
    required this.cropLayerPainter,
    required this.lineColor,
    required this.cornerColor,
    required this.cornerSize,
    required this.lineHeight,
    required this.maskColor,
    required this.pointerDown,
    required this.rotateRadians,
  });

  /// The rectangle defining the crop area
  final Rect cropRect;

  /// The size of the corner markers
  final Size cornerSize;

  /// The color of the corner markers
  final Color cornerColor;

  /// The color of the crop lines
  final Color lineColor;

  /// The thickness of the crop lines
  final double lineHeight;

  /// The color of the mask outside the crop area
  final Color maskColor;

  /// Indicates whether the pointer is down (user interaction in progress)
  final bool pointerDown;

  /// Custom painter to handle crop layer painting
  final EditorCropLayerPainter cropLayerPainter;

  /// The rotation angle of the crop area (in radians)
  final double rotateRadians;

  @override
  void paint(Canvas canvas, Size size) {
    Rect rect = Offset.zero & size;

    // Apply rotation if necessary
    if (rotateRadians != 0) {
      canvas.save();

      // Calculate the rotation origin (center of the canvas)
      final Offset origin = rect.center;
      final Matrix4 result = Matrix4.identity();

      result.translate(origin.dx, origin.dy);

      result.multiply(Matrix4.rotationZ(rotateRadians));

      result.translate(-origin.dx, -origin.dy);

      // Apply the transformation matrix
      canvas.transform(result.storage);

      // Adjust rect size to ensure the mask covers the whole area after rotation
      final double diagonal = sqrt(
        rect.width * rect.width + rect.height * rect.height,
      );
      rect = Rect.fromCenter(
        center: rect.center,
        width: diagonal,
        height: diagonal,
      );
    }

    // Paint the crop layer
    cropLayerPainter.paint(canvas, size, this, rect);

    // Restore the canvas after rotation
    if (rotateRadians != 0) {
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    if (oldDelegate.runtimeType != runtimeType) {
      return true;
    }

    final ExtendedImageCropLayerPainter delegate =
        oldDelegate as ExtendedImageCropLayerPainter;

    // Repaint if any properties have changed
    return cropRect != delegate.cropRect ||
        cornerSize != delegate.cornerSize ||
        lineColor != delegate.lineColor ||
        lineHeight != delegate.lineHeight ||
        maskColor != delegate.maskColor ||
        cropLayerPainter != delegate.cropLayerPainter ||
        cornerColor != delegate.cornerColor ||
        pointerDown != delegate.pointerDown ||
        rotateRadians != delegate.rotateRadians;
  }
}
