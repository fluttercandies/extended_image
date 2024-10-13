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
import 'edit_action_details.dart';
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

class ExtendedImageEditorState extends State<ExtendedImageEditor>
    with SingleTickerProviderStateMixin {
  EditActionDetails? _editActionDetails;
  EditorConfig? _editorConfig;
  late double _startingScale;
  // late double _startingRotation;
  late Offset _startingOffset;
  double _detailsScale = 1.0;
  final GlobalKey<ExtendedImageCropLayerState> _layerKey =
      GlobalKey<ExtendedImageCropLayerState>();

  late AnimationController _animationController;

  Animation<double>? _rotationYAnimation;
  Animation<double>? _rotateRadianAnimation;
  @override
  void initState() {
    super.initState();
    _initGestureConfig();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration.zero,
    );
    _animationController.addListener(_onAnimation);
  }

  void _onAnimation() {
    _updateRotate(
      _rotationYAnimation?.value ?? _editActionDetails!.rotationY,
      _rotateRadianAnimation?.value ?? _editActionDetails!.rotateRadian,
    );
    if (_animationController.isCompleted) {
      _layerKey.currentState?.pointerDown(false);
      _rotationYAnimation = null;
      _rotateRadianAnimation = null;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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

    if (_editorConfig!.cropAspectRatio != null &&
        _editorConfig!.cropAspectRatio! <= 0) {
      _editActionDetails!.cropAspectRatio =
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

    Widget result = ClipRect(
      child: GestureDetector(
          onScaleStart: _handleScaleStart,
          onScaleUpdate: _handleScaleUpdate,
          behavior: _editorConfig!.hitTestBehavior,
          child: IgnorePointer(
            ignoring: _animationController.isAnimating,
            child: Stack(
              children: <Widget>[
                Positioned.fill(child: image),
                Positioned.fill(
                  child: LayoutBuilder(builder:
                      (BuildContext context, BoxConstraints constraints) {
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
                              widget.extendedImageState.extendedImageInfo!.image
                                  .width
                                  .toDouble(),
                              widget.extendedImageState.extendedImageInfo!.image
                                  .height
                                  .toDouble()),
                          flipHorizontally: false,
                          fit: widget.extendedImageState.imageWidget.fit,
                          centerSlice:
                              widget.extendedImageState.imageWidget.centerSlice,
                          alignment: resolvedAlignment,
                          scale: widget
                              .extendedImageState.extendedImageInfo!.scale);

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
            ),
          )),
    );
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
    if (_editorConfig!.initialCropAspectRatio != null) {
      return _calculateCropRectFromAspectRatio(
        rect,
        _editorConfig!.initialCropAspectRatio!,
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
    // _startingRotation = _editActionDetails!.rotateRadian;
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
    _editActionDetails!.screenFocalPoint = details.focalPoint;
    // no more zoom
    if ((_editActionDetails!.reachCropRectEdge && zoomOut) ||
        _editActionDetails!.totalScale.equalTo(_editorConfig!.maxScale) &&
            zoomIn) {
      // correct _startingScale
      // details.scale was not calcuated at the moment
      _startingScale =
          _editActionDetails!.totalScale / details.scale / _editorConfig!.speed;

      return;
    }

    totalScale = min(totalScale, _editorConfig!.maxScale);
    if (mounted) {
      setState(() {
        if (
            // (_editorConfig!.gestureRotate && details.rotation != 0) ||
            scaleDelta != 1.0) {
          // _editActionDetails!.updateRotateRadian(
          //   _startingRotation +
          //       _editActionDetails!.reverseRotateRadian(details.rotation),
          //   totalScale,
          // );
          _editActionDetails!.updateScale(totalScale);
        } else if (delta != Offset.zero) {
          ///if we have shift offset, we should clear delta.
          ///we should += delta in case miss delta
          // _editActionDetails!.delta += delta;
          _editActionDetails!.updateDelta(delta);
        }
      });
      _editorConfig!.editActionDetailsIsChanged?.call(_editActionDetails);
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

    final Path path = _editActionDetails!.getImagePath();

    imageScreenRect = path.getBounds();

    // move to zero
    cropScreen = cropScreen.shift(-imageScreenRect.topLeft);

    imageScreenRect = imageScreenRect.shift(-imageScreenRect.topLeft);

    final ui.Image image = widget.extendedImageState.extendedImageInfo!.image;

    // rotate Physical rect
    Rect physicalimageRect = Offset.zero &
        Size(
          image.width.toDouble(),
          image.height.toDouble(),
        );

    final Path physicalimagePath =
        _editActionDetails!.getImagePath(rect: physicalimageRect);
    physicalimageRect = physicalimagePath.getBounds();

    final double ratioX = physicalimageRect.width / imageScreenRect.width;
    final double ratioY = physicalimageRect.height / imageScreenRect.height;

    final Rect cropImageRect = Rect.fromLTWH(
      cropScreen.left * ratioX,
      cropScreen.top * ratioY,
      cropScreen.width * ratioX,
      cropScreen.height * ratioY,
    );
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

  void rotate({
    double angle = 90,
    bool animation = false,
    Duration? duration,
  }) {
    if (_animationController.isAnimating) {
      return;
    }
    if (_layerKey.currentState == null) {
      return;
    }

    duration ??= Duration(milliseconds: (angle * 50).abs().toInt());

    final double begin = _editActionDetails!.rotateRadian;
    final double end =
        begin + _editActionDetails!.reverseRotateRadian(angle / 180 * pi);

    if (animation) {
      _animationController.duration = duration;
      _rotateRadianAnimation = Tween<double>(
        begin: begin,
        end: end,
      ).animate(_animationController);
      _layerKey.currentState?.pointerDown(true);
      _animationController.forward(from: 0);
    } else {
      _updateRotate(_editActionDetails!.rotationY, end);
    }
  }

  void flip({
    bool animation = false,
    Duration duration = const Duration(milliseconds: 500),
  }) {
    if (_animationController.isAnimating) {
      return;
    }

    assert(_editActionDetails != null && _editorConfig != null);

    final double begin = _editActionDetails!.rotationY;

    double end = 0.0;

    if (begin == 0.0) {
      end = pi;
    } else {
      end = 0.0;
    }

    if (animation) {
      _animationController.duration = duration;
      _rotationYAnimation = Tween<double>(
        begin: begin,
        end: end,
      ).animate(_animationController);
      _layerKey.currentState?.pointerDown(true);
      _animationController.forward(from: 0);
    } else {
      _updateRotate(end, _editActionDetails!.rotateRadian);
    }
  }

  void _updateRotate(double rotationY, double rotateRadian) {
    setState(() {
      _editActionDetails!.rotationY = rotationY;
      _editActionDetails!.updateRotateRadian(
        rotateRadian,
        _editorConfig!.maxScale,
      );

      _editorConfig!.editActionDetailsIsChanged?.call(_editActionDetails);
    });
  }

  void reset() {
    if (_animationController.isAnimating) {
      _animationController.stop();
    }
    setState(() {
      _editorConfig = null;
      _editActionDetails = null;
      _initGestureConfig();
      _editorConfig!.editActionDetailsIsChanged?.call(_editActionDetails);
    });
  }
}
