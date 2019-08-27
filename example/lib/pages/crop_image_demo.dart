import 'dart:async';

import 'package:example/common/crop_image.dart';

import 'package:example/common/push_to_refresh_header.dart';
import 'package:example/common/tu_chong_repository.dart';
import 'package:example/common/tu_chong_source.dart';
import 'package:flutter/material.dart' hide CircularProgressIndicator;

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:pull_to_refresh_notification/pull_to_refresh_notification.dart';
import 'package:ff_annotation_route/ff_annotation_route.dart';

@FFRoute(
    name: "fluttercandies://cropimage",
    routeName: "image crop rect",
    description: "show how to crop rect image")
class CropImageDemo extends StatefulWidget {
  @override
  _CropImageDemoState createState() => _CropImageDemoState();
}

class _CropImageDemoState extends State<CropImageDemo> {
  TuChongRepository listSourceRepository = TuChongRepository();

  //if you don't konw image size before build,
  //you have to handle copy when image is loaded.
  bool konwImageSize = true;
  DateTime dateTimeNow = DateTime.now();
  @override
  void dispose() {
    listSourceRepository.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                physics: ClampingScrollPhysics(),
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
                          title = "Image$index";
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

  Future<bool> onRefresh() {
    return listSourceRepository.refresh().whenComplete(() {
      dateTimeNow = DateTime.now();
    });
  }
}
