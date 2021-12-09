// ignore_for_file: deprecated_member_use_from_same_package, unnecessary_null_comparison, deprecated_member_use, always_put_control_body_on_new_line

import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';

import 'velocity_tracker.dart';

typedef CanHorizontalOrVerticalDrag = bool Function();

/// Recognizes movement in the horizontal direction.
///
/// Used for horizontal scrolling.
///
/// See also:
///
///  * [ExtendedVerticalDragGestureRecognizer], for a similar recognizer but for
///    vertical movement.
///  * [MultiDragGestureRecognizer], for a family of gesture recognizers that
///    track each touch point independently.
class ExtendedHorizontalDragGestureRecognizer
    extends ExtendedDragGestureRecognizer {
  /// Create a gesture recognizer for interactions in the horizontal axis.
  ///
  /// {@macro flutter.gestures.GestureRecognizer.supportedDevices}
  ExtendedHorizontalDragGestureRecognizer(
      {Object? debugOwner,
      @Deprecated(
        'Migrate to supportedDevices. '
        'This feature was deprecated after v2.3.0-1.0.pre.',
      )
          PointerDeviceKind? kind,
      Set<PointerDeviceKind>? supportedDevices,
      CanHorizontalOrVerticalDrag? canHorizontalOrVerticalDrag})
      : super(
          debugOwner: debugOwner,
          kind: kind,
          supportedDevices: supportedDevices,
          canHorizontalOrVerticalDrag: canHorizontalOrVerticalDrag,
        );

  @override
  bool isFlingGesture(VelocityEstimate estimate, PointerDeviceKind kind) {
    final double minVelocity = minFlingVelocity ?? kMinFlingVelocity;
    final double minDistance = minFlingDistance ?? computeHitSlop(kind, null);
    return estimate.pixelsPerSecond.dx.abs() > minVelocity &&
        estimate.offset.dx.abs() > minDistance;
  }

  @override
  bool _hasSufficientGlobalDistanceToAccept(
      PointerDeviceKind pointerDeviceKind) {
    return _globalDistanceMoved.abs() > computeHitSlop(pointerDeviceKind, null);
  }

  @override
  Offset _getDeltaForDetails(Offset delta) => Offset(delta.dx, 0.0);

  @override
  double _getPrimaryValueFromOffset(Offset value) => value.dx;

  @override
  String get debugDescription => 'horizontal drag';
}

/// Recognizes movement in the vertical direction.
///
/// Used for vertical scrolling.
///
/// See also:
///
///  * [HorizontalDragGestureRecognizer], for a similar recognizer but for
///    horizontal movement.
///  * [MultiDragGestureRecognizer], for a family of gesture recognizers that
///    track each touch point independently.
class ExtendedVerticalDragGestureRecognizer
    extends ExtendedDragGestureRecognizer {
  /// Create a gesture recognizer for interactions in the vertical axis.
  ///
  /// {@macro flutter.gestures.GestureRecognizer.supportedDevices}
  ExtendedVerticalDragGestureRecognizer(
      {Object? debugOwner,
      @Deprecated(
        'Migrate to supportedDevices. '
        'This feature was deprecated after v2.3.0-1.0.pre.',
      )
          PointerDeviceKind? kind,
      Set<PointerDeviceKind>? supportedDevices,
      CanHorizontalOrVerticalDrag? canHorizontalOrVerticalDrag})
      : super(
          debugOwner: debugOwner,
          kind: kind,
          supportedDevices: supportedDevices,
          canHorizontalOrVerticalDrag: canHorizontalOrVerticalDrag,
        );

  @override
  bool isFlingGesture(VelocityEstimate estimate, PointerDeviceKind kind) {
    final double minVelocity = minFlingVelocity ?? kMinFlingVelocity;
    final double minDistance = minFlingDistance ?? computeHitSlop(kind, null);
    return estimate.pixelsPerSecond.dy.abs() > minVelocity &&
        estimate.offset.dy.abs() > minDistance;
  }

  @override
  bool _hasSufficientGlobalDistanceToAccept(
      PointerDeviceKind pointerDeviceKind) {
    return _globalDistanceMoved.abs() > computeHitSlop(pointerDeviceKind, null);
  }

  @override
  Offset _getDeltaForDetails(Offset delta) => Offset(0.0, delta.dy);

  @override
  double _getPrimaryValueFromOffset(Offset value) => value.dy;

  @override
  String get debugDescription => 'vertical drag';
}

