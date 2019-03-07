import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui show Image;

enum LoadState {
  //loading
  loading,
  //completed
  completed,
  //failed
  failed
}

typedef LoadStateChanged = Widget Function(
    LoadState loadState, ReloadAction reloadAction);

///[rect] is render size
typedef BeforePaintImage = void Function(
    {@required Canvas canvas, @required Rect rect, @required ui.Image image});

typedef AfterPaintImage = void Function(
    {@required Canvas canvas, @required Rect rect, @required ui.Image image});

abstract class ReloadAction {
  void reLoadImage();
}
