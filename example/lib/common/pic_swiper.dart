import 'dart:async';

import 'package:extended_image/extended_image.dart';
//import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:flutter/rendering.dart';

class PicSwiper extends StatefulWidget {
  final int index;
  final List<PicSwiperItem> pics;
  PicSwiper(this.index, this.pics);
  @override
  _PicSwiperState createState() => _PicSwiperState();
}

class _PicSwiperState extends State<PicSwiper> {
  var rebuild = StreamController<int>.broadcast();
  int currentIndex;

  @override
  void initState() {
    currentIndex = widget.index;
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    rebuild.close();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Column(
      children: <Widget>[
        AppBar(
          actions: <Widget>[
            GestureDetector(
              child: Container(
                padding: EdgeInsets.only(right: 10.0),
                alignment: Alignment.center,
                child: Text(
                  "Save",
                  style: TextStyle(fontSize: 16.0, color: Colors.white),
                ),
              ),
              onTap: () {
                saveNetworkImageToPhoto(widget.pics[currentIndex].picUrl)
                    .then((bool done) {
                  showToast(done ? "save succeed" : "save failed",
                      position: ToastPosition(align: Alignment.topCenter));
                });
              },
            )
          ],
        ),
        Expanded(
            child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            PageView.builder(
              itemBuilder: (BuildContext context, int index) {
                var item = widget.pics[index].picUrl;
                Widget image = ExtendedImage.network(
                  item,
                  fit: BoxFit.contain,
                  //enableLoadState: false,
                  mode: ExtendedImageMode.Gesture,
                );

//                image = ScalableImage(
//                  imageProvider: NetworkImage(item),
//                );

                image = Container(
                  child: image,
                  padding: EdgeInsets.all(5.0),
                );
                if (index == currentIndex) {
                  return Hero(
                    tag: item + index.toString(),
                    child: image,
                  );
                } else {
                  return image;
                }
              },
              itemCount: widget.pics.length,
              onPageChanged: (int index) {
                currentIndex = index;
                rebuild.add(index);
              },
              controller: PageController(initialPage: currentIndex),
            ),
            Positioned(
              bottom: 0.0,
              left: 0.0,
              right: 0.0,
              child: MySwiperPlugin(widget.pics, currentIndex, rebuild),
            )
          ],
        ))
      ],
    ));
  }
}

class MySwiperPlugin extends StatelessWidget {
  final List<PicSwiperItem> pics;
  final int index;
  final StreamController<int> reBuild;
  MySwiperPlugin(this.pics, this.index, this.reBuild);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      builder: (BuildContext context, data) {
        return DefaultTextStyle(
          style: TextStyle(color: Colors.blue),
          child: Container(
            height: 50.0,
            width: double.infinity,
            color: Colors.grey.withOpacity(0.2),
            child: Row(
              children: <Widget>[
                Container(
                  width: 10.0,
                ),
                Text(
                  pics[data.data].des ?? "",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Expanded(
                  child: Container(),
                ),
                Text(
                  "${data.data + 1}",
                ),
                Text(
                  " / ${pics.length}",
                ),
                Container(
                  width: 10.0,
                ),
              ],
            ),
          ),
        );
      },
      initialData: index,
      stream: reBuild.stream,
    );
  }
}

class PicSwiperItem {
  String picUrl;
  String des;
  PicSwiperItem(this.picUrl, {this.des = ""});
}

