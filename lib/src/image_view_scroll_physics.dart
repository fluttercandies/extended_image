import 'package:flutter/material.dart';

class ImageViewScrollPhysics extends PageScrollPhysics {
  @override
  bool shouldAcceptUserOffset(ScrollMetrics position) {
    return false;
    // TODO: implement shouldAcceptUserOffset
    //return super.shouldAcceptUserOffset(position);
  }

  @override
  PageScrollPhysics applyTo(ScrollPhysics ancestor) {
    // TODO: implement applyTo
    return ImageViewScrollPhysics();
    //return super.applyTo(ancestor);
  }
}
