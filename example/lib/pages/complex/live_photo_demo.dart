import 'package:example/assets.dart';

import 'package:example/common/widget/hero.dart';
import 'package:example/example_routes.dart';
import 'package:extended_image/extended_image.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:path/path.dart' as path;
import 'package:video_player/video_player.dart';

@FFRoute(
  name: 'fluttercandies://LivePhotoDemo',
  routeName: 'LivePhoto',
  description: 'a live photho demo.',
  exts: <String, dynamic>{
    'group': 'Complex',
    'order': 5,
  },
)
class LivePhotoDemo extends StatefulWidget {
  @override
  _LivePhotoDemoState createState() => _LivePhotoDemoState();
}

class _LivePhotoDemoState extends State<LivePhotoDemo> {
  List<String> images = <String>[
    Assets.assets_live_photo_1_jpg,
    Assets.assets_live_photo_2_jpg,
    'https://photo.tuchong.com/14649482/f/601672690.jpg',
    'https://photo.tuchong.com/17325605/f/641585173.jpg',
    'https://photo.tuchong.com/3541468/f/256561232.jpg',
    'https://photo.tuchong.com/16709139/f/278778447.jpg',
    'https://photo.tuchong.com/15195571/f/233361383.jpg',
    'https://photo.tuchong.com/5040418/f/43305517.jpg',
    'https://photo.tuchong.com/3019649/f/302699092.jpg'
  ];
  bool _stopPlayLivePhotoWhenSlidingPage = false;
  bool _stopPlayLivePhotoWhenGesture = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Photo'),
      ),
      body: SafeArea(
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  const Text('stop play live photo when sliding page : '),
                  Checkbox(
                    value: _stopPlayLivePhotoWhenSlidingPage,
                    onChanged: (bool? value) {
                      setState(() {
                        _stopPlayLivePhotoWhenSlidingPage = value!;
                      });
                    },
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  const Text('stop play live photo when gesture : '),
                  Checkbox(
                    value: _stopPlayLivePhotoWhenGesture,
                    onChanged: (bool? value) {
                      setState(() {
                        _stopPlayLivePhotoWhenGesture = value!;
                      });
                    },
                  ),
                ],
              ),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 300,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    final String url = images[index];

                    late ImageProvider image;

                    if (url.startsWith('https')) {
                      image = ExtendedNetworkImageProvider(url);
                    } else {
                      image = ExtendedAssetImageProvider(url);
                    }

                    final Widget imageWidget = ExtendedImage(
                      image: image,
                      fit: BoxFit.cover,
                      loadStateChanged: (ExtendedImageState state) {
                        if (state.extendedImageLoadState ==
                                LoadState.completed &&
                            !url.startsWith('https')) {
                          return Stack(
                            children: <Widget>[
                              Positioned.fill(child: state.completedWidget),
                              const Positioned(
                                left: 5,
                                bottom: 5,
                                child: Text(
                                  'Live',
                                  style: TextStyle(
                                      color: Colors.pink, fontSize: 12),
                                ),
                              ),
                            ],
                          );
                        }

                        return null;
                      },
                    );

                    return GestureDetector(
                      child: AspectRatio(
                        aspectRatio: 1.0,
                        child: Hero(
                          tag: url,
                          child: imageWidget,
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          Routes.fluttercandiesLivePhotoPicsWiper.name,
                          arguments: Routes.fluttercandiesLivePhotoPicsWiper.d(
                            url: url,
                            images: images,
                            stopPlayLivePhotoWhenGesture:
                                _stopPlayLivePhotoWhenGesture,
                            stopPlayLivePhotoWhenSlidingPage:
                                _stopPlayLivePhotoWhenSlidingPage,
                          ),
                        );
                      },
                    );
                  },
                  itemCount: images.length,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

