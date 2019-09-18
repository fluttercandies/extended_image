import 'dart:async';
import 'dart:math';

import 'package:example/common/utils.dart';
import 'package:example/main.dart';
import 'package:extended_image/extended_image.dart';
import 'package:oktoast/oktoast.dart';
import 'dart:ui';
import 'package:flutter/material.dart' hide Image;
import 'package:flutter/rendering.dart';
import 'package:ff_annotation_route/ff_annotation_route.dart';

@FFRoute(
    name: "fluttercandies://picswiper",
    routeName: "PicSwiper",
    argumentNames: ["index", "pics"],
    showStatusBar: false,
    pageRouteType: PageRouteType.transparent)
class PicSwiper extends StatefulWidget {
  final int index;
  final List<PicSwiperItem> pics;
  PicSwiper({this.index, this.pics});
  @override
  _PicSwiperState createState() => _PicSwiperState();
}

class _PicSwiperState extends State<PicSwiper>
    with SingleTickerProviderStateMixin {
  var rebuildIndex = StreamController<int>.broadcast();
  var rebuildSwiper = StreamController<bool>.broadcast();
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
  GlobalKey<ExtendedImageSlidePageState> slidePagekey =
      GlobalKey<ExtendedImageSlidePageState>();
  int currentIndex;
  bool _showSwiper = true;

  @override
  void initState() {
    currentIndex = widget.index;
    _animationController = AnimationController(
        duration: const Duration(milliseconds: 150), vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    rebuildIndex.close();
    rebuildSwiper.close();
    _animationController?.dispose();
    clearGestureDetailsCache();
    //cancelToken?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    Widget result = Material(

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
                Widget image = ExtendedImage.network(
                  item,
                  fit: BoxFit.contain,
                  enableSlideOutPage: true,
                  mode: ExtendedImageMode.gesture,
                  heroBuilderForSlidingPage: (Widget result) {
                    if (index == currentIndex) {
                      return Hero(
                        tag: item + index.toString(),
                        child: result,
                        flightShuttleBuilder: (BuildContext flightContext,
                            Animation<double> animation,
                            HeroFlightDirection flightDirection,
                            BuildContext fromHeroContext,
                            BuildContext toHeroContext) {
                          final Hero hero =
                              flightDirection == HeroFlightDirection.pop
                                  ? fromHeroContext.widget
                                  : toHeroContext.widget;
                          return hero.child;
                        },
                      );
                    } else {
                      return result;
                    }
                  },
                  initGestureConfigHandler: (state) {
                    double initialScale = 1.0;

                    if (state.extendedImageInfo != null &&
                        state.extendedImageInfo.image != null) {
                      initialScale = initScale(
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
                image = GestureDetector(
                  child: image,
                  onTap: () {
                    slidePagekey.currentState.popPage();
                    Navigator.pop(context);
                  },
                );

                return image;
              },
              itemCount: widget.pics.length,
              onPageChanged: (int index) {
                currentIndex = index;
                rebuildIndex.add(index);
              },
              controller: PageController(
                initialPage: currentIndex,
              ),
              scrollDirection: Axis.horizontal,
              physics: BouncingScrollPhysics(),
//              //move page only when scale is not more than 1.0
//              canMovePage: (GestureDetails gestureDetails) =>
//                  gestureDetails.totalScale <= 1.0,
              //physics: ClampingScrollPhysics(),
            ),
            StreamBuilder<bool>(
              builder: (c, d) {
                if (d.data == null || !d.data) return Container();

                return Positioned(
                  bottom: 0.0,
                  left: 0.0,
                  right: 0.0,
                  child:
                      MySwiperPlugin(widget.pics, currentIndex, rebuildIndex),
                );
              },
              initialData: true,
              stream: rebuildSwiper.stream,
            )
          ],
        ));

    result = ExtendedImageSlidePage(
      key: slidePagekey,
      child: result,
      slideAxis: SlideAxis.both,
      slideType: SlideType.onlyImage,
      onSlidingPage: (state) {
        ///you can change other widgets' state on page as you want
        ///base on offset/isSliding etc
        //var offset= state.offset;
        var showSwiper = !state.isSliding;
        if (showSwiper != _showSwiper) {
          // do not setState directly here, the image state will change,
          // you should only notify the widgets which are needed to change
          // setState(() {
          // _showSwiper = showSwiper;
          // });

          _showSwiper = showSwiper;
          rebuildSwiper.add(_showSwiper);
        }
      },
    );

    return result;
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
