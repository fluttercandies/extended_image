import 'package:extended_image/src/editor/editor.dart';
import 'package:extended_image/src/typedef.dart';
import 'package:flutter/material.dart';

import 'editor_crop_layer_painter.dart';
import 'editor_utils.dart';

/// The `EditorConfig` class provides a customizable configuration for the image editor.
/// This class defines various parameters for controlling the behavior and appearance
/// of the cropping functionality, such as maximum scale, aspect ratio, padding,
/// and corner styles. It allows fine-tuning of the user interface and interaction
/// within the image editing and cropping environment.
///
/// You can use this class to adjust the appearance of the crop rect (corner size, color),
/// as well as control how interactions like scaling and panning work during editing.
/// It also offers flexibility in setting up animations and defining behavior when the
/// crop rect is modified.

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

  /// Callback triggered when `EditActionDetails` is changed.
  final EditActionDetailsIsChanged? editActionDetailsIsChanged;

  /// Behavior for hit tests. Controls how the editor responds when the user interacts
  /// with elements such as crop corners or boundary lines.
  ///
  /// `deferToChild`: Passes the event to child widgets.
  final HitTestBehavior hitTestBehavior;

  /// Maximum scale factor for zooming the image during editing.
  /// Determines how far the user can zoom in on the image.
  final double maxScale;

  /// Padding between the crop rect and the layout or image boundaries.
  /// Helps to provide spacing around the crop rect within the editor.
  final EdgeInsets cropRectPadding;

  /// Size of the corner handles for the crop rect.
  /// These are the draggable shapes at the corners of the crop rectangle.
  final Size cornerSize;

  /// Color of the corner handles for the crop rect.
  /// Defaults to the primary color if not provided.
  final Color? cornerColor;

  /// Color of the crop boundary lines.
  /// Defaults to `scaffoldBackgroundColor.withOpacity(0.7)` if not specified.
  final Color? lineColor;

  /// Thickness of the crop boundary lines.
  /// Controls how bold or thin the crop rect lines appear.
  final double lineHeight;

  /// Handler that defines the color of the mask applied to the image when the editor is active.
  /// The mask darkens the area outside the crop rect, and its color may vary depending on
  /// whether the user is interacting with the crop rect.
  final EditorMaskColorHandler? editorMaskColorHandler;

  /// The size of the hit test region used to detect user interactions with the crop
  /// rect corners and boundary lines.
  final double hitTestSize;

  /// Duration for the auto-center animation, which animates the crop rect back to the center
  /// after the user has finished manipulating it.
  final Duration animationDuration;

  /// Duration of the delay before starting the auto-center animation after the crop rect is moved or changed.
  final Duration tickerDuration;

  /// Aspect ratio of the crop rect. This controls the ratio between the width and height of the cropping area.
  /// By default, it's set to custom, allowing freeform cropping unless specified otherwise.
  final double? cropAspectRatio;

  /// Initial aspect ratio of the crop rect. This only affects the initial state of the crop rect,
  /// giving users the option to start with a pre-defined aspect ratio.
  final double? initialCropAspectRatio;

  /// Specifies how the initial crop rect is defined. It can either be based on the entire image rect
  /// or the layout rect (the visible part of the image).
  final InitCropRectType initCropRectType;

  /// A custom painter for drawing the crop rect and handles.
  /// This allows for customizing the appearance of the crop boundary and corner handles.
  final EditorCropLayerPainter cropLayerPainter;

  /// Speed factor for zooming and panning interactions.
  /// Adjusts how quickly the user can move or zoom the image during editing.
  final double speed;

  /// Reverses the direction of mouse pointer scroll for zoom actions.
  /// When `false` (default): scrolling down zooms in, and scrolling up zooms out.
  /// When `true`: scrolling up zooms in, and scrolling down zooms out.
  final bool reverseMousePointerScrollDirection;

  /// A controller to manage image editing actions, providing functions like rotating, flipping, undoing, and redoing actions..
  /// This allows for external control of the editing process.
  final ImageEditorController? controller;
}
