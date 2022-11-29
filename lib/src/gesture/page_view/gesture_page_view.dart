import 'package:extended_image/extended_image.dart';
import 'package:extended_image/src/gesture_detector/drag.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

export 'rendering/sliver_fill.dart';
export 'widgets/page_controller.dart';
export 'widgets/sliver_fill.dart';

part 'widgets/page_view.dart';

///
///  extended_image_view.dart
///  create by zmtzawqlp on 2019/4/3
///
final ExtendedPageController _defaultPageController = ExtendedPageController();
const PageScrollPhysics _kPagePhysics = PageScrollPhysics();
const ScrollPhysics _defaultScrollPhysics = NeverScrollableScrollPhysics();

final PageMetrics _testPageMetrics = PageMetrics(
  axisDirection: AxisDirection.down,
  minScrollExtent: 0,
  maxScrollExtent: 10,
  pixels: 5,
  viewportDimension: 10,
  viewportFraction: 1.0,
);

/// whether should scoll page
bool _defaultCanScrollPage(GestureDetails? gestureDetails) => true;

///page view to support gesture for image
class ExtendedImageGesturePageView extends StatefulWidget {
  ExtendedImageGesturePageView({
    Key? key,
    this.scrollDirection = Axis.horizontal,
    this.reverse = false,
    ExtendedPageController? controller,
    ScrollPhysics? physics,
    this.pageSnapping = true,
    this.onPageChanged,
    List<Widget> children = const <Widget>[],
    CanScrollPage? canScrollPage,
    this.preloadPagesCount = 0,
  })  : controller = controller ?? _defaultPageController,
        childrenDelegate = SliverChildListDelegate(children),
        physics = physics != null
            ? _defaultScrollPhysics.applyTo(physics)
            : _defaultScrollPhysics,
        canScrollPage = canScrollPage ?? _defaultCanScrollPage,
        super(key: key);

  /// Creates a scrollable list that works page by page using widgets that are
  /// created on demand.
  ///
  /// This constructor is appropriate for page views with a large (or infinite)
  /// number of children because the builder is called only for those children
  /// that are actually visible.
  ///
  /// Providing a non-null [itemCount] lets the [PageView] compute the maximum
  /// scroll extent.
  ///
  /// [itemBuilder] will be called only with indices greater than or equal to
  /// zero and less than [itemCount].
  ExtendedImageGesturePageView.builder({
    Key? key,
    this.scrollDirection = Axis.horizontal,
    this.reverse = false,
    ExtendedPageController? controller,
    ScrollPhysics? physics,
    this.pageSnapping = true,
    this.onPageChanged,
    required IndexedWidgetBuilder itemBuilder,
    int? itemCount,
    CanScrollPage? canScrollPage,
    this.preloadPagesCount = 0,
  })  : controller = controller ?? _defaultPageController,
        childrenDelegate =
            SliverChildBuilderDelegate(itemBuilder, childCount: itemCount),
        physics = physics != null
            ? _defaultScrollPhysics.applyTo(physics)
            : _defaultScrollPhysics,
        canScrollPage = canScrollPage ?? _defaultCanScrollPage,
        super(key: key);

  /// Creates a scrollable list that works page by page with a custom child
  /// model.
  ExtendedImageGesturePageView.custom({
    Key? key,
    this.scrollDirection = Axis.horizontal,
    this.reverse = false,
    ExtendedPageController? controller,
    //this.physics,
    this.pageSnapping = true,
    this.onPageChanged,
    CanScrollPage? canScrollPage,
    required this.childrenDelegate,
    this.preloadPagesCount = 0,
  })  : controller = controller ?? _defaultPageController,
        physics = _defaultScrollPhysics,
        canScrollPage = canScrollPage ?? _defaultCanScrollPage,
        super(key: key);

  ///Whether we can scroll page
  final CanScrollPage canScrollPage;

  /// The axis along which the page view scrolls.
  ///
  /// Defaults to [Axis.horizontal].
  final Axis scrollDirection;

  /// Whether the page view scrolls in the reading direction.
  ///
  /// For example, if the reading direction is left-to-right and
  /// [scrollDirection] is [Axis.horizontal], then the page view scrolls from
  /// left to right when [reverse] is false and from right to left when
  /// [reverse] is true.
  ///
  /// Similarly, if [scrollDirection] is [Axis.vertical], then the page view
  /// scrolls from top to bottom when [reverse] is false and from bottom to top
  /// when [reverse] is true.
  ///
  /// Defaults to false.
  final bool reverse;

  /// An object that can be used to control the position to which this page
  /// view is scrolled.
  final ExtendedPageController controller;