//typedef IndexedWidgetBuilder = Widget Function(
//    BuildContext context, int index, int currentIndex);
//
//class MySwiperPlugin extends SwiperPlugin {
//  final List<PicSwiperItem> pics;
//  MySwiperPlugin(this.pics);
//
//  @override
//  Widget build(BuildContext context, SwiperPluginConfig config) {
//    return DefaultTextStyle(
//      style: TextStyle(color: Colors.white),
//      child: Container(
//        height: 50.0,
//        width: double.infinity,
//        color: Colors.grey,
//        child: Row(
//          children: <Widget>[
//            Container(
//              width: 10.0,
//            ),
//            Text(
//              pics[config.activeIndex].des ?? "",
//              maxLines: 1,
//              overflow: TextOverflow.ellipsis,
//            ),
//            Expanded(
//              child: Container(),
//            ),
//            Text(
//              "${config.activeIndex + 1}",
//            ),
//            Text(
//              " / ${config.itemCount}",
//            ),
//            Container(
//              width: 10.0,
//            ),
//          ],
//        ),
//      ),
//    );
//  }
//}

class ScalableImage extends StatefulWidget {
  final Function onTap;

  const ScalableImage(
      {Key key,
      @required ImageProvider imageProvider,
      double maxScale,
      double dragSpeed,
      Size size,
      bool wrapInAspect,
      bool enableScaling,
      this.onTap})
      : assert(imageProvider != null),
        this._imageProvider = imageProvider,
        assert((maxScale ?? 16.0) > 1.0),
        this._maxScale = maxScale ?? 16.0,
        this._dragSpeed = dragSpeed ?? 8.0,
        this._size = size ?? const Size.square(double.infinity),
        this._wrapInAspect = wrapInAspect ?? false,
        this._enableScaling = enableScaling ?? true,
        super(key: key);

  final ImageProvider _imageProvider;
  final bool _wrapInAspect, _enableScaling;
  final double _maxScale, _dragSpeed;
  final Size _size;

  @override
  _ScalableImageState createState() => new _ScalableImageState();
}

