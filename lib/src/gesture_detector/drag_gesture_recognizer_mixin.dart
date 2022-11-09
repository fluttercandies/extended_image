part of 'drag.dart';

typedef CanHorizontalOrVerticalDrag = bool Function();
mixin DragGestureRecognizerMixin {
  bool get canDrag =>
      canHorizontalOrVerticalDrag == null || canHorizontalOrVerticalDrag!();
  Map<int, VelocityTracker> get _velocityTrackers;

  bool _shouldAccpet() {
    if (!canDrag) {
      return false;
    }
    if (_velocityTrackers.keys.length == 1) {
      return true;
    }

    // if pointers are not the only, check whether they are in the negative
    // maybe this is a Horizontal/Vertical zoom
    Offset offset = const Offset(1, 1);
    for (final VelocityTracker tracker in _velocityTrackers.values) {
      if (tracker is ExtendedVelocityTracker) {
        final Offset delta = tracker.getSamplesDelta();
        offset = Offset(offset.dx * (delta.dx == 0 ? 1 : delta.dx),
            offset.dy * (delta.dy == 0 ? 1 : delta.dy));
      }
    }

    return !(offset.dx < 0 || offset.dy < 0);
  }

  CanHorizontalOrVerticalDrag? get canHorizontalOrVerticalDrag;
}
