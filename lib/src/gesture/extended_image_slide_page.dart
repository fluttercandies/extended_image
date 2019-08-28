import 'package:flutter/material.dart';

import '../extended_image_typedef.dart';
import 'extended_image_gesture_utils.dart';
import 'extended_image_slide_page_handler.dart';

enum SlideAxis {
  both,
  horizontal,
  vertical,
}

enum SlideType {
  wholePage,
  onlyImage,
}

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

  /// slide whole page or only image
  final SlideType slideType;

  /// on sliding page
  final OnSlidingPage onSlidingPage;

  ExtendedImageSlidePage({
    this.child,
    this.slidePageBackgroundHandler,
    this.slideScaleHandler,
    this.slideEndHandler,
    this.slideAxis: SlideAxis.both,
    this.resetPageDuration: const Duration(milliseconds: 500),
    this.slideType: SlideType.onlyImage,
    this.onSlidingPage,
    Key key,
  }) : super(key: key);
  @override
  ExtendedImageSlidePageState createState() => ExtendedImageSlidePageState();
}

class ExtendedImageSlidePageState extends State<ExtendedImageSlidePage>
    with SingleTickerProviderStateMixin {
  bool _isSliding = false;

  ///whether is sliding page
  bool get isSliding => _isSliding;

  Size _pageSize;
  Size get pageSize => _pageSize ?? context.size;

  AnimationController _backAnimationController;
  AnimationController get backAnimationController => _backAnimationController;
  Animation<Offset> _backOffsetAnimation;
  Animation<Offset> get backOffsetAnimation => _backOffsetAnimation;
  Animation<double> _backScaleAnimation;
  Animation<double> get backScaleAnimation => _backScaleAnimation;
  Offset _offset = Offset.zero;
  Offset get offset => _backAnimationController.isAnimating
      ? _backOffsetAnimation.value
      : _offset;
  double _scale = 1.0;
  double get scale =>
      _backAnimationController.isAnimating ? backScaleAnimation.value : _scale;
  bool _poping = false;

  @override
  void initState() {
    super.initState();
    _backAnimationController =
        AnimationController(vsync: this, duration: widget.resetPageDuration);
    _backAnimationController.addListener(_backAnimation);
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

  ExtendedImageGestureState _extendedImageGestureState;
  ExtendedImageSlidePageHandlerState _extendedImageSlidePageHandlerState;
  void _backAnimation() {
    if (mounted) {
      setState(() {
        if (_backAnimationController.isCompleted) _isSliding = false;
      });
    }
    if (widget.slideType == SlideType.onlyImage) {
      _extendedImageGestureState?.slide();
      _extendedImageSlidePageHandlerState?.slide();
    }
    widget.onSlidingPage?.call(this);
  }

  @override
  void dispose() {
    super.dispose();
    _backAnimationController.removeListener(_backAnimation);
    _backAnimationController.dispose();
  }

  void slide(Offset value,
      {ExtendedImageGestureState extendedImageGestureState,
      ExtendedImageSlidePageHandlerState extendedImageSlidePageHandlerState}) {
    if (_backAnimationController.isAnimating) return;
    _offset = value;
    if (widget.slideAxis == SlideAxis.horizontal) {
      _offset = Offset(value.dx, 0.0);
    } else if (widget.slideAxis == SlideAxis.vertical) {
      _offset = Offset(0.0, value.dy);
    }

    _scale = widget.slideScaleHandler?.call(_offset) ??
        defaultSlideScaleHandler(
            offset: _offset,
            pageSize: pageSize,
            pageGestureAxis: widget.slideAxis);
    _isSliding = true;
    if (widget.slideType == SlideType.onlyImage) {
      _extendedImageGestureState = extendedImageGestureState;
      _extendedImageGestureState?.slide();
      _extendedImageSlidePageHandlerState = extendedImageSlidePageHandlerState;
      _extendedImageSlidePageHandlerState?.slide();
    }

    if (mounted) {
      setState(() {});
    }
    widget.onSlidingPage?.call(this);
  }

  void endSlide() {
    if (mounted && _isSliding) {
      var popPage = widget.slideEndHandler?.call(_offset) ??
          defaultSlideEndHandler(
              offset: _offset,
              pageSize: _pageSize,
              pageGestureAxis: widget.slideAxis);

      if (popPage) {
        setState(() {
          _poping = true;
          _isSliding = false;
        });
        Navigator.pop(context);
      } else {
        _backOffsetAnimation = _backAnimationController
            .drive(Tween<Offset>(begin: _offset, end: Offset.zero));
        _backScaleAnimation = _backAnimationController
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
        widget.slidePageBackgroundHandler?.call(offset, pageSize) ??
            defaultSlidePageBackgroundHandler(
                offset: offset,
                pageSize: pageSize,
                color: Theme.of(context).dialogBackgroundColor,
                pageGestureAxis: widget.slideAxis);

    Widget result = widget.child;
    if (widget.slideType == SlideType.wholePage) {
      result = Transform.translate(
        offset: offset,
        child: Transform.scale(
          scale: scale,
          child: result,
        ),
      );
    }

    result = Container(
      color: _poping ? Colors.transparent : pageColor,
      child: result,
    );

//    result = IgnorePointer(
//      ignoring: _isSliding,
//      child: result,
//    );

    return result;
  }

  void popPage() {
    setState(() {
      _poping = true;
    });
  }
}
