import 'dart:io' show File;
import 'dart:typed_data';
import 'dart:ui';

import 'package:extended_image/src/extended_image_border_painter.dart';
import 'package:extended_image/src/gesture/extended_image_gesture.dart';
import 'package:extended_image/src/extended_image_typedef.dart';
import 'package:extended_image/src/extended_image_utils.dart';
import 'package:extended_image/src/image/extended_raw_image.dart';
import 'package:extended_image_library/extended_image_library.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/semantics.dart';
import 'editor/extended_image_editor.dart';
import 'gesture/extended_image_slide_page.dart';
import 'gesture/extended_image_slide_page_handler.dart';

/// extended image base on official
class ExtendedImage extends StatefulWidget {
  ExtendedImage({
    Key key,
    @required this.image,
    this.semanticLabel,
    this.excludeFromSemantics = false,
    this.width,
    this.height,
    this.color,
    this.colorBlendMode,
    this.fit,
    this.alignment = Alignment.center,
    this.repeat = ImageRepeat.noRepeat,
    this.centerSlice,
    this.matchTextDirection = false,
    this.gaplessPlayback = false,
    this.filterQuality = FilterQuality.low,
    this.loadStateChanged,
    this.border,
    this.shape,
    this.borderRadius,
    this.clipBehavior = Clip.antiAlias,
    this.enableLoadState = false,
    this.beforePaintImage,
    this.afterPaintImage,
    this.mode = ExtendedImageMode.none,
    this.enableMemoryCache = true,
    this.clearMemoryCacheIfFailed = true,
    this.onDoubleTap,
    this.initGestureConfigHandler,
    this.enableSlideOutPage = false,
    BoxConstraints constraints,
    this.extendedImageEditorKey,
    this.initEditorConfigHandler,
    this.heroBuilderForSlidingPage,
    this.clearMemoryCacheWhenDispose = false,
    this.extendedImageGestureKey,
    this.isAntiAlias = false,
  })  : assert(image != null),
        assert(constraints == null || constraints.debugAssertIsValid()),
        constraints = (width != null || height != null)
            ? constraints?.tighten(width: width, height: height) ??
                BoxConstraints.tightFor(width: width, height: height)
            : constraints,
        handleLoadingProgress = false,
        super(key: key);

  ExtendedImage.network(
    String url, {
    Key key,
    this.semanticLabel,
    this.excludeFromSemantics = false,
    this.width,
    this.height,
    this.color,
    this.colorBlendMode,
    this.fit,
    this.alignment = Alignment.center,
    this.repeat = ImageRepeat.noRepeat,
    this.centerSlice,
    this.matchTextDirection = false,
    this.gaplessPlayback = false,
    this.filterQuality = FilterQuality.low,
    this.loadStateChanged,
    this.shape,
    this.border,
    this.borderRadius,
    this.clipBehavior = Clip.antiAlias,
    this.enableLoadState = true,
    this.beforePaintImage,
    this.afterPaintImage,
    this.mode = ExtendedImageMode.none,
    this.enableMemoryCache = true,
    this.clearMemoryCacheIfFailed = true,
    this.onDoubleTap,
    this.initGestureConfigHandler,
    this.enableSlideOutPage = false,
    BoxConstraints constraints,
    CancellationToken cancelToken,
    int retries = 3,
    Duration timeLimit,
    Map<String, String> headers,
    bool cache = true,
    double scale = 1.0,
    Duration timeRetry = const Duration(milliseconds: 100),
    this.extendedImageEditorKey,
    this.initEditorConfigHandler,
    this.heroBuilderForSlidingPage,
    this.clearMemoryCacheWhenDispose = false,
    this.handleLoadingProgress = false,
    this.extendedImageGestureKey,
    int cacheWidth,
    int cacheHeight,
    this.isAntiAlias = false,
  })  : assert(cacheWidth == null || cacheWidth > 0),
        assert(cacheHeight == null || cacheHeight > 0),
        assert(isAntiAlias != null),
        image = ResizeImage.resizeIfNeeded(
          cacheWidth,
          cacheHeight,
          ExtendedNetworkImageProvider(
            url,
            scale: scale,
            headers: headers,
            cache: cache,
            cancelToken: cancelToken,
            retries: retries,
            timeRetry: timeRetry,
            timeLimit: timeLimit,
          ),
        ),
        assert(constraints == null || constraints.debugAssertIsValid()),
        constraints = (width != null || height != null)
            ? constraints?.tighten(width: width, height: height) ??
                BoxConstraints.tightFor(width: width, height: height)
            : constraints,
        assert(cacheWidth == null || cacheWidth > 0),
        assert(cacheHeight == null || cacheHeight > 0),
        super(key: key);