class _ScalableImageState extends State<ScalableImage> {
  ImageStream _imageStream;
  ImageInfo _imageInfo;
  double _scale = 1.0;
  double _lastEndScale = 1.0;
  Offset _offset = Offset.zero;
  Offset _lastFocalPoint;
  Size _imageSize;
  Offset _targetPointPixelSpace;
  Offset _targetPointDrawSpace;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _getImage();
  }

  @override
  void didUpdateWidget(ScalableImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget._imageProvider != oldWidget._imageProvider) _getImage();
  }

  void _getImage() {
    final ImageStream oldImageStream = _imageStream;
    _imageStream =
        widget._imageProvider.resolve(createLocalImageConfiguration(context));
    if (_imageStream.key != oldImageStream?.key) {
      oldImageStream?.removeListener(_updateImage);
      _imageStream.addListener(_updateImage);
    }
  }

  void _updateImage(ImageInfo imageInfo, bool synchronousCall) {
    setState(() {
      _imageInfo = imageInfo;
      _imageSize = _imageInfo == null
          ? null
          : new Size(_imageInfo.image.width.toDouble(),
              _imageInfo.image.height.toDouble());
    });
  }

  @override
  void dispose() {
    _imageStream.removeListener(_updateImage);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_imageInfo == null) {
      return new Container(
        alignment: Alignment.center,
        child: new FractionallySizedBox(
          widthFactor: 0.1,
          child: new AspectRatio(
            aspectRatio: 1.0,
            child: new CircularProgressIndicator(),
          ),
        ),
      );
    } else {
      Widget painter = new CustomPaint(
        size: widget._size,
        painter: new _ScalableImagePainter(_imageInfo.image, _offset, _scale),
        willChange: true,
      );
      if (widget._wrapInAspect) {
        painter = new AspectRatio(
            aspectRatio: _imageSize.width / _imageSize.height, child: painter);
      }
      if (widget._enableScaling) {
        return Listener(
          onPointerDown: _onPointerDown,
          child: new GestureDetector(
            child: painter,
            onDoubleTap: _handleDoubleTap,
            onScaleUpdate: _handleScaleUpdate,
            onScaleEnd: _handleScaleEnd,
            onScaleStart: _handleScaleStart,
            onHorizontalDragStart: _scale == 1.0 ? null : _handlePanStart,
            onHorizontalDragUpdate: _scale == 1.0 ? null : _handlePanUpdate,
//          onPanStart: _scale == 1.0 ? null : _handlePanStart,
//          onPanUpdate: _scale == 1.0 ? null : _handlePanUpdate,
//          onVerticalDragStart: _scale == 1.0 ? null : _handlePanStart,
//          onVerticalDragUpdate: _scale == 1.0 ? null : _handlePanUpdate,
            onTap: () {
              if (_scale != 1.0) {
                setState(() {
                  _scale = 1.0;
                  _offset = Offset.zero;
                });
              } else {
                if (widget.onTap != null) widget.onTap();
              }
            },
//            onTapDown: _handleTapDown,
//            onTapUp: _handleTapUp,
          ),
        );
      } else {
        return painter;
      }
    }
  }

  Offset _panStart;

  void _handlePanStart(DragStartDetails details) {
    _panStart = (context.findRenderObject() as RenderBox)
        .globalToLocal(details.globalPosition);
//    _targetPointPixelSpace = drawSpaceToPixelSpace(_targetPointDrawSpace, context.size, _offset, _imageSize, _scale);
//
//    _panStart = _targetPointDrawSpace;
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    var localPosition = (context.findRenderObject() as RenderBox)
        .globalToLocal(details.globalPosition);
    var translateX = (_panStart.dx - localPosition.dx) /* / _scale*/;
    var translateY = (_panStart.dy - localPosition.dy) /* / _scale*/;

    var newOffset = _offset.translate(translateX, translateY);
    _panStart = localPosition;

//    print(newOffset);

    //Don't move to far left
    newOffset = _elementwiseMax(newOffset, Offset.zero);
    //Nor to far right
    double borderScale = 1.0 - 1.0 / _scale;
    newOffset = _elementwiseMin(newOffset, _asOffset(_imageSize * borderScale));

    setState(() {
      _offset = newOffset;
    });
  }

  void _handleScaleStart(ScaleStartDetails start) {
//    print("_handleScaleStart");
    _lastFocalPoint = start.focalPoint;
    _targetPointDrawSpace = (context.findRenderObject() as RenderBox)
        .globalToLocal(start.focalPoint);
    _targetPointPixelSpace = drawSpaceToPixelSpace(
        _targetPointDrawSpace, context.size, _offset, _imageSize, _scale);
  }

  void _handleScaleEnd(ScaleEndDetails end) {
    _lastEndScale = _scale;
  }

  void _handleScaleUpdate(ScaleUpdateDetails event) {
    //init old values
    double newScale = _scale;
    Offset newOffset = _offset;

    if (event.scale == 1.0) {
      //This is a movement
      //Calculate movement since last call
      Offset delta =
          (_lastFocalPoint - event.focalPoint) * widget._dragSpeed / _scale;
      //Store the new information
      _lastFocalPoint = event.focalPoint;
      //And move it
      newOffset += delta;
    } else {
      //Round the scale to three points after comma to prevent shaking
      double roundedScale = _roundAfter(event.scale, 3);
      //Calculate new scale but do not scale to far out or in
      newScale = min(widget._maxScale, max(1.0, roundedScale * _lastEndScale));
      //Move the offset so that the target point stays at the same position after scaling
      newOffset = _elementwiseDivision(
              _targetPointDrawSpace,
              -_linearTransformationFactor(
                  context.size, _imageSize, newScale)) +
          _targetPointPixelSpace;
    }
    //Don't move to far left
    newOffset = _elementwiseMax(newOffset, Offset.zero);
    //Nor to far right
    double borderScale = 1.0 - 1.0 / newScale;
    newOffset = _elementwiseMin(newOffset, _asOffset(_imageSize * borderScale));

    if (newScale != _scale || newOffset != _offset) {
      setState(() {
        _scale = newScale;
        _offset = newOffset;
      });
    }
  }

  void _handleDoubleTap() {
//    print("_scale = $_scale");
    setState(() {
      _scale = _scale == 1.0 ? 4.0 : 1.0;
      if (_scale == 1.0) {
        _offset = Offset.zero;
      } else {
        _offset = _doubleStartPosition;
      }
    });
  }
