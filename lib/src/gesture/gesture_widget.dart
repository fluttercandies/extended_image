import 'dart:typed_data';

import 'package:extended_image/src/extended_image.dart';
import 'package:extended_image/src/gesture/gesture.dart';
import 'package:extended_image/src/gesture/slide_page.dart';
import 'package:extended_image/src/typedef.dart';
import 'package:extended_image/src/utils.dart';
import 'package:flutter/material.dart' hide Image;

/// A widget that applies [ExtendedImageGesture] zoom, pan, page-view, and
/// slide-page behavior to an arbitrary child widget.
///
/// This is useful for vector images, SVG widgets, video, charts, or other
/// widget trees that should keep rendering as widgets instead of being decoded
/// into a [dart:ui.Image]. [childSize] is the logical size of [child] before it
/// is fitted into this widget's layout bounds.
class ExtendedImageGestureWidget extends StatefulWidget {
  ExtendedImageGestureWidget({
    Key? key,
    required this.child,
    required this.childSize,
    this.width,
    this.height,
    BoxConstraints? constraints,
    this.fit,
    this.alignment = Alignment.center,
    this.semanticLabel,
    this.excludeFromSemantics = false,
    this.onDoubleTap,
    this.initGestureConfigHandler,
    this.enableSlideOutPage = false,
    this.heroBuilderForSlidingPage,
    this.extendedImageGestureKey,
    this.canScaleImage,
    this.gestureCacheKey,
  }) : assert(childSize.width > 0.0),
       assert(childSize.height > 0.0),
       assert(constraints == null || constraints.debugAssertIsValid()),
       constraints = (width != null || height != null)
           ? constraints?.tighten(width: width, height: height) ??
                 BoxConstraints.tightFor(width: width, height: height)
           : constraints,
       super(key: key);

  /// The widget rendered through the gesture layout machinery.
  final Widget child;

  /// Logical size of [child] before [fit] and gesture transforms are applied.
  final Size childSize;

  /// If non-null, require the gesture viewport to have this width.
  final double? width;

  /// If non-null, require the gesture viewport to have this height.
  final double? height;

  /// Additional layout constraints for the gesture viewport.
  final BoxConstraints? constraints;

  /// How to inscribe [childSize] into the gesture viewport before zooming.
  final BoxFit? fit;

  /// How to align [child] inside the gesture viewport before zooming.
  final Alignment alignment;

  /// A semantic description of the custom child.
  final String? semanticLabel;

  /// Whether to exclude this widget from semantics.
  final bool excludeFromSemantics;

  /// Callback for double tap under gesture mode.
  final DoubleTap? onDoubleTap;

  /// Init [GestureConfig] for this custom child.
  final InitGestureConfigHandler? initGestureConfigHandler;

  /// Whether to enable slide out page.
  ///
  /// This should be true only when this widget is inside [ExtendedImageSlidePage].
  final bool enableSlideOutPage;

  /// Build Hero only for sliding page.
  final HeroBuilderForSlidingPage? heroBuilderForSlidingPage;

  /// Key of the internal [ExtendedImageGesture].
  final Key? extendedImageGestureKey;

  /// Whether the child should scale for the current gesture details.
  final CanScaleImage? canScaleImage;

  /// Cache key used when [GestureConfig.cacheGesture] is true.
  ///
  /// If omitted, this state's identity is used to avoid sharing gesture details
  /// between unrelated custom gesture widgets.
  final Object? gestureCacheKey;

  @override
  _ExtendedImageGestureWidgetState createState() =>
      _ExtendedImageGestureWidgetState();
}

