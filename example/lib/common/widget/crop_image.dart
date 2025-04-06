import 'dart:math';
import 'dart:ui' as ui show Image;
import 'package:example/common/data/tu_chong_source.dart';
import 'package:example/common/model/pic_swiper_item.dart';
import 'package:example/common/widget/common_widget.dart';
import 'package:example/example_routes.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

///
///  crop_image.dart
///  create by zmtzawqlp on 2019/4/4
///

class CropImage extends StatelessWidget {
  const CropImage({
    required this.index,
    required this.tuChongItem,
    this.knowImageSize,
  });
  final TuChongItem tuChongItem;
  final bool? knowImageSize;
  final int index;
  @override
  Widget build(BuildContext context) {
    if (!tuChongItem.hasImage) {
      return Container();
    }

    const double num300 = 150;
    const double num400 = 200;
    double height = num300;
    double width = num400;
    final ImageItem imageItem = tuChongItem.images![index];
    if (knowImageSize!) {
      height = imageItem.height!.toDouble();
      width = imageItem.width!.toDouble();
      final double n = height / width;
      if (n >= 4 / 3) {
        width = num300;
        height = num400;
      } else if (4 / 3 > n && n > 3 / 4) {
        final double maxValue = max(width, height);
        height = num400 * height / maxValue;
        width = num400 * width / maxValue;
      } else if (n <= 3 / 4) {
        width = num400;
        height = num300;
      }
    }

    return ExtendedImage.network(imageItem.imageUrl,
        width: width,
        clearMemoryCacheWhenDispose: false,
        imageCacheName: 'CropImage',
        height: height, loadStateChanged: (ExtendedImageState state) {
      Widget? widget;
      switch (state.extendedImageLoadState) {
        case LoadState.loading:
          widget = CommonCircularProgressIndicator();
          break;
        case LoadState.completed:
          //if you can't konw image size before build,
          //you have to handle crop when image is loaded.
          //so maybe your loading widget size will not the same
          //as image actual size, set returnLoadStateChangedWidget=true,so that
          //image will not to be limited by size which you set for ExtendedImage first time.
          state.returnLoadStateChangedWidget = !knowImageSize!;

          ///if you don't want override completed widget
          ///please return null or state.completedWidget
          //return null;
          //return state.completedWidget;
          widget = Hero(
            tag: imageItem.imageUrl,
            child: buildImage(state.extendedImageInfo!.image, num300, num400),
          );

          break;
        case LoadState.failed:
          widget = GestureDetector(
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
          break;
      }
      if (index == 8 && tuChongItem.images!.length > 9) {
        widget = Stack(children: <Widget>[
          widget,
          Container(
            color: Colors.grey.withValues(alpha: 0.2),
            alignment: Alignment.center,
            child: Text(
              '+${tuChongItem.images!.length - 9}',
              style: const TextStyle(fontSize: 18.0, color: Colors.white),
            ),
          )
        ]);
      }

      widget = GestureDetector(
        child: widget,
        onTap: () {
          Navigator.pushNamed(
            context,
            Routes.fluttercandiesPicswiper.name,
            arguments: Routes.fluttercandiesPicswiper.d(
              index: index,
              pics: tuChongItem.images!
                  .map<PicSwiperItem>((ImageItem f) =>
                      PicSwiperItem(picUrl: f.imageUrl, des: f.title))
                  .toList(),
              tuChongItem: tuChongItem,
            ),
          );
        },
      );

      return widget;
    });
  }

  Widget buildImage(ui.Image image, double num300, double num400) {
    final double n = image.height / image.width;
    if (tuChongItem.images!.length == 1) {
      return ExtendedRawImage(image: image, fit: BoxFit.cover);
    } else if (n >= 4 / 3) {
      Widget imageWidget = ExtendedRawImage(
        image: image,
        width: num300,
        height: num400,
        fit: BoxFit.fill,
        sourceRect: Rect.fromLTWH(
            0.0, 0.0, image.width.toDouble(), 4 * image.width / 3),
      );
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
                  padding: const EdgeInsets.all(2.0),
                  color: Colors.grey,
                  child: const Text(
                    'long image',
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
      final int maxValue = max(image.width, image.height);
      final double height = num400 * image.height / maxValue;
      final double width = num400 * image.width / maxValue;
      return ExtendedRawImage(
        height: height,
        width: width,
        image: image,
        fit: BoxFit.fill,
      );
    } else if (n <= 3 / 4) {
      final double width = 4 * image.height / 3;
      Widget imageWidget = ExtendedRawImage(
        image: image,
        width: num400,
        height: num300,
        fit: BoxFit.fill,
        sourceRect: Rect.fromLTWH(
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
                  padding: const EdgeInsets.all(2.0),
                  color: Colors.grey,
                  child: const Text(
                    'long image',
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