@FFRoute(
  name: 'fluttercandies://LivePhotoPicsWiper',
  routeName: 'LivePhotoPicsWiper',
  description: 'demo for LivePhoto Pics Wiper.',
  pageRouteType: PageRouteType.transparent,
)
class LivePhotoPicsWiper extends StatefulWidget {
  const LivePhotoPicsWiper({
    super.key,
    required this.url,
    required this.images,
    this.stopPlayLivePhotoWhenSlidingPage = false,
    this.stopPlayLivePhotoWhenGesture = false,
  });
  final String url;
  final List<String> images;
  final bool stopPlayLivePhotoWhenSlidingPage;
  final bool stopPlayLivePhotoWhenGesture;
  @override
  State<LivePhotoPicsWiper> createState() => _LivePhotoPicsWiperState();
}

class _LivePhotoPicsWiperState extends State<LivePhotoPicsWiper> {
  GlobalKey<ExtendedImageSlidePageState> slidePagekey =
      GlobalKey<ExtendedImageSlidePageState>();

  final List<int> _cachedIndexes = <int>[];
  final BoxFit _fit = BoxFit.contain;
  final ValueNotifier<bool> _isSliding = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _gestureDetailsIsChanging =
      ValueNotifier<bool>(false);

  late VoidFunction _gestureDetailsChangeCompleted;

  @override
  void initState() {
    super.initState();

    _gestureDetailsChangeCompleted = () {
      _gestureDetailsIsChanging.value = false;
    }.debounce(const Duration(milliseconds: 100));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final int index = widget.images.indexOf(widget.url);
    _preloadImage(index - 1);
    _preloadImage(index + 1);
  }

  void _preloadImage(int index) {
    if (_cachedIndexes.contains(index)) {
      return;
    }
    if (0 <= index && index < widget.images.length) {
      final String url = widget.images[index];
      if (url.startsWith('https:')) {
        precacheImage(ExtendedNetworkImageProvider(url, cache: true), context);
      }

      _cachedIndexes.add(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ExtendedImageSlidePage(
        key: slidePagekey,
        onSlidingPage: widget.stopPlayLivePhotoWhenSlidingPage
            ? (ExtendedImageSlidePageState state) {
                _isSliding.value = state.isSliding;
              }
            : null,
        child: GestureDetector(
          child: ExtendedImageGesturePageView.builder(
            controller: ExtendedPageController(
              initialPage: widget.images.indexOf(widget.url),
              pageSpacing: 50,
              shouldIgnorePointerWhenScrolling: false,
            ),
            itemCount: widget.images.length,
            onPageChanged: (int page) {
              _preloadImage(page - 1);
              _preloadImage(page + 1);
            },
            itemBuilder: (BuildContext context, int index) {
              final String url = widget.images[index];

              late ImageProvider image;

              if (url.startsWith('https')) {
                image = ExtendedNetworkImageProvider(url, cache: true);
              } else {
                image = ExtendedAssetImageProvider(url);
              }

              final Widget imageWidget = ExtendedImage(
                image: image,
                fit: _fit,
                mode: ExtendedImageMode.gesture,
                enableSlideOutPage: true,
                initGestureConfigHandler: (ExtendedImageState state) {
                  return GestureConfig(
                    //you must set inPageView true if you want to use ExtendedImageGesturePageView
                    inPageView: true,
                    initialScale: 1.0,
                    maxScale: 5.0,
                    animationMaxScale: 6.0,
                    initialAlignment: InitialAlignment.center,
                    gestureDetailsIsChanged: widget.stopPlayLivePhotoWhenGesture
                        ? (GestureDetails? details) {
                            _gestureDetailsIsChanging.value = true;
                            _gestureDetailsChangeCompleted();
                          }
                        : null,
                  );
                },
                loadStateChanged: (ExtendedImageState state) {
                  if (state.extendedImageLoadState == LoadState.completed &&
                      state.imageProvider is ExtendedAssetImageProvider) {
                    String assetName =
                        (state.imageProvider as ExtendedAssetImageProvider)
                            .assetName;
                    final String fileName =
                        assetName.replaceAll(path.extension(assetName), '');
                    for (final String element in assetsArray) {
                      if (element.startsWith(fileName) &&
                          element != assetName) {
                        assetName = element;
                        break;
                      }
                    }

                    return LivePhotoWidget(
                      videoUrl: assetName,
                      fit: _fit,
                      state: state,
                      isSliding: _isSliding,
                      gestureDetailsIsChanging: _gestureDetailsIsChanging,
                    );
                  }
                  return null;
                },
              );

              return HeroWidget(
                tag: url,
                slideType: SlideType.wholePage,
                slidePagekey: slidePagekey,
                child: imageWidget,
              );
            },
          ),
          onTap: () {
            slidePagekey.currentState!.popPage();
            Navigator.pop(context);
          },
        ),
        slideAxis: SlideAxis.both,
        slideType: SlideType.wholePage,
      ),
    );
  }
}

class LivePhotoWidget extends StatefulWidget {
  const LivePhotoWidget({
    super.key,
    required this.videoUrl,
    required this.fit,
    required this.state,
    required this.isSliding,
    required this.gestureDetailsIsChanging,
    this.buildWithImageRect = true,
  });