//
//  void _handleTapDown(TapDownDetails details) {
//    var dx = details.globalPosition.dx;
//    var dy = details.globalPosition.dy;
////    print("TapDown dx = $dx dy = $dy");
//  }
//
//  void _handleTapUp(TapUpDetails details) {
//    var dx = details.globalPosition.dx;
//    var dy = details.globalPosition.dy;
////    print("TapUp dx = $dx dy = $dy");
//  }

  void _onPointerDown(PointerDownEvent event) {
    var position = event.position;
    _doubleStartPosition =
        (context.findRenderObject() as RenderBox).globalToLocal(position);
  }

  Offset _doubleStartPosition = Offset.zero;
}

class _ScalableImagePainter extends CustomPainter {
  final Image _image;
  final Paint _paint;
  final Rect _rect;

  _ScalableImagePainter(this._image, Offset offset, double scale)
      : this._rect = new Rect.fromLTWH(offset.dx, offset.dy,
            _image.width.toDouble() / scale, _image.height.toDouble() / scale),
        this._paint = new Paint();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImageRect(_image, _rect,
        new Rect.fromLTWH(0.0, 0.0, size.width, size.height), _paint);
  }

  @override
  bool shouldRepaint(_ScalableImagePainter oldDelegate) {
    return _rect != oldDelegate._rect || _image != oldDelegate._image;
  }
}

Offset _linearTransformationFactor(
    Size drawSpaceSize, Size imageSize, double scale) {
  return new Offset(drawSpaceSize.width / (imageSize.width / scale),
      drawSpaceSize.height / (imageSize.height / scale));
}

Offset pixelSpaceToDrawSpace(Offset pixelSpace, Size drawSpaceSize,
    Offset offset, Size imageSize, double scale) {
  return _elementwiseMultiplication(pixelSpace - offset,
      _linearTransformationFactor(drawSpaceSize, imageSize, scale));
}

Offset drawSpaceToPixelSpace(Offset drawSpace, Size drawSpaceSize,
    Offset offset, Size imageSize, double scale) {
  return _elementwiseDivision(drawSpace,
          _linearTransformationFactor(drawSpaceSize, imageSize, scale)) +
      offset;
}

double _roundAfter(double number, int position) {
  double shift = pow(10, position).toDouble();
  return (number * shift).roundToDouble() / shift;
}

Offset _elementwiseDivision(Offset dividend, Offset divisor) {
  return dividend.scale(1.0 / divisor.dx, 1.0 / divisor.dy);
}

Offset _elementwiseMultiplication(Offset a, Offset b) {
  return a.scale(b.dx, b.dy);
}

Offset _elementwiseMin(Offset a, Offset b) {
  return new Offset(min(a.dx, b.dx), min(a.dy, b.dy));
}

Offset _elementwiseMax(Offset a, Offset b) {
  return new Offset(max(a.dx, b.dx), max(a.dy, b.dy));
}

Offset _asOffset(Size s) {
  return new Offset(s.width, s.height);
}

/// Draw the canvas from the ui.Image. copy from flutter.io's
//void _paintImage(
//    ui.Image image, Rect outputRect, Canvas canvas, Paint paint, BoxFit fit) {
//  final Size imageSize =
//      new Size(image.width.toDouble(), image.height.toDouble());
//  final FittedSizes sizes = applyBoxFit(fit, imageSize, outputRect.size);
//  final Rect inputSubrect =
//      Alignment.center.inscribe(sizes.source, Offset.zero & imageSize);
//  final Rect outputSubrect =
//      Alignment.center.inscribe(sizes.destination, outputRect);
//  canvas.drawImageRect(image, inputSubrect, outputSubrect, paint);
//}