  /// How the page view should respond to user input.
  ///
  /// For example, determines how the page view continues to animate after the
  /// user stops dragging the page view.
  ///
  /// The physics are modified to snap to page boundaries using
  /// [PageScrollPhysics] prior to being used.
  ///
  /// Defaults to matching platform conventions.
  final ScrollPhysics physics;

  /// Set to false to disable page snapping, useful for custom scroll behavior.
  final bool pageSnapping;

  /// Called whenever the page in the center of the viewport changes.
  final ValueChanged<int>? onPageChanged;

  /// A delegate that provides the children for the [PageView].
  ///
  /// The [PageView.custom] constructor lets you specify this delegate
  /// explicitly. The [PageView] and [PageView.builder] constructors create a
  /// [childrenDelegate] that wraps the given [List] and [IndexedWidgetBuilder],
  /// respectively.
  final SliverChildDelegate childrenDelegate;

  /// The count of pre-built pages
  final int preloadPagesCount;

  @override
  ExtendedImageGesturePageViewState createState() =>
      ExtendedImageGesturePageViewState();
}

class ExtendedImageGesturePageViewState
    extends State<ExtendedImageGesturePageView>
    with SingleTickerProviderStateMixin {
  MediaQueryData? _mediaQueryData;
  Map<Type, GestureRecognizerFactory> _gestureRecognizers =
      const <Type, GestureRecognizerFactory>{};
  late GestureAnimation _gestureAnimation;
  ScrollPosition get position => pageController.position;
  ExtendedPageController get pageController => widget.controller;
  ExtendedImageGestureState? get extendedImageGestureState {
    return extendedImageGestureStates.lastWhere(
        (ExtendedImageGestureState? element) => element?.mounted ?? false,
        orElse: () => null);
  }

  set extendedImageGestureState(ExtendedImageGestureState? value) {
    if (value != null && !value.mounted) {
      return;
    }
    extendedImageGestureStates.add(value!);
  }

  final Set<ExtendedImageGestureState?> extendedImageGestureStates =
      <ExtendedImageGestureState?>{};

  @override
  void initState() {
    super.initState();
    _gestureAnimation = GestureAnimation(this, offsetCallBack: (Offset value) {
      final GestureDetails? gestureDetails =
          extendedImageGestureState?.gestureDetails;
      if (gestureDetails != null) {
        extendedImageGestureState?.gestureDetails = GestureDetails(
            offset: value,
            totalScale: gestureDetails.totalScale,
            gestureDetails: gestureDetails);
      }
    });
  }

  void _initGestureRecognizers({ExtendedImageGesturePageView? oldWidget}) {
    if (oldWidget == null ||
        oldWidget.scrollDirection != widget.scrollDirection ||
        oldWidget.physics.parent != widget.physics.parent ||
        oldWidget.controller.shouldIgnorePointerWhenScrolling !=
            widget.controller.shouldIgnorePointerWhenScrolling) {
      bool canMove = true;

      ///user's physics
      if (widget.physics.parent != null) {
        canMove =
            widget.physics.parent!.shouldAcceptUserOffset(_testPageMetrics);
      }
      if (canMove) {
        switch (widget.scrollDirection) {
          case Axis.vertical:
            _gestureRecognizers = <Type, GestureRecognizerFactory>{
              ExtendedVerticalDragGestureRecognizer:
                  GestureRecognizerFactoryWithHandlers<
                      ExtendedVerticalDragGestureRecognizer>(
                () => ExtendedVerticalDragGestureRecognizer(
                  canHorizontalOrVerticalDrag: canHorizontalOrVerticalDrag,
                  debugOwner: this,
                ),
                (ExtendedVerticalDragGestureRecognizer instance) {
                  instance
                    ..onDown = onDragDown
                    ..onStart = onDragStart
                    ..onUpdate = onDragUpdate
                    ..onEnd = onDragEnd
                    ..onCancel = onDragCancel
                    ..minFlingDistance = widget.physics.minFlingDistance
                    ..minFlingVelocity = widget.physics.minFlingVelocity
                    ..maxFlingVelocity = widget.physics.maxFlingVelocity
                    ..gestureSettings = _mediaQueryData?.gestureSettings;
                },
              ),
            };
            break;
          case Axis.horizontal:
            _gestureRecognizers = <Type, GestureRecognizerFactory>{
              ExtendedHorizontalDragGestureRecognizer:
                  GestureRecognizerFactoryWithHandlers<
                      ExtendedHorizontalDragGestureRecognizer>(
                () => ExtendedHorizontalDragGestureRecognizer(
                  canHorizontalOrVerticalDrag: canHorizontalOrVerticalDrag,
                  debugOwner: this,
                ),
                (ExtendedHorizontalDragGestureRecognizer instance) {
                  instance
                    ..onDown = onDragDown
                    ..onStart = onDragStart
                    ..onUpdate = onDragUpdate
                    ..onEnd = onDragEnd
                    ..onCancel = onDragCancel
                    ..minFlingDistance = widget.physics.minFlingDistance
                    ..minFlingVelocity = widget.physics.minFlingVelocity
                    ..maxFlingVelocity = widget.physics.maxFlingVelocity
                    ..gestureSettings = _mediaQueryData?.gestureSettings;
                },
              ),
            };
            break;
        }

        /// if true, we should handle scale event in [ExtendedImageGesturePageView] before [ExtendedImageGesturePageView] stop scroll.
        /// notice: there is one issue that we may be zoom two image at the same time, because we can't find out which one should be zoomed.
        if (widget.controller.shouldIgnorePointerWhenScrolling) {
          _gestureRecognizers[ScaleGestureRecognizer] =
              GestureRecognizerFactoryWithHandlers<ScaleGestureRecognizer>(
            () => ScaleGestureRecognizer(debugOwner: this),
            (ScaleGestureRecognizer instance) {
              instance
                ..onStart = onScaleStart
                ..onUpdate = onScaleUpdate
                ..onEnd = onScaleEnd
                ..dragStartBehavior = DragStartBehavior.start
                ..gestureSettings = _mediaQueryData?.gestureSettings;
            },
          );
        }
      }
    }
  }

  @override
  void didChangeDependencies() {
    _mediaQueryData = MediaQuery.maybeOf(context);
    _initGestureRecognizers();
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(ExtendedImageGesturePageView oldWidget) {
    _initGestureRecognizers(oldWidget: oldWidget);
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _gestureAnimation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
//    var finallyPhysics = NeverScrollableScrollPhysics();
//    if (widget.physics != null) {
//      finallyPhysics = finallyPhysics.applyTo(widget.physics);
//    }

    Widget result = GesturePageView.custom(
      key: widget.key,
      scrollDirection: widget.scrollDirection,
      reverse: widget.reverse,
      controller: widget.controller,
      childrenDelegate: widget.childrenDelegate,
      pageSnapping: widget.pageSnapping,
      physics: widget.physics,
      onPageChanged: widget.onPageChanged,
      preloadPagesCount: widget.preloadPagesCount,
    );

    if (widget.physics.parent == null ||
        widget.physics.parent!.shouldAcceptUserOffset(_testPageMetrics)) {
      result = RawGestureDetector(
        gestures: _gestureRecognizers,
        behavior: HitTestBehavior.opaque,
        child: result,
      );
    }
    return result;
  }

  Drag? _drag;
  ScrollHoldController? _hold;

  void onDragDown(DragDownDetails details) {
    _gestureAnimation.stop();
    _hold?.cancel();
    _hold = null;
    _drag?.cancel();
    _drag = null;
    assert(_drag == null);
    assert(_hold == null);
    _hold = position.hold(_disposeHold);
  }

  // scale
  void onDragStart(DragStartDetails details) {
    // It's possible for _hold to become null between _handleDragDown and
    // _handleDragStart, for example if some user code calls jumpTo or otherwise
    // triggers a new activity to begin.
    assert(_drag == null);
    _drag = position.drag(details, _disposeDrag);
    assert(_drag != null);
    assert(_hold == null);
  }

  void onDragUpdate(DragUpdateDetails details) {
    // _drag might be null if the drag activity ended and called _disposeDrag.
    assert(_hold == null || _drag == null);
    //final Offset delta = details.delta;
    if (!widget.canScrollPage(extendedImageGestureState?.gestureDetails)) {
      return;
    }

    _drag?.update(details);

//     return;

//     if (extendedImageGestureState != null) {
//       final GestureDetails? gestureDetails =
//           extendedImageGestureState!.gestureDetails;
//       if (gestureDetails != null) {
//         final int currentPage = pageController.page!.round();
// //        bool pageChanging = false;
// //
// //        if (widget.scrollDirection == Axis.horizontal) {
// //          if (delta.dx != 0.0) {
// //            if (delta.dx < 0) {
// //              pageChanging = pageController.page > currentPage;
// //            } else {
// //              pageChanging = pageController.page < currentPage;
// //            }
// //          }
// //        } else {
// //          if (delta.dy != 0.0) {
// //            if (delta.dy < 0) {
// //              pageChanging = pageController.page < currentPage;
// //            } else {
// //              pageChanging = pageController.page > currentPage;
// //            }
// //          }
// //        }

//         if ((gestureDetails.movePage(delta, widget.scrollDirection) ||
//                 (currentPage != pageController.page)) &&
//             widget.canMovePage(gestureDetails)) {
//           _drag?.update(details);
//         } else {
//           if (currentPage == pageController.page) {
//             extendedImageGestureState!.gestureDetails = GestureDetails(
//                 offset: gestureDetails.offset! +
//                     delta *
//                         extendedImageGestureState!.imageGestureConfig!.speed,
//                 totalScale: gestureDetails.totalScale,
//                 gestureDetails: gestureDetails);
//           }
//         }
//       } else {
//         _drag?.update(details);
//       }
//     } else {
//       _drag?.update(details);
//     }
  }

  void onDragEnd(DragEndDetails details) {
    // _drag might be null if the drag activity ended and called _disposeDrag.
    assert(_hold == null || _drag == null);
    if (!widget.canScrollPage(extendedImageGestureState?.gestureDetails)) {
      _drag!.end(DragEndDetails(primaryVelocity: 0.0));
      return;
    }
    _drag!.end(details);
    assert(_drag == null);
    // return;
    // DragEndDetails temp = details;
    // if (extendedImageGestureState != null) {
    //   final GestureDetails? gestureDetails =
    //       extendedImageGestureState!.gestureDetails;
    //   final int currentPage = pageController.page!.round();
    //   final bool movePage = pageController.page != currentPage;

    //   if (!widget.canMovePage(gestureDetails)) {
    //     //stop
    //     temp = DragEndDetails(primaryVelocity: 0.0);
    //   }

    //   /// stop when zoom in, so that it will not move to next/previous page
    //   if (!movePage &&
    //       gestureDetails != null &&
    //       gestureDetails.totalScale! > 1.0 &&
    //       (gestureDetails.computeHorizontalBoundary ||
    //           gestureDetails.computeVerticalBoundary)) {
    //     //stop
    //     temp = DragEndDetails(primaryVelocity: 0.0);

    //     // get magnitude from gesture velocity
    //     final double magnitude = details.velocity.pixelsPerSecond.distance;

    //     // do a significant magnitude
    //     if (magnitude.greaterThanOrEqualTo(minMagnitude)) {
    //       Offset direction = details.velocity.pixelsPerSecond /
    //           magnitude *
    //           (extendedImageGestureState!.imageGestureConfig!.inertialSpeed);

    //       if (widget.scrollDirection == Axis.horizontal) {
    //         direction = Offset(direction.dx, 0.0);
    //       } else {
    //         direction = Offset(0.0, direction.dy);
    //       }

    //       _gestureAnimation.animationOffset(
    //           gestureDetails.offset, gestureDetails.offset! + direction);
    //     }
    //   }
    // }

    // _drag!.end(temp);

    // assert(_drag == null);
  }

  void onDragCancel() {
    // _hold might be null if the drag started.
    // _drag might be null if the drag activity ended and called _disposeDrag.
    assert(_hold == null || _drag == null);
    _hold?.cancel();
    _drag?.cancel();
    assert(_hold == null);
    assert(_drag == null);
  }

  void _disposeHold() {
    _hold = null;
  }

  void _disposeDrag() {
    _drag = null;
  }

  void onScaleStart(ScaleStartDetails details) {
    if (_drag != null) {
      return;
    }
    for (final ExtendedImageGestureState? extendedImageGestureState
        in extendedImageGestureStates) {
      extendedImageGestureState?.handleScaleStart(details);
    }
  }

  void onScaleUpdate(ScaleUpdateDetails details) {
    if (_drag != null) {
      return;
    }
    for (final ExtendedImageGestureState? extendedImageGestureState
        in extendedImageGestureStates) {
      extendedImageGestureState?.handleScaleUpdate(details);
    }
  }

  void onScaleEnd(ScaleEndDetails details) {
    // if (_drag != null) {
    //   return;
    // }
    for (final ExtendedImageGestureState? extendedImageGestureState
        in extendedImageGestureStates) {
      extendedImageGestureState?.handleScaleEnd(details);
    }
  }

  bool canHorizontalOrVerticalDrag() {
    if (extendedImageGestureState != null) {
      return (extendedImageGestureState?.gestureDetails?.totalScale ?? 1)
          .lessThanOrEqualTo(1);
    }
    return true;
  }

  bool get isHolding => _hold != null;
  bool get isDraging => _drag != null;
}
