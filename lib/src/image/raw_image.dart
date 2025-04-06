import 'dart:ui' as ui show Image;

import 'package:extended_image/src/editor/edit_action_details.dart';
import 'package:extended_image/src/gesture/utils.dart';
import 'package:extended_image/src/image/render_image.dart';
import 'package:extended_image/src/typedef.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A widget that displays a [dart:ui.Image] directly.
///
/// The image is painted using [paintImage], which describes the meanings of the
/// various fields on this class in more detail.
///
/// This widget is rarely used directly. Instead, consider using [Image].
class ExtendedRawImage extends LeafRenderObjectWidget {
  /// Creates a widget that displays an image.
  ///
  /// The [scale], [alignment], [repeat], [matchTextDirection] and [filterQuality] arguments must
  /// not be null.
  const ExtendedRawImage({
    Key? key,
    this.image,
    this.width,
    this.height,
    this.scale = 1.0,
    this.color,
    this.opacity,
    this.colorBlendMode,
    this.fit,
    this.alignment = Alignment.center,
    this.repeat = ImageRepeat.noRepeat,
    this.centerSlice,
    this.matchTextDirection = false,
    this.invertColors = false,
    this.filterQuality = FilterQuality.low,
    this.sourceRect,
    this.beforePaintImage,
    this.afterPaintImage,
    this.gestureDetails,
    this.editActionDetails,
    this.isAntiAlias = false,
    this.debugImageLabel,
    this.layoutInsets = EdgeInsets.zero,
  }) : super(key: key);

  /// details about edit
  final EditActionDetails? editActionDetails;

  /// details about gesture
  final GestureDetails? gestureDetails;

  ///you can paint anything if you want before paint image.
  final BeforePaintImage? beforePaintImage;

  ///you can paint anything if you want after paint image.
  final AfterPaintImage? afterPaintImage;

  /// The image to display.
  final ui.Image? image;

  /// A string identifying the source of the image.
  final String? debugImageLabel;

  /// If non-null, require the image to have this width.
  ///
  /// If null, the image will pick a size that best preserves its intrinsic
  /// aspect ratio.
  final double? width;

  /// If non-null, require the image to have this height.
  ///
  /// If null, the image will pick a size that best preserves its intrinsic
  /// aspect ratio.
  final double? height;

  /// Specifies the image's scale.
  ///
  /// Used when determining the best display size for the image.
  final double scale;

  /// If non-null, this color is blended with each image pixel using [colorBlendMode].
  final Color? color;

  /// If non-null, the value from the [Animation] is multiplied with the opacity
  /// of each image pixel before painting onto the canvas.
  ///
  /// This is more efficient than using [FadeTransition] to change the opacity
  /// of an image.
  final Animation<double>? opacity;

  /// Used to set the filterQuality of the image.
  ///
  /// Defaults to [FilterQuality.low] to scale the image, which corresponds to
  /// bilinear interpolation.
  final FilterQuality filterQuality;

  /// Used to combine [color] with this image.
  ///
  /// The default is [BlendMode.srcIn]. In terms of the blend mode, [color] is
  /// the source and this image is the destination.
  ///
  /// See also:
  ///
  ///  * [BlendMode], which includes an illustration of the effect of each blend mode.
  final BlendMode? colorBlendMode;

  /// How to inscribe the image into the space allocated during layout.
  ///
  /// The default varies based on the other fields. See the discussion at
  /// [paintImage].
  final BoxFit? fit;

  /// How to align the image within its bounds.
  ///
  /// The alignment aligns the given position in the image to the given position
  /// in the layout bounds. For example, an [Alignment] alignment of (-1.0,
  /// -1.0) aligns the image to the top-left corner of its layout bounds, while a
  /// [Alignment] alignment of (1.0, 1.0) aligns the bottom right of the
  /// image with the bottom right corner of its layout bounds. Similarly, an
  /// alignment of (0.0, 1.0) aligns the bottom middle of the image with the
  /// middle of the bottom edge of its layout bounds.
  ///
  /// To display a subpart of an image, consider using a [CustomPainter] and
  /// [Canvas.drawImageRect].
  ///
  /// If the [alignment] is [TextDirection]-dependent (i.e. if it is a
  /// [AlignmentDirectional]), then an ambient [Directionality] widget
  /// must be in scope.
  ///
  /// Defaults to [Alignment.center].
  ///
  /// See also:
  ///
  ///  * [Alignment], a class with convenient constants typically used to
  ///    specify an [AlignmentGeometry].
  ///  * [AlignmentDirectional], like [Alignment] for specifying alignments
  ///    relative to text direction.
  final AlignmentGeometry alignment;

  /// How to paint any portions of the layout bounds not covered by the image.
  final ImageRepeat repeat;

