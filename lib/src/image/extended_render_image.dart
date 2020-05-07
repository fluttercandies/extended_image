import 'dart:math';
import 'dart:ui' as ui show Image;
import 'package:extended_image/src/editor/extended_image_editor_utils.dart';
import 'package:extended_image/src/gesture/extended_image_gesture_utils.dart';
import 'package:extended_image/src/extended_image_typedef.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:meta/meta.dart';

class ExtendedRenderImage extends RenderBox {
  /// Creates a render box that displays an image.
  ///
  /// The [scale], [alignment], [repeat], [matchTextDirection] and [filterQuality] arguments
  /// must not be null. The [textDirection] argument must not be null if
  /// [alignment] will need resolving or if [matchTextDirection] is true.
  ExtendedRenderImage({
    ui.Image image,
    double width,
    double height,
    double scale = 1.0,
    Color color,
    BlendMode colorBlendMode,
    BoxFit fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect centerSlice,
    bool matchTextDirection = false,
    TextDirection textDirection,
    bool invertColors = false,
    FilterQuality filterQuality = FilterQuality.low,
    Rect sourceRect,
    AfterPaintImage afterPaintImage,
    BeforePaintImage beforePaintImage,
    GestureDetails gestureDetails,
    EditActionDetails editActionDetails,
  })  : assert(scale != null),
        assert(repeat != null),
        assert(alignment != null),
        assert(filterQuality != null),
        assert(matchTextDirection != null),
        _image = image,
        _width = width,
        _height = height,
        _scale = scale,
        _color = color,
        _colorBlendMode = colorBlendMode,
        _fit = fit,
        _alignment = alignment,
        _repeat = repeat,
        _centerSlice = centerSlice,
        _matchTextDirection = matchTextDirection,
        _invertColors = invertColors,
        _textDirection = textDirection,
        _filterQuality = filterQuality,
        _sourceRect = sourceRect,
        _beforePaintImage = beforePaintImage,
        _afterPaintImage = afterPaintImage,
        _gestureDetails = gestureDetails,
        _editActionDetails = editActionDetails {
    _updateColorFilter();
  }

  EditActionDetails _editActionDetails;
  EditActionDetails get editActionDetails => _editActionDetails;
  set editActionDetails(EditActionDetails value) {
    if (value == _editActionDetails) {
      return;
    }
    _editActionDetails = value;
    markNeedsPaint();
  }

  GestureDetails _gestureDetails;
  GestureDetails get gestureDetails => _gestureDetails;
  set gestureDetails(GestureDetails value) {
    if (value == _gestureDetails) {
      return;
    }
    _gestureDetails = value;
    markNeedsPaint();
  }

  ///you can paint anything if you want before paint image.
  BeforePaintImage _beforePaintImage;
  BeforePaintImage get beforePaintImage => _beforePaintImage;
  set beforePaintImage(BeforePaintImage value) {
    if (value == _beforePaintImage) {
      return;
    }
    _beforePaintImage = value;
    markNeedsPaint();
  }

  ///you can paint anything if you want after paint image.
  AfterPaintImage _afterPaintImage;
  AfterPaintImage get afterPaintImage => _afterPaintImage;
  set afterPaintImage(AfterPaintImage value) {
    if (value == _afterPaintImage) {
      return;
    }
    _afterPaintImage = value;
    markNeedsPaint();
  }

  ///input rect, you can use this to crop image.
  Rect _sourceRect;
  Rect get sourceRect => _sourceRect;
  set sourceRect(Rect value) {
    if (value == _sourceRect) {
      return;
    }
    _sourceRect = value;
    markNeedsPaint();
  }

  Alignment _resolvedAlignment;
  bool _flipHorizontally;

  void _resolve() {
    if (_resolvedAlignment != null) {
      return;
    }
    _resolvedAlignment = alignment.resolve(textDirection);
    _flipHorizontally =
        matchTextDirection && textDirection == TextDirection.rtl;
  }

  void _markNeedResolution() {
    _resolvedAlignment = null;
    _flipHorizontally = null;
    markNeedsPaint();
  }

  /// The image to display.
  ui.Image get image => _image;
  ui.Image _image;
  set image(ui.Image value) {
    if (value == _image) {
      return;
    }
    _image = value;
    markNeedsPaint();
    if (_width == null || _height == null) {
      markNeedsLayout();
    }
  }

