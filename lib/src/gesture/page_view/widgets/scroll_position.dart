part of 'page_controller.dart';
// ignore_for_file: unnecessary_null_comparison, always_put_control_body_on_new_line

class ExtendedPagePosition extends ScrollPositionWithSingleContext
    implements PageMetrics {
  ExtendedPagePosition({
    required ScrollPhysics physics,
    required ScrollContext context,
    this.initialPage = 0,
    bool keepPage = true,
    double viewportFraction = 1.0,
    ScrollPosition? oldPosition,
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
  // When the viewport has a zero-size, the `page` can not
  // be retrieved by `getPageFromPixels`, so we need to cache the page
  // for use when resizing the viewport to non-zero next time.
  double? _cachedPage;

  @override
  Future<void> ensureVisible(
    RenderObject object, {
    double alignment = 0.0,
    Duration duration = Duration.zero,
    Curve curve = Curves.ease,
    ScrollPositionAlignmentPolicy alignmentPolicy =
        ScrollPositionAlignmentPolicy.explicit,
    RenderObject? targetRenderObject,
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
      targetRenderObject: null,
    );
  }

  @override
  double get viewportFraction => _viewportFraction;
  double _viewportFraction;
  set viewportFraction(double value) {
    if (_viewportFraction == value) return;
    final double? oldPage = page;
    _viewportFraction = value;
    if (oldPage != null) forcePixels(getPixelsFromPage(oldPage));
  }

  double _pageSpacing;
  double get pageSpacing => _pageSpacing;
  set pageSpacing(double value) {
    if (_pageSpacing != value) {
      final double? oldPage = page;
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
  double? get page {
    assert(
      !hasPixels || hasContentDimensions,
      'Page value is only available after content dimensions are established.',
    );
    return !hasPixels || !hasContentDimensions
        ? null
        : _cachedPage ??
            getPageFromPixels(
                clampDouble(pixels, minScrollExtent, maxScrollExtent),
                viewportDimension);
  }

  @override
  void saveScrollOffset() {
    PageStorage.maybeOf(context.storageContext)?.writeState(
        context.storageContext,
        _cachedPage ?? getPageFromPixels(pixels, viewportDimension));
  }

  @override
  void restoreScrollOffset() {
    if (!hasPixels) {
      final double? value = PageStorage.maybeOf(context.storageContext)
          ?.readState(context.storageContext) as double?;
      if (value != null) {
        _pageToUseOnStartup = value;
      }
    }
  }

  @override
  void saveOffset() {
    context.saveOffset(
        _cachedPage ?? getPageFromPixels(pixels, viewportDimension));
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
    final double? oldViewportDimensions =
        // fix viewportDimension
        hasViewportDimension ? this.viewportDimension - pageSpacing : null;

    if (viewportDimension == oldViewportDimensions) {
      return true;
    }
    final bool result = super.applyViewportDimension(viewportDimension);
    final double? oldPixels = hasPixels ? pixels : null;
    double page;
    if (oldPixels == null) {
      page = _pageToUseOnStartup;
    } else if (oldViewportDimensions == 0.0) {
      // If resize from zero, we should use the _cachedPage to recover the state.
      page = _cachedPage!;
    } else {
      page = getPageFromPixels(oldPixels, oldViewportDimensions!);
    }
    final double newPixels = getPixelsFromPage(page);

    // If the viewportDimension is zero, cache the page
    // in case the viewport is resized to be non-zero.
    _cachedPage = (viewportDimension == 0.0) ? page : null;
    if (newPixels != oldPixels) {
      correctPixels(newPixels);
      return false;
    }
    return result;
  }

  @override
  void absorb(ScrollPosition other) {
    super.absorb(other);
    assert(_cachedPage == null);

    if (other is! ExtendedPagePosition) {
      return;
    }

    if (other._cachedPage != null) {
      _cachedPage = other._cachedPage;
    }
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
    double? minScrollExtent,
    double? maxScrollExtent,
    double? pixels,
    double? viewportDimension,
    AxisDirection? axisDirection,
    double? viewportFraction,
    double? devicePixelRatio,
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
      devicePixelRatio: devicePixelRatio ?? this.devicePixelRatio,
    );
  }
}
