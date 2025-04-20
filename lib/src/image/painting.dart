import 'dart:ui' as ui show Image;
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

// /// Used by [paintImage] to report image sizes drawn at the end of the frame.
// Map<String, ImageSizeInfo> _pendingImageSizeInfo = <String, ImageSizeInfo>{};

// /// [ImageSizeInfo]s that were reported on the last frame.
// ///
// /// Used to prevent duplicative reports from frame to frame.
// Set<ImageSizeInfo> _lastFrameImageSizeInfo = <ImageSizeInfo>{};

// /// Flushes inter-frame tracking of image size information from [paintImage].
// ///
// /// Has no effect if asserts are disabled.
// @visibleForTesting
// void debugFlushLastFrameImageSizeInfo() {
//   assert(() {
//     _lastFrameImageSizeInfo = <ImageSizeInfo>{};
//     return true;
//   }());
// }

/// Paints an image into the given rectangle on the canvas.
///
/// The arguments have the following meanings:
///
///  * `canvas`: The canvas onto which the image will be painted.
///
///  * `rect`: The region of the canvas into which the image will be painted.
///    The image might not fill the entire rectangle (e.g., depending on the
///    `fit`). If `rect` is empty, nothing is painted.
///
///  * `image`: The image to paint onto the canvas.
///
///  * `scale`: The number of image pixels for each logical pixel.
///
///  * `opacity`: The opacity to paint the image onto the canvas with.
///
///  * `colorFilter`: If non-null, the color filter to apply when painting the
///    image.
///
///  * `fit`: How the image should be inscribed into `rect`. If null, the
///    default behavior depends on `centerSlice`. If `centerSlice` is also null,
///    the default behavior is [BoxFit.scaleDown]. If `centerSlice` is
///    non-null, the default behavior is [BoxFit.fill]. See [BoxFit] for
///    details.
///
///  * `alignment`: How the destination rectangle defined by applying `fit` is
///    aligned within `rect`. For example, if `fit` is [BoxFit.contain] and
///    `alignment` is [Alignment.bottomRight], the image will be as large
///    as possible within `rect` and placed with its bottom right corner at the
///    bottom right corner of `rect`. Defaults to [Alignment.center].
///
///  * `centerSlice`: The image is drawn in nine portions described by splitting
///    the image by drawing two horizontal lines and two vertical lines, where
///    `centerSlice` describes the rectangle formed by the four points where
///    these four lines intersect each other. (This forms a 3-by-3 grid
///    of regions, the center region being described by `centerSlice`.)
///    The four regions in the corners are drawn, without scaling, in the four
///    corners of the destination rectangle defined by applying `fit`. The
///    remaining five regions are drawn by stretching them to fit such that they
///    exactly cover the destination rectangle while maintaining their relative
///    positions.
///
///  * `repeat`: If the image does not fill `rect`, whether and how the image
///    should be repeated to fill `rect`. By default, the image is not repeated.
///    See [ImageRepeat] for details.
///
///  * `flipHorizontally`: Whether to flip the image horizontally. This is
///    occasionally used with images in right-to-left environments, for images
///    that were designed for left-to-right locales (or vice versa). Be careful,
///    when using this, to not flip images with integral shadows, text, or other
///    effects that will look incorrect when flipped.
///
///  * `invertColors`: Inverting the colors of an image applies a new color
///    filter to the paint. If there is another specified color filter, the
///    invert will be applied after it. This is primarily used for implementing
///    smart invert on iOS.
///
///  * `filterQuality`: Use this to change the quality when scaling an image.
///     Use the [FilterQuality.low] quality setting to scale the image, which corresponds to
///     bilinear interpolation, rather than the default [FilterQuality.none] which corresponds
///     to nearest-neighbor.
///
/// The `canvas`, `rect`, `image`, `scale`, `alignment`, `repeat`, `flipHorizontally` and `filterQuality`
/// arguments must not be null.
///
/// See also:
///
///  * [paintBorder], which paints a border around a rectangle on a canvas.
///  * [DecorationImage], which holds a configuration for calling this function.
///  * [BoxDecoration], which uses this function to paint a [DecorationImage].

