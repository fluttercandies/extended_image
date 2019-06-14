import 'dart:async';
import 'dart:math';

import 'package:example/main.dart';
import 'package:extended_image/extended_image.dart';
import 'package:oktoast/oktoast.dart';
import 'dart:ui';
import 'package:flutter/material.dart' hide Image;
import 'package:flutter/rendering.dart';

class PicSwiper extends StatefulWidget {
  final int index;
  final List<PicSwiperItem> pics;
  PicSwiper(this.index, this.pics);
  @override
  _PicSwiperState createState() => _PicSwiperState();
}

class _PicSwiperState extends State<PicSwiper>
    with SingleTickerProviderStateMixin {
  var rebuild = StreamController<int>.broadcast();
  AnimationController _animationController;
  Animation<double> _animation;
  Function animationListener;
//  CancellationToken _cancelToken;
//  CancellationToken get cancelToken {
//    if (_cancelToken == null || _cancelToken.isCanceled)
//      _cancelToken = CancellationToken();
//
//    return _cancelToken;
//  }
  List<double> doubleTapScales = <double>[1.0, 2.0];

  int currentIndex;

  @override
  void initState() {
    currentIndex = widget.index;
    _animationController = AnimationController(
        duration: const Duration(milliseconds: 150), vsync: this);
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    rebuild.close();
    _animationController?.dispose();
    clearGestureDetailsCache();
    //cancelToken?.cancel();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Material(

        /// if you use ExtendedImageSlidePage and slideType =SlideType.onlyImage,
        /// make sure your page is transparent background
        color: Colors.transparent,
        shadowColor: Colors.transparent,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            ExtendedImageGesturePageView.builder(
              itemBuilder: (BuildContext context, int index) {
                var item = widget.pics[index].picUrl;
                item =
                    "https://gbres.dfcfw.com/Files/picture/20190419/E8A506FEC5728D4ADD5A74AA1B86F14A_w1243h160.jpg";
                item =
                    "https://z1.dfcfw.com/2019/1/2/20190102163807677609656.jpg";
                Widget image = ExtendedImage.network(
                  item,
                  fit: BoxFit.contain,
                  mode: ExtendedImageMode.Gesture,
                  initGestureConfigHandler: (state) {
                    double initialScale = 1.0;

                    if (state.extendedImageInfo != null &&
                        state.extendedImageInfo.image != null) {
                      initialScale = _initalScale(
                          size: size,
                          initialScale: initialScale,
                          imageSize: Size(
                              state.extendedImageInfo.image.width.toDouble(),
                              state.extendedImageInfo.image.height.toDouble()));
                    }
                    return GestureConfig(
                        inPageView: true,
                        initialScale: initialScale,
                        maxScale: max(initialScale, 5.0),
                        animationMaxScale: max(initialScale, 5.0),
                        //you can cache gesture state even though page view page change.
                        //remember call clearGestureDetailsCache() method at the right time.(for example,this page dispose)
                        cacheGesture: false);
                  },
                  onDoubleTap: (ExtendedImageGestureState state) {
                    ///you can use define pointerDownPosition as you can,
                    ///default value is double tap pointer down postion.
                    var pointerDownPosition = state.pointerDownPosition;
                    double begin = state.gestureDetails.totalScale;
                    double end;

                    //remove old
                    _animation?.removeListener(animationListener);

                    //stop pre
                    _animationController.stop();

                    //reset to use
                    _animationController.reset();

                    if (begin == doubleTapScales[0]) {
                      end = doubleTapScales[1];
                    } else {
                      end = doubleTapScales[0];
                    }

                    animationListener = () {
                      //print(_animation.value);
                      state.handleDoubleTap(
                          scale: _animation.value,
                          doubleTapPosition: pointerDownPosition);
                    };
                    _animation = _animationController
                        .drive(Tween<double>(begin: begin, end: end));

                    _animation.addListener(animationListener);

                    _animationController.forward();
                  },
                );
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
              controller: PageController(
                initialPage: currentIndex,
              ),
              scrollDirection: Axis.horizontal,
              physics: BouncingScrollPhysics(),
              //physics: ClampingScrollPhysics(),
            ),
            Positioned(
              bottom: 0.0,
              left: 0.0,
              right: 0.0,
              child: MySwiperPlugin(widget.pics, currentIndex, rebuild),
            )
          ],
        ));
  }

  double _initalScale({Size imageSize, Size size, double initialScale}) {
    var n1 = imageSize.height / imageSize.width;
    var n2 = size.height / size.width;
    if (n1 > n2) {
      final FittedSizes fittedSizes =
          applyBoxFit(BoxFit.contain, imageSize, size);
      //final Size sourceSize = fittedSizes.source;
      Size destinationSize = fittedSizes.destination;
      return size.width / destinationSize.width;
    } else if (n1 / n2 < 1 / 4) {
      final FittedSizes fittedSizes =
          applyBoxFit(BoxFit.contain, imageSize, size);
      //final Size sourceSize = fittedSizes.source;
      Size destinationSize = fittedSizes.destination;
      return size.height / destinationSize.height;
    }

    return initialScale;
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
                  "${data.data + 1}",
                ),
                Text(
                  " / ${pics.length}",
                ),
                Expanded(
                    child: Text(pics[data.data].des ?? "",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 16.0, color: Colors.blue))),
                Container(
                  width: 10.0,
                ),
                GestureDetector(
                  child: Container(
                    padding: EdgeInsets.only(right: 10.0),
                    alignment: Alignment.center,
                    child: Text(
                      "Save",
                      style: TextStyle(fontSize: 16.0, color: Colors.blue),
                    ),
                  ),
                  onTap: () {
                    saveNetworkImageToPhoto(pics[index].picUrl)
                        .then((bool done) {
                      showToast(done ? "save succeed" : "save failed",
                          position: ToastPosition(align: Alignment.topCenter));
                    });
                  },
                )
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