  /// If non-null, requires the image to have this width.
  ///
  /// If null, the image will pick a size that best preserves its intrinsic
  /// aspect ratio.
  double get width => _width;
  double _width;
  set width(double value) {
    if (value == _width) {
      return;
    }
    _width = value;
    markNeedsLayout();
  }

  /// If non-null, require the image to have this height.
  ///
  /// If null, the image will pick a size that best preserves its intrinsic
  /// aspect ratio.
  double get height => _height;
  double _height;
  set height(double value) {
    if (value == _height) {
      return;
    }
    _height = value;
    markNeedsLayout();
  }

  /// Specifies the image's scale.
  ///
  /// Used when determining the best display size for the image.
  double get scale => _scale;
  double _scale;
  set scale(double value) {
    assert(value != null);
    if (value == _scale) {
      return;
    }
    _scale = value;
    markNeedsLayout();
  }

  ColorFilter _colorFilter;

  void _updateColorFilter() {
    if (_color == null) {
      _colorFilter = null;
    } else {
      _colorFilter =
          ColorFilter.mode(_color, _colorBlendMode ?? BlendMode.srcIn);
    }
  }

  /// If non-null, this color is blended with each image pixel using [colorBlendMode].
  Color get color => _color;
  Color _color;
  set color(Color value) {
    if (value == _color) {
      return;
    }
    _color = value;
    _updateColorFilter();
    markNeedsPaint();
  }

  /// Used to set the filterQuality of the image
  /// Use the [FilterQuality.low] quality setting to scale the image, which corresponds to
  /// bilinear interpolation, rather than the default [FilterQuality.none] which corresponds
  /// to nearest-neighbor.
  FilterQuality get filterQuality => _filterQuality;
  FilterQuality _filterQuality;
  set filterQuality(FilterQuality value) {
    assert(value != null);
    if (value == _filterQuality) {
      return;
    }
    _filterQuality = value;
    markNeedsPaint();
  }

  /// Used to combine [color] with this image.
  ///
  /// The default is [BlendMode.srcIn]. In terms of the blend mode, [color] is
  /// the source and this image is the destination.
  ///
  /// See also:
  ///
  ///  * [BlendMode], which includes an illustration of the effect of each blend mode.
  BlendMode get colorBlendMode => _colorBlendMode;
  BlendMode _colorBlendMode;
  set colorBlendMode(BlendMode value) {
    if (value == _colorBlendMode) {
      return;
    }
    _colorBlendMode = value;
    _updateColorFilter();
    markNeedsPaint();
  }

  /// How to inscribe the image into the space allocated during layout.
  ///
  /// The default varies based on the other fields. See the discussion at
  /// [paintImage].
  BoxFit get fit => _fit;
  BoxFit _fit;
  set fit(BoxFit value) {
    if (value == _fit) {
      return;
    }
    _fit = value;
    markNeedsPaint();
  }

  /// How to align the image within its bounds.
  ///
  /// If this is set to a text-direction-dependent value, [textDirection] must
  /// not be null.
  AlignmentGeometry get alignment => _alignment;
  AlignmentGeometry _alignment;
  set alignment(AlignmentGeometry value) {
    assert(value != null);
    if (value == _alignment) {
      return;
    }
    _alignment = value;
    _markNeedResolution();
  }

  /// How to repeat this image if it doesn't fill its layout bounds.
  ImageRepeat get repeat => _repeat;
  ImageRepeat _repeat;
  set repeat(ImageRepeat value) {
    assert(value != null);
    if (value == _repeat) {
      return;
    }
    _repeat = value;
    markNeedsPaint();
  }

  /// The center slice for a nine-patch image.
  ///
  /// The region of the image inside the center slice will be stretched both
  /// horizontally and vertically to fit the image into its destination. The
  /// region of the image above and below the center slice will be stretched
  /// only horizontally and the region of the image to the left and right of
  /// the center slice will be stretched only vertically.
  Rect get centerSlice => _centerSlice;
  Rect _centerSlice;
  set centerSlice(Rect value) {
    if (value == _centerSlice) {
      return;
    }
    _centerSlice = value;
    markNeedsPaint();
  }

