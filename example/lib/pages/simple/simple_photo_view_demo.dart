import 'package:example/common/widget/hero.dart';
import 'package:example/example_routes.dart';
import 'package:extended_image/extended_image.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/material.dart';

@FFRoute(
  name: 'fluttercandies://SimplePhotoView',
  routeName: 'SimplePhotoView',
  description: 'Simple demo for PhotoView.',
  exts: <String, dynamic>{
    'group': 'Simple',
    'order': 8,
  },
)
class SimplePhotoViewDemo extends StatefulWidget {
  @override
  _SimplePhotoViewDemoState createState() => _SimplePhotoViewDemoState();
}

class _SimplePhotoViewDemoState extends State<SimplePhotoViewDemo> {
  List<String> images = <String>[
    'https://photo.tuchong.com/14649482/f/601672690.jpg',
    'https://photo.tuchong.com/17325605/f/641585173.jpg',
    'https://photo.tuchong.com/3541468/f/256561232.jpg',
    'https://photo.tuchong.com/16709139/f/278778447.jpg',
    'This is an video',
    'https://photo.tuchong.com/5040418/f/43305517.jpg',
    'https://photo.tuchong.com/3019649/f/302699092.jpg'
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SimplePhotoView'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 300,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (BuildContext context, int index) {
            final String url = images[index];
            return GestureDetector(
              child: AspectRatio(
                aspectRatio: 1.0,
                child: Hero(
                  tag: url,
                  child: url == 'This is an video'
                      ? Container(
                          alignment: Alignment.center,
                          child: const Text('This is an video'),
                        )
                      : ExtendedImage.network(
                          url,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              onTap: () {
                Navigator.of(context).pushNamed(
                    Routes.fluttercandiesSimplePicsWiper,
                    arguments: <String, dynamic>{
                      'url': url,
                      'images': images,
                    });
              },
            );
          },
          itemCount: images.length,
        ),
      ),
    );
  }
}

@FFRoute(
  name: 'fluttercandies://SimplePicsWiper',
  routeName: 'SimplePicsWiper',
  description: 'Simple demo for Simple Pics Wiper.',
  pageRouteType: PageRouteType.transparent,
)
class SimplePicsWiper extends StatefulWidget {
  const SimplePicsWiper({required this.url, required this.images});
  final String url;
  final List<String> images;
  @override
  _SimplePicsWiperState createState() => _SimplePicsWiperState();
}

class _SimplePicsWiperState extends State<SimplePicsWiper> {
  GlobalKey<ExtendedImageSlidePageState> slidePagekey =
      GlobalKey<ExtendedImageSlidePageState>();

  final List<int> _cachedIndexes = <int>[];

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

              return url == 'This is an video'
                  ? ExtendedImageSlidePageHandler(
                      child: Material(
                        child: Container(
                          alignment: Alignment.center,
                          color: Colors.yellow,
                          child: const Text('This is an video'),
                        ),
                      ),

                      ///make hero better when slide out
                      heroBuilderForSlidingPage: (Widget result) {
                        return Hero(
                          tag: url,
                          child: result,
                          flightShuttleBuilder: (BuildContext flightContext,
                              Animation<double> animation,
                              HeroFlightDirection flightDirection,
                              BuildContext fromHeroContext,
                              BuildContext toHeroContext) {
                            final Hero hero =
                                (flightDirection == HeroFlightDirection.pop
                                    ? fromHeroContext.widget
                                    : toHeroContext.widget) as Hero;

                            return hero.child;
                          },
                        );
                      },
                    )
                  : HeroWidget(
                      child: ExtendedImage.network(
                        url,
                        enableSlideOutPage: true,
                        fit: BoxFit.contain,
                        mode: ExtendedImageMode.gesture,
                        initGestureConfigHandler: (ExtendedImageState state) {
                          return GestureConfig(
                            //you must set inPageView true if you want to use ExtendedImageGesturePageView
                            inPageView: true,
                            initialScale: 1.0,
                            maxScale: 5.0,
                            animationMaxScale: 6.0,
                            initialAlignment: InitialAlignment.center,
                          );
                        },
                      ),
                      tag: url,
                      slideType: SlideType.wholePage,
                      slidePagekey: slidePagekey,
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