  final String videoUrl;
  final BoxFit fit;
  final ExtendedImageState state;
  final ValueNotifier<bool> isSliding;
  final ValueNotifier<bool> gestureDetailsIsChanging;
  final bool buildWithImageRect;
  @override
  State<LivePhotoWidget> createState() => _LivePhotoWidgetState();
}

class _LivePhotoWidgetState extends State<LivePhotoWidget> {
  final ValueNotifier<bool> _showVideo = ValueNotifier<bool>(false);
  late VideoPlayerController _controller;

  bool _pointerDown = false;
  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(
      widget.videoUrl,
    );

    _controller.initialize().then((_) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _showVideo.value = true;
        if (!widget.gestureDetailsIsChanging.value && !widget.isSliding.value) {
          _controller.play();
        }
      });
    });

    _controller.addListener(_notfiy);

    widget.isSliding.addListener(_isSlidingChanged);
    widget.gestureDetailsIsChanging.addListener(_onGestureDetailsIsChanged);
  }

  Future<void> _onGestureDetailsIsChanged() async {
    if (!_showVideo.value) {
      return;
    }
    if (widget.gestureDetailsIsChanging.value) {
      await _controller.pause();
    } else if (!_pointerDown) {
      await continuePlay();
    }
  }

  Future<void> continuePlay() async {
    if (_showVideo.value && _controller.value.position != Duration.zero) {
      await _controller.play();
    }
  }

  Future<void> _isSlidingChanged() async {
    if (!_showVideo.value) {
      return;
    }
    if (widget.isSliding.value) {
      await _controller.pause();
    } else {
      await continuePlay();
    }
  }

  Future<void> _notfiy() async {
    // finish and change to image ui
    if (_showVideo.value && _controller.value.isCompleted) {
      _showVideo.value = false;
    }
  }

  Future<void> _showVideoAndPlay() async {
    await _controller.seekTo(Duration.zero);
    _showVideo.value = true;
    await _controller.play();
  }

  Future<void> _hideVideoAndStop() async {
    _showVideo.value = false;
    await _controller.pause();

    // keep position animation
    // await _controller.seekTo(Duration.zero);
  }

  @override
  void dispose() {
    widget.gestureDetailsIsChanging.removeListener(_onGestureDetailsIsChanged);
    widget.isSliding.removeListener(_isSlidingChanged);
    _controller.removeListener(_notfiy);
    _controller.pause();
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (PointerDownEvent event) {
        _pointerDown = true;
      },
      onPointerUp: (PointerUpEvent event) {
        _pointerDown = false;

        SchedulerBinding.instance.addPostFrameCallback((_) {
          continuePlay();
        });
      },
      onPointerCancel: (PointerCancelEvent event) {
        _pointerDown = false;

        SchedulerBinding.instance.addPostFrameCallback((_) {
          continuePlay();
        });
      },
      child: GestureDetector(
        onLongPress: () {
          _showVideoAndPlay();
        },
        onLongPressUp: () {
          _hideVideoAndStop();
        },
        child: ExtendedImageGesture(
          widget.state,
          imageBuilder: (
            Widget image, {
            ExtendedImageGestureState? imageGestureState,
          }) {
            return ValueListenableBuilder<bool>(
              valueListenable: _showVideo,
              builder: (BuildContext b, bool showVideo, Widget? child) {
                if (widget.buildWithImageRect) {
                  return _buildContentWithImageRect(
                    context,
                    imageGestureState,
                    showVideo,
                    image,
                  );
                }

                return _buildContent(
                  showVideo,
                  context,
                  imageGestureState,
                  image,
                );
              },
              child: image,
            );
          },
        ),
      ),
    );
  }

  Widget _buildContentWithImageRect(
    BuildContext context,
    ExtendedImageGestureState? imageGestureState,
    bool showVideo,
    Widget image,
  ) {
    final Size size = MediaQuery.of(context).size;

    final Rect destinationRect =
        GestureWidgetDelegateFromState.getRectFormState(
      Offset.zero & size,
      imageGestureState!,
      copy: true,
    );

    final double aspectRatio = widget.state.extendedImageInfo!.image.width /
        widget.state.extendedImageInfo!.image.height;

    Widget videoWidget = VideoPlayer(_controller);
    final bool converVideo =
        showVideo && (_controller.value.aspectRatio - aspectRatio).abs() > 0.01;
    if (converVideo) {
      final Rect widgetDestinationRect =
          GestureWidgetDelegateFromState.getRectFormState(
        Offset.zero & size,
        imageGestureState,
        width: _controller.value.size.width,
        height: _controller.value.size.height,
        copy: true,
      );
      videoWidget = FittedBox(
        child: SizedBox(
          child: videoWidget,
          width: widgetDestinationRect.width,
          height: widgetDestinationRect.height,
        ),
        fit: BoxFit.cover,
        clipBehavior: Clip.hardEdge,
      );
    }

    final bool showLive = imageGestureState.gestureDetails?.totalScale ==
            imageGestureState.imageGestureConfig?.initialScale &&
        !showVideo;

    return Stack(
      children: <Widget>[
        Positioned.fromRect(
          rect: destinationRect,
          child: videoWidget,
        ),
        Positioned.fill(
          child: AnimatedOpacity(
            // always show image to calculate gesture
            opacity: showVideo ? 0.001 : 1,
            onEnd: () {
              if (!showVideo) {
                _controller.seekTo(Duration.zero);
              }
            },
            duration: const Duration(milliseconds: 300),
            child: image,
          ),
        ),
        Positioned.fromRect(
          rect: destinationRect.shift(const Offset(5, -5)),
          child: AnimatedOpacity(
            opacity: showLive ? 1 : 0,
            duration: const Duration(milliseconds: 300),
            child: const Align(
              child: Text(
                'Live',
                style: TextStyle(color: Colors.pink, fontSize: 20),
              ),
              alignment: Alignment.bottomLeft,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(bool showVideo, BuildContext context,
      ExtendedImageGestureState? imageGestureState, Widget image) {
    late Widget child;
    if (showVideo) {
      child = VideoPlayer(_controller);
      if (widget.buildWithImageRect) {
        final double aspectRatio = widget.state.extendedImageInfo!.image.width /
            widget.state.extendedImageInfo!.image.height;
        if ((_controller.value.aspectRatio - aspectRatio).abs() > 0.01) {
          final Size size = MediaQuery.of(context).size;
          final Rect widgetDestinationRect =
              GestureWidgetDelegateFromState.getRectFormState(
            Offset.zero & size,
            imageGestureState!,
            width: _controller.value.size.width,
            height: _controller.value.size.height,
            copy: true,
          );
          child = FittedBox(
            child: SizedBox(
              child: child,
              width: widgetDestinationRect.width,
              height: widgetDestinationRect.height,
            ),
            fit: BoxFit.cover,
            clipBehavior: Clip.hardEdge,
          );
        }
        child = imageGestureState!.wrapGestureWidget(child);
      } else {
        child = imageGestureState!.wrapGestureWidget(
          child,
          imageWidth: _controller.value.size.width,
          imageHeight: _controller.value.size.height,
        );
      }

      // _buildVideo method is the same as wrapGestureWidget
      // if you want to custom your own, you can use _buildVideo
      // child = _buildVideo(imageGestureState);
    }
    // zooming has no live mark logo
    else if (imageGestureState?.gestureDetails?.totalScale !=
        imageGestureState?.imageGestureConfig?.initialScale) {
      child = image;
    } else {
      // live mark logo
      final Size size = MediaQuery.of(context).size;

      final Rect destinationRect =
          GestureWidgetDelegateFromState.getRectFormState(
        Offset.zero & size,
        imageGestureState!,
        copy: true,
      );

      // add mark live
      child = Stack(
        children: <Widget>[
          Positioned.fill(
            child: image,
          ),
          Positioned.fromRect(
            rect: destinationRect.shift(const Offset(5, -5)),
            child: const Align(
              child: Text(
                'Live',
                style: TextStyle(color: Colors.pink, fontSize: 20),
              ),
              alignment: Alignment.bottomLeft,
            ),
          ),
        ],
      );
    }
    return child;
    // return AnimatedSwitcher(
    //   duration: const Duration(milliseconds: 200),
    //   child: child,
    // );
  }

  // ignore: unused_element
  Widget _buildVideo(ExtendedImageGestureState? imageGestureState) {
    // The image to render into the area rect.
    // in demo case, it is the page size.
    // and you can also get it from LayoutBuilder base on your case.
    final Size size = MediaQuery.of(context).size;

    final Rect destinationRect = widget.buildWithImageRect
        ? GestureWidgetDelegateFromState.getRectFormState(
            Offset.zero & size,
            imageGestureState!,
          )
        : GestureWidgetDelegateFromState.getRectFormState(
            Offset.zero & size,
            imageGestureState!,
            width: _controller.value.size.width,
            height: _controller.value.size.height,
          );
    final ExtendedImageSlidePageState? extendedImageSlidePageState =
        imageGestureState.extendedImageSlidePageState;

    Widget child = VideoPlayer(_controller);

    if (widget.buildWithImageRect) {
      final double aspectRatio = widget.state.extendedImageInfo!.image.width /
          widget.state.extendedImageInfo!.image.height;

      if ((_controller.value.aspectRatio - aspectRatio).abs() > 0.01) {
        final Rect widgetDestinationRect =
            GestureWidgetDelegateFromState.getRectFormState(
          Offset.zero & size,
          imageGestureState,
          width: _controller.value.size.width,
          height: _controller.value.size.height,
          copy: true,
        );
        child = FittedBox(
          child: SizedBox(
            child: child,
            width: widgetDestinationRect.width,
            height: widgetDestinationRect.height,
          ),
          fit: BoxFit.cover,
          clipBehavior: Clip.hardEdge,
        );
      }
    }

    child = CustomSingleChildLayout(
      delegate: GestureWidgetDelegateFromRect(
        destinationRect,
      ),
      child: child,
    );

    // The same as use CustomSingleChildLayout
    // child = Stack(
    //   children: <Widget>[
    //     Positioned.fromRect(
    //       rect: destinationRect,
    //       child: child,
    //     ),
    //   ],
    // );

    if (extendedImageSlidePageState != null) {
      child = imageGestureState
              .widget.extendedImageState.imageWidget.heroBuilderForSlidingPage
              ?.call(child) ??
          child;
      if (extendedImageSlidePageState.widget.slideType == SlideType.onlyImage) {
        child = Transform.translate(
          offset: extendedImageSlidePageState.offset,
          child: Transform.scale(
            scale: extendedImageSlidePageState.scale,
            child: child,
          ),
        );
      }
    }

    return child;
  }
}
