import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui show Image;

import 'package:flutter/src/foundation/diagnostics.dart';

enum LoadState {
  //loading
  loading,
  //completed
  completed,
  //failed
  failed
}

typedef LoadStateChanged = Widget Function(ExtendedImageState state);

///[rect] is render size
typedef BeforePaintImage = void Function(
    {@required Canvas canvas, @required Rect rect, @required ui.Image image});

typedef AfterPaintImage = void Function(
    {@required Canvas canvas, @required Rect rect, @required ui.Image image});

abstract class ExtendedImageState {
  void reLoadImage();
  ImageInfo get ExtendedImageInfo;
  LoadState get ExtendedImageLoadState;

  ///return LoadStateChanged fucntion widget immediately
  bool returnLoadStateChangedWidget;
}