  /// The center slice for a nine-patch image.
  ///
  /// The region of the image inside the center slice will be stretched both
  /// horizontally and vertically to fit the image into its destination. The
  /// region of the image above and below the center slice will be stretched
  /// only horizontally and the region of the image to the left and right of
  /// the center slice will be stretched only vertically.
  final Rect? centerSlice;

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
  /// If this is true, there must be an ambient [Directionality] widget in
  /// scope.
  final bool matchTextDirection;

  /// Whether the colors of the image are inverted when drawn.
  ///
  /// inverting the colors of an image applies a new color filter to the paint.
  /// If there is another specified color filter, the invert will be applied
  /// after it. This is primarily used for implementing smart invert on iOS.
  ///
  /// See also:
  ///
  ///  * [Paint.invertColors], for the dart:ui implementation.
  final bool invertColors;

  ///input Rect, you can use this to crop image.
  ///it work when centerSlice==null
  final Rect? sourceRect;

  /// Insets to apply before laying out the image.
  ///
  /// The image will still be painted in the full area.
  final EdgeInsets layoutInsets;

  /// Whether to paint the image with anti-aliasing.
  ///
  /// Anti-aliasing alleviates the sawtooth artifact when the image is rotated.
  final bool isAntiAlias;

  @override
  ExtendedRenderImage createRenderObject(BuildContext context) {
    assert(
      (!matchTextDirection && alignment is Alignment) ||
          debugCheckHasDirectionality(context),
    );
    assert(
      image?.debugGetOpenHandleStackTraces()?.isNotEmpty ?? true,
      'Creator of a RawImage disposed of the image when the RawImage still '
      'needed it.',
    );
    return ExtendedRenderImage(
      image: image?.clone(),
      debugImageLabel: debugImageLabel,
      width: width,
      height: height,
      scale: scale,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      textDirection:
          matchTextDirection || alignment is! Alignment
              ? Directionality.of(context)
              : null,
      invertColors: invertColors,
      isAntiAlias: isAntiAlias,
      filterQuality: filterQuality,
      sourceRect: sourceRect,
      beforePaintImage: beforePaintImage,
      afterPaintImage: afterPaintImage,
      gestureDetails: gestureDetails,
      editActionDetails: editActionDetails,
      layoutInsets: layoutInsets,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    ExtendedRenderImage renderObject,
  ) {
    assert(
      image?.debugGetOpenHandleStackTraces()?.isNotEmpty ?? true,
      'Creator of a RawImage disposed of the image when the RawImage still '
      'needed it.',
    );
    renderObject
      ..image = image?.clone()
      ..debugImageLabel = debugImageLabel
      ..width = width
      ..height = height
      ..scale = scale
      ..color = color
      ..opacity = opacity
      ..colorBlendMode = colorBlendMode
      ..fit = fit
      ..alignment = alignment
      ..repeat = repeat
      ..centerSlice = centerSlice
      ..matchTextDirection = matchTextDirection
      ..textDirection =
          matchTextDirection || alignment is! Alignment
              ? Directionality.of(context)
              : null
      ..invertColors = invertColors
      ..isAntiAlias = isAntiAlias
      ..filterQuality = filterQuality
      ..layoutInsets = layoutInsets
      ..afterPaintImage = afterPaintImage
      ..beforePaintImage = beforePaintImage
      ..sourceRect = sourceRect
      ..gestureDetails = gestureDetails
      ..editActionDetails = editActionDetails;
  }

  @override
  void didUnmountRenderObject(ExtendedRenderImage renderObject) {
    // Have the render object dispose its image handle.
    renderObject.image = null;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ui.Image>('image', image));
    properties.add(DoubleProperty('width', width, defaultValue: null));
    properties.add(DoubleProperty('height', height, defaultValue: null));
    properties.add(DoubleProperty('scale', scale, defaultValue: 1.0));
    properties.add(ColorProperty('color', color, defaultValue: null));
    properties.add(
      DiagnosticsProperty<Animation<double>?>(
        'opacity',
        opacity,
        defaultValue: null,
      ),
    );
    properties.add(
      EnumProperty<BlendMode>(
        'colorBlendMode',
        colorBlendMode,
        defaultValue: null,
      ),
    );
    properties.add(EnumProperty<BoxFit>('fit', fit, defaultValue: null));
    properties.add(
      DiagnosticsProperty<AlignmentGeometry>(
        'alignment',
        alignment,
        defaultValue: null,
      ),
    );
    properties.add(
      EnumProperty<ImageRepeat>(
        'repeat',
        repeat,
        defaultValue: ImageRepeat.noRepeat,
      ),
    );
    properties.add(
      DiagnosticsProperty<Rect>('centerSlice', centerSlice, defaultValue: null),
    );
    properties.add(
      FlagProperty(
        'matchTextDirection',
        value: matchTextDirection,
        ifTrue: 'match text direction',
      ),
    );
    properties.add(DiagnosticsProperty<bool>('invertColors', invertColors));
    properties.add(EnumProperty<FilterQuality>('filterQuality', filterQuality));
    properties.add(
      DiagnosticsProperty<EdgeInsets>('layoutInsets', layoutInsets),
    );
  }
}
