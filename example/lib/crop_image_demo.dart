import 'dart:async';

import 'package:example/common/pic_swiper.dart';
import 'package:example/common/push_to_refresh_header.dart';
import 'package:example/common/tu_chong_repository.dart';
import 'package:example/common/tu_chong_source.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart' hide CircularProgressIndicator;

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:pull_to_refresh_notification/pull_to_refresh_notification.dart';
import 'dart:math';
import 'dart:ui' as ui show Image;

class CropImageDemo extends StatefulWidget {
  @override
  _CropImageDemoState createState() => _CropImageDemoState();
}

class _CropImageDemoState extends State<CropImageDemo>
    with AutomaticKeepAliveClientMixin {
  TuChongRepository listSourceRepository = TuChongRepository();

  //if you can't konw image size before build,
  //you have to handle copy when image is loaded.
  bool konwImageSize = true;
  DateTime dateTimeNow = DateTime.now();
  @override
  void dispose() {
    listSourceRepository.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final double margin = ScreenUtil.instance.setWidth(22);

    return Material(
      child: Column(
        children: <Widget>[
          AppBar(
            title: Text("Crop image after it's ready"),
          ),
          Expanded(
            child: PullToRefreshNotification(
              pullBackOnRefresh: false,
              maxDragOffset: maxDragOffset,
              armedDragUpCancel: false,
              onRefresh: onRefresh,
              child: LoadingMoreCustomScrollView(
                showGlowLeading: false,
                slivers: <Widget>[
                  SliverToBoxAdapter(
                    child: PullToRefreshContainer((info) {
                      return PullToRefreshHeader(info, dateTimeNow);
                    }),
                  ),
                  LoadingMoreSliverList(
                    SliverListConfig<TuChongItem>(
                      itemBuilder: (context, item, index) {
                        String title = item.title;
                        if (title == null || title == "") {
                          title = "Image${index}";
                        }

                        return Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(
                                  top: margin, left: margin, right: margin),
                              child: Text(title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: ScreenUtil.instance.setSp(34))),
                            ),
                            item.content == null || item.content == ""
                                ? Container()
                                : Padding(
                                    padding: EdgeInsets.only(
                                        left: margin, right: margin),
                                    child: Text(
                                      item.content ?? "",
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize:
                                              ScreenUtil.instance.setSp(28),
                                          color: Colors.grey),
                                    )),
                            CropImage(item, index, margin, konwImageSize,
                                listSourceRepository),
                            Container(
                              padding:
                                  EdgeInsets.only(left: margin, right: margin),
                              height: ScreenUtil.instance.setWidth(80),
                              color: Colors.grey.withOpacity(0.5),
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Icon(
                                        Icons.comment,
                                        color: Colors.amberAccent,
                                      ),
                                      Text(
                                        item.comments.toString(),
                                        style: TextStyle(color: Colors.white),
                                      )
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Icon(
                                        Icons.favorite,
                                        color: Colors.deepOrange,
                                      ),
                                      Text(
                                        item.favorites.toString(),
                                        style: TextStyle(color: Colors.white),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            )
                          ],
                        );
                      },
                      sourceList: listSourceRepository,
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  Future<bool> onRefresh() {
    return listSourceRepository.refresh().whenComplete(() {
      dateTimeNow = DateTime.now();
    });
  }
}

class CropImage extends StatelessWidget {
  final TuChongItem item;
  final int index;
  final double margin;
  final bool konwImageSize;
  final TuChongRepository listSourceRepository;
  CropImage(this.item, this.index, this.margin, this.konwImageSize,
      this.listSourceRepository);

  @override
  Widget build(BuildContext context) {
    if (!item.hasImage) return Container();

    final double num300 = ScreenUtil.getInstance().setWidth(300);
    final double num400 = ScreenUtil.getInstance().setWidth(400);
    double height = num300;
    double width = num400;

    if (konwImageSize) {
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
        switch (state.extendedImageLoadState) {
          case LoadState.loading:
            return Container(
              color: Colors.grey,
              alignment: Alignment.center,
              child: CircularProgressIndicator(
                strokeWidth: 2.0,
                valueColor:
                    AlwaysStoppedAnimation(Theme.of(context).primaryColor),
              ),
            );
//            return Image.asset(
//              "assets/loading1.gif",
//              fit: BoxFit.fill,
//            );
            break;
          case LoadState.completed:
            //if you can't konw image size before build,
            //you have to handle copy when image is loaded.
            //so maybe your loading widget size will not the same
            //as image actual size, set returnLoadStateChangedWidget=true,so that
            //image will not to be limited by size which you set for ExtendedImage first time.
            state.returnLoadStateChangedWidget = !konwImageSize;

            return GestureDetector(
              child: Hero(
                  tag: item.imageUrl + index.toString(),
                  child: buildImage(
                      state.extendedImageInfo.image, num300, num400)),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) {
                  return PicSwiper(
                    index,
                    listSourceRepository
                        .map<PicSwiperItem>(
                            (f) => PicSwiperItem(f.imageUrl, des: f.title))
                        .toList(),
                  );
                }));
              },
            );
            break;
          case LoadState.failed:
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
  }
}
