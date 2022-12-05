import 'dart:math';
import 'dart:ui' as ui show Image;
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

void paintExtendedImage(
    {required Canvas canvas,
    required Rect rect,
    required ui.Image image,
    String? debugImageLabel,
    double scale = 1.0,
    double opacity = 1.0,
    ColorFilter? colorFilter,
    BoxFit? fit,
    Alignment alignment = Alignment.center,
    Rect? centerSlice,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    bool flipHorizontally = false,
    bool invertColors = false,
    FilterQuality filterQuality = FilterQuality.low,
    Rect? customSourceRect,
    //you can paint anything if you want before paint image.
    BeforePaintImage? beforePaintImage,
    //you can paint anything if you want after paint image.
    AfterPaintImage? afterPaintImage,
    GestureDetails? gestureDetails,
    EditActionDetails? editActionDetails,
    bool isAntiAlias = false,
    EdgeInsets layoutInsets = EdgeInsets.zero}) {
  if (rect.isEmpty) {
    return;
  }

  final Rect paintRect = rect;
  rect = layoutInsets.deflateRect(rect);

  Size outputSize = rect.size;
  Size inputSize = Size(image.width.toDouble(), image.height.toDouble());

  final Offset topLeft = rect.topLeft;

  // if (editActionDetails != null && editActionDetails.isHalfPi) {
  //   outputSize = Size(outputSize.height, outputSize.width);
  //   var center = rect.center;
  //   topLeft = Rect.fromLTWH(center.dx - rect.height / 2.0,
  //           center.dy - rect.width / 2.0, rect.height, rect.width)
  //       .topLeft;
  // }

  late Offset sliceBorder;
  if (centerSlice != null) {
    sliceBorder = Offset(centerSlice.left + inputSize.width - centerSlice.right,
        centerSlice.top + inputSize.height - centerSlice.bottom);
    outputSize = outputSize - sliceBorder as Size;
    inputSize = inputSize - sliceBorder as Size;
  }
  fit ??= centerSlice == null ? BoxFit.scaleDown : BoxFit.fill;
  assert(centerSlice == null || (fit != BoxFit.none && fit != BoxFit.cover));
  final FittedSizes fittedSizes =
      applyBoxFit(fit, inputSize / scale, outputSize);
  final Size sourceSize = fittedSizes.source * scale;
  Size destinationSize = fittedSizes.destination;
  if (centerSlice != null) {
    outputSize += sliceBorder;
    destinationSize += sliceBorder;
    // We don't have the ability to draw a subset of the image at the same time
    // as we apply a nine-patch stretch.
    assert(sourceSize == inputSize,
        'centerSlice was used with a BoxFit that does not guarantee that the image is fully visible.');
  }
  if (repeat != ImageRepeat.noRepeat && destinationSize == outputSize) {
    // There's no need to repeat the image because we're exactly filling the
    // output rect with the image.
    repeat = ImageRepeat.noRepeat;
  }
  final Paint paint = Paint()..isAntiAlias = isAntiAlias;
  if (colorFilter != null) {
    paint.colorFilter = colorFilter;
  }
  paint.color = Color.fromRGBO(0, 0, 0, opacity);
  paint.filterQuality = filterQuality;
  paint.invertColors = invertColors;
  final double halfWidthDelta =
      (outputSize.width - destinationSize.width) / 2.0;
  final double halfHeightDelta =
      (outputSize.height - destinationSize.height) / 2.0;
  final double dx = halfWidthDelta +
      (flipHorizontally ? -alignment.x : alignment.x) * halfWidthDelta;
  final double dy = halfHeightDelta + alignment.y * halfHeightDelta;
  final Offset destinationPosition = topLeft.translate(dx, dy);
  Rect destinationRect = destinationPosition & destinationSize;

  bool needClip = false;

  if (gestureDetails != null) {
    destinationRect =
        gestureDetails.calculateFinalDestinationRect(rect, destinationRect);

    ///outside and need clip
    needClip = rect.beyond(destinationRect);

    if (gestureDetails.slidePageOffset != null) {
      destinationRect = destinationRect.shift(gestureDetails.slidePageOffset!);
      rect = rect.shift(gestureDetails.slidePageOffset!);
    }

    if (needClip) {
      canvas.save();
      canvas.clipRect(paintRect);
    }
  }
  bool hasEditAction = false;
  if (editActionDetails != null) {
    if (editActionDetails.cropRectPadding != null) {
      destinationRect = getDestinationRect(
          inputSize: inputSize,
          rect: editActionDetails.cropRectPadding!.deflateRect(rect),
          fit: fit,
          flipHorizontally: false,
          scale: scale,
          centerSlice: centerSlice,
          alignment: alignment);
    }

    editActionDetails.initRect(rect, destinationRect);

    destinationRect = editActionDetails.getFinalDestinationRect();

    ///outside and need clip
    needClip = rect.beyond(destinationRect);

    hasEditAction = editActionDetails.hasEditAction;

    if (needClip || hasEditAction) {
      canvas.save();
      if (needClip) {
        canvas.clipRect(paintRect);
      }
    }

    if (hasEditAction) {
      final Offset origin =
          editActionDetails.screenCropRect?.center ?? destinationRect.center;

      final Matrix4 result = Matrix4.identity();

      final EditActionDetails editAction = editActionDetails;

      result.translate(
        origin.dx,
        origin.dy,
      );

      if (editAction.hasRotateAngle) {
        result.multiply(Matrix4.rotationZ(editAction.rotateRadian));
      }

      if (editAction.flipY) {
        result.multiply(Matrix4.rotationY(pi));
      }

      if (editAction.flipX) {
        result.multiply(Matrix4.rotationX(pi));
      }

      result.translate(-origin.dx, -origin.dy);
      canvas.transform(result.storage);
      destinationRect = editAction.paintRect(destinationRect);
    }
  }

  if (beforePaintImage != null) {
    final bool handle = beforePaintImage(canvas, destinationRect, image, paint);
    if (handle) {
      return;
    }
  }

  final bool needSave = repeat != ImageRepeat.noRepeat || flipHorizontally;
  if (needSave) {
    canvas.save();
  }
  if (repeat != ImageRepeat.noRepeat) {
    canvas.clipRect(paintRect);
  }
  if (flipHorizontally) {
    final double dx = -(rect.left + rect.width / 2.0);
    canvas.translate(-dx, 0.0);
    canvas.scale(-1.0, 1.0);
    canvas.translate(dx, 0.0);
  }

  if (centerSlice == null) {
    final Rect sourceRect = customSourceRect ??
        alignment.inscribe(sourceSize, Offset.zero & inputSize);
    if (repeat == ImageRepeat.noRepeat) {
      canvas.drawImageRect(image, sourceRect, destinationRect, paint);
    } else {
      for (final Rect tileRect
          in _generateImageTileRects(rect, destinationRect, repeat))
        canvas.drawImageRect(image, sourceRect, tileRect, paint);
    }
  } else {
    canvas.scale(1 / scale);
    if (repeat == ImageRepeat.noRepeat) {
      canvas.drawImageNine(image, _scaleRect(centerSlice, scale),
          _scaleRect(destinationRect, scale), paint);
    } else {
      for (final Rect tileRect
          in _generateImageTileRects(rect, destinationRect, repeat))
        canvas.drawImageNine(image, _scaleRect(centerSlice, scale),
            _scaleRect(tileRect, scale), paint);
    }
  }

  if (needSave) {
    canvas.restore();
  }

  if (needClip || hasEditAction) {
    canvas.restore();
  }

  if (afterPaintImage != null) {
    afterPaintImage(canvas, destinationRect, image, paint);
  }
}

Iterable<Rect> _generateImageTileRects(
    Rect outputRect, Rect fundamentalRect, ImageRepeat repeat) sync* {
  int startX = 0;
  int startY = 0;
  int stopX = 0;
  int stopY = 0;
  final double strideX = fundamentalRect.width;
  final double strideY = fundamentalRect.height;

  if (repeat == ImageRepeat.repeat || repeat == ImageRepeat.repeatX) {
    startX = ((outputRect.left - fundamentalRect.left) / strideX).floor();
    stopX = ((outputRect.right - fundamentalRect.right) / strideX).ceil();
  }

  if (repeat == ImageRepeat.repeat || repeat == ImageRepeat.repeatY) {
    startY = ((outputRect.top - fundamentalRect.top) / strideY).floor();
    stopY = ((outputRect.bottom - fundamentalRect.bottom) / strideY).ceil();
  }

  for (int i = startX; i <= stopX; ++i) {
    for (int j = startY; j <= stopY; ++j) {
      yield fundamentalRect.shift(Offset(i * strideX, j * strideY));
    }
  }
}

Rect _scaleRect(Rect rect, double scale) => Rect.fromLTRB(rect.left * scale,
    rect.top * scale, rect.right * scale, rect.bottom * scale);
