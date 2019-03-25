import 'dart:math';

import 'package:extended_image/src/extended_image.dart';
import 'package:extended_image/src/extended_image_utils.dart';
import 'package:extended_image/src/extended_raw_image.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui show Image;

/// zoom image
class ExtendedImageGesture extends StatefulWidget {
  final ExtendedImage extendedImage;
  final ExtendedImageState extendedImageState;
  ExtendedImageGesture(this.extendedImage, this.extendedImageState);
  @override
  _ExtendedImageGestureState createState() => _ExtendedImageGestureState();
}

class _ExtendedImageGestureState extends State<ExtendedImageGesture> {
  Offset _startingFocalPoint;

  Offset _previousOffset;
  Offset _offset = Offset.zero;
  GestureDetails _previousGestureDetails;

  double _previousScale;
  double _scale = 1.0;

  ImageGestureHandler _gestureHandler;
  @override
  void initState() {
    // TODO: implement initState
    _gestureHandler =
        widget.extendedImage.imageGestureHandler ?? ImageGestureHandler();

    if (_gestureHandler.cacheGesture) {
      var cache =
          _gestureDetailsCache[widget.extendedImageState.imageStreamKey];
      if (cache != null) {
        _scale = cache.scale;
        _offset = cache.offset;
      }
    }

    super.initState();
  }

