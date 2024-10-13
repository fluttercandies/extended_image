import 'package:extended_image/src/editor/editor.dart';
import 'package:extended_image/src/typedef.dart';
import 'package:flutter/material.dart';

import 'editor_crop_layer_painter.dart';
import 'editor_utils.dart';

class EditorConfig {
  EditorConfig({
    this.maxScale = 5.0,
    this.cropRectPadding = const EdgeInsets.all(20.0),
    this.cornerSize = const Size(30.0, 5.0),
    this.cornerColor,
    this.lineColor,
    this.lineHeight = 0.6,
    this.editorMaskColorHandler,
    this.hitTestSize = 20.0,
    this.animationDuration = const Duration(milliseconds: 200),
    this.tickerDuration = const Duration(milliseconds: 400),
    this.cropAspectRatio = CropAspectRatios.custom,
    this.initialCropAspectRatio = CropAspectRatios.custom,
    this.initCropRectType = InitCropRectType.imageRect,
    this.cropLayerPainter = const EditorCropLayerPainter(),
    this.speed = 1.0,
    this.hitTestBehavior = HitTestBehavior.deferToChild,
    this.editActionDetailsIsChanged,
    this.reverseMousePointerScrollDirection = false,
    this.controller,
  })  : assert(lineHeight > 0.0),
        assert(hitTestSize >= 0.0),
        assert(maxScale > 0.0),
        assert(speed > 0.0);

  /// Call when EditActionDetails is changed
  final EditActionDetailsIsChanged? editActionDetailsIsChanged;

  /// How to behave during hit tests.
  final HitTestBehavior hitTestBehavior;

  /// Max scale
  final double maxScale;

  /// Padding of crop rect to layout rect
  /// it's refer to initial image rect and crop rect
  final EdgeInsets cropRectPadding;

  /// Size of corner shape
  final Size cornerSize;

  /// Color of corner shape
  /// default: primaryColor
  final Color? cornerColor;

  /// Color of crop line
  /// default: scaffoldBackgroundColor.withOpacity(0.7)
  final Color? lineColor;

  /// Height of crop line
  final double lineHeight;

  /// Editor mask color base on pointerDown
  /// default: scaffoldBackgroundColor.withOpacity(pointerDown ? 0.4 : 0.8)
  final EditorMaskColorHandler? editorMaskColorHandler;

  /// Hit test region of corner and line
  final double hitTestSize;

  /// Auto center animation duration
  final Duration animationDuration;

  /// Duration to begin auto center animation after crop rect is changed
  final Duration tickerDuration;

  /// Aspect ratio of crop rect
  /// default is custom
  ///
  /// Typically the aspect ratio will not be changed during the editing process,
  /// but it might be relevant with states (e.g. [ExtendedImageState]).
  final double? cropAspectRatio;

  /// Initial Aspect ratio of crop rect
  /// default is custom
  ///
  /// The argument only affects the initial aspect ratio,
  /// users can set it based on the desire despite of [cropAspectRatio].
  final double? initialCropAspectRatio;

  /// Init crop rect base on initial image rect or image layout rect
  final InitCropRectType initCropRectType;

  /// Custom crop layer
  final EditorCropLayerPainter cropLayerPainter;

  /// Speed for zoom/pan
  final double speed;

  /// reverse mouse pointer scroll deirection
  /// false: zoom int => down, zoom out => up
  /// true: zoom int => up, zoom out => down
  /// default is false
  final bool reverseMousePointerScrollDirection;

  final ImageEditorController? controller;
}
