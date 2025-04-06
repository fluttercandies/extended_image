part of 'official.dart';

/// [VelocityTracker]
class ExtendedVelocityTracker extends _VelocityTracker {
  ExtendedVelocityTracker.withKind(super.kind) : super.withKind();
  Offset getSamplesDelta() {
    Offset? first;
    Offset? last;
    for (int i = 0; i < _samples.length; i++) {
      final _PointAtTime? d = _samples[i];
      if (d != null && first == null) {
        first = d.point;
        break;
      }
    }

    for (int i = _samples.length - 1; i >= 0; i--) {
      final _PointAtTime? d = _samples[i];
      if (d != null && last == null) {
        last = d.point;
        break;
      }
    }
    last ??= Offset.zero;
    first ??= Offset.zero;
    return last - first;
  }
}

/// Computes a pointer's velocity based on data from [PointerMoveEvent]s.
///
/// The input data is provided by calling [addPosition]. Adding data is cheap.
///
/// To obtain a velocity, call [getVelocity] or [getVelocityEstimate]. This will
/// compute the velocity based on the data added so far. Only call these when
/// you need to use the velocity, as they are comparatively expensive.
///
/// The quality of the velocity estimation will be better if more data points
/// have been received.
class _VelocityTracker extends VelocityTracker {
  /// Create a new velocity tracker for a pointer [kind].
  _VelocityTracker.withKind(PointerDeviceKind kind) : super.withKind(kind);

  static const int _assumePointerMoveStoppedMilliseconds = 40;
  static const int _historySize = 20;
  static const int _horizonMilliseconds = 100;
  static const int _minSampleSize = 3;

  /// The kind of pointer this tracker is for.
  // final PointerDeviceKind kind;

  // Time difference since the last sample was added
  Stopwatch get _sinceLastSample {
    _stopwatch ??= GestureBinding.instance.samplingClock.stopwatch();
    return _stopwatch!;
  }

  Stopwatch? _stopwatch;

  // Circular buffer; current sample at _index.
  final List<_PointAtTime?> _samples = List<_PointAtTime?>.filled(
    _historySize,
    null,
  );
  int _index = 0;

  /// Adds a position as the given time to the tracker.
  @override
  void addPosition(Duration time, Offset position) {
    _sinceLastSample.start();
    _sinceLastSample.reset();
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
    // Has user recently moved since last sample?
    if (_sinceLastSample.elapsedMilliseconds >
        _assumePointerMoveStoppedMilliseconds) {
      return const VelocityEstimate(
        pixelsPerSecond: Offset.zero,
        confidence: 1.0,
        duration: Duration.zero,
        offset: Offset.zero,
      );
    }

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
      // Marking as "late" ensures that yFit isn't evaluated unless it's needed.
      late final PolynomialFit? xFit = LeastSquaresSolver(time, x, w).solve(2);
      late final PolynomialFit? yFit = LeastSquaresSolver(time, y, w).solve(2);

      if (xFit != null && yFit != null) {
        return VelocityEstimate(
          // convert from pixels/ms to pixels/s
          pixelsPerSecond: Offset(
            xFit.coefficients[1] * 1000,
            yFit.coefficients[1] * 1000,
          ),
          confidence: xFit.confidence * yFit.confidence,
          duration: newestSample.time - oldestSample.time,
          offset: newestSample.point - oldestSample.point,
        );
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

class _PointAtTime {
  const _PointAtTime(this.point, this.time);

  final Duration time;
  final Offset point;

  @override
  String toString() => '_PointAtTime($point at $time)';
}