  /// Creates a widget that displays an [ImageStream] obtained from a [File].
  ///
  /// The [file], [scale], and [repeat] arguments must not be null.
  ///
  /// Either the [width] and [height] arguments should be specified, or the
  /// widget should be placed in a context that sets tight layout constraints.
  /// Otherwise, the image dimensions will change as the image is loaded, which
  /// will result in ugly layout changes.
  ///
  /// On Android, this may require the
  /// `android.permission.READ_EXTERNAL_STORAGE` permission.
  ///
  /// Use [filterQuality] to change the quality when scaling an image.
  /// Use the [FilterQuality.low] quality setting to scale the image,
  /// which corresponds to bilinear interpolation, rather than the default
  /// [FilterQuality.none] which corresponds to nearest-neighbor.
  ///
  /// If [excludeFromSemantics] is true, then [semanticLabel] will be ignored.
  ExtendedImage.file(
    File file, {
    Key key,
    double scale = 1.0,
    this.semanticLabel,
    this.excludeFromSemantics = false,
    this.width,
    this.height,
    this.color,
    this.colorBlendMode,
    this.fit,
    this.alignment = Alignment.center,
    this.repeat = ImageRepeat.noRepeat,
    this.centerSlice,
    this.matchTextDirection = false,
    this.gaplessPlayback = false,
    this.filterQuality = FilterQuality.low,
    this.loadStateChanged,
    this.shape,
    this.border,
    this.borderRadius,
    this.clipBehavior = Clip.antiAlias,
    this.enableLoadState = false,
    this.beforePaintImage,
    this.afterPaintImage,
    this.mode = ExtendedImageMode.none,
    this.enableMemoryCache = true,
    this.clearMemoryCacheIfFailed = true,
    this.onDoubleTap,
    this.initGestureConfigHandler,
    this.enableSlideOutPage = false,
    BoxConstraints constraints,
    this.extendedImageEditorKey,
    this.initEditorConfigHandler,
    this.heroBuilderForSlidingPage,
    this.clearMemoryCacheWhenDispose = false,
    this.extendedImageGestureKey,
    int cacheWidth,
    int cacheHeight,
    this.isAntiAlias = false,
  })  : assert(cacheWidth == null || cacheWidth > 0),
        assert(cacheHeight == null || cacheHeight > 0),
        assert(isAntiAlias != null),
        image = ResizeImage.resizeIfNeeded(
          cacheWidth,
          cacheHeight,
          ExtendedFileImageProvider(
            file,
            scale: scale,
          ),
        ),
        assert(alignment != null),
        assert(repeat != null),
        assert(filterQuality != null),
        assert(matchTextDirection != null),
        constraints = (width != null || height != null)
            ? constraints?.tighten(width: width, height: height) ??
                BoxConstraints.tightFor(width: width, height: height)
            : constraints,
        handleLoadingProgress = false,
        super(key: key);

