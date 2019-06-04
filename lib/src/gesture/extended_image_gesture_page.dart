import 'package:flutter/material.dart';

import '../extended_image_typedef.dart';
import 'extended_image_gesture_utils.dart';

class ExtendedImageGesturePage extends StatefulWidget {
  final Widget child;
  final GesturePageBackgroundBuilder backgroundBuilder;
  final PageGestureScaleHandler pageGestureScaleHandler;
  final PageGestureEndHandler pageGestureEndHandler;
  final PageGestureAxis pageGestureAxis;
  final Duration resetPageDuration;
  ExtendedImageGesturePage(
      {this.child,
      this.backgroundBuilder,
      this.pageGestureScaleHandler,
      this.pageGestureEndHandler,
      this.pageGestureAxis: PageGestureAxis.both,
      this.resetPageDuration: const Duration(milliseconds: 500)});
  @override
  ExtendedImageGesturePageState createState() =>
      ExtendedImageGesturePageState();
}

class ExtendedImageGesturePageState extends State<ExtendedImageGesturePage>
    with SingleTickerProviderStateMixin {
  bool _absorbing = false;
  bool get absorbing => _absorbing;

  Size _pageSize;
  Size get pageSize => _pageSize ?? context.size;

  AnimationController _backAnimationController;
  Animation<Offset> _backOffsetAnimation;
  Animation<double> _bcakScaleAnimation;
  Offset _offset = Offset.zero;
  double _scale = 1.0;
  bool _poping = false;

  @override
  void initState() {
    super.initState();
    _backAnimationController =
        AnimationController(vsync: this, duration: widget.resetPageDuration);
    _backAnimationController.addListener(_bcakAnimation);
  }

  @override
  void didUpdateWidget(ExtendedImageGesturePage oldWidget) {
    if (oldWidget.resetPageDuration != widget.resetPageDuration) {
      _backAnimationController.stop();
      _backAnimationController.dispose();
      _backAnimationController =
          AnimationController(vsync: this, duration: widget.resetPageDuration);
    }
    super.didUpdateWidget(oldWidget);
  }

  void _bcakAnimation() {
    if (_backAnimationController.isCompleted) {
      setState(() {
        _absorbing = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _backAnimationController.removeListener(_bcakAnimation);
    _backAnimationController.dispose();
  }

  void updateGesture(Offset delta) {
    if (_backAnimationController.isAnimating) return;
    if (mounted) {
      setState(() {
        _offset = delta;
        if (widget.pageGestureAxis == PageGestureAxis.horizontal) {
          _offset = Offset(delta.dx, 0.0);
        } else if (widget.pageGestureAxis == PageGestureAxis.vertical) {
          _offset = Offset(0.0, delta.dy);
        }

        _scale = widget.pageGestureScaleHandler?.call(_offset) ??
            defaultPageGestureScaleHandler(
                offset: _offset,
                pageSize: pageSize,
                pageGestureAxis: widget.pageGestureAxis);
        _absorbing = true;
      });
    }
  }

  void endGesture() {
    if (mounted && _absorbing) {
      var popPage = widget.pageGestureEndHandler?.call(_offset) ??
          defaultPageGestureEndHandler(
              offset: _offset,
              pageSize: _pageSize,
              pageGestureAxis: widget.pageGestureAxis);

      if (popPage) {
        setState(() {
          _poping = true;
          _absorbing = false;
        });
        Navigator.pop(context);
      } else {
        _backOffsetAnimation = _backAnimationController
            .drive(Tween<Offset>(begin: _offset, end: Offset.zero));
        _bcakScaleAnimation = _backAnimationController
            .drive(Tween<double>(begin: _scale, end: 1.0));
        _offset = Offset.zero;
        _scale = 1.0;
        _backAnimationController.reset();
        _backAnimationController.forward();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _pageSize = MediaQuery.of(context).size;
    final Color pageColor = widget.backgroundBuilder?.call(_offset, pageSize) ??
        defaultGesturePageBackgroundBuilder(
            offset: _offset,
            pageSize: pageSize,
            color: Theme.of(context).dialogBackgroundColor,
            pageGestureAxis: widget.pageGestureAxis);

    Widget result = Container(
      color: _poping ? Colors.transparent : pageColor,
      child: AnimatedBuilder(
          animation: _backAnimationController,
          builder: (context, b) {
            return Transform.translate(
              offset: _backAnimationController.isAnimating
                  ? _backOffsetAnimation.value
                  : _offset,
              child: Transform.scale(
                scale: _backAnimationController.isAnimating
                    ? _bcakScaleAnimation.value
                    : _scale,
                child: AbsorbPointer(
                  absorbing: _absorbing,
                  child: widget.child,
                ),
              ),
            );
          }),
    );

    return result;
  }
}