  void _handleScaleStart(ScaleStartDetails details) {
    //print(details);
    //print("_handleScaleStart");
    //setState(() {
    _startingFocalPoint = details.focalPoint;
    _previousOffset = _offset;
    _previousScale = _scale;
    //_offset = details.focalPoint;
    // });
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      _scale = (_previousScale * details.scale * _gestureHandler.speed)
          .clamp(_gestureHandler.minScale, _gestureHandler.maxScale);
      _scale = _roundAfter(_scale, 3);

      //if (details.scale != 1.0) {
      final Offset normalizedOffset =
          (_startingFocalPoint - _previousOffset) / _previousScale;

      Offset _temp = _offset;

      _offset = details.focalPoint - normalizedOffset * _scale;

      _previousGestureDetails = GestureDetails(
          offset: _offset, scale: _scale, delta: _offset - _temp);
//      if (details.scale == 1.0) {
//        if (_scale > 1.0) {
//          _offset = details.focalPoint - normalizedOffset * _scale;
//        }
//      } else {
//        // Ensure that item under the focal point stays in the same place despite zooming
//        //use _startingFocalPoint so that
//        _offset = _startingFocalPoint - normalizedOffset * _scale;
//      }

//      if (_scale == _gestureHandler.minScale) {
//        _offset = Offset.zero;
//      }

      ///move
//      if (details.scale == 1.0 && _previousGestureDetails != null) {
//        var offsetMove = _offset - _previousGestureDetails.offset;
//
//        Rect temp = hanldeGesture(
//            GestureDetails(_offset, _scale),
//            _previousGestureDetails.rect,
//            _previousGestureDetails.destinationRect);
//
//        //move on horizontal
//        if (offsetMove.dx != 0.0) {
//          //move left to right
//          if (offsetMove.dx > 0) {
//            if (temp.left > _previousGestureDetails.rect.left) {
//              _offset = Offset(
//                  _offset.dx - (temp.left - _previousGestureDetails.rect.left),
//                  _offset.dy);
//            }
//          } else {
//            if (temp.right < _previousGestureDetails.rect.right) {
//              _offset = Offset(
//                  _offset.dx +
//                      (_previousGestureDetails.rect.right - temp.right),
//                  _offset.dy);
//            }
//          }
//        }
//
//        //move on vertical
//        if (offsetMove.dy != 0.0) {}
//      }

      //offset = details.focalPoint;
      //print("_handleScaleUpdate$_offset");
    });
  }

  void _handleScaleReset() {
    setState(() {
      _scale = 1.0;
      _offset = Offset.zero;
    });
  }

  //Round the scale to three points after comma to prevent shaking
  double _roundAfter(double number, int position) {
    double shift = pow(10, position).toDouble();
    return (number * shift).roundToDouble() / shift;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
//    final Offset center = size.center(Offset.zero) * zoom + offset;
//    final double radius = size.width / 2.0 * zoom;

    var newGestureDetails = GestureDetails(offset: _offset, scale: _scale);

    _previousGestureDetails = newGestureDetails;

    if (_gestureHandler.cacheGesture) {
      _gestureDetailsCache[widget.extendedImageState.imageStreamKey] =
          _previousGestureDetails;
    }

    Widget image = ExtendedRawImage(
      image: widget.extendedImageState.extendedImageInfo?.image,
      width: widget.extendedImage.width,
      height: widget.extendedImage.height,
      scale: widget.extendedImageState.extendedImageInfo?.scale ?? 1.0,
      color: widget.extendedImage.color,
      colorBlendMode: widget.extendedImage.colorBlendMode,
      fit: widget.extendedImage.fit,
      alignment: widget.extendedImage.alignment,
      repeat: widget.extendedImage.repeat,
      centerSlice: widget.extendedImage.centerSlice,
      matchTextDirection: widget.extendedImage.matchTextDirection,
      invertColors: widget.extendedImageState.invertColors,
      filterQuality: widget.extendedImage.filterQuality,
      beforePaintImage: widget.extendedImage.beforePaintImage,
      afterPaintImage: widget.extendedImage.afterPaintImage,
      gestureDetails: _previousGestureDetails,
    );

    image = GestureDetector(
      onScaleStart: _handleScaleStart,
      onScaleUpdate: _handleScaleUpdate,
      onDoubleTap: _handleScaleReset,
      onHorizontalDragUpdate: _scale <= 1.0
          ? null
          : (DragUpdateDetails detail) {
              setState(() {
                //print(_previousGestureDetails.offset - _offset);
                _offset = _offset + detail.delta;
                _previousGestureDetails = GestureDetails(
                    offset: _offset, scale: _scale, delta: detail.delta);
              });

//              if (_previousGestureDetails != null) {
//                var delta = detail.delta;
//
//                Rect temp = hanldeGesture(
//                    GestureDetails(offset: _offset, scale: _scale),
//                    _previousGestureDetails.rect,
//                    _previousGestureDetails.destinationRect);
//
//                //move on horizontal
//                if (delta.dx != 0.0) {
//                  //move left to right
//                  if (delta.dx > 0) {
//                    if (temp.left > _previousGestureDetails.rect.left) {
////                      _offset = Offset(
////                          _offset.dx -
////                              (temp.left - _previousGestureDetails.rect.left),
////                          _offset.dy);
////                      _previousGestureDetails = GestureDetails(
////                          destinationRect: Rect.fromLTWH(
////                              0.0,
////                              _previousGestureDetails.destinationRect.top,
////                              _previousGestureDetails.destinationRect.width,
////                              _previousGestureDetails.destinationRect.height));
//                    }
//                  } else {
//                    if (temp.right < _previousGestureDetails.rect.right) {
////                      _offset = Offset(
////                          _offset.dx +
////                              (_previousGestureDetails.rect.right - temp.right),
////                          _offset.dy);
////                      _previousGestureDetails = GestureDetails(
////                          destinationRect: Rect.fromLTWH(
////                              0.0,
////                              _previousGestureDetails.destinationRect.top,
////                              _previousGestureDetails.destinationRect.width,
////                              _previousGestureDetails.destinationRect.height));
//                    }
//                  }
//                }
//              }
            },
      child: image,
    );

//    image = Listener(
//      child: image,
//    );

    return image;
  }
}

Map<Object, GestureDetails> _gestureDetailsCache =
    Map<Object, GestureDetails>();

void clearGestureDetailsCache() {
  _gestureDetailsCache.clear();
}