  /// Whether to invert the colors of the image.
  ///
  /// inverting the colors of an image applies a new color filter to the paint.
  /// If there is another specified color filter, the invert will be applied
  /// after it. This is primarily used for implementing smart invert on iOS.
  bool get invertColors => _invertColors;
  bool _invertColors;
  set invertColors(bool value) {
    if (value == _invertColors) {
      return;
    }
    _invertColors = value;
    markNeedsPaint();
  }

  /// Whether to paint the image in the direction of the [TextDirection].
  ///
  /// If this is true, then in [TextDirection.ltr] contexts, the image will be
  /// drawn with its origin in the top left (the "normal" painting direction for
  /// images); and in [TextDirection.rtl] contexts, the image will be drawn with
  /// a scaling factor of -1 in the horizontal direction so that the origin is
  /// in the top right.
  ///
  /// This is occasionally used with images in right-to-left environments, for
  /// images that were designed for left-to-right locales. Be careful, when
  /// using this, to not flip images with integral shadows, text, or other
  /// effects that will look incorrect when flipped.
  ///
  /// If this is set to true, [textDirection] must not be null.
  bool get matchTextDirection => _matchTextDirection;
  bool _matchTextDirection;
  set matchTextDirection(bool value) {
    assert(value != null);
    if (value == _matchTextDirection) {
      return;
    }
    _matchTextDirection = value;
    _markNeedResolution();
  }

  /// The text direction with which to resolve [alignment].
  ///
  /// This may be changed to null, but only after the [alignment] and
  /// [matchTextDirection] properties have been changed to values that do not
  /// depend on the direction.
  TextDirection get textDirection => _textDirection;
  TextDirection _textDirection;
  set textDirection(TextDirection value) {
    if (_textDirection == value) {
      return;
    }
    _textDirection = value;
    _markNeedResolution();
  }

  /// Find a size for the render image within the given constraints.
  ///
  ///  - The dimensions of the RenderImage must fit within the constraints.
  ///  - The aspect ratio of the RenderImage matches the intrinsic aspect
  ///    ratio of the image.
  ///  - The RenderImage's dimension are maximal subject to being smaller than
  ///    the intrinsic size of the image.
  Size _sizeForConstraints(BoxConstraints constraints) {
    // Folds the given |width| and |height| into |constraints| so they can all
    // be treated uniformly.
    constraints = BoxConstraints.tightFor(width: _width, height: _height)
        .enforce(constraints);

    if (_image == null) {
      return constraints.smallest;
    }

    return constraints.constrainSizeAndAttemptToPreserveAspectRatio(Size(
        _image.width.toDouble() / _scale, _image.height.toDouble() / _scale));
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    assert(height >= 0.0);
    if (_width == null && _height == null) {
      return 0.0;
    }
    return _sizeForConstraints(BoxConstraints.tightForFinite(height: height))
        .width;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    assert(height >= 0.0);
    return _sizeForConstraints(BoxConstraints.tightForFinite(height: height))
        .width;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    assert(width >= 0.0);
    if (_width == null && _height == null) {
      return 0.0;
    }
    return _sizeForConstraints(BoxConstraints.tightForFinite(width: width))
        .height;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    assert(width >= 0.0);
    return _sizeForConstraints(BoxConstraints.tightForFinite(width: width))
        .height;
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void performLayout() {
    size = _sizeForConstraints(constraints);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_image == null) {
      return;
    }
    _resolve();
    assert(_resolvedAlignment != null);
    assert(_flipHorizontally != null);
    Rect rect = offset & size;
    if (gestureDetails != null && gestureDetails.slidePageOffset != null) {
      rect = rect.shift(-gestureDetails.slidePageOffset);
    }
    paintExtendedImage(
        canvas: context.canvas,
        rect: rect,
        image: _image,
        scale: _scale,
        colorFilter: _colorFilter,
        fit: _fit,
        alignment: _resolvedAlignment,
        centerSlice: _centerSlice,
        repeat: _repeat,
        flipHorizontally: _flipHorizontally,
        invertColors: invertColors,
        filterQuality: _filterQuality,
        customSourceRect: _sourceRect,
        beforePaintImage: beforePaintImage,
        afterPaintImage: afterPaintImage,
        gestureDetails: gestureDetails,
        editActionDetails: editActionDetails);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ui.Image>('image', image));
    properties.add(DoubleProperty('width', width, defaultValue: null));
    properties.add(DoubleProperty('height', height, defaultValue: null));
    properties.add(DoubleProperty('scale', scale, defaultValue: 1.0));
    properties
        .add(DiagnosticsProperty<Color>('color', color, defaultValue: null));
    properties.add(EnumProperty<BlendMode>('colorBlendMode', colorBlendMode,
        defaultValue: null));
    properties.add(EnumProperty<BoxFit>('fit', fit, defaultValue: null));
    properties.add(DiagnosticsProperty<AlignmentGeometry>(
        'alignment', alignment,
        defaultValue: null));
    properties.add(EnumProperty<ImageRepeat>('repeat', repeat,
        defaultValue: ImageRepeat.noRepeat));
    properties.add(DiagnosticsProperty<Rect>('centerSlice', centerSlice,
        defaultValue: null));
    properties.add(FlagProperty('matchTextDirection',
        value: matchTextDirection, ifTrue: 'match text direction'));
    properties.add(EnumProperty<TextDirection>('textDirection', textDirection,
        defaultValue: null));
    properties.add(DiagnosticsProperty<bool>('invertColors', invertColors));
    properties.add(EnumProperty<FilterQuality>('filterQuality', filterQuality));
  }
}

