import 'package:flutter/widgets.dart';

class ExtendedHoldScrollActivity extends HoldScrollActivity {
  ExtendedHoldScrollActivity({
    required ScrollActivityDelegate delegate,
    VoidCallback? onHoldCanceled,
    required this.shouldIgnorePointer,
  }) : super(
          delegate: delegate,
          onHoldCanceled: onHoldCanceled,
        );
  @override
  final bool shouldIgnorePointer;
}

class ExtendedDragScrollActivity extends DragScrollActivity {
  ExtendedDragScrollActivity(
    ScrollActivityDelegate delegate,
    ScrollDragController controller,
    this.shouldIgnorePointer,
  ) : super(
          delegate,
          controller,
        );
  @override
  final bool shouldIgnorePointer;
}

class ExtendedDrivenScrollActivity extends DrivenScrollActivity {
  ExtendedDrivenScrollActivity(
    ScrollActivityDelegate delegate, {
    required double from,
    required double to,
    required Duration duration,
    required Curve curve,
    required TickerProvider vsync,
    required this.shouldIgnorePointer,
  }) : super(
          delegate,
          from: from,
          to: to,
          duration: duration,
          curve: curve,
          vsync: vsync,
        );
  @override
  final bool shouldIgnorePointer;
}

class ExtendedBallisticScrollActivity extends BallisticScrollActivity {
  ExtendedBallisticScrollActivity(
    ScrollActivityDelegate delegate,
    Simulation simulation,
    TickerProvider vsync,
    this.shouldIgnorePointer,
  ) : super(
          delegate,
          simulation,
          vsync,
        );
  @override
  final bool shouldIgnorePointer;
}
