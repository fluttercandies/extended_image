import 'package:flutter/material.dart';

import 'extended_image_gesture_utils.dart';
import 'extended_image_slide_page.dart';

///
///  create by zmtzawqlp on 2019/6/14
///

/// for loading/failed widget
class ExtendedImageSlidePageHandler extends StatefulWidget {
  final Widget child;
  final ExtendedImageSlidePageState extendedImageSlidePageState;
  ExtendedImageSlidePageHandler(this.child, this.extendedImageSlidePageState);
  @override
  ExtendedImageSlidePageHandlerState createState() =>
      ExtendedImageSlidePageHandlerState();
}

class ExtendedImageSlidePageHandlerState
    extends State<ExtendedImageSlidePageHandler> {
  Offset _startingOffset;
  @override
  Widget build(BuildContext context) {
    Widget result = GestureDetector(
      onScaleStart: _handleScaleStart,
      onScaleUpdate: _handleScaleUpdate,
      onScaleEnd: _handleScaleEnd,
      child: widget.child,
      behavior: HitTestBehavior.translucent,
    );

    if (widget.extendedImageSlidePageState != null &&
        widget.extendedImageSlidePageState.widget.slideType ==
            SlideType.onlyImage) {
      var extendedImageSlidePageState = widget.extendedImageSlidePageState;
      result = Transform.translate(
        offset: extendedImageSlidePageState.offset,
        child: Transform.scale(
          scale: extendedImageSlidePageState.scale,
          child: result,
        ),
      );
    }
    return result;
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _startingOffset = details.focalPoint;
  }

  Offset _updatePageGestureStartingOffset;
  void _handleScaleUpdate(ScaleUpdateDetails details) {
    ///whether gesture page
    if (widget.extendedImageSlidePageState != null && details.scale == 1.0) {
      //var offsetDelta = (details.focalPoint - _startingOffset);

      var delta = (details.focalPoint - _startingOffset).distance;

      if (delta > minGesturePageDelta) {
        _updatePageGestureStartingOffset ??= details.focalPoint;
        widget.extendedImageSlidePageState.slide(
            details.focalPoint - _updatePageGestureStartingOffset,
            extendedImageSlidePageHandlerState: this);
      }
    }
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    if (widget.extendedImageSlidePageState != null &&
        widget.extendedImageSlidePageState.isSliding) {
      _updatePageGestureStartingOffset = null;
      widget.extendedImageSlidePageState.endSlide();
      return;
    }
  }

  void slide() {
    if (mounted) {
      setState(() {});
    }
  }
}
