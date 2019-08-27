import 'package:example/main.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:oktoast/oktoast.dart';

import 'package:ff_annotation_route/ff_annotation_route.dart';

@FFRoute(
    name: "fluttercandies://customimage",
    routeName: "custom image load state",
    description: "show image with loading,failed,animation state")
class CustomImageDemo extends StatefulWidget {
  @override
  _CustomImageDemoState createState() => _CustomImageDemoState();
}

class _CustomImageDemoState extends State<CustomImageDemo>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  @override
  void initState() {
    _controller = AnimationController(
        vsync: this,
        duration: Duration(seconds: 3),
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
    var url = imageTestUrl;
    return Material(
      child: Column(
        children: <Widget>[
          AppBar(
            title: Text("CustomImage"),
          ),
          RaisedButton(
            child: Text("clear all cache"),
            onPressed: () {
              clearDiskCachedImages().then((bool done) {
                showToast(done ? "clear succeed" : "clear failed",
                    position: ToastPosition(align: Alignment.topCenter));
              });
            },
          ),
          Expanded(
            child: Align(
              child: ExtendedImage.network(
                url,
                width: ScreenUtil.instance.setWidth(600),
                height: ScreenUtil.instance.setWidth(400),
                fit: BoxFit.fill,
                cache: true,
                loadStateChanged: (ExtendedImageState state) {
                  switch (state.extendedImageLoadState) {
                    case LoadState.loading:
                      _controller.reset();
                      return Image.asset(
                        "assets/loading.gif",
                        fit: BoxFit.fill,
                      );
                      break;
                    case LoadState.completed:
                      _controller.forward();
                      return FadeTransition(
                        opacity: _controller,
                        child: ExtendedRawImage(
                          image: state.extendedImageInfo?.image,
                          width: ScreenUtil.instance.setWidth(600),
                          height: ScreenUtil.instance.setWidth(400),
                        ),
                      );
                      break;
                    case LoadState.failed:
                      _controller.reset();
                      //remove memory cached
                      state.imageProvider.evict();
                      return GestureDetector(
                        child: Stack(
                          fit: StackFit.expand,
                          children: <Widget>[
                            Image.asset(
                              "assets/failed.jpg",
                              fit: BoxFit.fill,
                            ),
                            Positioned(
                              bottom: 0.0,
                              left: 0.0,
                              right: 0.0,
                              child: Text(
                                "load image failed, click to reload",
                                textAlign: TextAlign.center,
                              ),
                            )
                          ],
                        ),
                        onTap: () {
                          state.reLoadImage();
                        },
                      );
                      break;
                  }
                  return Container();
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
