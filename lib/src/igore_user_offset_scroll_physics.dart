import 'package:flutter/material.dart';

///igore user offset
///scroll will handle by image gesture
///do this to avoid gesture conflict in pageview
class IgoreUserOffsetScrollPhysics extends PageScrollPhysics {
  const IgoreUserOffsetScrollPhysics({ScrollPhysics parent})
      : super(parent: parent);

  ///igore user offset
  @override
  bool shouldAcceptUserOffset(ScrollMetrics position) {
    return false;
    // TODO: implement shouldAcceptUserOffset
    //return super.shouldAcceptUserOffset(position);
  }

  @override
  PageScrollPhysics applyTo(ScrollPhysics ancestor) {
    // TODO: implement applyTo
    return IgoreUserOffsetScrollPhysics(parent: ancestor);
    //return super.applyTo(ancestor);
  }
}
