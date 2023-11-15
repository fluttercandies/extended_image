import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

import '../utils.dart';
import 'editor_utils.dart';

///
///  create by zmtzawqlp on 2019/8/22
///

enum _MoveType {
  topLeft,
  topRight,
  bottomRight,
  bottomLeft,
  top,
  right,
  bottom,
  left
}

class ExtendedImageCropLayer extends StatefulWidget {
  const ExtendedImageCropLayer(
    this.editActionDetails,
    this.editorConfig,
    this.layoutRect, {
    Key? key,
    this.fit = BoxFit.contain,
  }) : super(key: key);

  final EditActionDetails editActionDetails;
  final EditorConfig editorConfig;
  final Rect layoutRect;
  final BoxFit fit;
  @override
  ExtendedImageCropLayerState createState() => ExtendedImageCropLayerState();
}

class ExtendedImageCropLayerState extends State<ExtendedImageCropLayer>
    with SingleTickerProviderStateMixin {
  Rect get layoutRect => widget.layoutRect;

  Rect? get cropRect => widget.editActionDetails.cropRect;
  set cropRect(Rect? value) {
    widget.editActionDetails.cropRect = value;
    widget.editorConfig.editActionDetailsIsChanged
        ?.call(widget.editActionDetails);
  }

  bool get isAnimating => _rectTweenController.isAnimating;
  bool get isMoving => _currentMoveType != null;

  Timer? _timer;
  bool _pointerDown = false;
  Animation<Rect?>? _rectAnimation;
  late AnimationController _rectTweenController;
  _MoveType? _currentMoveType;
  @override
  void initState() {
    super.initState();
    _pointerDown = false;
    _rectTweenController = AnimationController(
        vsync: this, duration: widget.editorConfig.animationDuration)
      ..addListener(_doCropAutoCenterAnimation);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _rectTweenController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ExtendedImageCropLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.editorConfig.animationDuration !=
        oldWidget.editorConfig.animationDuration) {
      _rectTweenController.stop();
      _rectTweenController.dispose();
      _rectTweenController = AnimationController(
          vsync: this, duration: widget.editorConfig.animationDuration)
        ..addListener(_doCropAutoCenterAnimation);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (cropRect == null) {
      return Container();
    }
    final EditorConfig editConfig = widget.editorConfig;
    final Color primaryColor = Theme.of(context).primaryColor;

    final Color cornerColor = editConfig.cornerColor ?? primaryColor;

    final Color maskColor = widget.editorConfig.editorMaskColorHandler
            ?.call(context, _pointerDown) ??
        defaultEditorMaskColorHandler(context, _pointerDown);
    final double gWidth = widget.editorConfig.hitTestSize;

    final Widget result = CustomPaint(
      painter: ExtendedImageCropLayerPainter(
        cropRect: cropRect!,
        cropLayerPainter: editConfig.cropLayerPainter,
        cornerColor: cornerColor,
        cornerSize: editConfig.cornerSize,
        lineColor: editConfig.lineColor ??
            Theme.of(context).scaffoldBackgroundColor.withOpacity(0.7),
        lineHeight: editConfig.lineHeight,
        maskColor: maskColor,
        pointerDown: _pointerDown,
      ),
      child: Stack(
        children: <Widget>[
          //top left
          Positioned(
            top: cropRect!.top - gWidth,
            left: cropRect!.left - gWidth,
            child: Container(
              height: gWidth * 2,
              width: gWidth * 2,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onPanUpdate: (DragUpdateDetails details) {
                  moveUpdate(_MoveType.topLeft, details.delta);
                },
                onPanEnd: (_) {
                  _moveEnd(_MoveType.topLeft);
                },
              ),
            ),
          ),
          //top right
          Positioned(
            top: cropRect!.top - gWidth,
            left: cropRect!.right - gWidth,
            child: Container(
              height: gWidth * 2,
              width: gWidth * 2,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onPanUpdate: (DragUpdateDetails details) {
                  moveUpdate(_MoveType.topRight, details.delta);
                },
                onPanEnd: (_) {
                  _moveEnd(_MoveType.topRight);
                },
              ),
            ),
          ),
          //bottom left
          Positioned(
            top: cropRect!.bottom - gWidth,
            left: cropRect!.left - gWidth,
            child: Container(
              height: gWidth * 2,
              width: gWidth * 2,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onPanUpdate: (DragUpdateDetails details) {
                  moveUpdate(_MoveType.bottomLeft, details.delta);
                },
                onPanEnd: (_) {
                  _moveEnd(_MoveType.bottomLeft);
                },
              ),
            ),
          ),
          // bottom right
          Positioned(
            top: cropRect!.bottom - gWidth,
            left: cropRect!.right - gWidth,
            child: Container(
              height: gWidth * 2,
              width: gWidth * 2,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onPanUpdate: (DragUpdateDetails details) {
                  moveUpdate(_MoveType.bottomRight, details.delta);
                },
                onPanEnd: (_) {
                  _moveEnd(_MoveType.bottomRight);
                },
              ),
            ),
          ),
          // top
          Positioned(
            top: cropRect!.top - gWidth,
            left: cropRect!.left + gWidth,
            child: Container(
              height: gWidth * 2,
              width: max(cropRect!.width - gWidth * 2, gWidth * 2),
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onVerticalDragUpdate: (DragUpdateDetails details) {
                  moveUpdate(_MoveType.top, details.delta);
                },
                onVerticalDragEnd: (_) {
                  _moveEnd(_MoveType.top);
                },
              ),
            ),
          ),
          //left
          Positioned(
            top: cropRect!.top + gWidth,
            left: cropRect!.left - gWidth,
            child: Container(
              height: max(cropRect!.height - gWidth * 2, gWidth * 2),
              width: gWidth * 2,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onHorizontalDragUpdate: (DragUpdateDetails details) {
                  moveUpdate(_MoveType.left, details.delta);
                },
                onHorizontalDragEnd: (_) {
                  _moveEnd(_MoveType.left);
                },
              ),
            ),
          ),
          //bottom
          Positioned(
            top: cropRect!.bottom - gWidth,
            left: cropRect!.left + gWidth,
            child: Container(
              height: gWidth * 2,
              width: max(cropRect!.width - gWidth * 2, gWidth * 2),
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onVerticalDragUpdate: (DragUpdateDetails details) {
                  moveUpdate(_MoveType.bottom, details.delta);
                },
                onVerticalDragEnd: (_) {
                  _moveEnd(_MoveType.bottom);
                },
              ),
            ),
          ),
          //right
          Positioned(
            top: cropRect!.top + gWidth,
            left: cropRect!.right - gWidth,
            child: Container(
              height: max(cropRect!.height - gWidth * 2, gWidth * 2),
              width: gWidth * 2,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onHorizontalDragUpdate: (DragUpdateDetails details) {
                  moveUpdate(_MoveType.right, details.delta);
                },
                onHorizontalDragEnd: (_) {
                  _moveEnd(_MoveType.right);
                },
              ),
            ),
          ),
        ],
      ),
    );

    return result;
  }

  void pointerDown(bool down) {
    if (mounted && _pointerDown != down) {
      setState(() {
        _pointerDown = down;
      });
    }
  }

  void moveUpdate(_MoveType moveType, Offset delta) {
    if (isAnimating) {
      return;
    }

    ///only move by one type at the same time
    if (_currentMoveType != null && moveType != _currentMoveType) {
      return;
    }
    _currentMoveType = moveType;

    final Rect? layerDestinationRect =
        widget.editActionDetails.layerDestinationRect;
    Rect? result = cropRect;
    final double gWidth = widget.editorConfig.cornerSize.width;
    switch (moveType) {
      case _MoveType.topLeft:
      case _MoveType.top:
      case _MoveType.left:
        Offset topLeft = result!.topLeft + delta;
        topLeft = Offset(min(topLeft.dx, result.right - gWidth * 2),
            min(topLeft.dy, result.bottom - gWidth * 2));
        result = Rect.fromPoints(topLeft, result.bottomRight);
        break;
      case _MoveType.topRight:
        Offset topRight = result!.topRight + delta;
        topRight = Offset(max(topRight.dx, result.left + gWidth * 2),
            min(topRight.dy, result.bottom - gWidth * 2));
        result = Rect.fromPoints(topRight, result.bottomLeft);
        break;
      case _MoveType.bottomRight:
      case _MoveType.right:
      case _MoveType.bottom:
        Offset bottomRight = result!.bottomRight + delta;
        bottomRight = Offset(max(bottomRight.dx, result.left + gWidth * 2),
            max(bottomRight.dy, result.top + gWidth * 2));
        result = Rect.fromPoints(result.topLeft, bottomRight);
        break;
      case _MoveType.bottomLeft:
        Offset bottomLeft = result!.bottomLeft + delta;
        bottomLeft = Offset(min(bottomLeft.dx, result.right - gWidth * 2),
            max(bottomLeft.dy, result.top + gWidth * 2));
        result = Rect.fromPoints(bottomLeft, result.topRight);
        break;
      default:
    }

    // result = Rect.fromPoints(
    //     Offset(
    //         max(result.left, layoutRect.left), max(result.top, layoutRect.top)),
    //     Offset(min(result.right, layoutRect.right),
    //         min(result.bottom, layoutRect.bottom)));

    ///make sure crop rect doesn't out of image rect
    result = Rect.fromPoints(
        Offset(max(result!.left, layerDestinationRect!.left),
            max(result.top, layerDestinationRect.top)),
        Offset(min(result.right, layerDestinationRect.right),
            min(result.bottom, layerDestinationRect.bottom)));

    result = _handleAspectRatio(
        gWidth, moveType, result, layerDestinationRect, delta);

    ///move and scale image rect when crop rect is bigger than layout rect

    if (result.beyond(layoutRect)) {
      cropRect = result;
      final Rect centerCropRect = getDestinationRect(
          rect: layoutRect, inputSize: result.size, fit: widget.fit);
      final Rect newScreenCropRect =
          centerCropRect.shift(widget.editActionDetails.layoutTopLeft!);
      _doCropAutoCenterAnimation(newScreenCropRect: newScreenCropRect);
    } else {
      result = _doWithMaxScale(result);

      if (result != null && result != cropRect && mounted) {
        setState(() {
          cropRect = result;
        });
      }
    }
  }

  /// handle crop rect with aspectRatio
  Rect _handleAspectRatio(double gWidth, _MoveType moveType, Rect result,
      Rect? layerDestinationRect, Offset delta) {
    final double? aspectRatio = widget.editActionDetails.cropAspectRatio;
    // do with aspect ratio
    if (aspectRatio != null) {
      final double minD = gWidth * 2;
      switch (moveType) {
        case _MoveType.top:
        case _MoveType.bottom:
          final bool isTop = moveType == _MoveType.top;
          result = _doAspectRatioV(
              minD, result, aspectRatio, layerDestinationRect!,
              isTop: isTop);
          break;
        case _MoveType.left:
        case _MoveType.right:
          final bool isLeft = moveType == _MoveType.left;
          result = _doAspectRatioH(
              minD, result, aspectRatio, layerDestinationRect!,
              isLeft: isLeft);
          break;
        case _MoveType.topLeft:
        case _MoveType.topRight:
        case _MoveType.bottomRight:
        case _MoveType.bottomLeft:
          final double dx = delta.dx.abs();
          final double dy = delta.dy.abs();
          double width = result.width;
          double height = result.height;
          if (dx.greaterThanOrEqualTo(dy)) {
            height = max(minD,
                min(result.width / aspectRatio, layerDestinationRect!.height));
            width = height * aspectRatio;
          } else {
            width = max(minD,
                min(result.height * aspectRatio, layerDestinationRect!.width));
            height = width / aspectRatio;
          }
          double top = result.top;
          double left = result.left;
          switch (moveType) {
            case _MoveType.topLeft:
              top = result.bottom - height;
              left = result.right - width;
              break;
            case _MoveType.topRight:
              top = result.bottom - height;
              left = result.left;
              break;
            case _MoveType.bottomRight:
              top = result.top;
              left = result.left;
              break;
            case _MoveType.bottomLeft:
              top = result.top;
              left = result.right - width;
              break;
            default:
          }
          result = Rect.fromLTWH(left, top, width, height);
          break;
        default:
      }
    }
    return result;
  }

  ///horizontal
  Rect _doAspectRatioH(
      double minD, Rect result, double aspectRatio, Rect layerDestinationRect,
      {required bool isLeft}) {
    final double height =
        max(minD, min(result.width / aspectRatio, layerDestinationRect.height));
    final double width = height * aspectRatio;
    final double left = isLeft ? result.right - width : result.left;
    final double top = result.centerRight.dy - height / 2.0;
    result = Rect.fromLTWH(left, top, width, height);
    return result;
  }

  ///vertical
  Rect _doAspectRatioV(
      double minD, Rect result, double aspectRatio, Rect layerDestinationRect,
      {required bool isTop}) {
    final double width =
        max(minD, min(result.height * aspectRatio, layerDestinationRect.width));
    final double height = width / aspectRatio;
    final double top = isTop ? result.bottom - height : result.top;
    final double left = result.topCenter.dx - width / 2.0;
    result = Rect.fromLTWH(left, top, width, height);
    return result;
  }

  Rect? _doWithMaxScale(Rect rect) {
    final Rect centerCropRect = getDestinationRect(
        rect: layoutRect, inputSize: rect.size, fit: widget.fit);
    final Rect newScreenCropRect =
        centerCropRect.shift(widget.editActionDetails.layoutTopLeft!);

    final Rect oldScreenCropRect = widget.editActionDetails.screenCropRect!;

    final double scale = newScreenCropRect.width / oldScreenCropRect.width;

    final double totalScale = widget.editActionDetails.totalScale * scale;
    if (totalScale.greaterThan(widget.editorConfig.maxScale)) {
      if (rect.width.greaterThan(cropRect!.width) ||
          rect.height.greaterThan(cropRect!.height)) {
        return rect;
      }
      return null;
    }

    return rect;
  }

  void _moveEnd(_MoveType moveType) {
    if (_currentMoveType != null && moveType == _currentMoveType) {
      _currentMoveType = null;
      //if (widget.editorConfig.autoCenter)
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    if (isAnimating) {
      return;
    }
    _timer = Timer.periodic(widget.editorConfig.tickerDuration, (Timer timer) {
      _timer?.cancel();

      //move to center
      final Rect? oldScreenCropRect = widget.editActionDetails.screenCropRect;

      final Rect centerCropRect = getDestinationRect(
          rect: layoutRect, inputSize: cropRect!.size, fit: widget.fit);
      final Rect newScreenCropRect =
          centerCropRect.shift(widget.editActionDetails.layoutTopLeft!);

      _rectAnimation = _rectTweenController.drive<Rect?>(
          RectTween(begin: oldScreenCropRect, end: newScreenCropRect));
      _rectTweenController.reset();
      _rectTweenController.forward();
    });
  }

  void _doCropAutoCenterAnimation({Rect? newScreenCropRect}) {
    if (mounted) {
      setState(() {
        final Rect oldScreenCropRect = widget.editActionDetails.screenCropRect!;
        final Rect oldScreenDestinationRect =
            widget.editActionDetails.screenDestinationRect!;

        newScreenCropRect ??= _rectAnimation!.value;

        final double scale = newScreenCropRect!.width / oldScreenCropRect.width;

        final Offset offset =
            newScreenCropRect!.center - oldScreenCropRect.center;

        /// scale then move
        /// so we do scale first, get the new center
        /// then move to new offset
        final Offset newImageCenter = oldScreenCropRect.center +
            (oldScreenDestinationRect.center - oldScreenCropRect.center) *
                scale;
        final Rect newScreenDestinationRect = Rect.fromCenter(
          center: newImageCenter + offset,
          width: oldScreenDestinationRect.width * scale,
          height: oldScreenDestinationRect.height * scale,
        );

        // var totalScale = newScreenDestinationRect.width /
        //     (widget.editActionDetails.rawDestinationRect.width *
        //     widget.editorConfig.initialScale);
        final double totalScale = widget.editActionDetails.totalScale * scale;

        cropRect =
            newScreenCropRect!.shift(-widget.editActionDetails.layoutTopLeft!);

        widget.editActionDetails
            .setScreenDestinationRect(newScreenDestinationRect);
        widget.editActionDetails.totalScale = totalScale;
        widget.editActionDetails.preTotalScale = totalScale;
      });
    }
  }
}
