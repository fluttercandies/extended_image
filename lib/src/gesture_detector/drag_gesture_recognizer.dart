part of 'official.dart';

typedef CanHorizontalOrVerticalDrag = bool Function();

typedef ShouldAccpetHorizontalOrVerticalDrag =
    bool Function(Map<int, VelocityTracker> velocityTrackers);

mixin DragGestureRecognizerMixin on _DragGestureRecognizer {
  bool get canDrag =>
      canHorizontalOrVerticalDrag == null || canHorizontalOrVerticalDrag!();

  bool _shouldAccpet() {
    if (!canDrag) {
      return false;
    }
    if (shouldAccpetHorizontalOrVerticalDrag != null) {
      return shouldAccpetHorizontalOrVerticalDrag!(_velocityTrackers);
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
        offset = Offset(
          offset.dx * (delta.dx == 0 ? 1 : delta.dx),
          offset.dy * (delta.dy == 0 ? 1 : delta.dy),
        );
      }
    }

    return !(offset.dx < 0 || offset.dy < 0);
  }

  CanHorizontalOrVerticalDrag? get canHorizontalOrVerticalDrag;
  ShouldAccpetHorizontalOrVerticalDrag?
  get shouldAccpetHorizontalOrVerticalDrag;

  @override
  bool hasSufficientGlobalDistanceToAccept(
    PointerDeviceKind pointerDeviceKind,
    double? deviceTouchSlop,
  ) {
    return super.hasSufficientGlobalDistanceToAccept(
          pointerDeviceKind,
          deviceTouchSlop,
        ) &&
        // zmtzawqlp
        _shouldAccpet();
  }

  @override
  GestureVelocityTrackerBuilder get velocityTrackerBuilder => _defaultBuilder;
}

ExtendedVelocityTracker _defaultBuilder(PointerEvent event) =>
    ExtendedVelocityTracker.withKind(event.kind);

/// [HorizontalDragGestureRecognizer]
class ExtendedHorizontalDragGestureRecognizer
    extends _HorizontalDragGestureRecognizer
    with DragGestureRecognizerMixin {
  ExtendedHorizontalDragGestureRecognizer({
    super.debugOwner,
    super.supportedDevices,
    super.allowedButtonsFilter,
    this.canHorizontalOrVerticalDrag,
    this.shouldAccpetHorizontalOrVerticalDrag,
  });

  @override
  final CanHorizontalOrVerticalDrag? canHorizontalOrVerticalDrag;

  @override
  final ShouldAccpetHorizontalOrVerticalDrag?
  shouldAccpetHorizontalOrVerticalDrag;
}

class ExtendedVerticalDragGestureRecognizer
    extends _VerticalDragGestureRecognizer
    with DragGestureRecognizerMixin {
  ExtendedVerticalDragGestureRecognizer({
    super.debugOwner,
    super.supportedDevices,
    super.allowedButtonsFilter,
    this.canHorizontalOrVerticalDrag,
    this.shouldAccpetHorizontalOrVerticalDrag,
  });

  @override
  final CanHorizontalOrVerticalDrag? canHorizontalOrVerticalDrag;
  @override
  final ShouldAccpetHorizontalOrVerticalDrag?
  shouldAccpetHorizontalOrVerticalDrag;
}
