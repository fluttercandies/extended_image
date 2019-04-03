import 'package:extended_image/src/extended_image_utils.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui show Image;

///
///  extended_image_typedef.dart
///  create by eastmoney on 2019/4/3
///

typedef LoadStateChanged = Widget Function(ExtendedImageState state);

///[rect] is render size
///if return true, it will not paint original image,
typedef BeforePaintImage = bool Function(
    Canvas canvas, Rect rect, ui.Image image, Paint paint);

typedef AfterPaintImage = void Function(
    Canvas canvas, Rect rect, ui.Image image, Paint paint);

typedef Rebuild = GestureDetails Function();

typedef PageViewDragUpdate = void Function(DragUpdateDetails details);

typedef PageViewDragEnd = void Function(DragEndDetails details);
