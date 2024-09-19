import 'dart:async';

extension DebounceThrottlingE on Function {
  VoidFunction debounce([Duration duration = const Duration(seconds: 1)]) {
    Timer? _debounce;
    return () {
      if (_debounce?.isActive ?? false) {
        _debounce!.cancel();
      }
      _debounce = Timer(duration, () {
        this.call();
      });
    };
  }

  VoidFunction throttle([Duration duration = const Duration(seconds: 1)]) {
    Timer? _throttle;
    return () {
      if (_throttle?.isActive ?? false) {
        return;
      }
      this.call();
      _throttle = Timer(duration, () {});
    };
  }
}

typedef VoidFunction = void Function();
