import 'dart:async';
import 'dart:math';

@FFAutoImport()
import 'package:example/common/data/tu_chong_source.dart' hide asT;
@FFAutoImport()
import 'package:example/common/model/pic_swiper_item.dart';
// import 'package:example/common/text/my_extended_text_selection_controls.dart';
// import 'package:example/common/text/my_special_text_span_builder.dart';
import 'package:example/common/utils/util.dart';
import 'package:extended_image/extended_image.dart';
//import 'package:extended_text/extended_text.dart';
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:oktoast/oktoast.dart';
// import 'package:url_launcher/url_launcher.dart';

import 'hero.dart';
import 'item_builder.dart';

const String attachContent =
    '''[love]Extended text help you to build rich text quickly. any special text you will have with extended text.It's my pleasure to invite you to join \$FlutterCandies\$ if you want to improve flutter .[love] if you meet any problem, please let me konw @zmtzawqlp .[sun_glasses]''';

typedef DoubleClickAnimationListener = void Function();

class FloatText extends StatelessWidget {
  const FloatText(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3.0),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.6),
        border:
            Border.all(color: Colors.grey.withValues(alpha: 0.4), width: 1.0),
        borderRadius: const BorderRadius.all(
          Radius.circular(5.0),
        ),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}

class ImageDetail extends StatelessWidget {
  const ImageDetail(
    this.info,
    this.index,
    this.tuChongItem,
  );
  final ImageDetailInfo? info;
  final int index;
  final TuChongItem? tuChongItem;
  @override
  Widget build(BuildContext context) {
    String content =
        tuChongItem!.content ?? (tuChongItem!.excerpt ?? tuChongItem!.title!);
    content += attachContent * 2;
    final Widget result = Container(
      // constraints: BoxConstraints(minHeight: 25.0),
      key: info!.key,
      margin: const EdgeInsets.only(
        left: 5,
        right: 5,
      ),
      padding: const EdgeInsets.all(20.0),
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              buildTagsWidget(
                tuChongItem!,
                maxNum: tuChongItem!.tags!.length,
              ),
              const SizedBox(
                height: 15.0,
              ),
              Text(
                content,
                // onSpecialTextTap: (dynamic parameter) {
                //   if (parameter.toString().startsWith('\$')) {
                //     launchUrl(Uri.parse('https://github.com/fluttercandies'));
                //   } else if (parameter.toString().startsWith('@')) {
                //     launchUrl(Uri.parse('mailto:zmtzawqlp@live.com'));
                //   }
                // },
                // specialTextSpanBuilder: MySpecialTextSpanBuilder(),
                //overflow: ExtendedTextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                maxLines: 10,
                // overflowWidget: TextOverflowWidget(
                //   //maxHeight: double.infinity,
                //   //align: TextOverflowAlign.right,
                //   //fixedOffset: Offset.zero,
                //   //debugOverflowRectColor: Colors.red,
                //   child: DefaultTextStyle(
                //     style: const TextStyle(fontSize: 12, color: Colors.blue),
                //     child: Row(
                //       mainAxisSize: MainAxisSize.min,
                //       children: <Widget>[
                //         const Text('\u2026 '),
                //         GestureDetector(
                //           child: const Text('more'),
                //           onTap: () {
                //             launchUrl(Uri.parse(
                //                 'https://github.com/fluttercandies/extended_text'));
                //           },
                //         )
                //       ],
                //     ),
                //   ),
                // ),
                // selectionEnabled: true,
                // selectionControls: MyTextSelectionControls(),
              ),
              const SizedBox(
                height: 20.0,
              ),
              const Divider(height: 1),
              const SizedBox(
                height: 20.0,
              ),
              buildBottomWidget(
                tuChongItem!,
                showAvatar: true,
              ),
            ],
          ),
          Positioned(
            top: -30.0,
            left: -15.0,
            child: FloatText(
              '${(index + 1).toString().padLeft(tuChongItem!.images!.length.toString().length, '0')}/${tuChongItem!.images!.length}',
            ),
          ),
          if (tuChongItem != null)
            Positioned(
              top: -30.0,
              right: -15.0,
              child: FloatText(
                '${tuChongItem?.imageSize.width.toInt()} * ${tuChongItem?.imageSize.height.toInt()}',
              ),
            ),
          const Positioned(
            top: -33.0,
            right: 0,
            left: 0,
            child: SingleChildScrollView(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.star,
                    color: Colors.yellow,
                  ),
                  Icon(
                    Icons.star,
                    color: Colors.yellow,
                  ),
                  Icon(
                    Icons.star,
                    color: Colors.yellow,
                  ),
                  Icon(
                    Icons.star,
                    color: Colors.yellow,
                  ),
                  Icon(
                    Icons.star,
                    color: Colors.yellow,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          border: Border.all(
            color: Colors.grey,
          ),
          boxShadow: const <BoxShadow>[
            BoxShadow(color: Colors.grey, blurRadius: 15.0, spreadRadius: 20.0),
          ]),
    );
    return result;
    // return ExtendedTextSelectionPointerHandler(
    //   //default behavior
    //   // child: result,
    //   //custom your behavior
    //   builder: (List<ExtendedTextSelectionState> states) {
    //     return GestureDetector(
    //       onTap: () {
    //         //do not pop page
    //       },
    //       child: Listener(
    //         child: result,
    //         behavior: HitTestBehavior.translucent,
    //         onPointerDown: (PointerDownEvent value) {
    //           for (final ExtendedTextSelectionState state in states) {
    //             if (!state.containsPosition(value.position)) {
    //               //clear other selection
    //               state.clearSelection();
    //             }
    //           }
    //         },
    //         onPointerMove: (PointerMoveEvent value) {
    //           //clear other selection
    //           for (final ExtendedTextSelectionState state in states) {
    //             state.clearSelection();
    //           }
    //         },
    //       ),
    //     );
    //   },
    // );
  }
}

