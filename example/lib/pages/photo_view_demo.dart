///
///  photo_view_demo.dart
///  create by zmtzawqlp on 2019/4/4
///

import 'dart:async';
import 'package:example/common/crop_image.dart';
import 'package:example/common/my_extended_text_selection_controls.dart';
import 'package:example/common/push_to_refresh_header.dart';
import 'package:example/common/tu_chong_repository.dart';
import 'package:example/common/tu_chong_source.dart';
import 'package:example/special_text/my_special_text_span_builder.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart' hide CircularProgressIndicator;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:like_button/like_button.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:pull_to_refresh_notification/pull_to_refresh_notification.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:ff_annotation_route/ff_annotation_route.dart';

@FFRoute(
    name: "fluttercandies://photoview",
    routeName: "photo view",
    description: "show how to zoom/pan image in page view like WeChat")
class PhotoViewDemo extends StatefulWidget {
  @override
  _PhotoViewDemoState createState() => _PhotoViewDemoState();
}

class _PhotoViewDemoState extends State<PhotoViewDemo> {
  MyExtendedMaterialTextSelectionControls
      _myExtendedMaterialTextSelectionControls;
  final String _attachContent =
      "[love]Extended text help you to build rich text quickly. any special text you will have with extended text.It's my pleasure to invite you to join \$FlutterCandies\$ if you want to improve flutter .[love] if you meet any problem, please let me konw @zmtzawqlp .[sun_glasses]";
  @override
  void initState() {
    _myExtendedMaterialTextSelectionControls =
        MyExtendedMaterialTextSelectionControls();
    super.initState();
  }

  TuChongRepository listSourceRepository = TuChongRepository();

  //if you can't konw image size before build,
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

    Widget result = Material(
      child: Column(
        children: <Widget>[
          AppBar(
            title: Text("photo view demo"),
          ),
          Container(
            padding: EdgeInsets.all(margin),
            child: Text(
                "click image to show photo view, support zoom/pan image. horizontal and vertical page view are supported."),
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

                        var content = item.content ?? (item.excerpt ?? title);
                        content += this._attachContent;

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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                CropImage(item, index, margin, konwImageSize,
                                    listSourceRepository),
                                Expanded(
                                  child: Padding(
                                    child: ExtendedText(
                                      content,
                                      onSpecialTextTap: (dynamic parameter) {
                                        if (parameter.startsWith("\$")) {
                                          launch(
                                              "https://github.com/fluttercandies");
                                        } else if (parameter.startsWith("@")) {
                                          launch("mailto:zmtzawqlp@live.com");
                                        }
                                      },
                                      specialTextSpanBuilder:
                                          MySpecialTextSpanBuilder(),
                                      //overflow: ExtendedTextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize:
                                              ScreenUtil.instance.setSp(28),
                                          color: Colors.grey),
                                      maxLines: 10,
                                      overflow: TextOverflow.ellipsis,
//                                      overFlowTextSpan: OverFlowTextSpan(
//                                        children: <TextSpan>[
//                                          TextSpan(text: '  \u2026  '),
//                                          TextSpan(
//                                              text: "more detail",
//                                              style: TextStyle(
//                                                color: Colors.blue,
//                                              ),
//                                              recognizer: TapGestureRecognizer()
//                                                ..onTap = () {
//                                                  launch(
//                                                      "https://github.com/fluttercandies/extended_text");
//                                                })
//                                        ],
//                                      ),
                                      selectionEnabled: true,
                                      textSelectionControls:
                                          _myExtendedMaterialTextSelectionControls,
                                    ),
                                    padding: EdgeInsets.only(
                                        left: margin,
                                        right: margin,
                                        bottom: margin),
                                  ),
                                )
                              ],
                            ),
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
                                  LikeButton(
                                    size: 20.0,
                                    isLiked: item.isFavorite,
                                    likeCount: item.favorites,
                                    countBuilder:
                                        (int count, bool isLiked, String text) {
                                      var color = isLiked
                                          ? Colors.pinkAccent
                                          : Colors.grey;
                                      Widget result;
                                      if (count == 0) {
                                        result = Text(
                                          "love",
                                          style: TextStyle(color: color),
                                        );
                                      } else
                                        result = Text(
                                          count >= 1000
                                              ? (count / 1000.0)
                                                      .toStringAsFixed(1) +
                                                  "k"
                                              : text,
                                          style: TextStyle(color: color),
                                        );
                                      return result;
                                    },
                                    likeCountAnimationType:
                                        item.favorites < 1000
                                            ? LikeCountAnimationType.part
                                            : LikeCountAnimationType.none,
                                    onTap: (bool isLiked) {
                                      return onLikeButtonTap(isLiked, item);
                                    },
                                  ),
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

    return ExtendedTextSelectionPointerHandler(
      //default behavior
      // child: result,
      //custom your behavior
      builder: (states) {
        return Listener(
          child: result,
          behavior: HitTestBehavior.translucent,
          onPointerDown: (value) {
            for (var state in states) {
              if (!state.containsPosition(value.position)) {
                //clear other selection
                state.clearSelection();
              }
            }
          },
          onPointerMove: (value) {
            //clear other selection
            for (var state in states) {
              state.clearSelection();
            }
          },
        );
      },
    );
  }

  Future<bool> onLikeButtonTap(bool isLiked, TuChongItem item) {
    ///send your request here
    ///
    final Completer<bool> completer = new Completer<bool>();
    Timer(const Duration(milliseconds: 200), () {
      item.isFavorite = !item.isFavorite;
      item.favorites =
          item.isFavorite ? item.favorites + 1 : item.favorites - 1;

      // if your request is failed,return null,
      completer.complete(item.isFavorite);
    });
    return completer.future;
  }

  Future<bool> onRefresh() {
    return listSourceRepository.refresh().whenComplete(() {
      dateTimeNow = DateTime.now();
    });
  }
}
