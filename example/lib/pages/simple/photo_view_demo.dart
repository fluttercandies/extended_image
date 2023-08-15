import 'package:extended_image/extended_image.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/material.dart';

@FFRoute(
  name: 'fluttercandies://extendedImageGesturePageView',
  routeName: 'ExtendedImageGesturePageView',
  description: 'Simple demo for ExtendedImageGesturePageView.',
  showStatusBar: false,
  exts: <String, dynamic>{
    'group': 'Simple',
    'order': 7,
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
    'https://photo.tuchong.com/15195571/f/233361383.jpg',
    'https://photo.tuchong.com/5040418/f/43305517.jpg',
    'https://photo.tuchong.com/3019649/f/302699092.jpg'
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _preloadImage(1);
  }

  final List<int> _cachedIndexes = <int>[];

  void _preloadImage(int index) {
    if (_cachedIndexes.contains(index)) {
      return;
    }
    if (0 <= index && index < images.length) {
      final String url = images[index];

      precacheImage(ExtendedNetworkImageProvider(url, cache: true), context);

      _cachedIndexes.add(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ExtendedImageGesturePageView'),
      ),
      body: ExtendedImageGesturePageView.builder(
        controller: ExtendedPageController(
          initialPage: 0,
          pageSpacing: 50,
        ),
        onPageChanged: (int page) {
          _preloadImage(page - 1);
          _preloadImage(page + 1);
        },
        itemCount: images.length,
        itemBuilder: (BuildContext context, int index) {
          return ExtendedImage.network(
            images[index],
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
          );
        },
      ),
    );
  }
}
