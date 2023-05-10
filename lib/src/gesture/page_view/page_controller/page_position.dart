// ignore_for_file: prefer_final_fields, overridden_fields, always_put_control_body_on_new_line

part of 'official.dart';

class _ExtendedPagePosition extends _PagePosition {
  _ExtendedPagePosition({
    required super.physics,
    required super.context,
    super.initialPage = 0,
    super.keepPage = true,
    super.viewportFraction = 1.0,
    super.oldPosition,
    double pageSpacing = 0.0,
  }) : _pageSpacing = pageSpacing;
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
}
