// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/gestures.dart';
part 'velocity_tracker_mixin.dart';

class _PointAtTime {
  const _PointAtTime(this.point, this.time)
      : assert(point != null),
        assert(time != null);

  final Duration time;
  final Offset point;

  @override
  String toString() => '_PointAtTime($point at $time)';
}

class ExtendedVelocityTracker extends VelocityTracker
    with VelocityTrackerMixin {
  /// Create a new velocity tracker for a pointer [kind].
  ExtendedVelocityTracker.withKind(PointerDeviceKind kind)
      : super.withKind(kind);

  static const int _assumePointerMoveStoppedMilliseconds = 40;
  static const int _historySize = 20;
  static const int _horizonMilliseconds = 100;
  static const int _minSampleSize = 3;

  // /// The kind of pointer this tracker is for.
  // @override
  // final PointerDeviceKind kind;

  // Circular buffer; current sample at _index.
  @override
  final List<_PointAtTime?> _samples =
      List<_PointAtTime?>.filled(_historySize, null);
  int _index = 0;

  /// Adds a position as the given time to the tracker.
  @override
  void addPosition(Duration time, Offset position) {
    _index += 1;
    if (_index == _historySize) {
      _index = 0;
    }
    _samples[_index] = _PointAtTime(position, time);
  }

  /// Returns an estimate of the velocity of the object being tracked by the
  /// tracker given the current information available to the tracker.
  ///
  /// Information is added using [addPosition].
  ///
  /// Returns null if there is no data on which to base an estimate.
  @override
  VelocityEstimate? getVelocityEstimate() {
    final List<double> x = <double>[];
    final List<double> y = <double>[];
    final List<double> w = <double>[];
    final List<double> time = <double>[];
    int sampleCount = 0;
    int index = _index;

    final _PointAtTime? newestSample = _samples[index];
    if (newestSample == null) {
      return null;
    }

    _PointAtTime previousSample = newestSample;
    _PointAtTime oldestSample = newestSample;

    // Starting with the most recent PointAtTime sample, iterate backwards while
    // the samples represent continuous motion.
    do {
      final _PointAtTime? sample = _samples[index];
      if (sample == null) {
        break;
      }

      final double age =
          (newestSample.time - sample.time).inMicroseconds.toDouble() / 1000;
      final double delta =
          (sample.time - previousSample.time).inMicroseconds.abs().toDouble() /
              1000;
      previousSample = sample;
      if (age > _horizonMilliseconds ||
          delta > _assumePointerMoveStoppedMilliseconds) {
        break;
      }

      oldestSample = sample;
      final Offset position = sample.point;
      x.add(position.dx);
      y.add(position.dy);
      w.add(1.0);
      time.add(-age);
      index = (index == 0 ? _historySize : index) - 1;

      sampleCount += 1;
    } while (sampleCount < _historySize);

    if (sampleCount >= _minSampleSize) {
      final LeastSquaresSolver xSolver = LeastSquaresSolver(time, x, w);
      final PolynomialFit? xFit = xSolver.solve(2);
      if (xFit != null) {
        final LeastSquaresSolver ySolver = LeastSquaresSolver(time, y, w);
        final PolynomialFit? yFit = ySolver.solve(2);
        if (yFit != null) {
          return VelocityEstimate(
            // convert from pixels/ms to pixels/s
            pixelsPerSecond: Offset(
                xFit.coefficients[1] * 1000, yFit.coefficients[1] * 1000),
            confidence: xFit.confidence * yFit.confidence,
            duration: newestSample.time - oldestSample.time,
            offset: newestSample.point - oldestSample.point,
          );
        }
      }
    }

    // We're unable to make a velocity estimate but we did have at least one
    // valid pointer position.
    return VelocityEstimate(
      pixelsPerSecond: Offset.zero,
      confidence: 1.0,
      duration: newestSample.time - oldestSample.time,
      offset: newestSample.point - oldestSample.point,
    );
  }

  /// Computes the velocity of the pointer at the time of the last
  /// provided data point.
  ///
  /// This can be expensive. Only call this when you need the velocity.
  ///
  /// Returns [Velocity.zero] if there is no data from which to compute an
  /// estimate or if the estimated velocity is zero.
  @override
  Velocity getVelocity() {
    final VelocityEstimate? estimate = getVelocityEstimate();
    if (estimate == null || estimate.pixelsPerSecond == Offset.zero) {
      return Velocity.zero;
    }
    return Velocity(pixelsPerSecond: estimate.pixelsPerSecond);
  }
}
