import 'package:flutter/material.dart';

import '../extended_image_typedef.dart';
import 'extended_image_gesture_utils.dart';

class ExtendedImageSlidePage extends StatefulWidget {
  ///The [child] contained by the ExtendedImageGesturePage.
  final Widget child;

  ///builder background when slide page
  final SlidePageBackgroundHandler slidePageBackgroundHandler;

  ///builder of page background when slide page
  final SlideScaleHandler slideScaleHandler;

  ///call back of slide end
  ///decide whether pop page
  final SlideEndHandler slideEndHandler;

  ///axis of slide
  ///both,horizontal,vertical
  final SlideAxis slideAxis;

  ///reset page position when slide end(not pop page)
  final Duration resetPageDuration;

  ExtendedImageSlidePage(
      {this.child,
      this.slidePageBackgroundHandler,
      this.slideScaleHandler,
      this.slideEndHandler,
      this.slideAxis: SlideAxis.both,
      this.resetPageDuration: const Duration(milliseconds: 500)});
  @override
  ExtendedImageSlidePageState createState() => ExtendedImageSlidePageState();
}

class ExtendedImageSlidePageState extends State<ExtendedImageSlidePage>
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
  void didUpdateWidget(ExtendedImageSlidePage oldWidget) {
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

  void slide(Offset delta) {
    if (_backAnimationController.isAnimating) return;
    if (mounted) {
      setState(() {
        _offset = delta;
        if (widget.slideAxis == SlideAxis.horizontal) {
          _offset = Offset(delta.dx, 0.0);
        } else if (widget.slideAxis == SlideAxis.vertical) {
          _offset = Offset(0.0, delta.dy);
        }

        _scale = widget.slideScaleHandler?.call(_offset) ??
            defaultSlideScaleHandler(
                offset: _offset,
                pageSize: pageSize,
                pageGestureAxis: widget.slideAxis);
        _absorbing = true;
      });
    }
  }

  void endSlide() {
    if (mounted && _absorbing) {
      var popPage = widget.slideEndHandler?.call(_offset) ??
          defaultSlideEndHandler(
              offset: _offset,
              pageSize: _pageSize,
              pageGestureAxis: widget.slideAxis);

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
    final Color pageColor =
        widget.slidePageBackgroundHandler?.call(_offset, pageSize) ??
            defaultSlidePageBackgroundHandler(
                offset: _offset,
                pageSize: pageSize,
                color: Theme.of(context).dialogBackgroundColor,
                pageGestureAxis: widget.slideAxis);

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
