part of 'official.dart';

typedef CanHorizontalOrVerticalDrag = bool Function();

mixin DragGestureRecognizerMixin on _DragGestureRecognizer {
  bool get canDrag =>
      canHorizontalOrVerticalDrag == null || canHorizontalOrVerticalDrag!();

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

  @override
  void handleEvent(PointerEvent event) {
    assert(_state != _DragState.ready);
    if (!event.synthesized &&
        (event is PointerDownEvent ||
            event is PointerMoveEvent ||
            event is PointerPanZoomStartEvent ||
            event is PointerPanZoomUpdateEvent)) {
      final VelocityTracker tracker = _velocityTrackers[event.pointer]!;
      if (event is PointerPanZoomStartEvent) {
        tracker.addPosition(event.timeStamp, Offset.zero);
      } else if (event is PointerPanZoomUpdateEvent) {
        tracker.addPosition(event.timeStamp, event.pan);
      } else {
        tracker.addPosition(event.timeStamp, event.localPosition);
      }
    }
    if (event is PointerMoveEvent && event.buttons != _initialButtons) {
      _giveUpPointer(event.pointer);
      return;
    }
    if (event is PointerMoveEvent || event is PointerPanZoomUpdateEvent) {
      final Offset delta = (event is PointerMoveEvent)
          ? event.delta
          : (event as PointerPanZoomUpdateEvent).panDelta;
      final Offset localDelta = (event is PointerMoveEvent)
          ? event.localDelta
          : (event as PointerPanZoomUpdateEvent).localPanDelta;
      final Offset position = (event is PointerMoveEvent)
          ? event.position
          : (event.position + (event as PointerPanZoomUpdateEvent).pan);
      final Offset localPosition = (event is PointerMoveEvent)
          ? event.localPosition
          : (event.localPosition +
              (event as PointerPanZoomUpdateEvent).localPan);
      if (_state == _DragState.accepted) {
        _checkUpdate(
          sourceTimeStamp: event.timeStamp,
          delta: _getDeltaForDetails(localDelta),
          primaryDelta: _getPrimaryValueFromOffset(localDelta),
          globalPosition: position,
          localPosition: localPosition,
        );
      } else {
        _pendingDragOffset += OffsetPair(local: localDelta, global: delta);
        _lastPendingEventTimestamp = event.timeStamp;
        _lastTransform = event.transform;
        final Offset movedLocally = _getDeltaForDetails(localDelta);
        final Matrix4? localToGlobalTransform = event.transform == null
            ? null
            : Matrix4.tryInvert(event.transform!);
        _globalDistanceMoved += PointerEvent.transformDeltaViaPositions(
                    transform: localToGlobalTransform,
                    untransformedDelta: movedLocally,
                    untransformedEndPosition: localPosition)
                .distance *
            (_getPrimaryValueFromOffset(movedLocally) ?? 1).sign;
        if (_hasSufficientGlobalDistanceToAccept(
                event.kind, gestureSettings?.touchSlop) &&
            // zmtzawqlp
            _shouldAccpet()) {
          _hasDragThresholdBeenMet = true;
          if (_acceptedActivePointers.contains(event.pointer)) {
            _checkDrag(event.pointer);
          } else {
            resolve(GestureDisposition.accepted);
          }
        }
      }
    }
    if (event is PointerUpEvent ||
        event is PointerCancelEvent ||
        event is PointerPanZoomEndEvent) {
      _giveUpPointer(event.pointer);
    }
  }
}

abstract class ExtendedDragGestureRecognizer extends _DragGestureRecognizer
    with DragGestureRecognizerMixin {
  ExtendedDragGestureRecognizer({
    super.debugOwner,
    super.dragStartBehavior = DragStartBehavior.start,
    super.velocityTrackerBuilder = _defaultBuilder,
    super.supportedDevices,
    super.allowedButtonsFilter,
    this.canHorizontalOrVerticalDrag,
  });

  static ExtendedVelocityTracker _defaultBuilder(PointerEvent event) =>
      ExtendedVelocityTracker.withKind(event.kind);
  @override
  final CanHorizontalOrVerticalDrag? canHorizontalOrVerticalDrag;
}

class ExtendedHorizontalDragGestureRecognizer
    extends _HorizontalDragGestureRecognizer with DragGestureRecognizerMixin {
  ExtendedHorizontalDragGestureRecognizer({
    super.debugOwner,
    super.supportedDevices,
    super.allowedButtonsFilter,
    this.canHorizontalOrVerticalDrag,
  });

  @override
  final CanHorizontalOrVerticalDrag? canHorizontalOrVerticalDrag;
}

class ExtendedVerticalDragGestureRecognizer
    extends _VerticalDragGestureRecognizer with DragGestureRecognizerMixin {
  ExtendedVerticalDragGestureRecognizer({
    super.debugOwner,
    super.supportedDevices,
    super.allowedButtonsFilter,
    this.canHorizontalOrVerticalDrag,
  });

  @override
  final CanHorizontalOrVerticalDrag? canHorizontalOrVerticalDrag;
}
