///
///  photo_view_demo.dart
///  create by zmtzawqlp on 2019/4/4
///

import 'dart:async';
import 'dart:math';
// ignore: implementation_imports
import 'package:extended_text/src/selection/extended_text_selection.dart';
import 'package:flutter_candies_demo_library/flutter_candies_demo_library.dart';
import 'package:extended_image/extended_image.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide CircularProgressIndicator;
import 'package:loading_more_list/loading_more_list.dart';
import 'package:pull_to_refresh_notification/pull_to_refresh_notification.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';

import 'package:ff_annotation_route/ff_annotation_route.dart';

@FFRoute(
    name: 'fluttercandies://photoview',
    routeName: 'photo view',
    description: 'show how to zoom/pan image in page view like WeChat')
class PhotoViewDemo extends StatefulWidget {
  @override
  _PhotoViewDemoState createState() => _PhotoViewDemoState();
}

class _PhotoViewDemoState extends State<PhotoViewDemo> {
  MyExtendedMaterialTextSelectionControls
      _myExtendedMaterialTextSelectionControls;
  final String _attachContent =
      '[love]Extended text help you to build rich text quickly. any special text you will have with extended text.It\'s my pleasure to invite you to join \$FlutterCandies\$ if you want to improve flutter .[love] if you meet any problem, please let me konw @zmtzawqlp .[sun_glasses]';
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
    final  double margin = ScreenUtil.instance.setWidth(22);
    final Widget result = Material(
      child: Column(
        children: <Widget>[
          AppBar(
            title: const Text('photo view demo'),
          ),
          Container(
            padding: EdgeInsets.all(margin),
            child: const Text(
                'click image to show photo view, support zoom/pan image. horizontal and vertical page view are supported.'),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (BuildContext c, BoxConstraints data) {
                final int crossAxisCount =
                    max(data.maxWidth ~/ ScreenUtil.instance.screenWidthDp, 1);
                return PullToRefreshNotification(
                    pullBackOnRefresh: false,
                    maxDragOffset: maxDragOffset,
                    armedDragUpCancel: false,
                    onRefresh: onRefresh,
                    child: LoadingMoreCustomScrollView(
                      showGlowLeading: false,
                      physics: const ClampingScrollPhysics(),
                      slivers: <Widget>[
                        SliverToBoxAdapter(
                          child: PullToRefreshContainer((PullToRefreshScrollNotificationInfo info) {
                            return PullToRefreshHeader(info, dateTimeNow);
                          }),
                        ),
                        LoadingMoreSliverList<TuChongItem>(
                          SliverListConfig<TuChongItem>(
                            waterfallFlowDelegate: WaterfallFlowDelegate(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: 5,
                              mainAxisSpacing: 5,
                            ),
                            // collectGarbage: (List<int> indexes) {
                            //   ///collectGarbage
                            //   indexes.forEach((index) {
                            //     final item = listSourceRepository[index];
                            //     if (item.hasImage) {
                            //       item.images.forEach((image) {
                            //         image.clearCache();
                            //       });
                            //     }
                            //   });
                            // },
                            itemBuilder: (BuildContext context, TuChongItem item, int index) {
                              String title = item.site.name;
                              if (title == null || title == '') {
                                title = 'Image$index';
                              }

                              String content =
                                  item.content ?? (item.excerpt ?? title);
                              content += _attachContent;

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
                                          clearMemoryCacheWhenDispose: true,
                                          border: Border.all(
                                              color:
                                                  Colors.grey.withOpacity(0.4),
                                              width: 1.0),
                                          loadStateChanged: (ExtendedImageState state) {
                                            if (state.extendedImageLoadState ==
                                                LoadState.completed) {
                                              return null;
                                            }
                                            return Image.asset(
                                              'assets/avatar.jpg',
                                              package:
                                                  'flutter_candies_demo_library',
                                            );
                                          },
                                        ),
                                        SizedBox(
                                          width: margin,
                                        ),
                                        Text(title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize:
                                                  ScreenUtil.instance.setSp(34),
                                            )),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    child: ExtendedText(
                                      content,
                                      onSpecialTextTap: (dynamic parameter) {
                                        if (parameter.toString().startsWith('\$')) {
                                          launch(
                                              'https://github.com/fluttercandies');
                                        } else if (parameter.toString().startsWith('@')) {
                                          launch('mailto:zmtzawqlp@live.com');
                                        }
                                      },
                                      specialTextSpanBuilder:
                                          MySpecialTextSpanBuilder(),
                                      //overflow: ExtendedTextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.grey),
                                      maxLines: 10,
                                      overFlowTextSpan: kIsWeb
                                          ? null
                                          : OverFlowTextSpan(
                                              children: <TextSpan>[
                                                const TextSpan(text: '  \u2026  '),
                                                TextSpan(
                                                    text: 'more detail',
                                                    style: TextStyle(
                                                      color: Colors.blue,
                                                    ),
                                                    recognizer:
                                                        TapGestureRecognizer()
                                                          ..onTap = () {
                                                            launch(
                                                                'https://github.com/fluttercandies/extended_text');
                                                          })
                                              ],
                                            ),
                                      selectionEnabled: true,
                                      textSelectionControls:
                                          _myExtendedMaterialTextSelectionControls,
                                    ),
                                    padding: EdgeInsets.only(
                                        left: margin,
                                        right: margin,
                                        bottom: margin),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: margin),
                                    child: buildTagsWidget(item),
                                  ),
                                  PicGridView(
                                    tuChongItem: item,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: margin),
                                    child: buildBottomWidget(item,
                                        showAvatar: false),
                                  ),
                                  Container(
                                    margin:
                                        EdgeInsets.symmetric(vertical: margin),
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
                    ));
              },
            ),
          )
        ],
      ),
    );

    return ExtendedTextSelectionPointerHandler(
      //default behavior
      // child: result,
      //custom your behavior
      builder: (List<ExtendedTextSelectionState> states) {
        return Listener(
          child: result,
          behavior: HitTestBehavior.translucent,
          onPointerDown: (PointerDownEvent value) {
            for (final ExtendedTextSelectionState state in states) {
              if (!state.containsPosition(value.position)) {
                //clear other selection
                state.clearSelection();
              }
            }
          },
          onPointerMove: (PointerMoveEvent value) {
            //clear other selection
            for (final ExtendedTextSelectionState state in states) {
              state.clearSelection();
            }
          },
        );
      },
    );
  }


  Future<bool> onRefresh() {
    return listSourceRepository.refresh().whenComplete(() {
      dateTimeNow = DateTime.now();
    });
  }
}
