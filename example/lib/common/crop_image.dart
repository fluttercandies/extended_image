import 'dart:io';
import 'dart:math';
import 'package:example/common/pic_swiper.dart';
import 'package:example/common/tu_chong_repository.dart';
import 'package:example/common/tu_chong_source.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui' as ui show Image;

///
///  crop_image.dart
///  create by zmtzawqlp on 2019/4/4
///

class CropImage extends StatelessWidget {
  final TuChongItem item;
  final int index;
  final double margin;
  final bool knowImageSize;
  final TuChongRepository listSourceRepository;
  CropImage(this.item, this.index, this.margin, this.knowImageSize,
      this.listSourceRepository);

  @override
  Widget build(BuildContext context) {
    if (!item.hasImage) return Container();

    final double num300 = ScreenUtil.getInstance().setWidth(300);
    final double num400 = ScreenUtil.getInstance().setWidth(400);
    double height = num300;
    double width = num400;

    if (knowImageSize) {
      height = item.imageSize.height;
      width = item.imageSize.width;
      var n = height / width;
      if (n >= 4 / 3) {
        width = num300;
        height = num400;
      } else if (4 / 3 > n && n > 3 / 4) {
        var maxValue = max(width, height);
        height = num400 * height / maxValue;
        width = num400 * width / maxValue;
      } else if (n <= 3 / 4) {
        width = num400;
        height = num300;
      }
    }

    return Padding(
      padding: EdgeInsets.all(margin),
      child: ExtendedImage.network(item.imageUrl,
          fit: BoxFit.fill,
          //height: 200.0,
          width: width,
          height: height, loadStateChanged: (ExtendedImageState state) {
        Widget widget;
        switch (state.extendedImageLoadState) {
          case LoadState.loading:
            widget = Container(
              color: Colors.grey,
              alignment: Alignment.center,
              child: CircularProgressIndicator(
                strokeWidth: 2.0,
                valueColor:
                    AlwaysStoppedAnimation(Theme.of(context).primaryColor),
              ),
            );
            break;
          case LoadState.completed:
            //if you can't konw image size before build,
            //you have to handle crop when image is loaded.
            //so maybe your loading widget size will not the same
            //as image actual size, set returnLoadStateChangedWidget=true,so that
            //image will not to be limited by size which you set for ExtendedImage first time.
            state.returnLoadStateChangedWidget = !knowImageSize;

            widget = Hero(
                tag: item.imageUrl + index.toString(),
                child:
                    buildImage(state.extendedImageInfo.image, num300, num400));
            break;
          case LoadState.failed:
            widget = GestureDetector(
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

        widget = GestureDetector(
          child: widget,
          onTap: () {
            Navigator.pushNamed(context, "fluttercandies://picswiper",
                arguments: {
                  "index": index,
                  "pics": listSourceRepository
                      .map<PicSwiperItem>(
                          (f) => PicSwiperItem(f.imageUrl, des: f.title))
                      .toList(),
                });
          },
        );

        return widget;
      }),
    );
  }

  Widget buildImage(ui.Image image, double num300, double num400) {
    var n = image.height / image.width;
    if (n >= 4 / 3) {
      Widget imageWidget = ExtendedRawImage(
          image: image,
          width: num300,
          height: num400,
          fit: BoxFit.fill,
          soucreRect: Rect.fromLTWH(
              0.0, 0.0, image.width.toDouble(), 4 * image.width / 3));
      if (n >= 4) {
        imageWidget = Container(
          width: num300,
          height: num400,
          child: Stack(
            children: <Widget>[
              Positioned(
                top: 0.0,
                right: 0.0,
                left: 0.0,
                bottom: 0.0,
                child: imageWidget,
              ),
              Positioned(
                bottom: 0.0,
                right: 0.0,
                child: Container(
                  padding: EdgeInsets.all(2.0),
                  color: Colors.grey,
                  child: const Text(
                    "long image",
                    style: TextStyle(color: Colors.white, fontSize: 10.0),
                  ),
                ),
              )
            ],
          ),
        );
      }
      return imageWidget;
    } else if (4 / 3 > n && n > 3 / 4) {
      var maxValue = max(image.width, image.height);
      var height = num400 * image.height / maxValue;
      var width = num400 * image.width / maxValue;
      return ExtendedRawImage(
        height: height,
        width: width,
        image: image,
        fit: BoxFit.fill,
      );
    } else if (n <= 3 / 4) {
      var width = 4 * image.height / 3;
      Widget imageWidget = ExtendedRawImage(
        image: image,
        width: num400,
        height: num300,
        fit: BoxFit.fill,
        soucreRect: Rect.fromLTWH(
            (image.width - width) / 2.0, 0.0, width, image.height.toDouble()),
      );

      if (n <= 1 / 4) {
        imageWidget = Container(
          width: num400,
          height: num300,
          child: Stack(
            children: <Widget>[
              Positioned(
                top: 0.0,
                right: 0.0,
                left: 0.0,
                bottom: 0.0,
                child: imageWidget,
              ),
              Positioned(
                bottom: 0.0,
                right: 0.0,
                child: Container(
                  padding: EdgeInsets.all(2.0),
                  color: Colors.grey,
                  child: const Text(
                    "long image",
                    style: TextStyle(color: Colors.white, fontSize: 10.0),
                  ),
                ),
              )
            ],
          ),
        );
      }
      return imageWidget;
    }
    return Container();
  }
}