  /// Creates a widget that displays an [ImageStream] obtained from an asset
  /// bundle. The key for the image is given by the `name` argument.
  ///
  /// The `package` argument must be non-null when displaying an image from a
  /// package and null otherwise. See the `Assets in packages` section for
  /// details.
  ///
  /// If the `bundle` argument is omitted or null, then the
  /// [DefaultAssetBundle] will be used.
  ///
  /// By default, the pixel-density-aware asset resolution will be attempted. In
  /// addition:
  ///
  /// * If the `scale` argument is provided and is not null, then the exact
  /// asset specified will be used. To display an image variant with a specific
  /// density, the exact path must be provided (e.g. `images/2x/cat.png`).
  ///
  /// If [excludeFromSemantics] is true, then [semanticLabel] will be ignored.
  //
  //
  // ///
  // /// * If [width] and [height] are both specified, and [scale] is not, then
  // ///   size-aware asset resolution will be attempted also, with the given
  // ///   dimensions interpreted as logical pixels.
  // ///
  // /// * If the images have platform, locale, or directionality variants, the
  // ///   current platform, locale, and directionality are taken into account
  // ///   during asset resolution as well.
  ///
  /// The [name] and [repeat] arguments must not be null.
  ///
  /// Either the [width] and [height] arguments should be specified, or the
  /// widget should be placed in a context that sets tight layout constraints.
  /// Otherwise, the image dimensions will change as the image is loaded, which
  /// will result in ugly layout changes.
  ///
  /// Use [filterQuality] to change the quality when scaling an image.
  /// Use the [FilterQuality.low] quality setting to scale the image,
  /// which corresponds to bilinear interpolation, rather than the default
  /// [FilterQuality.none] which corresponds to nearest-neighbor.
  ///
  /// {@tool sample}
  ///
  /// Suppose that the project's `pubspec.yaml` file contains the following:
  ///
  /// ```yaml
  /// flutter:
  ///   assets:
  ///     - images/cat.png
  ///     - images/2x/cat.png
  ///     - images/3.5x/cat.png
  /// ```
  /// {@end-tool}
  ///
  /// On a screen with a device pixel ratio of 2.0, the following widget would
  /// render the `images/2x/cat.png` file:
  ///
  /// ```dart
  /// Image.asset('images/cat.png')
  /// ```
  ///
  /// This corresponds to the file that is in the project's `images/2x/`
  /// directory with the name `cat.png` (the paths are relative to the
  /// `pubspec.yaml` file).
  ///
  /// On a device with a 4.0 device pixel ratio, the `images/3.5x/cat.png` asset
  /// would be used. On a device with a 1.0 device pixel ratio, the
  /// `images/cat.png` resource would be used.
  ///
  /// The `images/cat.png` image can be omitted from disk (though it must still
  /// be present in the manifest). If it is omitted, then on a device with a 1.0
  /// device pixel ratio, the `images/2x/cat.png` image would be used instead.
  ///
  ///
  /// ## Assets in packages
  ///
  /// To create the widget with an asset from a package, the [package] argument
  /// must be provided. For instance, suppose a package called `my_icons` has
  /// `icons/heart.png` .
  ///
  /// {@tool sample}
  /// Then to display the image, use:
  ///
  /// ```dart
  /// Image.asset('icons/heart.png', package: 'my_icons')
  /// ```
  /// {@end-tool}
  ///
  /// Assets used by the package itself should also be displayed using the
  /// [package] argument as above.
  ///
  /// If the desired asset is specified in the `pubspec.yaml` of the package, it
  /// is bundled automatically with the app. In particular, assets used by the
  /// package itself must be specified in its `pubspec.yaml`.
  ///
  /// A package can also choose to have assets in its 'lib/' folder that are not
  /// specified in its `pubspec.yaml`. In this case for those images to be
  /// bundled, the app has to specify which ones to include. For instance a
  /// package named `fancy_backgrounds` could have:
  ///
  /// ```
  /// lib/backgrounds/background1.png
  /// lib/backgrounds/background2.png
  /// lib/backgrounds/background3.png
  /// ```
  ///
  /// To include, say the first image, the `pubspec.yaml` of the app should
  /// specify it in the assets section:
  ///
  /// ```yaml
  ///  assets:
  ///    - packages/fancy_backgrounds/backgrounds/background1.png
  /// ```
  ///
  /// The `lib/` is implied, so it should not be included in the asset path.
  ///
  ///
  /// See also:
  ///
  ///  * [AssetImage], which is used to implement the behavior when the scale is
  ///    omitted.
  ///  * [ExactAssetImage], which is used to implement the behavior when the
  ///    scale is present.
  ///  * <https://flutter.io/assets-and-images/>, an introduction to assets in
  ///    Flutter.
  ExtendedImage.asset(
    String name, {
    Key key,
    AssetBundle bundle,
    this.semanticLabel,
    this.excludeFromSemantics = false,
    double scale,
    this.width,
    this.height,
    this.color,
    this.colorBlendMode,
    this.fit,
    this.alignment = Alignment.center,
    this.repeat = ImageRepeat.noRepeat,
    this.centerSlice,
    this.matchTextDirection = false,
    this.gaplessPlayback = false,
    String package,
    this.filterQuality = FilterQuality.low,
    this.loadStateChanged,
    this.shape,
    this.border,
    this.borderRadius,
    this.clipBehavior = Clip.antiAlias,
    this.enableLoadState = false,
    this.beforePaintImage,
    this.afterPaintImage,
    this.mode = ExtendedImageMode.none,
    this.enableMemoryCache = true,
    this.clearMemoryCacheIfFailed = true,
    this.onDoubleTap,
    this.initGestureConfigHandler,
    this.enableSlideOutPage = false,
    BoxConstraints constraints,
    this.extendedImageEditorKey,
    this.initEditorConfigHandler,
    this.heroBuilderForSlidingPage,
    this.clearMemoryCacheWhenDispose = false,
    this.extendedImageGestureKey,
    int cacheWidth,
    int cacheHeight,
    this.isAntiAlias = false,
  })  : assert(cacheWidth == null || cacheWidth > 0),
        assert(cacheHeight == null || cacheHeight > 0),
        assert(isAntiAlias != null),
        image = ResizeImage.resizeIfNeeded(
            cacheWidth,
            cacheHeight,
            scale != null
                ? ExtendedExactAssetImageProvider(name,
                    bundle: bundle, scale: scale, package: package)
                : ExtendedAssetImageProvider(name,
                    bundle: bundle, package: package)),
        assert(alignment != null),
        assert(repeat != null),
        assert(matchTextDirection != null),
        constraints = (width != null || height != null)
            ? constraints?.tighten(width: width, height: height) ??
                BoxConstraints.tightFor(width: width, height: height)
            : constraints,
        handleLoadingProgress = false,
        super(key: key);

