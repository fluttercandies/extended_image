import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:extended_image/src/image/raw_image.dart';
import 'package:extended_image/src/utils.dart';
import 'package:extended_image_library/extended_image_library.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../extended_image.dart';
import 'crop_layer.dart';
import 'editor_utils.dart';

///
///  create by zmtzawqlp on 2019/8/22
///

class ExtendedImageEditor extends StatefulWidget {
  ExtendedImageEditor({required this.extendedImageState, Key? key})
      : assert(extendedImageState.imageWidget.fit == BoxFit.contain,
            'Make sure the image is all painted to crop,the fit of image must be BoxFit.contain'),
        assert(extendedImageState.imageWidget.image is ExtendedImageProvider,
            'Make sure the image provider is ExtendedImageProvider, we will get raw image data from it'),
        super(key: key);
  final ExtendedImageState extendedImageState;
  @override
  ExtendedImageEditorState createState() => ExtendedImageEditorState();
}

class ExtendedImageEditorState extends State<ExtendedImageEditor> {
  EditActionDetails? _editActionDetails;
  EditorConfig? _editorConfig;
  late double _startingScale;
  late Offset _startingOffset;
  double _detailsScale = 1.0;
  final GlobalKey<ExtendedImageCropLayerState> _layerKey =
      GlobalKey<ExtendedImageCropLayerState>();
  @override
  void initState() {
    super.initState();
    _initGestureConfig();
  }

  void _initGestureConfig() {
    final double? cropAspectRatio = _editorConfig?.cropAspectRatio;
    _editorConfig = widget
            .extendedImageState.imageWidget.initEditorConfigHandler
            ?.call(widget.extendedImageState) ??
        EditorConfig();

    if (cropAspectRatio != _editorConfig!.cropAspectRatio) {
      _editActionDetails = null;
    }

    _editActionDetails ??= EditActionDetails()
      ..delta = Offset.zero
      ..totalScale = 1.0
      ..preTotalScale = 1.0
      ..cropRectPadding = _editorConfig!.cropRectPadding;

    if (widget.extendedImageState.extendedImageInfo?.image != null) {
      _editActionDetails!.originalAspectRatio =
          widget.extendedImageState.extendedImageInfo!.image.width /
              widget.extendedImageState.extendedImageInfo!.image.height;
    }
    _editActionDetails!.cropAspectRatio = _editorConfig!.cropAspectRatio;
    _editActionDetails!.initialCropAspectRatio =
        _editorConfig!.initialCropAspectRatio;

    if (_editorConfig!.cropAspectRatio != null &&
        _editorConfig!.cropAspectRatio! <= 0) {
      _editActionDetails!.cropAspectRatio =
          _editActionDetails!.originalAspectRatio;
    }
    if (_editorConfig!.initialCropAspectRatio != null &&
        _editorConfig!.initialCropAspectRatio! <= 0) {
      _editActionDetails!.initialCropAspectRatio =
          _editActionDetails!.originalAspectRatio;
    }
  }