void paintExtendedImage({
  @required Canvas canvas,
  @required Rect rect,
  @required ui.Image image,
  double scale = 1.0,
  ColorFilter colorFilter,
  BoxFit fit,
  Alignment alignment = Alignment.center,
  Rect centerSlice,
  ImageRepeat repeat = ImageRepeat.noRepeat,
  bool flipHorizontally = false,
  bool invertColors = false,
  FilterQuality filterQuality = FilterQuality.low,
  Rect customSourceRect,
  //you can paint anything if you want before paint image.
  BeforePaintImage beforePaintImage,
  //you can paint anything if you want after paint image.
  AfterPaintImage afterPaintImage,
  GestureDetails gestureDetails,
  EditActionDetails editActionDetails,
}) {
  assert(canvas != null);
  assert(image != null);
  assert(alignment != null);
  assert(repeat != null);
  assert(flipHorizontally != null);
  if (rect.isEmpty) {
    return;
  }

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

  Offset sliceBorder;
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
  final Paint paint = Paint()..isAntiAlias = false;
  if (colorFilter != null) {
    paint.colorFilter = colorFilter;
  }
  if (sourceSize != destinationSize) {
    paint.filterQuality = filterQuality;
  }
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
    needClip = outRect(rect, destinationRect);

    if (gestureDetails.slidePageOffset != null) {
      destinationRect = destinationRect.shift(gestureDetails.slidePageOffset);
      rect = rect.shift(gestureDetails.slidePageOffset);
    }

    if (needClip) {
      canvas.save();
      canvas.clipRect(rect);
    }
  }
  bool hasEditAction = false;
  if (editActionDetails != null) {
    if (editActionDetails.cropRectPadding != null) {
      destinationRect = getDestinationRect(
          inputSize: inputSize,
          rect: editActionDetails.cropRectPadding.deflateRect(rect),
          fit: fit,
          flipHorizontally: false,
          scale: scale,
          centerSlice: centerSlice,
          alignment: alignment);
    }

    editActionDetails.initRect(rect, destinationRect);

    destinationRect = editActionDetails.getFinalDestinationRect();

    ///outside and need clip
    needClip = outRect(rect, destinationRect);

    hasEditAction = editActionDetails.hasEditAction;

    if (needClip || hasEditAction) {
      canvas.save();
      if (needClip) {
        canvas.clipRect(rect);
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
    canvas.clipRect(rect);
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
    for (final Rect tileRect
        in _generateImageTileRects(rect, destinationRect, repeat)) {
      canvas.drawImageRect(image, sourceRect, tileRect, paint);
    }
  } else {
    for (final Rect tileRect
        in _generateImageTileRects(rect, destinationRect, repeat)) {
      canvas.drawImageNine(image, centerSlice, tileRect, paint);
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
  if (repeat == ImageRepeat.noRepeat) {
    yield fundamentalRect;
    return;
  }

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