  /// Creates a widget that displays an [ImageStream] obtained from a [Uint8List].
  ///
  /// The [bytes], [scale], and [repeat] arguments must not be null.
  ///
  /// Either the [width] and [height] arguments should be specified, or the
  /// widget should be placed in a context that sets tight layout constraints.
  /// Otherwise, the image dimensions will change as the image is loaded, which
  /// will result in ugly layout changes.
  ///
  /// Use [filterQuality] to change the quality when scaling an image.
  /// Use the [FilterQuality.low] quality setting to scale the image,
  /// which corresponds to bilinear interpolation, rather than the default
  /// [FilterQuality.none] which corresponds to nearest-neighbor.
  ///
  /// If [excludeFromSemantics] is true, then [semanticLabel] will be ignored.
  ExtendedImage.memory(
    Uint8List bytes, {
    Key key,
    double scale = 1.0,
    this.semanticLabel,
    this.excludeFromSemantics = false,
    this.width,
    this.height,
    this.color,
    this.colorBlendMode,
    this.fit,
    this.alignment = Alignment.center,
    this.repeat = ImageRepeat.noRepeat,
    this.centerSlice,
    this.matchTextDirection = false,
    this.gaplessPlayback = false,
    this.filterQuality = FilterQuality.low,
    this.loadStateChanged,
    this.shape,
    this.border,
    this.borderRadius,
    this.clipBehavior = Clip.antiAlias,
    this.enableLoadState = false,
    this.beforePaintImage,
    this.afterPaintImage,
    this.mode = ExtendedImageMode.none,
    this.enableMemoryCache = true,
    this.clearMemoryCacheIfFailed = true,
    this.onDoubleTap,
    this.initGestureConfigHandler,
    this.enableSlideOutPage = false,
    BoxConstraints constraints,
    this.extendedImageEditorKey,
    this.initEditorConfigHandler,
    this.heroBuilderForSlidingPage,
    this.clearMemoryCacheWhenDispose = false,
    this.extendedImageGestureKey,
    int cacheWidth,
    int cacheHeight,
    this.isAntiAlias = false,
  })  : assert(cacheWidth == null || cacheWidth > 0),
        assert(cacheHeight == null || cacheHeight > 0),
        assert(isAntiAlias != null),
        image = ResizeImage.resizeIfNeeded(
          cacheWidth,
          cacheHeight,
          ExtendedMemoryImageProvider(
            bytes,
            scale: scale,
          ),
        ),
        assert(alignment != null),
        assert(repeat != null),
        assert(matchTextDirection != null),
        constraints = (width != null || height != null)
            ? constraints?.tighten(width: width, height: height) ??
                BoxConstraints.tightFor(width: width, height: height)
            : constraints,
        handleLoadingProgress = false,
        super(key: key);

  /// key of ExtendedImageGesture
  final Key extendedImageGestureKey;