/// Recognizes movement.
///
/// In contrast to [MultiDragGestureRecognizer], [ExtendedDragGestureRecognizer]
/// recognizes a single gesture sequence for all the pointers it watches, which
/// means that the recognizer has at most one drag sequence active at any given
/// time regardless of how many pointers are in contact with the screen.
///
/// [ExtendedDragGestureRecognizer] is not intended to be used directly. Instead,
/// consider using one of its subclasses to recognize specific types for drag
/// gestures.
///
/// [ExtendedDragGestureRecognizer] competes on pointer events of [kPrimaryButton]
/// only when it has at least one non-null callback. If it has no callbacks, it
/// is a no-op.
///
/// See also:
///
///  * [ExtendedHorizontalDragGestureRecognizer], for left and right drags.
///  * [ExtendedVerticalDragGestureRecognizer], for up and down drags.
///  * [PanGestureRecognizer], for drags that are not locked to a single axis.
abstract class ExtendedDragGestureRecognizer
    extends OneSequenceGestureRecognizer {
  /// Initialize the object.
  ///
  /// [dragStartBehavior] must not be null.
  ///
  /// {@macro flutter.gestures.GestureRecognizer.supportedDevices}
  ExtendedDragGestureRecognizer({
    Object? debugOwner,
    @Deprecated(
      'Migrate to supportedDevices. '
      'This feature was deprecated after v2.3.0-1.0.pre.',
    )
        PointerDeviceKind? kind,
    this.dragStartBehavior = DragStartBehavior.start,
    this.velocityTrackerBuilder = _defaultBuilder,
    Set<PointerDeviceKind>? supportedDevices,
    this.canHorizontalOrVerticalDrag,
  })  : assert(dragStartBehavior != null),
        super(
          debugOwner: debugOwner,
          kind: kind,
          supportedDevices: supportedDevices,
        );

  final CanHorizontalOrVerticalDrag? canHorizontalOrVerticalDrag;

  static ExtendedVelocityTracker _defaultBuilder(PointerEvent event) =>
      ExtendedVelocityTracker.withKind(event.kind);

  /// Configure the behavior of offsets passed to [onStart].
  ///
  /// If set to [DragStartBehavior.start], the [onStart] callback will be called
  /// with the position of the pointer at the time this gesture recognizer won
  /// the arena. If [DragStartBehavior.down], [onStart] will be called with
  /// the position of the first detected down event for the pointer. When there
  /// are no other gestures competing with this gesture in the arena, there's
  /// no difference in behavior between the two settings.
  ///
  /// For more information about the gesture arena:
  /// https://flutter.dev/docs/development/ui/advanced/gestures#gesture-disambiguation
  ///
  /// By default, the drag start behavior is [DragStartBehavior.start].
  ///
  /// ## Example:
  ///
  /// A [ExtendedHorizontalDragGestureRecognizer] and a [ExtendedVerticalDragGestureRecognizer]
  /// compete with each other. A finger presses down on the screen with
  /// offset (500.0, 500.0), and then moves to position (510.0, 500.0) before
  /// the [ExtendedHorizontalDragGestureRecognizer] wins the arena. With
  /// [dragStartBehavior] set to [DragStartBehavior.down], the [onStart]
  /// callback will be called with position (500.0, 500.0). If it is
  /// instead set to [DragStartBehavior.start], [onStart] will be called with
  /// position (510.0, 500.0).
  DragStartBehavior dragStartBehavior;

  /// A pointer has contacted the screen with a primary button and might begin
  /// to move.
  ///
  /// The position of the pointer is provided in the callback's `details`
  /// argument, which is a [DragDownDetails] object.
  ///
  /// See also:
  ///
  ///  * [kPrimaryButton], the button this callback responds to.
  ///  * [DragDownDetails], which is passed as an argument to this callback.
  GestureDragDownCallback? onDown;

  /// A pointer has contacted the screen with a primary button and has begun to
  /// move.
  ///
  /// The position of the pointer is provided in the callback's `details`
  /// argument, which is a [DragStartDetails] object. The [dragStartBehavior]
  /// determines this position.
  ///
  /// See also:
  ///
  ///  * [kPrimaryButton], the button this callback responds to.
  ///  * [DragStartDetails], which is passed as an argument to this callback.
  GestureDragStartCallback? onStart;

  /// A pointer that is in contact with the screen with a primary button and
  /// moving has moved again.
  ///
  /// The distance traveled by the pointer since the last update is provided in
  /// the callback's `details` argument, which is a [DragUpdateDetails] object.
  ///
  /// See also:
  ///
  ///  * [kPrimaryButton], the button this callback responds to.
  ///  * [DragUpdateDetails], which is passed as an argument to this callback.
  GestureDragUpdateCallback? onUpdate;

  /// A pointer that was previously in contact with the screen with a primary
  /// button and moving is no longer in contact with the screen and was moving
  /// at a specific velocity when it stopped contacting the screen.
  ///
  /// The velocity is provided in the callback's `details` argument, which is a
  /// [DragEndDetails] object.
  ///
  /// See also:
  ///
  ///  * [kPrimaryButton], the button this callback responds to.
  ///  * [DragEndDetails], which is passed as an argument to this callback.
  GestureDragEndCallback? onEnd;

  /// The pointer that previously triggered [onDown] did not complete.
  ///
  /// See also:
  ///
  ///  * [kPrimaryButton], the button this callback responds to.
  GestureDragCancelCallback? onCancel;

  /// The minimum distance an input pointer drag must have moved to
  /// to be considered a fling gesture.
  ///
  /// This value is typically compared with the distance traveled along the
  /// scrolling axis. If null then [kTouchSlop] is used.
  double? minFlingDistance;

  /// The minimum velocity for an input pointer drag to be considered fling.
  ///
  /// This value is typically compared with the magnitude of fling gesture's
  /// velocity along the scrolling axis. If null then [kMinFlingVelocity]
  /// is used.
  double? minFlingVelocity;

  /// Fling velocity magnitudes will be clamped to this value.
  ///
  /// If null then [kMaxFlingVelocity] is used.
  double? maxFlingVelocity;

  /// Determines the type of velocity estimation method to use for a potential
  /// drag gesture, when a new pointer is added.
  ///
  /// To estimate the velocity of a gesture, [ExtendedDragGestureRecognizer] calls
  /// [velocityTrackerBuilder] when it starts to track a new pointer in
  /// [addAllowedPointer], and add subsequent updates on the pointer to the
  /// resulting velocity tracker, until the gesture recognizer stops tracking
  /// the pointer. This allows you to specify a different velocity estimation
  /// strategy for each allowed pointer added, by changing the type of velocity
  /// tracker this [GestureVelocityTrackerBuilder] returns.
  ///
  /// If left unspecified the default [velocityTrackerBuilder] creates a new
  /// [VelocityTracker] for every pointer added.
  ///
  /// See also:
  ///
  ///  * [VelocityTracker], a velocity tracker that uses least squares estimation
  ///    on the 20 most recent pointer data samples. It's a well-rounded velocity
  ///    tracker and is used by default.
  ///  * [IOSScrollViewFlingVelocityTracker], a specialized velocity tracker for
  ///    determining the initial fling velocity for a [Scrollable] on iOS, to
  ///    match the native behavior on that platform.
  GestureVelocityTrackerBuilder velocityTrackerBuilder;

  _DragState _state = _DragState.ready;
  late OffsetPair _initialPosition;
  late OffsetPair _pendingDragOffset;
  Duration? _lastPendingEventTimestamp;
  // The buttons sent by `PointerDownEvent`. If a `PointerMoveEvent` comes with a
  // different set of buttons, the gesture is canceled.
  int? _initialButtons;
  Matrix4? _lastTransform;

  /// Distance moved in the global coordinate space of the screen in drag direction.
  ///
  /// If drag is only allowed along a defined axis, this value may be negative to
  /// differentiate the direction of the drag.
  late double _globalDistanceMoved;

  /// Determines if a gesture is a fling or not based on velocity.
  ///
  /// A fling calls its gesture end callback with a velocity, allowing the
  /// provider of the callback to respond by carrying the gesture forward with
  /// inertia, for example.
  bool isFlingGesture(VelocityEstimate estimate, PointerDeviceKind kind);

  Offset _getDeltaForDetails(Offset delta);
  double? _getPrimaryValueFromOffset(Offset value);
  bool _hasSufficientGlobalDistanceToAccept(
      PointerDeviceKind pointerDeviceKind);

  final Map<int, VelocityTracker> _velocityTrackers = <int, VelocityTracker>{};

  @override
  bool isPointerAllowed(PointerEvent event) {
    if (_initialButtons == null) {
      switch (event.buttons) {
        case kPrimaryButton:
          if (onDown == null &&
              onStart == null &&
              onUpdate == null &&
              onEnd == null &&
              onCancel == null) return false;
          break;
        default:
          return false;
      }
    } else {
      // There can be multiple drags simultaneously. Their effects are combined.
      if (event.buttons != _initialButtons) {
        return false;
      }
    }
    return super.isPointerAllowed(event as PointerDownEvent);
  }

  @override
  void addAllowedPointer(PointerDownEvent event) {
    super.addAllowedPointer(event);
    _velocityTrackers[event.pointer] = velocityTrackerBuilder(event);
    if (_state == _DragState.ready) {
      _state = _DragState.possible;
      _initialPosition =
          OffsetPair(global: event.position, local: event.localPosition);
      _initialButtons = event.buttons;
      _pendingDragOffset = OffsetPair.zero;
      _globalDistanceMoved = 0.0;
      _lastPendingEventTimestamp = event.timeStamp;
      _lastTransform = event.transform;
      _checkDown();
    } else if (_state == _DragState.accepted) {
      resolve(GestureDisposition.accepted);
    }
  }

  @override
  void handleEvent(PointerEvent event) {
    assert(_state != _DragState.ready);
    if (!event.synthesized &&
        (event is PointerDownEvent || event is PointerMoveEvent)) {
      final VelocityTracker tracker = _velocityTrackers[event.pointer]!;
      assert(tracker != null);
      tracker.addPosition(event.timeStamp, event.localPosition);
    }

    if (event is PointerMoveEvent) {
      if (event.buttons != _initialButtons) {
        _giveUpPointer(event.pointer);
        return;
      }
      if (_state == _DragState.accepted) {
        _checkUpdate(
          sourceTimeStamp: event.timeStamp,
          delta: _getDeltaForDetails(event.localDelta),
          primaryDelta: _getPrimaryValueFromOffset(event.localDelta),
          globalPosition: event.position,
          localPosition: event.localPosition,
        );
      } else {
        _pendingDragOffset +=
            OffsetPair(local: event.localDelta, global: event.delta);
        _lastPendingEventTimestamp = event.timeStamp;
        _lastTransform = event.transform;
        final Offset movedLocally = _getDeltaForDetails(event.localDelta);
        final Matrix4? localToGlobalTransform = event.transform == null
            ? null
            : Matrix4.tryInvert(event.transform!);
        _globalDistanceMoved += PointerEvent.transformDeltaViaPositions(
              transform: localToGlobalTransform,
              untransformedDelta: movedLocally,
              untransformedEndPosition: event.localPosition,
            ).distance *
            (_getPrimaryValueFromOffset(movedLocally) ?? 1).sign;
        if (_hasSufficientGlobalDistanceToAccept(event.kind) && _shouldAccpet())
          resolve(GestureDisposition.accepted);
      }
    }
    if (event is PointerUpEvent || event is PointerCancelEvent) {
      _giveUpPointer(event.pointer);
    }
  }

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
      final Offset delta =
          (tracker as ExtendedVelocityTracker).getSamplesDelta();
      offset = Offset(offset.dx * (delta.dx == 0 ? 1 : delta.dx),
          offset.dy * (delta.dy == 0 ? 1 : delta.dy));
    }

    return !(offset.dx < 0 || offset.dy < 0);
  }

  final Set<int> _acceptedActivePointers = <int>{};

  @override
  void acceptGesture(int pointer) {
    assert(!_acceptedActivePointers.contains(pointer));
    _acceptedActivePointers.add(pointer);
    if (_state != _DragState.accepted) {
      _state = _DragState.accepted;
      final OffsetPair delta = _pendingDragOffset;
      final Duration timestamp = _lastPendingEventTimestamp!;
      final Matrix4? transform = _lastTransform;
      final Offset localUpdateDelta;
      switch (dragStartBehavior) {
        case DragStartBehavior.start:
          _initialPosition = _initialPosition + delta;
          localUpdateDelta = Offset.zero;
          break;
        case DragStartBehavior.down:
          localUpdateDelta = _getDeltaForDetails(delta.local);
          break;
      }
      _pendingDragOffset = OffsetPair.zero;
      _lastPendingEventTimestamp = null;
      _lastTransform = null;
      _checkStart(timestamp, pointer);
      if (localUpdateDelta != Offset.zero && onUpdate != null) {
        final Matrix4? localToGlobal =
            transform != null ? Matrix4.tryInvert(transform) : null;
        final Offset correctedLocalPosition =
            _initialPosition.local + localUpdateDelta;
        final Offset globalUpdateDelta =
            PointerEvent.transformDeltaViaPositions(
          untransformedEndPosition: correctedLocalPosition,
          untransformedDelta: localUpdateDelta,
          transform: localToGlobal,
        );
        final OffsetPair updateDelta =
            OffsetPair(local: localUpdateDelta, global: globalUpdateDelta);
        final OffsetPair correctedPosition = _initialPosition +
            updateDelta; // Only adds delta for down behaviour
        _checkUpdate(
          sourceTimeStamp: timestamp,
          delta: localUpdateDelta,
          primaryDelta: _getPrimaryValueFromOffset(localUpdateDelta),
          globalPosition: correctedPosition.global,
          localPosition: correctedPosition.local,
        );
      }
      // This acceptGesture might have been called only for one pointer, instead
      // of all pointers. Resolve all pointers to `accepted`. This won't cause
      // infinite recursion because an accepted pointer won't be accepted again.
      resolve(GestureDisposition.accepted);
    }
  }

  @override
  void rejectGesture(int pointer) {
    _giveUpPointer(pointer);
  }

  @override
  void didStopTrackingLastPointer(int pointer) {
    assert(_state != _DragState.ready);
    switch (_state) {
      case _DragState.ready:
        break;

      case _DragState.possible:
        resolve(GestureDisposition.rejected);
        _checkCancel();
        break;

      case _DragState.accepted:
        _checkEnd(pointer);
        break;
    }
    _velocityTrackers.clear();
    _initialButtons = null;
    _state = _DragState.ready;
  }

  void _giveUpPointer(int pointer) {
    stopTrackingPointer(pointer);
    // If we never accepted the pointer, we reject it since we are no longer
    // interested in winning the gesture arena for it.
    if (!_acceptedActivePointers.remove(pointer))
      resolvePointer(pointer, GestureDisposition.rejected);
  }

  void _checkDown() {
    assert(_initialButtons == kPrimaryButton);
    if (onDown != null) {
      final DragDownDetails details = DragDownDetails(
        globalPosition: _initialPosition.global,
        localPosition: _initialPosition.local,
      );
      invokeCallback<void>('onDown', () => onDown!(details));
    }
  }

  void _checkStart(Duration timestamp, int pointer) {
    assert(_initialButtons == kPrimaryButton);
    if (onStart != null) {
      final DragStartDetails details = DragStartDetails(
        sourceTimeStamp: timestamp,
        globalPosition: _initialPosition.global,
        localPosition: _initialPosition.local,
        kind: getKindForPointer(pointer),
      );
      invokeCallback<void>('onStart', () => onStart!(details));
    }
  }

  void _checkUpdate({
    Duration? sourceTimeStamp,
    required Offset delta,
    double? primaryDelta,
    required Offset globalPosition,
    Offset? localPosition,
  }) {
    assert(_initialButtons == kPrimaryButton);
    if (onUpdate != null) {
      final DragUpdateDetails details = DragUpdateDetails(
        sourceTimeStamp: sourceTimeStamp,
        delta: delta,
        primaryDelta: primaryDelta,
        globalPosition: globalPosition,
        localPosition: localPosition,
      );
      invokeCallback<void>('onUpdate', () => onUpdate!(details));
    }
  }

  void _checkEnd(int pointer) {
    assert(_initialButtons == kPrimaryButton);
    if (onEnd == null) return;

    final VelocityTracker tracker = _velocityTrackers[pointer]!;
    assert(tracker != null);

    final DragEndDetails details;
    final String Function() debugReport;

    final VelocityEstimate? estimate = tracker.getVelocityEstimate();
    if (estimate != null && isFlingGesture(estimate, tracker.kind)) {
      final Velocity velocity =
          Velocity(pixelsPerSecond: estimate.pixelsPerSecond).clampMagnitude(
              minFlingVelocity ?? kMinFlingVelocity,
              maxFlingVelocity ?? kMaxFlingVelocity);
      details = DragEndDetails(
        velocity: velocity,
        primaryVelocity: _getPrimaryValueFromOffset(velocity.pixelsPerSecond),
      );
      debugReport = () {
        return '$estimate; fling at $velocity.';
      };
    } else {
      details = DragEndDetails(
        velocity: Velocity.zero,
        primaryVelocity: 0.0,
      );
      debugReport = () {
        if (estimate == null) return 'Could not estimate velocity.';
        return '$estimate; judged to not be a fling.';
      };
    }
    invokeCallback<void>('onEnd', () => onEnd!(details),
        debugReport: debugReport);
  }

  void _checkCancel() {
    assert(_initialButtons == kPrimaryButton);
    if (onCancel != null) invokeCallback<void>('onCancel', onCancel!);
  }

  @override
  void dispose() {
    _velocityTrackers.clear();
    super.dispose();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
        EnumProperty<DragStartBehavior>('start behavior', dragStartBehavior));
  }
}

enum _DragState {
  ready,
  possible,
  accepted,
}
