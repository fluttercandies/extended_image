import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_page_indicator/flutter_page_indicator.dart';
import 'package:oktoast/oktoast.dart';
import 'package:flutter_swiper/flutter_swiper.dart';

class PicSwiper extends StatelessWidget {
  final int index;
  final List<PicSwiperItem> pics;
  PicSwiper(this.index, this.pics);

  @override
  Widget build(BuildContext context) {
    int currentIndex = index;
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
                saveNetworkImageToPhoto(pics[index].picUrl).then((bool done) {
                  showToast(done ? "save succeed" : "save failed",
                      position: ToastPosition(align: Alignment.topCenter));
                });
              },
            )
          ],
        ),
        Expanded(
            child: Swiper(
          onTap: (index) {},
          itemBuilder: (
            BuildContext context,
            int index,
          ) {
            var item = pics[index].picUrl;
            Widget image = ExtendedImage.network(
              item,
              fit: BoxFit.contain,
              enableLoadState: false,
            );
            image = Container(
              child: image,
              padding:
                  EdgeInsets.only(top: 5.0, bottom: 5.0, left: 3.0, right: 3.0),
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
          itemCount: pics.length,
          index: index,
          pagination: new SwiperPagination(
              builder: MySwiperPlugin(pics), margin: const EdgeInsets.all(0.0)),
          indicatorLayout: PageIndicatorLayout.SCALE,
          loop: false,
//              viewportFraction: 0.8,
//              scale: 0.9,
          outer: true,
          onIndexChanged: (index) {
            currentIndex = index;
          },
        ))
      ],
    ));
  }
}

class PicSwiperItem {
  String picUrl;
  String des;
  PicSwiperItem(this.picUrl, {this.des = ""});
}

typedef IndexedWidgetBuilder = Widget Function(
    BuildContext context, int index, int currentIndex);

class MySwiperPlugin extends SwiperPlugin {
  final List<PicSwiperItem> pics;
  MySwiperPlugin(this.pics);

  @override
  Widget build(BuildContext context, SwiperPluginConfig config) {
    return DefaultTextStyle(
      style: TextStyle(color: Colors.white),
      child: Container(
        height: 50.0,
        width: double.infinity,
        color: Colors.grey,
        child: Row(
          children: <Widget>[
            Container(
              width: 10.0,
            ),
            Text(
              pics[config.activeIndex].des ?? "",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Expanded(
              child: Container(),
            ),
            Text(
              "${config.activeIndex + 1}",
            ),
            Text(
              " / ${config.itemCount}",
            ),
            Container(
              width: 10.0,
            ),
          ],
        ),
      ),
    );
  }
}