void paintExtendedImage({
  required Canvas canvas,
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
  EdgeInsets layoutInsets = EdgeInsets.zero,
}) {
  assert(
    image.debugGetOpenHandleStackTraces()?.isNotEmpty ?? true,
    'Cannot paint an image that is disposed.\n'
    'The caller of paintImage is expected to wait to dispose the image until '
    'after painting has completed.',
  );
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

  Offset? sliceBorder;
  if (centerSlice != null) {
    sliceBorder = Offset(
      centerSlice.left + inputSize.width - centerSlice.right,
      centerSlice.top + inputSize.height - centerSlice.bottom,
    );
    outputSize = outputSize - sliceBorder as Size;
    inputSize = inputSize - sliceBorder as Size;
  }
  fit ??= centerSlice == null ? BoxFit.scaleDown : BoxFit.fill;
  assert(centerSlice == null || (fit != BoxFit.none && fit != BoxFit.cover));
  final FittedSizes fittedSizes = applyBoxFit(
    fit,
    inputSize / scale,
    outputSize,
  );
  final Size sourceSize = fittedSizes.source * scale;
  Size destinationSize = fittedSizes.destination;
  if (centerSlice != null) {
    outputSize += sliceBorder!;
    destinationSize += sliceBorder;
    // We don't have the ability to draw a subset of the image at the same time
    // as we apply a nine-patch stretch.
    assert(
      sourceSize == inputSize,
      'centerSlice was used with a BoxFit that does not guarantee that the image is fully visible.',
    );
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
  final double dx =
      halfWidthDelta +
      (flipHorizontally ? -alignment.x : alignment.x) * halfWidthDelta;
  final double dy = halfHeightDelta + alignment.y * halfHeightDelta;
  final Offset destinationPosition = topLeft.translate(dx, dy);
  Rect destinationRect = destinationPosition & destinationSize;

  bool needClip = false;

  if (gestureDetails != null) {
    destinationRect = gestureDetails.calculateFinalDestinationRect(
      rect,
      destinationRect,
    );

    // outside and need clip
    needClip = !rect.containsRect(destinationRect);

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
        alignment: alignment,
      );
    }

    editActionDetails.initRect(rect, destinationRect);

    destinationRect = editActionDetails.getFinalDestinationRect();

    // outside and need clip
    needClip = !rect.containsRect(editActionDetails.getImagePath().getBounds());

    hasEditAction = editActionDetails.hasEditAction;

    if (needClip || hasEditAction) {
      canvas.save();
      if (needClip) {
        canvas.clipRect(paintRect);
      }
    }

    if (hasEditAction) {
      canvas.transform(editActionDetails.getTransform().storage);
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
  if (repeat != ImageRepeat.noRepeat && centerSlice != null) {
    // Don't clip if an image shader is used.
    canvas.clipRect(paintRect);
  }
  if (flipHorizontally) {
    final double dx = -(rect.left + rect.width / 2.0);
    canvas.translate(-dx, 0.0);
    canvas.scale(-1.0, 1.0);
    canvas.translate(dx, 0.0);
  }

  if (centerSlice == null) {
    final Rect sourceRect =
        customSourceRect ??
        alignment.inscribe(sourceSize, Offset.zero & inputSize);
    if (repeat == ImageRepeat.noRepeat) {
      canvas.drawImageRect(image, sourceRect, destinationRect, paint);
    } else {
      for (final Rect tileRect in _generateImageTileRects(
        rect,
        destinationRect,
        repeat,
      )) {
        canvas.drawImageRect(image, sourceRect, tileRect, paint);
      }
    }
  } else {
    canvas.scale(1 / scale);
    if (repeat == ImageRepeat.noRepeat) {
      canvas.drawImageNine(
        image,
        _scaleRect(centerSlice, scale),
        _scaleRect(destinationRect, scale),
        paint,
      );
    } else {
      for (final Rect tileRect in _generateImageTileRects(
        rect,
        destinationRect,
        repeat,
      ))
        canvas.drawImageNine(
          image,
          _scaleRect(centerSlice, scale),
          _scaleRect(tileRect, scale),
          paint,
        );
    }
  }

  if (needSave) {
    canvas.restore();
  }

  if (needClip || hasEditAction) {
    canvas.restore();

    // final Path path = editActionDetails!.getImagePath();
    // canvas.drawPath(
    //   path,
    //   Paint()
    //     ..color = Colors.red
    //     ..style = PaintingStyle.stroke
    //     ..strokeWidth = 5,
    // );
  }

  if (afterPaintImage != null) {
    afterPaintImage(canvas, destinationRect, image, paint);
  }
}

List<Rect> _generateImageTileRects(
  Rect outputRect,
  Rect fundamentalRect,
  ImageRepeat repeat,
) {
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

  return <Rect>[
    for (int i = startX; i <= stopX; ++i)
      for (int j = startY; j <= stopY; ++j)
        fundamentalRect.shift(Offset(i * strideX, j * strideY)),
  ];
}

Rect _scaleRect(Rect rect, double scale) => Rect.fromLTRB(
  rect.left * scale,
  rect.top * scale,
  rect.right * scale,
  rect.bottom * scale,
);