  @override
  void didUpdateWidget(ExtendedImageEditor oldWidget) {
    _initGestureConfig();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    assert(_editActionDetails != null && _editorConfig != null);
    final ExtendedImage extendedImage = widget.extendedImageState.imageWidget;
    final Widget image = ExtendedRawImage(
      image: widget.extendedImageState.extendedImageInfo?.image,
      width: extendedImage.width,
      height: extendedImage.height,
      scale: widget.extendedImageState.extendedImageInfo?.scale ?? 1.0,
      color: extendedImage.color,
      colorBlendMode: extendedImage.colorBlendMode,
      fit: extendedImage.fit,
      alignment: extendedImage.alignment,
      repeat: extendedImage.repeat,
      centerSlice: extendedImage.centerSlice,
      //matchTextDirection: extendedImage.matchTextDirection,
      //don't support TextDirection for editor
      matchTextDirection: false,
      invertColors: widget.extendedImageState.invertColors,
      filterQuality: extendedImage.filterQuality,
      editActionDetails: _editActionDetails,
    );

    Widget result = GestureDetector(
        onScaleStart: _handleScaleStart,
        onScaleUpdate: _handleScaleUpdate,
        behavior: _editorConfig!.hitTestBehavior,
        child: Stack(
          children: <Widget>[
            Positioned.fill(child: image),
            Positioned.fill(
              child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                Rect layoutRect = Offset.zero &
                    Size(constraints.maxWidth, constraints.maxHeight);
                final EdgeInsets padding = _editorConfig!.cropRectPadding;

                layoutRect = padding.deflateRect(layoutRect);

                if (_editActionDetails!.cropRect == null) {
                  final AlignmentGeometry alignment =
                      widget.extendedImageState.imageWidget.alignment;
                  //matchTextDirection: extendedImage.matchTextDirection,
                  //don't support TextDirection for editor
                  final TextDirection? textDirection =
                      //extendedImage.matchTextDirection ||
                      alignment is! Alignment
                          ? Directionality.of(context)
                          : null;
                  final Alignment resolvedAlignment =
                      alignment.resolve(textDirection);
                  final Rect destinationRect = getDestinationRect(
                      rect: layoutRect,
                      inputSize: Size(
                          widget
                              .extendedImageState.extendedImageInfo!.image.width
                              .toDouble(),
                          widget.extendedImageState.extendedImageInfo!.image
                              .height
                              .toDouble()),
                      flipHorizontally: false,
                      fit: widget.extendedImageState.imageWidget.fit,
                      centerSlice:
                          widget.extendedImageState.imageWidget.centerSlice,
                      alignment: resolvedAlignment,
                      scale:
                          widget.extendedImageState.extendedImageInfo!.scale);

                  Rect cropRect = _initCropRect(destinationRect);
                  if (_editorConfig!.initCropRectType ==
                          InitCropRectType.layoutRect &&
                      _editorConfig!.cropAspectRatio != null &&
                      _editorConfig!.cropAspectRatio! > 0) {
                    final Rect rect = _initCropRect(layoutRect);
                    _editActionDetails!.totalScale = _editActionDetails!
                        .preTotalScale = destinationRect.width
                            .greaterThan(destinationRect.height)
                        ? rect.height / cropRect.height
                        : rect.width / cropRect.width;
                    cropRect = rect;
                  }
                  _editActionDetails!.cropRect = cropRect;
                }

                return ExtendedImageCropLayer(
                  _editActionDetails!,
                  _editorConfig!,
                  layoutRect,
                  key: _layerKey,
                  fit: BoxFit.contain,
                );
              }),
            ),
          ],
        ));
    result = Listener(
      child: result,
      onPointerDown: (_) {
        _layerKey.currentState?.pointerDown(true);
      },
      onPointerUp: (_) {
        _layerKey.currentState?.pointerDown(false);
      },
      onPointerSignal: _handlePointerSignal,
      // onPointerCancel: (_) {
      //   pointerDown(false);
      // },
      behavior: _editorConfig!.hitTestBehavior,
    );
    return result;
  }

  Rect _initCropRect(Rect rect) {
    if (_editActionDetails!.cropAspectRatio != null) {
      return _calculateCropRectFromAspectRatio(
        rect,
        _editActionDetails!.cropAspectRatio!,
      );
    }
    if (_editActionDetails!.initialCropAspectRatio != null) {
      return _calculateCropRectFromAspectRatio(
        rect,
        _editActionDetails!.initialCropAspectRatio!,
      );
    }
    return _editActionDetails!.getRectWithScale(rect);
  }

  Rect _calculateCropRectFromAspectRatio(Rect rect, double aspectRatio) {
    final Rect cropRect = _editActionDetails!.getRectWithScale(rect);
    final double height = min(cropRect.height, cropRect.width / aspectRatio);
    final double width = height * aspectRatio;

    return Rect.fromCenter(
      center: cropRect.center,
      width: width,
      height: height,
    );
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _layerKey.currentState!.pointerDown(true);
    _startingOffset = details.focalPoint;
    _editActionDetails!.screenFocalPoint = details.focalPoint;
    _startingScale = _editActionDetails!.totalScale;
    _detailsScale = 1.0;
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    _layerKey.currentState!.pointerDown(true);
    if (_layerKey.currentState!.isAnimating ||
        _layerKey.currentState!.isMoving) {
      return;
    }
    double totalScale = _startingScale * details.scale * _editorConfig!.speed;
    final Offset delta =
        details.focalPoint * _editorConfig!.speed - _startingOffset;
    final double scaleDelta = details.scale / _detailsScale;
    final bool zoomOut = scaleDelta < 1;
    final bool zoomIn = scaleDelta > 1;

    _detailsScale = details.scale;

    _startingOffset = details.focalPoint;
    //no more zoom
    if ((_editActionDetails!.reachCropRectEdge && zoomOut) ||
        _editActionDetails!.totalScale.equalTo(_editorConfig!.maxScale) &&
            zoomIn) {
      //correct _startingScale
      //details.scale was not calcuated at the moment
      _startingScale = _editActionDetails!.totalScale / details.scale;
      return;
    }

    totalScale = min(totalScale, _editorConfig!.maxScale);

    if (mounted && (scaleDelta != 1.0 || delta != Offset.zero)) {
      setState(() {
        _editActionDetails!.totalScale = totalScale;

        ///if we have shift offset, we should clear delta.
        ///we should += delta in case miss delta
        _editActionDetails!.delta += delta;
        _editorConfig!.editActionDetailsIsChanged?.call(_editActionDetails);
      });
    }
  }

  void _handlePointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent && event.kind == PointerDeviceKind.mouse) {
      _handleScaleStart(ScaleStartDetails(focalPoint: event.position));
      final double dy = event.scrollDelta.dy;
      final double dx = event.scrollDelta.dx;
      _handleScaleUpdate(ScaleUpdateDetails(
          focalPoint: event.position,
          scale: 1.0 +
              _reverseIf((dy.abs() > dx.abs() ? dy : dx) *
                  _editorConfig!.speed /
                  1000.0)));
    }
  }

  double _reverseIf(double scaleDetal) {
    if (_editorConfig?.reverseMousePointerScrollDirection ?? false) {
      return -scaleDetal;
    } else {
      return scaleDetal;
    }
  }

  Rect? getCropRect() {
    if (widget.extendedImageState.extendedImageInfo?.image == null ||
        _editActionDetails == null) {
      return null;
    }

    Rect? cropScreen = _editActionDetails!.screenCropRect;
    Rect? imageScreenRect = _editActionDetails!.screenDestinationRect;

    if (cropScreen == null || imageScreenRect == null) {
      return null;
    }

    imageScreenRect = _editActionDetails!.paintRect(imageScreenRect);
    cropScreen = _editActionDetails!.paintRect(cropScreen);

    //move to zero
    cropScreen = cropScreen.shift(-imageScreenRect.topLeft);

    imageScreenRect = imageScreenRect.shift(-imageScreenRect.topLeft);

    final ui.Image image = widget.extendedImageState.extendedImageInfo!.image;
    // var size = _editActionDetails.isHalfPi
    //     ? Size(image.height.toDouble(), image.width.toDouble())
    //     : Size(image.width.toDouble(), image.height.toDouble());
    final Rect imageRect =
        Offset.zero & Size(image.width.toDouble(), image.height.toDouble());

    final double ratioX = imageRect.width / imageScreenRect.width;
    final double ratioY = imageRect.height / imageScreenRect.height;

    final Rect cropImageRect = Rect.fromLTWH(
        cropScreen.left * ratioX,
        cropScreen.top * ratioY,
        cropScreen.width * ratioX,
        cropScreen.height * ratioY);
    return cropImageRect;
  }

  ui.Image? get image => widget.extendedImageState.extendedImageInfo?.image;

  Uint8List get rawImageData {
    assert(
        widget.extendedImageState.imageWidget.image is ExtendedImageProvider);

    final ExtendedImageProvider<dynamic> extendedImageProvider =
        widget.extendedImageState.imageWidget.image
            // ignore: always_specify_types
            as ExtendedImageProvider<dynamic>;
    return extendedImageProvider.rawImageData;
  }

  EditActionDetails? get editAction => _editActionDetails;

  void rotate({bool right = true}) {
    if (_layerKey.currentState == null) {
      return;
    }
    setState(() {
      _editActionDetails!.rotate(
        right ? pi / 2.0 : -pi / 2.0,
        _layerKey.currentState!.layoutRect,
        BoxFit.contain,
      );
      _editorConfig!.editActionDetailsIsChanged?.call(_editActionDetails);
    });
  }

  void flip() {
    assert(_editActionDetails != null && _editorConfig != null);
    setState(() {
      _editActionDetails!.flip();
      _editorConfig!.editActionDetailsIsChanged?.call(_editActionDetails);
    });
  }

  void reset() {
    setState(() {
      _editorConfig = null;
      _editActionDetails = null;
      _initGestureConfig();
      _editorConfig!.editActionDetailsIsChanged?.call(_editActionDetails);
    });
  }
}
