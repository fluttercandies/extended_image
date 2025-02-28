import 'package:flutter/material.dart';

/// [CropAspectRatios] defines a set of commonly used aspect ratios
/// for cropping an image. These static constants represent different
/// ratios between width and height.
class CropAspectRatios {
  /// No aspect ratio for crop; free-form cropping is allowed.
  static const double? custom = null;

  /// The same as the original aspect ratio of the image.
  /// if it's equal or less than 0, it will be treated as original.
  static const double original = 0.0;

  /// Aspect ratio of 1:1 (square).
  static const double ratio1_1 = 1.0;

  /// Aspect ratio of 3:4 (portrait).
  static const double ratio3_4 = 3.0 / 4.0;

  /// Aspect ratio of 4:3 (landscape).
  static const double ratio4_3 = 4.0 / 3.0;

  /// Aspect ratio of 9:16 (portrait).
  static const double ratio9_16 = 9.0 / 16.0;

  /// Aspect ratio of 16:9 (landscape).
  static const double ratio16_9 = 16.0 / 9.0;
}

/// `getDestinationRect` calculates the destination rectangle where an image
/// or widget should be drawn based on the given input size, scale, alignment,
/// and fit behavior. This is useful when transforming or resizing images.
///
/// - `rect`: The outer boundary where the image is drawn.
/// - `inputSize`: The size of the input image or widget.
/// - `scale`: The scale factor applied to the image.
/// - `fit`: Defines how the image should be fit within the destination area.
/// - `alignment`: Controls how the image aligns within the destination.
/// - `centerSlice`: Specifies a region for nine-patch scaling.
/// - `flipHorizontally`: If true, flips the image horizontally.
Rect getDestinationRect({
  required Rect rect,
  required Size inputSize,
  double scale = 1.0,
  BoxFit? fit,
  Alignment alignment = Alignment.center,
  Rect? centerSlice,
  bool flipHorizontally = false,
}) {
  // Size of the output area (the destination).
  Size outputSize = rect.size;

  late Offset sliceBorder;

  // Adjust the input and output sizes if centerSlice is provided (for nine-patch scaling).
  if (centerSlice != null) {
    sliceBorder = Offset(
      centerSlice.left + inputSize.width - centerSlice.right,
      centerSlice.top + inputSize.height - centerSlice.bottom,
    );
    outputSize = outputSize - sliceBorder as Size;
    inputSize = inputSize - sliceBorder as Size;
  }

  // Set the BoxFit if not already provided, defaulting to `scaleDown`.
  fit ??= centerSlice == null ? BoxFit.scaleDown : BoxFit.fill;

  // Ensure centerSlice is used with a valid BoxFit.
  assert(centerSlice == null || (fit != BoxFit.none && fit != BoxFit.cover));

  // Calculate the fitted sizes based on the BoxFit.
  final FittedSizes fittedSizes = applyBoxFit(
    fit,
    inputSize / scale,
    outputSize,
  );

  // Get the source and destination sizes for drawing the image.
  final Size sourceSize = fittedSizes.source * scale;
  Size destinationSize = fittedSizes.destination;

  if (centerSlice != null) {
    outputSize += sliceBorder;
    destinationSize += sliceBorder;
    // Ensure sourceSize matches inputSize when using a centerSlice.
    assert(
      sourceSize == inputSize,
      'centerSlice was used with a BoxFit that does not guarantee that the image is fully visible.',
    );
  }

  // Calculate the positioning offsets based on alignment and potential flipping.
  final double halfWidthDelta =
      (outputSize.width - destinationSize.width) / 2.0;
  final double halfHeightDelta =
      (outputSize.height - destinationSize.height) / 2.0;
  final double dx =
      halfWidthDelta +
      (flipHorizontally ? -alignment.x : alignment.x) * halfWidthDelta;
  final double dy = halfHeightDelta + alignment.y * halfHeightDelta;

  // Compute the final position and size of the destination rectangle.
  final Offset destinationPosition = rect.topLeft.translate(dx, dy);
  final Rect destinationRect = destinationPosition & destinationSize;

  return destinationRect;
}

/// `defaultEditorMaskColorHandler` is a helper function that determines the color
/// of the editor mask overlay based on whether the pointer is down or not.
/// - When the pointer is down, the opacity is lower to highlight the focus.
/// - Otherwise, the opacity is higher, indicating an idle state.
Color defaultEditorMaskColorHandler(BuildContext context, bool pointerDown) {
  return Theme.of(
    context,
  ).scaffoldBackgroundColor.withValues(alpha: (pointerDown ? 0.4 : 0.8));
}

/// `InitCropRectType` specifies how the initial crop rectangle should be defined.
/// - `imageRect`: Crop rectangle is based on the image's original boundaries.
/// - `layoutRect`: Crop rectangle is based on the image's layout dimensions
///   within the user interface.
enum InitCropRectType {
  /// Crop rectangle is based on the image's original boundaries.
  imageRect,

  ///  Crop rectangle is based on the image's layout dimensions
  layoutRect,
}