  /// whether handle loading progress for network
  final bool handleLoadingProgress;

  ///when image is removed from the tree permanently, whether clear memory cache
  final bool clearMemoryCacheWhenDispose;

  ///build Hero only for sliding page
  final HeroBuilderForSlidingPage heroBuilderForSlidingPage;

  /// init EditConfig when image is ready.
  final InitEditorConfigHandler initEditorConfigHandler;

  /// key of ExtendedImageEditor
  final Key extendedImageEditorKey;

  /// whether enable slide out page
  /// you should make sure this is in [ExtendedImageSlidePage]
  final bool enableSlideOutPage;

  ///init GestureConfig when image is ready.
  final InitGestureConfigHandler initGestureConfigHandler;

  ///call back of double tap  under ExtendedImageMode.gesture
  final DoubleTap onDoubleTap;

  ///whether cache in PaintingBinding.instance.imageCache
  final bool enableMemoryCache;

  ///when failed to load image, whether clear memory cache
  ///if true, image will reload in next time.
  final bool clearMemoryCacheIfFailed;

  /// image mode (none,gesture)
  final ExtendedImageMode mode;

  ///you can paint anything if you want before paint image.
  ///it's to used in  [ExtendedRawImage]
  ///and [ExtendedRenderImage]
  final BeforePaintImage beforePaintImage;

  ///you can paint anything if you want after paint image.
  ///it's to used in  [ExtendedRawImage]
  ///and [ExtendedRenderImage]
  final AfterPaintImage afterPaintImage;

  ///whether has loading or failed state
  ///default is false
  ///but network image is true
  ///better to set it's true when your image is big and take some time to ready
  final bool enableLoadState;

  /// {@macro flutter.clipper.clipBehavior}
  final Clip clipBehavior;

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

  /// custom load state widget if you want
  final LoadStateChanged loadStateChanged;

  /// The image to display.
  final ImageProvider image;

  /// If non-null, require the image to have this width.
  ///
  /// If null, the image will pick a size that best preserves its intrinsic
  /// aspect ratio.
  ///
  /// It is strongly recommended that either both the [width] and the [height]
  /// be specified, or that the widget be placed in a context that sets tight
  /// layout constraints, so that the image does not change size as it loads.
  /// Consider using [fit] to adapt the image's rendering to fit the given width
  /// and height if the exact image dimensions are not known in advance.
  final double width;

  /// If non-null, require the image to have this height.
  ///
  /// If null, the image will pick a size that best preserves its intrinsic
  /// aspect ratio.
  ///
  /// It is strongly recommended that either both the [width] and the [height]
  /// be specified, or that the widget be placed in a context that sets tight
  /// layout constraints, so that the image does not change size as it loads.
  /// Consider using [fit] to adapt the image's rendering to fit the given width
  /// and height if the exact image dimensions are not known in advance.
  final double height;

  final BoxConstraints constraints;

  /// If non-null, this color is blended with each image pixel using [colorBlendMode].
  final Color color;

  /// Used to set the [FilterQuality] of the image.
  ///
  /// Use the [FilterQuality.low] quality setting to scale the image with
  /// bilinear interpolation, or the [FilterQuality.none] which corresponds
  /// to nearest-neighbor.
  final FilterQuality filterQuality;

  /// Used to combine [color] with this image.
  ///
  /// The default is [BlendMode.srcIn]. In terms of the blend mode, [color] is
  /// the source and this image is the destination.
  ///
  /// See also:
  ///
  ///  * [BlendMode], which includes an illustration of the effect of each blend mode.
  final BlendMode colorBlendMode;

  /// How to inscribe the image into the space allocated during layout.
  ///
  /// The default varies based on the other fields. See the discussion at
  /// [paintImage].
  final BoxFit fit;

  /// How to align the image within its bounds.
  ///
  /// The alignment aligns the given position in the image to the given position
  /// in the layout bounds. For example, an [Alignment] alignment of (-1.0,
  /// -1.0) aligns the image to the top-left corner of its layout bounds, while an
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
  final Alignment alignment;

  /// How to paint any portions of the layout bounds not covered by the image.
  final ImageRepeat repeat;

  /// The center slice for a nine-patch image.
  ///
  /// The region of the image inside the center slice will be stretched both
  /// horizontally and vertically to fit the image into its destination. The
  /// region of the image above and below the center slice will be stretched
  /// only horizontally and the region of the image to the left and right of
  /// the center slice will be stretched only vertically.
  final Rect centerSlice;

