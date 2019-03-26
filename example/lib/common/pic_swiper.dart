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
                  fit: BoxFit.fill,
                  //enableLoadState: false,
                  mode: ExtendedImageMode.Gesture,
                  imageGestureConfig:
                      ImageGestureConfig(inPageView: InPageView.horizontal),
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
