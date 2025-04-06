import 'dart:ui' as ui show Image;
import 'package:extended_image/src/editor/edit_action_details.dart';
import 'package:extended_image/src/gesture/utils.dart';
import 'package:extended_image/src/utils.dart';
import 'package:flutter/material.dart';

import 'editor/editor_config.dart';
import 'gesture/gesture.dart';
import 'gesture/slide_page.dart';

///
///  extended_image_typedef.dart
///  create by zmtzawqlp on 2019/4/3
///

typedef LoadStateChanged = Widget? Function(ExtendedImageState state);

/// [rect] is render size
/// if return true, it will not paint original image,
typedef BeforePaintImage =
    bool Function(Canvas canvas, Rect rect, ui.Image image, Paint paint);

/// Call after paint image
typedef AfterPaintImage =
    void Function(Canvas canvas, Rect rect, ui.Image image, Paint paint);

/// Animation call back for inertia drag
typedef GestureOffsetAnimationCallBack = void Function(Offset offset);

/// Animation call back for scale
typedef GestureScaleAnimationCallBack = void Function(double scale);

/// Double tap call back
typedef DoubleTap = void Function(ExtendedImageGestureState state);

/// Build page background when slide page
typedef SlidePageBackgroundHandler =
    Color Function(Offset offset, Size pageSize);

/// customize offset of page when slide page
typedef SlideOffsetHandler =
    Offset? Function(Offset offset, {ExtendedImageSlidePageState state});

/// if return true ,pop page
/// else reset page state
typedef SlideEndHandler =
    bool? Function(
      Offset offset, {
      ExtendedImageSlidePageState state,
      ScaleEndDetails details,
    });

/// Customize scale of page when slide page
typedef SlideScaleHandler =
    double? Function(Offset offset, {ExtendedImageSlidePageState state});

/// Init GestureConfig when image is ready.
typedef InitGestureConfigHandler =
    GestureConfig Function(ExtendedImageState state);

/// Call on sliding page
typedef OnSlidingPage = void Function(ExtendedImageSlidePageState state);

/// Whether we can scroll page
typedef CanScrollPage = bool Function(GestureDetails? gestureDetails);

/// Return initial destination rect
typedef InitDestinationRect = void Function(Rect initialDestinationRect);

/// Return merged editRect rect
typedef MergeEditRect = Rect Function(Rect editRect);

/// Build Gesture Image
typedef BuildGestureImage = Widget Function(GestureDetails gestureDetails);

/// Init GestureConfig when image is ready.
typedef InitEditorConfigHandler =
    EditorConfig? Function(ExtendedImageState? state);

/// Get editor mask color base on pointerDown
typedef EditorMaskColorHandler =
    Color Function(BuildContext context, bool pointerDown);

/// Build Hero only for sliding page
/// the transform of sliding page must be working on Hero
/// so that Hero animation wouldn't be strange when pop page
typedef HeroBuilderForSlidingPage = Widget Function(Widget widget);

/// Build image for gesture, we can handle custom Widget about gesture
typedef ImageBuilderForGesture =
    Widget Function(
      Widget image, {
      ExtendedImageGestureState? imageGestureState,
    });

/// Whether should scale image
typedef CanScaleImage = bool Function(GestureDetails? details);

/// Call when GestureDetails is changed
typedef GestureDetailsIsChanged = void Function(GestureDetails? details);

/// Call when EditActionDetails is changed
typedef EditActionDetailsIsChanged = void Function(EditActionDetails? details);
