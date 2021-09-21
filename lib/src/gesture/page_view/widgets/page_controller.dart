// ignore_for_file: unnecessary_null_comparison, always_put_control_body_on_new_line

import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ExtendedPageController extends ScrollController {
  /// Creates a page controller.
  ///
  /// The [initialPage], [keepPage], and [viewportFraction] arguments must not be null.
  ExtendedPageController({
    this.initialPage = 0,
    this.keepPage = true,
    this.viewportFraction = 1.0,
    this.pageSpacing = 0.0,
  })  : assert(initialPage != null),
        assert(keepPage != null),
        assert(viewportFraction != null),
        assert(viewportFraction > 0.0);

  /// The page to show when first creating the [PageView].
  final int initialPage;

  /// Save the current [page] with [PageStorage] and restore it if
  /// this controller's scrollable is recreated.
  ///
  /// If this property is set to false, the current [page] is never saved
  /// and [initialPage] is always used to initialize the scroll offset.
  /// If true (the default), the initial page is used the first time the
  /// controller's scrollable is created, since there's isn't a page to
  /// restore yet. Subsequently the saved page is restored and
  /// [initialPage] is ignored.
  ///
  /// See also:
  ///
  ///  * [PageStorageKey], which should be used when more than one
  ///    scrollable appears in the same route, to distinguish the [PageStorage]
  ///    locations used to save scroll offsets.
  final bool keepPage;

  /// The fraction of the viewport that each page should occupy.
  ///
  /// Defaults to 1.0, which means each page fills the viewport in the scrolling
  /// direction.
  final double viewportFraction;

  /// The number of logical pixels between each page.
  final double pageSpacing;

  /// The current page displayed in the controlled [PageView].
  ///
  /// There are circumstances that this [ExtendedPageController] can't know the current
  /// page. Reading [page] will throw an [AssertionError] in the following cases:
  ///
  /// 1. No [PageView] is currently using this [ExtendedPageController]. Once a
  /// [PageView] starts using this [ExtendedPageController], the new [page]
  /// position will be derived:
  ///
  ///   * First, based on the attached [PageView]'s [BuildContext] and the
  ///     position saved at that context's [PageStorage] if [keepPage] is true.
  ///   * Second, from the [ExtendedPageController]'s [initialPage].
  ///
  /// 2. More than one [PageView] using the same [ExtendedPageController].
  ///
  /// The [hasClients] property can be used to check if a [PageView] is attached
  /// prior to accessing [page].
  double get page {
    assert(
      positions.isNotEmpty,
      'PageController.page cannot be accessed before a PageView is built with it.',
    );
    assert(
      positions.length == 1,
      'The page property cannot be read when multiple PageViews are attached to '
      'the same PageController.',
    );
    final _PagePosition position = this.position as _PagePosition;
    return position.page;
  }

  /// Animates the controlled [PageView] from the current page to the given page.
  ///
  /// The animation lasts for the given duration and follows the given curve.
  /// The returned [Future] resolves when the animation completes.
  ///
  /// The `duration` and `curve` arguments must not be null.
  Future<void> animateToPage(
    int page, {
    @required Duration duration,
    @required Curve curve,
  }) {
    final _PagePosition position = this.position as _PagePosition;
    return position.animateTo(
      position.getPixelsFromPage(page.toDouble()),
      duration: duration,
      curve: curve,
    );
  }

  /// Changes which page is displayed in the controlled [PageView].
  ///
  /// Jumps the page position from its current value to the given value,
  /// without animation, and without checking if the new value is in range.
  void jumpToPage(int page) {
    final _PagePosition position = this.position as _PagePosition;
    position.jumpTo(position.getPixelsFromPage(page.toDouble()));
  }

  /// Animates the controlled [PageView] to the next page.
  ///
  /// The animation lasts for the given duration and follows the given curve.
  /// The returned [Future] resolves when the animation completes.
  ///
  /// The `duration` and `curve` arguments must not be null.
  Future<void> nextPage({@required Duration duration, @required Curve curve}) {
    return animateToPage(page.round() + 1, duration: duration, curve: curve);
  }

  /// Animates the controlled [PageView] to the previous page.
  ///
  /// The animation lasts for the given duration and follows the given curve.
  /// The returned [Future] resolves when the animation completes.
  ///
  /// The `duration` and `curve` arguments must not be null.
  Future<void> previousPage(
      {@required Duration duration, @required Curve curve}) {
    return animateToPage(page.round() - 1, duration: duration, curve: curve);
  }

  @override
  ScrollPosition createScrollPosition(ScrollPhysics physics,
      ScrollContext context, ScrollPosition oldPosition) {
    return _PagePosition(
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
    final _PagePosition pagePosition = position as _PagePosition;
    pagePosition.viewportFraction = viewportFraction;
  }
}

class _PagePosition extends ScrollPositionWithSingleContext
    implements PageMetrics {
  _PagePosition({
    @required ScrollPhysics physics,
    @required ScrollContext context,
    this.initialPage = 0,
    bool keepPage = true,
    double viewportFraction = 1.0,
    ScrollPosition oldPosition,
    double pageSpacing = 0.0,
  })  : assert(initialPage != null),
        assert(keepPage != null),
        assert(viewportFraction != null),
        assert(viewportFraction > 0.0),
        assert(pageSpacing != null),
        assert(pageSpacing >= 0.0),
        _viewportFraction = viewportFraction,
        _pageSpacing = pageSpacing,
        _pageToUseOnStartup = initialPage.toDouble(),
        super(
          physics: physics,
          context: context,
          initialPixels: null,
          keepScrollOffset: keepPage,
          oldPosition: oldPosition,
        );

  final int initialPage;
  double _pageToUseOnStartup;
  bool get hasPixels => pixels != null;
  bool get hasViewportDimension => viewportDimension != null;
  bool get hasContentDimensions =>
      minScrollExtent != null && maxScrollExtent != null;
  @override
  Future<void> ensureVisible(
    RenderObject object, {
    double alignment = 0.0,
    Duration duration = Duration.zero,
    Curve curve = Curves.ease,
    ScrollPositionAlignmentPolicy alignmentPolicy =
        ScrollPositionAlignmentPolicy.explicit,
    RenderObject targetRenderObject,
  }) {
    // Since the _PagePosition is intended to cover the available space within
    // its viewport, stop trying to move the target render object to the center
    // - otherwise, could end up changing which page is visible and moving the
    // targetRenderObject out of the viewport.
    return super.ensureVisible(
      object,
      alignment: alignment,
      duration: duration,
      curve: curve,
      alignmentPolicy: alignmentPolicy,
      //targetRenderObject: null,
    );
  }

  @override
  double get viewportFraction => _viewportFraction;
  double _viewportFraction;
  set viewportFraction(double value) {
    if (_viewportFraction == value) return;
    final double oldPage = page;
    _viewportFraction = value;
    if (oldPage != null) forcePixels(getPixelsFromPage(oldPage));
  }

  double _pageSpacing;
  double get pageSpacing => _pageSpacing;
  set pageSpacing(double value) {
    if (_pageSpacing != value) {
      final double oldPage = page;
      _pageSpacing = value;
      if (oldPage != null) forcePixels(getPixelsFromPage(oldPage));
    }
  }

  // fix viewportDimension
  @override
  double get viewportDimension => super.viewportDimension + pageSpacing;

  // The amount of offset that will be added to [minScrollExtent] and subtracted
  // from [maxScrollExtent], such that every page will properly snap to the center
  // of the viewport when viewportFraction is greater than 1.
  //
  // The value is 0 if viewportFraction is less than or equal to 1, larger than 0
  // otherwise.
  double get _initialPageOffset =>
      math.max(0, viewportDimension * (viewportFraction - 1) / 2);

  double getPageFromPixels(double pixels, double viewportDimension) {
    final double actual = math.max(0.0, pixels - _initialPageOffset) /
        math.max(1.0, viewportDimension * viewportFraction);
    final double round = actual.roundToDouble();
    if ((actual - round).abs() < precisionErrorTolerance) {
      return round;
    }
    return actual;
  }

  double getPixelsFromPage(double page) {
    return page * viewportDimension * viewportFraction + _initialPageOffset;
  }

  @override
  double get page {
    assert(
      !hasPixels || (minScrollExtent != null && maxScrollExtent != null),
      'Page value is only available after content dimensions are established.',
    );
    return !hasPixels
        ? null
        : getPageFromPixels(
            pixels.clamp(minScrollExtent, maxScrollExtent) as double,
            viewportDimension);
  }

  @override
  void saveScrollOffset() {
    PageStorage.of(context.storageContext)?.writeState(
        context.storageContext, getPageFromPixels(pixels, viewportDimension));
  }

  @override
  void restoreScrollOffset() {
    if (!hasPixels) {
      final double value = PageStorage.of(context.storageContext)
          ?.readState(context.storageContext) as double;
      if (value != null) _pageToUseOnStartup = value;
    }
  }

  @override
  void saveOffset() {
    context.saveOffset(getPageFromPixels(pixels, viewportDimension));
  }

  @override
  void restoreOffset(double offset, {bool initialRestore = false}) {
    assert(initialRestore != null);
    assert(offset != null);
    if (initialRestore) {
      _pageToUseOnStartup = offset;
    } else {
      jumpTo(getPixelsFromPage(offset));
    }
  }

  @override
  bool applyViewportDimension(double viewportDimension) {
    final double oldViewportDimensions =
        hasViewportDimension ? this.viewportDimension : null;
    // fix viewportDimension
    if (viewportDimension + pageSpacing == oldViewportDimensions) {
      return true;
    }
    final bool result = super.applyViewportDimension(viewportDimension);
    final double oldPixels = hasPixels ? pixels : null;
    final double page = (oldPixels == null || oldViewportDimensions == 0.0)
        ? _pageToUseOnStartup
        : getPageFromPixels(oldPixels, oldViewportDimensions);
    final double newPixels = getPixelsFromPage(page);

    if (newPixels != oldPixels) {
      correctPixels(newPixels);
      return false;
    }
    return result;
  }

  @override
  bool applyContentDimensions(double minScrollExtent, double maxScrollExtent) {
    final double newMinScrollExtent = minScrollExtent + _initialPageOffset;
    return super.applyContentDimensions(
      newMinScrollExtent,
      math.max(newMinScrollExtent, maxScrollExtent - _initialPageOffset),
    );
  }

  @override
  PageMetrics copyWith({
    double minScrollExtent,
    double maxScrollExtent,
    double pixels,
    double viewportDimension,
    AxisDirection axisDirection,
    double viewportFraction,
  }) {
    return PageMetrics(
      minScrollExtent: minScrollExtent ??
          (hasContentDimensions ? this.minScrollExtent : null),
      maxScrollExtent: maxScrollExtent ??
          (hasContentDimensions ? this.maxScrollExtent : null),
      pixels: pixels ?? (hasPixels ? this.pixels : null),
      viewportDimension: viewportDimension ??
          (hasViewportDimension ? this.viewportDimension : null),
      axisDirection: axisDirection ?? this.axisDirection,
      viewportFraction: viewportFraction ?? this.viewportFraction,
    );
  }
}
