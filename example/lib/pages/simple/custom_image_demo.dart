import 'package:example/main.dart';
import 'package:extended_image/extended_image.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';

@FFRoute(
  name: 'fluttercandies://customimage',
  routeName: 'Custom load state',
  description: 'Custom state for loading, failed and completed.',
  exts: <String, dynamic>{
    'group': 'Simple',
    'order': 1,
  },
)
class CustomImageDemo extends StatefulWidget {
  @override
  _CustomImageDemoState createState() => _CustomImageDemoState();
}

class _CustomImageDemoState extends State<CustomImageDemo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    _controller = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 3),
        lowerBound: 0.0,
        upperBound: 1.0);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String url = imageTestUrl;

    return Material(
      child: Column(
        children: <Widget>[
          AppBar(
            title: const Text('CustomImage'),
          ),
          if (!kIsWeb)
            TextButton(
              child: const Text('clear all cache'),
              onPressed: () {
                clearDiskCachedImages().then((bool done) {
                  showToast(done ? 'clear succeed' : 'clear failed',
                      position:
                          const ToastPosition(align: Alignment.topCenter));
                });
              },
            ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(20),
              alignment: Alignment.center,
              child: ExtendedImage.network(
                url,
                fit: BoxFit.contain,
                width: 300,
                height: 200,
                cache: true,
                loadStateChanged: (ExtendedImageState state) {
                  switch (state.extendedImageLoadState) {
                    case LoadState.loading:
                      _controller.reset();
                      return Image.asset(
                        'assets/loading.gif',
                        fit: BoxFit.fill,
                      );
                    case LoadState.completed:
                      if (state.wasSynchronouslyLoaded) {
                        return state.completedWidget;
                      }
                      _controller.forward();

                      ///if you don't want override completed widget
                      ///please return null or state.completedWidget
                      //return null;
                      //return state.completedWidget;
                      return FadeTransition(
                        opacity: _controller,
                        child: state.completedWidget,
                      );
                    case LoadState.failed:
                      _controller.reset();
                      //remove memory cached
                      state.imageProvider.evict();
                      return GestureDetector(
                        child: Stack(
                          fit: StackFit.expand,
                          children: <Widget>[
                            Image.asset(
                              'assets/failed.jpg',
                              fit: BoxFit.fill,
                            ),
                            const Positioned(
                              bottom: 0.0,
                              left: 0.0,
                              right: 0.0,
                              child: Text(
                                'load image failed, click to reload',
                                textAlign: TextAlign.center,
                              ),
                            )
                          ],
                        ),
                        onTap: () {
                          state.reLoadImage();
                        },
                      );
                  }
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
