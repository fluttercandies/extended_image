part of 'official.dart';

typedef CanHorizontalOrVerticalDrag = bool Function();

mixin DragGestureRecognizerMixin on _DragGestureRecognizer {
  bool get canDrag =>
      canHorizontalOrVerticalDrag == null || canHorizontalOrVerticalDrag!();

  bool _shouldAccept() {
    // If dragging is not allowed, return false immediately
    if (!canDrag) {
      return false;
    }

    // Get the number of current touch points
    int pointerCount = _velocityTrackers.keys.length;

    // If there's only one touch point, allow dragging
    if (pointerCount == 1) {
      return true;
    }

    // For multiple touch points, check if it's a zooming operation
    return !_isZoomingOrOppositeMovement();
  }

// Check if it's a zooming operation or if there's movement in opposite directions
  bool _isZoomingOrOppositeMovement() {
    List<Offset> deltas = _velocityTrackers.values
        .whereType<ExtendedVelocityTracker>()
        .map((tracker) => tracker.getSamplesDelta())
        .toList();

    // Check for opposite directions in x or y axis
    for (int i = 0; i < deltas.length - 1; i++) {
      for (int j = i + 1; j < deltas.length; j++) {
        if (deltas[i].dx * deltas[j].dx < 0 ||
            deltas[i].dy * deltas[j].dy < 0) {
          return true; // Found opposite directions, likely zooming
        }
      }
    }

    // Check if all movements are in the same direction
    Offset combinedOffset = deltas.fold(
      Offset.zero,
      (prev, delta) => Offset(
        prev.dx * (delta.dx == 0 ? 1 : delta.dx),
        prev.dy * (delta.dy == 0 ? 1 : delta.dy),
      ),
    );

    // If combinedOffset's x or y is less than 0, it means there's movement in opposite directions
    return combinedOffset.dx < 0 || combinedOffset.dy < 0;
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
            _shouldAccept()) {
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
