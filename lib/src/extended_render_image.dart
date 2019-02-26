import 'package:flutter/rendering.dart';
import 'dart:ui' as ui show Image;

class ExtendedRenderImage extends RenderImage {
  ExtendedRenderImage(
      {ui.Image image,
      double width,
      double height,
      double scale = 1.0,
      Color color,
      BlendMode colorBlendMode,
      BoxFit fit,
      AlignmentGeometry alignment = Alignment.center,
      ImageRepeat repeat = ImageRepeat.noRepeat,
      Rect centerSlice,
      bool matchTextDirection = false,
      TextDirection textDirection,
      bool invertColors = false,
      FilterQuality filterQuality = FilterQuality.low})
      : super(
            image: image,
            width: width,
            height: height,
            scale: scale,
            color: color,
            colorBlendMode: colorBlendMode,
            fit: fit,
            alignment: alignment,
            repeat: repeat,
            centerSlice: centerSlice,
            matchTextDirection: matchTextDirection,
            textDirection: textDirection,
            invertColors: invertColors,
            filterQuality: filterQuality);
}
