part of 'official.dart';

class ExtendedPageController extends _PageController {
  ExtendedPageController({
    super.initialPage = 0,
    super.keepPage = true,
    super.viewportFraction = 1.0,
    this.shouldIgnorePointerWhenScrolling = false,
    this.pageSpacing = 0.0,
  });

  /// Whether the contents of the widget should ignore [PointerEvent] inputs.
  ///
  /// Setting this value to true prevents the use from interacting with the
  /// contents of the widget with pointer events. The widget itself is still
  /// interactive.
  ///
  /// For example, if the scroll position is being driven by an animation, it
  /// might be appropriate to set this value to ignore pointer events to
  /// prevent the user from accidentally interacting with the contents of the
  /// widget as it animates. The user will still be able to touch the widget,
  /// potentially stopping the animation.
  ///
  ///
  /// if true, we should handle scale event in [ExtendedImageGesturePageView] before [ExtendedImageGesturePageView] stop scroll.
  /// notice: there is one issue that we may be zoom two image at the same time, because we can't find out which one should be zoomed.
  ///
  ///
  /// if false, Image can accept scale event before [ExtendedImageGesturePageView] stop scroll.
  /// notice: we don't know  there are any issues if we don't ignore [PointerEvent] inputs when it's scrolling.
  ///
  ///
  /// Two way to solve issue that we can's zoom image before [PageView] stop scroll.
  ///
  ///
  /// default is false.

  final bool shouldIgnorePointerWhenScrolling;

  /// The number of logical pixels between each page.

  final double pageSpacing;

  @override
  ScrollPosition createScrollPosition(
    ScrollPhysics physics,
    ScrollContext context,
    ScrollPosition? oldPosition,
  ) {
    return _ExtendedPagePosition(
      physics: physics,
      context: context,
      initialPage: initialPage,
      keepPage: keepPage,
      viewportFraction: viewportFraction,
      oldPosition: oldPosition,
      pageSpacing: pageSpacing,
    );
  }

  @override
  void attach(ScrollPosition position) {
    super.attach(position);
    final _ExtendedPagePosition pagePosition =
        position as _ExtendedPagePosition;
    pagePosition.pageSpacing = pageSpacing;
  }
}