  /// Whether to paint the image in the direction of the [TextDirection].
  ///
  /// If this is true, then in [TextDirection.ltr] contexts, the image will be
  /// drawn with its origin in the top left (the 'normal' painting direction for
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

  /// Whether to continue showing the old image (true), or briefly show nothing
  /// (false), when the image provider changes.
  final bool gaplessPlayback;

  /// A Semantic description of the image.
  ///
  /// Used to provide a description of the image to TalkBack on Android, and
  /// VoiceOver on iOS.
  final String semanticLabel;

  /// Whether to exclude this image from semantics.
  ///
  /// Useful for images which do not contribute meaningful information to an
  /// application.
  final bool excludeFromSemantics;

  /// Whether to paint the image with anti-aliasing.
  ///
  /// Anti-aliasing alleviates the sawtooth artifact when the image is rotated.
  final bool isAntiAlias;
  @override
  _ExtendedImageState createState() => _ExtendedImageState();
}

class _ExtendedImageState extends State<ExtendedImage>
    with ExtendedImageState, WidgetsBindingObserver {
  LoadState _loadState;
  ImageStream _imageStream;
  ImageInfo _imageInfo;
  bool _isListeningToStream = false;
  bool _invertColors;
  ExtendedImageSlidePageState _slidePageState;
  ImageChunkEvent _loadingProgress;
  int _frameNumber;
  bool _wasSynchronouslyLoaded;
  DisposableBuildContext<State<ExtendedImage>> _scrollAwareContext;

  @override
  void initState() {
    returnLoadStateChangedWidget = false;
    _loadState = LoadState.loading;
    WidgetsBinding.instance.addObserver(this);
    _scrollAwareContext = DisposableBuildContext<State<ExtendedImage>>(this);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _updateInvertColors();
    _resolveImage();

    _slidePageState = null;
    if (widget.enableSlideOutPage) {
      _slidePageState =
          context.findAncestorStateOfType<ExtendedImageSlidePageState>();
    }

    if (TickerMode.of(context)) {
      _listenToStream();
    } else {
      _stopListeningToStream();
    }

    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(ExtendedImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.image != oldWidget.image) {
      //_cancelNetworkImageRequest(oldWidget.image);
      _resolveImage();
    }
    if (widget.enableSlideOutPage != oldWidget.enableSlideOutPage) {
      _slidePageState = null;
      if (widget.enableSlideOutPage) {
        _slidePageState =
            context.findAncestorStateOfType<ExtendedImageSlidePageState>();
      }
    }
  }

  @override
  void didChangeAccessibilityFeatures() {
    super.didChangeAccessibilityFeatures();
    setState(() {
      _updateInvertColors();
    });
  }

  @override
  void reassemble() {
    _resolveImage(); // in case the image cache was flushed
    super.reassemble();
  }

  void _updateInvertColors() {
    _invertColors = MediaQuery.maybeOf(context)?.invertColors ??
        SemanticsBinding.instance.accessibilityFeatures.invertColors;
  }

  void _resolveImage([bool rebuild = false]) {
    if (rebuild) {
      widget.image.evict();
    }

    final ScrollAwareImageProvider provider = ScrollAwareImageProvider<dynamic>(
      context: _scrollAwareContext,
      imageProvider: widget.image,
    );

    final ImageStream newStream = provider.resolve(
        createLocalImageConfiguration(context,
            size: widget.width != null && widget.height != null
                ? Size(widget.width, widget.height)
                : null));
    assert(newStream != null);

    if (_imageInfo != null && !rebuild && _imageStream?.key == newStream?.key) {
      setState(() {
        _loadState = LoadState.completed;
      });
    }

    _updateSourceStream(newStream, rebuild: rebuild);
  }

  void _loadFailed(dynamic exception, StackTrace stackTrace) {
    //print('$exception');

//    ImageProvider imageProvider = widget.image;
//    if (imageProvider is ExtendedNetworkImageProvider) {
//      pendingImages.remove(imageProvider);
//    }

    setState(() {
      _loadState = LoadState.failed;
    });
    // if (kDebugMode) {
    //   print(exception);
    // }
    if (!widget.enableMemoryCache || widget.clearMemoryCacheIfFailed) {
      widget.image.evict();
    }
  }

  void _handleImageChunk(ImageChunkEvent event) {
    setState(() {
      _loadingProgress = event;
    });
  }

  void _handleImageChanged(ImageInfo imageInfo, bool synchronousCall) {
//    ImageProvider imageProvider = widget.image;
//    if (imageProvider is ExtendedNetworkImageProvider) {
//      pendingImages.remove(imageProvider);
//    }

    setState(() {
      if (imageInfo != null) {
        _loadState = LoadState.completed;
      } else {
        _loadState = LoadState.failed;
      }
      //_loadState = LoadState.completed;
      _imageInfo = imageInfo;
      _loadingProgress = null;
      _frameNumber = _frameNumber == null ? 0 : _frameNumber + 1;
      _wasSynchronouslyLoaded |= synchronousCall;
    });

    if (!widget.enableMemoryCache) {
      widget.image.evict();
    }
  }

  // Update _imageStream to newStream, and moves the stream listener
  // registration from the old stream to the new stream (if a listener was
  // registered).
  void _updateSourceStream(ImageStream newStream, {bool rebuild = false}) {
    if (_imageStream?.key == newStream?.key) {
      return;
    }
    //print('_updateSourceStream');
    if (_isListeningToStream) {
      _imageStream.removeListener(ImageStreamListener(
        _handleImageChanged,
        onError: _loadFailed,
        onChunk: widget.handleLoadingProgress ? _handleImageChunk : null,
      ));
    }

    if (!widget.gaplessPlayback || rebuild) {
      setState(() {
        _imageInfo = null;
        _loadState = LoadState.loading;
      });
    }

    setState(() {
      _loadingProgress = null;
      _frameNumber = null;
      _wasSynchronouslyLoaded = false;
    });

    _imageStream = newStream;
    if (_isListeningToStream) {
      _imageStream.addListener(ImageStreamListener(
        _handleImageChanged,
        onError: _loadFailed,
        onChunk: widget.handleLoadingProgress ? _handleImageChunk : null,
      ));
    }
  }

  void _listenToStream() {
    if (_isListeningToStream) {
      return;
    }
    _imageStream.addListener(ImageStreamListener(
      _handleImageChanged,
      onError: _loadFailed,
      onChunk: widget.handleLoadingProgress ? _handleImageChunk : null,
    ));
    _isListeningToStream = true;
  }

  void _stopListeningToStream() {
    if (!_isListeningToStream) {
      return;
    }
    _imageStream.removeListener(ImageStreamListener(
      _handleImageChanged,
      onError: _loadFailed,
      onChunk: widget.handleLoadingProgress ? _handleImageChunk : null,
    ));
    _isListeningToStream = false;
  }

//  void _cancelNetworkImageRequest(ImageProvider provider) {
//    if (provider == null) return;
//
//    ///cancel network request
////    if (provider is ExtendedNetworkImageProvider && provider.autoCancel) {
////      cancelPendingNetworkImageByProvider(provider);
////    }
//  }

  @override
  void dispose() {
    assert(_imageStream != null);
    if (widget.clearMemoryCacheWhenDispose) {
      widget.image?.evict();
    }
    WidgetsBinding.instance.removeObserver(this);
    _stopListeningToStream();
    _scrollAwareContext.dispose();
    //_cancelNetworkImageRequest(widget.image);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget current;
    returnLoadStateChangedWidget = false;
    if (widget.loadStateChanged != null) {
      current = widget.loadStateChanged(this);
      if (current != null && returnLoadStateChangedWidget) {
        return current;
      }
    }

    if (current == null) {
      if (widget.enableLoadState) {
        switch (_loadState) {
          case LoadState.loading:
            current = Container(
              alignment: Alignment.center,
              child: _getIndicator(context),
            );
            break;
          case LoadState.completed:
            current = _getCompletedWidget();
            break;
          case LoadState.failed:
            current = Container(
              alignment: Alignment.center,
              child: GestureDetector(
                onTap: () {
                  reLoadImage();
                },
                child: const Text('Failed to load image'),
              ),
            );
            break;
        }
      } else {
        if (_loadState == LoadState.completed) {
          current = _getCompletedWidget();
        } else {
          current = _buildExtendedRawImage();
        }
      }
    }

    if (widget.shape != null) {
      switch (widget.shape) {
        case BoxShape.circle:
          current = ClipOval(
            child: current,
            clipBehavior: widget.clipBehavior,
          );
          break;
        case BoxShape.rectangle:
          if (widget.borderRadius != null) {
            current = ClipRRect(
              child: current,
              borderRadius: widget.borderRadius,
              clipBehavior: widget.clipBehavior,
            );
          }
          break;
      }
    }

    if (widget.border != null) {
      current = CustomPaint(
        foregroundPainter: ExtendedImageBorderPainter(
            borderRadius: widget.borderRadius,
            border: widget.border,
            shape: widget.shape),
        child: current,
        size: widget.width != null && widget.height != null
            ? Size(widget.width, widget.height)
            : Size.zero,
      );
    }

    if (widget.constraints != null) {
      current = ConstrainedBox(constraints: widget.constraints, child: current);
    }

    ///add for loading/failed/ unGesture image
    if (_slidePageState != null &&
        !(_loadState == LoadState.completed &&
            widget.mode == ExtendedImageMode.gesture)) {
      current = ExtendedImageSlidePageHandler(
        current,
        _slidePageState,
        widget.heroBuilderForSlidingPage,
      );
    }

    if (widget.excludeFromSemantics) {
      return current;
    }
    return Semantics(
      container: widget.semanticLabel != null,
      image: true,
      label: widget.semanticLabel ?? '',
      child: current,
    );
  }

  Widget _getCompletedWidget() {
    Widget current;
    if (widget.mode == ExtendedImageMode.gesture) {
      current = ExtendedImageGesture(
        this,
        key: widget.extendedImageGestureKey,
      );
    } else if (widget.mode == ExtendedImageMode.editor) {
      current = ExtendedImageEditor(
        extendedImageState: this,
        key: widget.extendedImageEditorKey,
      );
    } else {
      current = _buildExtendedRawImage();
    }
    return current;
  }

  Widget _getIndicator(BuildContext context) {
    return Theme.of(context).platform == TargetPlatform.iOS
        ? const CupertinoActivityIndicator(
            animating: true,
            radius: 16.0,
          )
        : CircularProgressIndicator(
            strokeWidth: 2.0,
            valueColor:
                AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
          );
  }

  Widget _buildExtendedRawImage() {
    return ExtendedRawImage(
      image: _imageInfo?.image,
      width: widget.width,
      height: widget.height,
      scale: _imageInfo?.scale ?? 1.0,
      color: widget.color,
      colorBlendMode: widget.colorBlendMode,
      fit: widget.fit,
      alignment: widget.alignment,
      repeat: widget.repeat,
      centerSlice: widget.centerSlice,
      matchTextDirection: widget.matchTextDirection,
      invertColors: _invertColors,
      isAntiAlias: widget.isAntiAlias,
      filterQuality: widget.filterQuality,
      beforePaintImage: widget.beforePaintImage,
      afterPaintImage: widget.afterPaintImage,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder description) {
    super.debugFillProperties(description);
    description.add(DiagnosticsProperty<ImageStream>('stream', _imageStream));
    description.add(DiagnosticsProperty<ImageInfo>('pixels', _imageInfo));
    description.add(DiagnosticsProperty<ImageChunkEvent>(
        'loadingProgress', _loadingProgress));
    description.add(DiagnosticsProperty<int>('frameNumber', _frameNumber));
    description.add(DiagnosticsProperty<bool>(
        'wasSynchronouslyLoaded', _wasSynchronouslyLoaded));
  }

  //reload image as you wish,(loaded failed)
  @override
  void reLoadImage() {
    _resolveImage(true);
  }

  @override
  ImageInfo get extendedImageInfo => _imageInfo;

  @override
  LoadState get extendedImageLoadState => _loadState;

  @override
  ImageProvider get imageProvider => widget.image;

  @override
  bool get invertColors => _invertColors;

  @override
  Object get imageStreamKey => _imageStream?.key;

  @override
  ExtendedImage get imageWidget => widget;

  @override
  Widget get completedWidget => _getCompletedWidget();

  @override
  ImageChunkEvent get loadingProgress => _loadingProgress;

  @override
  int get frameNumber => _frameNumber;

  @override
  bool get wasSynchronouslyLoaded => _wasSynchronouslyLoaded;

  @override
  ExtendedImageSlidePageState get slidePageState => _slidePageState;
}
