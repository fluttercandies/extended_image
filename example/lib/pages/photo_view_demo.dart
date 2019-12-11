///
///  photo_view_demo.dart
///  create by zmtzawqlp on 2019/4/4
///

import 'dart:async';
import 'package:example/common/item_builder.dart';
import 'package:example/common/my_extended_text_selection_controls.dart';
import 'package:example/common/pic_grid_view.dart';
import 'package:example/common/push_to_refresh_header.dart';
import 'package:example/common/tu_chong_repository.dart';
import 'package:example/common/tu_chong_source.dart';
import 'package:example/special_text/my_special_text_span_builder.dart';
import 'package:extended_image/extended_image.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide CircularProgressIndicator;
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
                      collectGarbage: (List<int> indexes) {
                        ///collectGarbage
                        indexes.forEach((index) {
                          final item = listSourceRepository[index];
                          if (item.hasImage) {
                            item.images.forEach((image) {
                              image.clearCache();
                            });
                          }
                        });
                      },
                      itemBuilder: (context, item, index) {
                        String title = item.site.name;
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
                              padding: EdgeInsets.all(margin),
                              child: Row(
                                children: <Widget>[
                                  ExtendedImage.network(
                                    item.avatarUrl,
                                    width: 40.0,
                                    height: 40.0,
                                    shape: BoxShape.circle,
                                    //enableLoadState: false,
                                    border: Border.all(
                                        color: Colors.grey.withOpacity(0.4),
                                        width: 1.0),
                                    loadStateChanged: (state) {
                                      if (state.extendedImageLoadState ==
                                          LoadState.completed) {
                                        return null;
                                      }
                                      return Image.asset("assets/avatar.jpg");
                                    },
                                  ),
                                  SizedBox(
                                    width: margin,
                                  ),
                                  Text(title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: ScreenUtil.instance.setSp(34),
                                      )),
                                ],
                              ),
                            ),
                            Padding(
                              child: ExtendedText(
                                content,
                                onSpecialTextTap: (dynamic parameter) {
                                  if (parameter.startsWith("\$")) {
                                    launch("https://github.com/fluttercandies");
                                  } else if (parameter.startsWith("@")) {
                                    launch("mailto:zmtzawqlp@live.com");
                                  }
                                },
                                specialTextSpanBuilder:
                                    MySpecialTextSpanBuilder(),
                                //overflow: ExtendedTextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: ScreenUtil.instance.setSp(28),
                                    color: Colors.grey),
                                maxLines: 10,
                                overflow: TextOverflow.ellipsis,
                                overFlowTextSpan: OverFlowTextSpan(
                                  children: <TextSpan>[
                                    TextSpan(text: '  \u2026  '),
                                    TextSpan(
                                        text: "more detail",
                                        style: TextStyle(
                                          color: Colors.blue,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            launch(
                                                "https://github.com/fluttercandies/extended_text");
                                          })
                                  ],
                                ),
                                selectionEnabled: true,
                                textSelectionControls:
                                    _myExtendedMaterialTextSelectionControls,
                              ),
                              padding: EdgeInsets.only(
                                  left: margin, right: margin, bottom: margin),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: margin),
                              child: buildTagsWidget(item),
                            ),
                            PicGridView(
                              tuChongItem: item,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: margin),
                              child: buildBottomWidget(item, showAvatar: false),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(vertical: margin),
                              color: Colors.grey.withOpacity(0.2),
                              height: margin,
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
