import 'dart:io';

import 'package:collection/collection.dart';
import 'package:extended_image/src/border_painter.dart';
import 'package:extended_image/src/extended_network_image_provider.dart';
import 'package:extended_image/src/extended_raw_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/semantics.dart';
import 'package:transparent_image/transparent_image.dart';

class ExtendedImage extends StatefulWidget {
  ExtendedImage(
      {Key key,
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
      this.borderRadius})
      : assert(image != null),
        super(key: key);

  ExtendedImage.network(String url,
      {Key key,
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
      Map<String, String> headers,
      bool cache: true,
      double scale = 1.0,
      this.loadStateChanged,
      this.shape,
      this.border,
      this.borderRadius})
      : image = ExtendedNetworkImageProvider(url,
            scale: scale, headers: headers, cache: cache),
        super(key: key);

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
  final BorderRadiusGeometry borderRadius;

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
  final Rect centerSlice;

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

  /// Whether to continue showing the old image (true), or briefly show nothing
  /// (false), when the image provider changes.
  final bool gaplessPlayback;

  /// A Semantic description of the image.
  ///
  /// Used to provide a description of the image to TalkBack on Andoid, and
  /// VoiceOver on iOS.
  final String semanticLabel;

  /// Whether to exclude this image from semantics.
  ///
  /// Useful for images which do not contribute meaningful information to an
  /// application.
  final bool excludeFromSemantics;

  @override
  ExtendedImageState createState() => ExtendedImageState();
}

class ExtendedImageState extends State<ExtendedImage> {
  LoadState _loadState;
  ImageStream _imageStream;
  ImageInfo _imageInfo;
  bool _isListeningToStream = false;
  bool _invertColors;

  @override
  void didChangeDependencies() {
    _invertColors = MediaQuery.of(context, nullOk: true)?.invertColors ??
        SemanticsBinding.instance.accessibilityFeatures.invertColors;
    _resolveImage();

    if (TickerMode.of(context))
      _listenToStream();
    else
      _stopListeningToStream();

    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(ExtendedImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.image != oldWidget.image) _resolveImage();
  }

  @override
  void reassemble() {
    _resolveImage(); // in case the image cache was flushed
    super.reassemble();
  }

  void _resolveImage([bool rebuild = true]) {
    final ImageStream newStream = widget.image.resolve(
        createLocalImageConfiguration(context,
            size: widget.width != null && widget.height != null
                ? Size(widget.width, widget.height)
                : null));
    assert(newStream != null);
    _updateSourceStream(newStream);
  }

  void _handleImageChanged(ImageInfo imageInfo, bool synchronousCall) {
    setState(() {
      if (imageInfo != null) {
        imageInfo.image.toByteData().then((data) {
          if (ListEquality()
              .equals(data.buffer.asUint8List(), kTransparentImage)) {
            _loadState = LoadState.failed;
          } else {
            _loadState = LoadState.completed;
          }
        });
      }
      _imageInfo = imageInfo;
    });
  }

  // Update _imageStream to newStream, and moves the stream listener
  // registration from the old stream to the new stream (if a listener was
  // registered).
  void _updateSourceStream(ImageStream newStream, {bool rebuild = true}) {
    if (_imageStream?.key == newStream?.key) return;

    if (_isListeningToStream) _imageStream.removeListener(_handleImageChanged);

    if (!widget.gaplessPlayback || rebuild) {
      setState(() {
        _imageInfo = null;
        _loadState = LoadState.loading;
      });
    }

    _imageStream = newStream;
    if (_isListeningToStream) _imageStream.addListener(_handleImageChanged);
  }

  resolveImage() {
    _resolveImage(true);
  }

  void _listenToStream() {
    if (_isListeningToStream) return;
    _imageStream.addListener(_handleImageChanged);
    _isListeningToStream = true;
  }

  void _stopListeningToStream() {
    if (!_isListeningToStream) return;
    _imageStream.removeListener(_handleImageChanged);
    _isListeningToStream = false;
  }

  @override
  void dispose() {
    assert(_imageStream != null);
    _stopListeningToStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget image;
    if (widget.loadStateChanged != null)
      image = widget.loadStateChanged(_loadState, this);

    if (image == null) {
      switch (_loadState) {
        case LoadState.loading:
          image = Container(
            width: widget.width,
            height: widget.height,
            child: Row(
              children: <Widget>[
                _getIndicator(context),
                SizedBox(
                  width: 5.0,
                ),
                Text("loading...")
              ],
            ),
          );
          break;
        case LoadState.completed:
          image = ExtendedRawImage(
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
            filterQuality: widget.filterQuality,
          );
          break;
        case LoadState.failed:
          image = Container(
            width: widget.width,
            height: widget.height,
            child: GestureDetector(
              onTap: () {
                resolveImage();
              },
              child: Text("loaded falied"),
            ),
          );
          break;
      }
    }

    if (widget.border != null) {
      image = CustomPaint(
        painter: BorderPainter(
            borderRadius: widget.borderRadius,
            border: widget.border,
            shape: widget.shape),
        child: image,
        size: Size(widget.width, widget.height),
      );
    }

    if (widget.excludeFromSemantics) return image;
    return Semantics(
      container: widget.semanticLabel != null,
      image: true,
      label: widget.semanticLabel == null ? '' : widget.semanticLabel,
      child: image,
    );
  }

  Widget _getIndicator(BuildContext context) {
    return Platform.isIOS
        ? CupertinoActivityIndicator(
            animating: true,
            radius: 16.0,
          )
        : CircularProgressIndicator(
            strokeWidth: 2.0,
            valueColor: AlwaysStoppedAnimation(Theme.of(context).primaryColor),
          );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder description) {
    super.debugFillProperties(description);
    description.add(DiagnosticsProperty<ImageStream>('stream', _imageStream));
    description.add(DiagnosticsProperty<ImageInfo>('pixels', _imageInfo));
  }
}

enum LoadState {
  //loading
  loading,
  //completed
  completed,
  //failed
  failed
}

typedef LoadStateChanged = Widget Function(
    LoadState loadState, ExtendedImageState extendedImageState);