class _ExtendedImageGestureWidgetState extends State<ExtendedImageGestureWidget>
    with ExtendedImageState {
  static final Uint8List _transparentImageBytes = Uint8List.fromList(<int>[
    0x89,
    0x50,
    0x4E,
    0x47,
    0x0D,
    0x0A,
    0x1A,
    0x0A,
    0x00,
    0x00,
    0x00,
    0x0D,
    0x49,
    0x48,
    0x44,
    0x52,
    0x00,
    0x00,
    0x00,
    0x01,
    0x00,
    0x00,
    0x00,
    0x01,
    0x08,
    0x06,
    0x00,
    0x00,
    0x00,
    0x1F,
    0x15,
    0xC4,
    0x89,
    0x00,
    0x00,
    0x00,
    0x0A,
    0x49,
    0x44,
    0x41,
    0x54,
    0x78,
    0x9C,
    0x63,
    0x00,
    0x01,
    0x00,
    0x00,
    0x05,
    0x00,
    0x01,
    0x0D,
    0x0A,
    0x2D,
    0xB4,
    0x00,
    0x00,
    0x00,
    0x00,
    0x49,
    0x45,
    0x4E,
    0x44,
    0xAE,
    0x42,
    0x60,
    0x82,
  ]);
  static final ImageProvider _transparentImageProvider = MemoryImage(
    _transparentImageBytes,
  );

  late ExtendedImage _imageWidget;
  ExtendedImageSlidePageState? _slidePageState;

  @override
  Widget get completedWidget => _buildGestureWidget();

  @override
  ImageInfo? get extendedImageInfo => null;

  @override
  LoadState get extendedImageLoadState => LoadState.completed;

  @override
  int? get frameNumber => 0;

  @override
  ImageProvider get imageProvider => _transparentImageProvider;

  @override
  Object? get imageStreamKey => widget.gestureCacheKey ?? this;

  @override
  ExtendedImage get imageWidget => _imageWidget;

  @override
  bool get invertColors => false;

  @override
  Object? get lastException => null;

  @override
  StackTrace? get lastStack => null;

  @override
  ImageChunkEvent? get loadingProgress => null;

  @override
  ExtendedImageSlidePageState? get slidePageState => _slidePageState;

  @override
  bool get wasSynchronouslyLoaded => true;

  @override
  Widget build(BuildContext context) {
    Widget current = _buildGestureWidget();

    if (widget.constraints != null) {
      current = ConstrainedBox(
        constraints: widget.constraints!,
        child: current,
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

  @override
  void didChangeDependencies() {
    _updateSlidePageState();
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant ExtendedImageGestureWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _imageWidget = _buildImageWidget();
    if (widget.enableSlideOutPage != oldWidget.enableSlideOutPage) {
      _updateSlidePageState();
    }
  }

  @override
  void initState() {
    super.initState();
    returnLoadStateChangedWidget = false;
    _imageWidget = _buildImageWidget();
  }

  @override
  void reLoadImage() {}

  Widget _buildGestureWidget() {
    return ExtendedImageGesture(
      this,
      key: widget.extendedImageGestureKey,
      canScaleImage: widget.canScaleImage,
      imageBuilder:
          (Widget image, {ExtendedImageGestureState? imageGestureState}) {
            return imageGestureState!.wrapGestureWidget(
              widget.child,
              imageWidth: widget.childSize.width,
              imageHeight: widget.childSize.height,
              imageFit: widget.fit,
              alignment: widget.alignment,
            );
          },
    );
  }

  ExtendedImage _buildImageWidget() {
    return ExtendedImage(
      image: _transparentImageProvider,
      semanticLabel: widget.semanticLabel,
      excludeFromSemantics: widget.excludeFromSemantics,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      alignment: widget.alignment,
      mode: ExtendedImageMode.gesture,
      onDoubleTap: widget.onDoubleTap,
      initGestureConfigHandler: widget.initGestureConfigHandler,
      enableSlideOutPage: widget.enableSlideOutPage,
      constraints: widget.constraints,
      heroBuilderForSlidingPage: widget.heroBuilderForSlidingPage,
      extendedImageGestureKey: widget.extendedImageGestureKey,
    );
  }

  void _updateSlidePageState() {
    _slidePageState = widget.enableSlideOutPage
        ? context.findAncestorStateOfType<ExtendedImageSlidePageState>()
        : null;
  }
}