class ImageDetailInfo {
  ImageDetailInfo({
    required this.imageDRect,
    required this.pageSize,
    required this.imageInfo,
  });
  final GlobalKey<State<StatefulWidget>> key = GlobalKey<State>();

  final Rect imageDRect;

  final Size pageSize;

  final ImageInfo imageInfo;

  double? _maxImageDetailY;
  double get imageBottom => imageDRect.bottom - 20;
  double get maxImageDetailY {
    try {
      //
      return _maxImageDetailY ??= max(
          key.currentContext!.size!.height - (pageSize.height - imageBottom),
          0.1);
    } catch (e) {
      //currentContext is not ready
      return 100.0;
    }
  }
}

class MySwiperPlugin extends StatelessWidget {
  const MySwiperPlugin(this.pics, this.index, this.reBuild);
  final List<PicSwiperItem>? pics;
  final int? index;
  final StreamController<int> reBuild;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      builder: (BuildContext context, AsyncSnapshot<int> data) {
        return DefaultTextStyle(
          style: const TextStyle(color: Colors.blue),
          child: Container(
            height: 50.0,
            width: double.infinity,
            color: Colors.grey.withValues(alpha: 0.2),
            child: Row(
              children: <Widget>[
                Container(
                  width: 10.0,
                ),
                Text(
                  '${data.data! + 1}',
                ),
                Text(
                  ' / ${pics!.length}',
                ),
                const SizedBox(
                  width: 10.0,
                ),
                Expanded(
                    child: Text(pics![data.data!].des ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 16.0, color: Colors.blue))),
                const SizedBox(
                  width: 10.0,
                ),
                if (!kIsWeb)
                  GestureDetector(
                    child: Container(
                      padding: const EdgeInsets.only(right: 10.0),
                      alignment: Alignment.center,
                      child: const Text(
                        'Save',
                        style: TextStyle(fontSize: 16.0, color: Colors.blue),
                      ),
                    ),
                    onTap: () {
                      saveNetworkImageToPhoto(pics![index!].picUrl)
                          .then((bool done) {
                        showToast(done ? 'save succeed' : 'save failed',
                            position: const ToastPosition(
                                align: Alignment.topCenter));
                      });
                    },
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

@FFRoute(
  name: 'fluttercandies://picswiper',
  routeName: 'PicSwiper',
  showStatusBar: false,
  pageRouteType: PageRouteType.transparent,
)
class PicSwiper extends StatefulWidget {
  const PicSwiper({
    this.index,
    this.pics,
    this.tuChongItem,
  });
  final int? index;
  final List<PicSwiperItem>? pics;
  final TuChongItem? tuChongItem;
  @override
  _PicSwiperState createState() => _PicSwiperState();
}

class _PicSwiperState extends State<PicSwiper> with TickerProviderStateMixin {
  final StreamController<int> rebuildIndex = StreamController<int>.broadcast();
  final StreamController<bool> rebuildSwiper =
      StreamController<bool>.broadcast();
  final StreamController<double> rebuildDetail =
      StreamController<double>.broadcast();
  final Map<int, ImageDetailInfo> detailKeys = <int, ImageDetailInfo>{};
  late AnimationController _doubleClickAnimationController;
  late AnimationController _slideEndAnimationController;
  late Animation<double> _slideEndAnimation;
  Animation<double>? _doubleClickAnimation;
  late DoubleClickAnimationListener _doubleClickAnimationListener;
  List<double> doubleTapScales = <double>[1.0, 2.0];
  GlobalKey<ExtendedImageSlidePageState> slidePagekey =
      GlobalKey<ExtendedImageSlidePageState>();
  int? _currentIndex = 0;
  bool _showSwiper = true;
  double _imageDetailY = 0;
  Rect? imageDRect;

  final List<int> _cachedIndexes = <int>[];
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _preloadImage(widget.index! - 1);
    _preloadImage(widget.index! + 1);
  }

  void _preloadImage(int index) {
    if (_cachedIndexes.contains(index)) {
      return;
    }
    if (0 <= index && index < widget.pics!.length) {
      final String url = widget.pics![index].picUrl;

      precacheImage(
        ExtendedNetworkImageProvider(
          url,
          cache: true,
          imageCacheName: 'CropImage',
        ),
        context,
      );

      _cachedIndexes.add(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    imageDRect = Offset.zero & size;
    Widget result = Material(

        /// if you use ExtendedImageSlidePage and slideType =SlideType.onlyImage,
        /// make sure your page is transparent background
        color: Colors.transparent,
        shadowColor: Colors.transparent,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            ExtendedImageGesturePageView.builder(
              controller: ExtendedPageController(
                initialPage: widget.index!,
                pageSpacing: 50,
                shouldIgnorePointerWhenScrolling: false,
              ),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              canScrollPage: (GestureDetails? gestureDetails) {
                return _imageDetailY >= 0;
                //return (gestureDetails?.totalScale ?? 1.0) <= 1.0;
              },
              itemBuilder: (BuildContext context, int index) {
                final String item = widget.pics![index].picUrl;

                Widget image = ExtendedImage.network(
                  item,
                  fit: BoxFit.contain,
                  enableSlideOutPage: true,
                  mode: ExtendedImageMode.gesture,
                  imageCacheName: 'CropImage',
                  //layoutInsets: EdgeInsets.all(20),
                  initGestureConfigHandler: (ExtendedImageState state) {
                    double? initialScale = 1.0;

                    if (state.extendedImageInfo != null) {
                      initialScale = initScale(
                          size: size,
                          initialScale: initialScale,
                          imageSize: Size(
                              state.extendedImageInfo!.image.width.toDouble(),
                              state.extendedImageInfo!.image.height
                                  .toDouble()));
                    }
                    return GestureConfig(
                      inPageView: true,
                      initialScale: initialScale!,
                      maxScale: max(initialScale, 5.0),
                      animationMaxScale: max(initialScale, 5.0),
                      initialAlignment: InitialAlignment.center,
                      //you can cache gesture state even though page view page change.
                      //remember call clearGestureDetailsCache() method at the right time.(for example,this page dispose)
                      cacheGesture: false,
                    );
                  },
                  onDoubleTap: (ExtendedImageGestureState state) {
                    ///you can use define pointerDownPosition as you can,
                    ///default value is double tap pointer down postion.
                    final Offset? pointerDownPosition =
                        state.pointerDownPosition;
                    final double? begin = state.gestureDetails!.totalScale;
                    double end;

                    //remove old
                    _doubleClickAnimation
                        ?.removeListener(_doubleClickAnimationListener);

                    //stop pre
                    _doubleClickAnimationController.stop();

                    //reset to use
                    _doubleClickAnimationController.reset();

                    if (begin == doubleTapScales[0]) {
                      end = doubleTapScales[1];
                    } else {
                      end = doubleTapScales[0];
                    }

                    _doubleClickAnimationListener = () {
                      //print(_animation.value);
                      state.handleDoubleTap(
                          scale: _doubleClickAnimation!.value,
                          doubleTapPosition: pointerDownPosition);
                    };
                    _doubleClickAnimation = _doubleClickAnimationController
                        .drive(Tween<double>(begin: begin, end: end));

                    _doubleClickAnimation!
                        .addListener(_doubleClickAnimationListener);

                    _doubleClickAnimationController.forward();
                  },
                  loadStateChanged: (ExtendedImageState state) {
                    if (state.extendedImageLoadState == LoadState.completed) {
                      final Rect imageDRect = getDestinationRect(
                        rect: Offset.zero & size,
                        inputSize: Size(
                          state.extendedImageInfo!.image.width.toDouble(),
                          state.extendedImageInfo!.image.height.toDouble(),
                        ),
                        fit: BoxFit.contain,
                      );

                      detailKeys[index] ??= ImageDetailInfo(
                        imageDRect: imageDRect,
                        pageSize: size,
                        imageInfo: state.extendedImageInfo!,
                      );
                      final ImageDetailInfo? imageDetailInfo =
                          detailKeys[index];
                      return StreamBuilder<double>(
                        builder:
                            (BuildContext context, AsyncSnapshot<double> data) {
                          return ExtendedImageGesture(
                            state,
                            canScaleImage: (_) => _imageDetailY == 0,
                            imageBuilder: (
                              Widget image, {
                              ExtendedImageGestureState? imageGestureState,
                            }) {
                              return Stack(
                                children: <Widget>[
                                  Positioned.fill(
                                    child: image,
                                    top: _imageDetailY,
                                    bottom: -_imageDetailY,
                                  ),
                                  Positioned(
                                    left: 0.0,
                                    right: 0.0,
                                    top: imageDetailInfo!.imageBottom +
                                        _imageDetailY,
                                    child: Opacity(
                                      opacity: _imageDetailY == 0
                                          ? 0
                                          : min(
                                              1,
                                              _imageDetailY.abs() /
                                                  (imageDetailInfo
                                                          .maxImageDetailY /
                                                      4.0),
                                            ),
                                      child: ImageDetail(
                                        imageDetailInfo,
                                        index,
                                        widget.tuChongItem,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        initialData: _imageDetailY,
                        stream: rebuildDetail.stream,
                      );
                    }
                    return null;
                  },
                );

                if (index < min(9, widget.pics!.length)) {
                  image = HeroWidget(
                    child: image,
                    tag: item,
                    slideType: SlideType.onlyImage,
                    slidePagekey: slidePagekey,
                  );
                }

                image = GestureDetector(
                  child: image,
                  onTap: () {
                    if (_imageDetailY != 0) {
                      _imageDetailY = 0;
                      rebuildDetail.sink.add(_imageDetailY);
                    } else {
                      slidePagekey.currentState!.popPage();
                      Navigator.pop(context);
                    }
                  },
                );

                return image;
              },
              itemCount: widget.pics!.length,
              onPageChanged: (int index) {
                _currentIndex = index;
                rebuildIndex.add(index);
                if (_imageDetailY != 0) {
                  _imageDetailY = 0;
                  rebuildDetail.sink.add(_imageDetailY);
                }
                _showSwiper = true;
                rebuildSwiper.add(_showSwiper);
                _preloadImage(index - 1);
                _preloadImage(index + 1);
              },
            ),
            StreamBuilder<bool>(
              builder: (BuildContext c, AsyncSnapshot<bool> d) {
                if (d.data == null || !d.data!) {
                  return Container();
                }

                return Positioned(
                  top: 0.0,
                  left: 0.0,
                  right: 0.0,
                  child:
                      MySwiperPlugin(widget.pics, _currentIndex, rebuildIndex),
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
      slideAxis: SlideAxis.vertical,
      slideType: SlideType.onlyImage,
      slideScaleHandler: (
        Offset offset, {
        ExtendedImageSlidePageState? state,
      }) {
        if (state == null) {
          return null;
        }
        //image is ready and it's not sliding.
        if (detailKeys[_currentIndex!] != null && state.scale == 1.0) {
          //don't slide page if scale of image is more than 1.0
          if (state.imageGestureState!.gestureDetails!.totalScale! > 1.0) {
            return 1.0;
          }
          //or slide down into detail mode
          if (offset.dy < 0 || _imageDetailY < 0) {
            return 1.0;
          }
        }

        return null;
      },
      slideOffsetHandler: (
        Offset offset, {
        ExtendedImageSlidePageState? state,
      }) {
        if (state == null) {
          return null;
        }
        //image is ready and it's not sliding.
        if (detailKeys[_currentIndex!] != null && state.scale == 1.0) {
          //don't slide page if scale of image is more than 1.0

          if (state.imageGestureState!.gestureDetails!.totalScale! > 1.0) {
            return Offset.zero;
          }

          //or slide down into detail mode
          if (offset.dy < 0 || _imageDetailY < 0) {
            _imageDetailY += offset.dy;

            // print(offset.dy);
            _imageDetailY = max(
                -detailKeys[_currentIndex!]!.maxImageDetailY, _imageDetailY);
            rebuildDetail.sink.add(_imageDetailY);
            return Offset.zero;
          }

          if (_imageDetailY != 0) {
            _imageDetailY = 0;
            _showSwiper = true;
            rebuildSwiper.add(_showSwiper);
            rebuildDetail.sink.add(_imageDetailY);
          }
        }
        return null;
      },
      slideEndHandler: (
        Offset offset, {
        ExtendedImageSlidePageState? state,
        ScaleEndDetails? details,
      }) {
        if (state == null || details == null) {
          return null;
        }
        if (_imageDetailY != 0 && state.scale == 1) {
          if (!_slideEndAnimationController.isAnimating) {
// get magnitude from gesture velocity
            final double magnitude = details.velocity.pixelsPerSecond.distance;

            // do a significant magnitude

            if (magnitude.greaterThanOrEqualTo(minMagnitude)) {
              final Offset direction =
                  details.velocity.pixelsPerSecond / magnitude * 1000;

              _slideEndAnimation =
                  _slideEndAnimationController.drive(Tween<double>(
                begin: _imageDetailY,
                end: (_imageDetailY + direction.dy)
                    .clamp(-detailKeys[_currentIndex!]!.maxImageDetailY, 0.0),
              ));
              _slideEndAnimationController.reset();
              _slideEndAnimationController.forward();
            }
          }
          return false;
        }

        return null;
      },
      onSlidingPage: (ExtendedImageSlidePageState state) {
        ///you can change other widgets' state on page as you want
        ///base on offset/isSliding etc
        //var offset= state.offset;
        final bool showSwiper = !state.isSliding;
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

  @override
  void dispose() {
    rebuildIndex.close();
    rebuildSwiper.close();
    rebuildDetail.close();
    _doubleClickAnimationController.dispose();
    _slideEndAnimationController.dispose();
    clearGestureDetailsCache();
    //cancelToken?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.index;
    _doubleClickAnimationController = AnimationController(
        duration: const Duration(milliseconds: 150), vsync: this);

    _slideEndAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _slideEndAnimationController.addListener(() {
      _imageDetailY = _slideEndAnimation.value;
      if (_imageDetailY == 0) {
        _showSwiper = true;
        rebuildSwiper.add(_showSwiper);
      }
      rebuildDetail.sink.add(_imageDetailY);
    });
  }
}
