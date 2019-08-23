import 'package:extended_image/src/extended_image_utils.dart';
import 'package:extended_image/src/gesture/extended_image_gesture_utils.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui show Image;

import 'gesture/extended_image_slide_page.dart';

///
///  extended_image_typedef.dart
///  create by zmtzawqlp on 2019/4/3
///

typedef LoadStateChanged = Widget Function(ExtendedImageState state);

///[rect] is render size
///if return true, it will not paint original image,
typedef BeforePaintImage = bool Function(
    Canvas canvas, Rect rect, ui.Image image, Paint paint);

typedef AfterPaintImage = void Function(
    Canvas canvas, Rect rect, ui.Image image, Paint paint);

/// animation call back for inertia drag
typedef GestureOffsetAnimationCallBack = void Function(Offset offset);

/// animation call back for scale
typedef GestureScaleAnimationCallBack = void Function(double scale);

/// double tap call back
typedef DoubleTap = void Function(ExtendedImageGestureState state);

/// build page background when slide page
typedef SlidePageBackgroundHandler = Color Function(
    Offset offset, Size pageSize);

///if return true ,pop page
///else reset page state
typedef SlideEndHandler = bool Function(Offset offset);

///custom scale of page when slide page
typedef SlideScaleHandler = double Function(Offset offset);

///init GestureConfig when image is ready.
typedef InitGestureConfigHandler = GestureConfig Function(
    ExtendedImageState state);

///on sliding page
typedef OnSlidingPage = void Function(ExtendedImageSlidePageState state);

///whether we can move page
typedef CanMovePage = bool Function(GestureDetails gestureDetails);

///return initial destination rect
typedef InitDestinationRect = void Function(Rect initialDestinationRect);
