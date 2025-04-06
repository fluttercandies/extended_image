///
///  photo_view_demo.dart
///  create by zmtzawqlp on 2019/4/4
///
import 'dart:async';

import 'package:example/common/data/tu_chong_repository.dart';
import 'package:example/common/data/tu_chong_source.dart';
import 'package:example/common/utils/vm_helper.dart';
import 'package:example/common/widget/item_builder.dart';
import 'package:example/common/widget/pic_grid_view.dart';
import 'package:example/common/widget/push_to_refresh_header.dart';
import 'package:extended_image/extended_image.dart';
// import 'package:extended_text/extended_text.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/material.dart' hide CircularProgressIndicator;
import 'package:loading_more_list/loading_more_list.dart';
import 'package:pull_to_refresh_notification/pull_to_refresh_notification.dart';

@FFRoute(
  name: 'fluttercandies://photoview',
  routeName: 'PhotoView',
  description: 'Complex demo for photo view.',
  exts: <String, dynamic>{
    'group': 'Complex',
    'order': 2,
  },
)
class PhotoViewDemo extends StatefulWidget {
  @override
  _PhotoViewDemoState createState() => _PhotoViewDemoState();
}

class _PhotoViewDemoState extends State<PhotoViewDemo> {
  // MyTextSelectionControls? _myExtendedMaterialTextSelectionControls;
  final String _attachContent =
      '[love]Extended text help you to build rich text quickly. any special text you will have with extended text.It\'s my pleasure to invite you to join \$FlutterCandies\$ if you want to improve flutter .[love] if you meet any problem, please let me konw @zmtzawqlp .[sun_glasses]';
  TuChongRepository listSourceRepository = TuChongRepository();

  bool konwImageSize = true;

  //if you can't konw image size before build,
  //you have to handle copy when image is loaded.
  DateTime dateTimeNow = DateTime.now();
  @override
  Widget build(BuildContext context) {
    const double margin = 11;
    final Widget result = Scaffold(
      appBar: AppBar(
        title: const Text('photo view demo'),
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(margin),
            child: const Text(
                'click image to show photo view, support zoom/pan image. horizontal and vertical page view are supported.'),
          ),
          Expanded(
            child: PullToRefreshNotification(
                pullBackOnRefresh: false,
                maxDragOffset: maxDragOffset,
                armedDragUpCancel: false,
                onRefresh: onRefresh,
                child: LoadingMoreCustomScrollView(
                  showGlowLeading: false,
                  physics: const ClampingScrollPhysics(),
                  slivers: <Widget>[
                    SliverToBoxAdapter(
                      child: PullToRefreshContainer(
                          (PullToRefreshScrollNotificationInfo? info) {
                        return PullToRefreshHeader(info, dateTimeNow);
                      }),
                    ),
                    LoadingMoreSliverList<TuChongItem>(
                      SliverListConfig<TuChongItem>(
                        extendedListDelegate:
                            const SliverWaterfallFlowDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 600,
                          crossAxisSpacing: 5,
                          mainAxisSpacing: 5,
                        ),
                        itemBuilder: (BuildContext context, TuChongItem item,
                            int index) {
                          String? title = item.site!.name;
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
                                padding: const EdgeInsets.all(margin),
                                child: Row(
                                  children: <Widget>[
                                    ExtendedImage.network(
                                      item.avatarUrl!,
                                      width: 40.0,
                                      height: 40.0,
                                      shape: BoxShape.circle,
                                      imageCacheName: 'CropImage',
                                      clearMemoryCacheWhenDispose: true,
                                      border: Border.all(
                                          color: Colors.grey
                                              .withValues(alpha: 0.4),
                                          width: 1.0),
                                      loadStateChanged:
                                          (ExtendedImageState state) {
                                        if (state.extendedImageLoadState ==
                                            LoadState.completed) {
                                          return null;
                                        }
                                        return ExtendedImage.asset(
                                          'assets/avatar.jpg',
                                          imageCacheName: 'CropImage',
                                        );
                                      },
                                    ),
                                    const SizedBox(
                                      width: margin,
                                    ),
                                    Text(title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 17,
                                        )),
                                  ],
                                ),
                              ),
                              Padding(
                                child: Text(
                                  content,
                                  // onSpecialTextTap: (dynamic parameter) {
                                  //   if (parameter.toString().startsWith('\$')) {
                                  //     launchUrl(Uri.parse(
                                  //         'https://github.com/fluttercandies'));
                                  //   } else if (parameter
                                  //       .toString()
                                  //       .startsWith('@')) {
                                  //     launchUrl(Uri.parse(
                                  //         'mailto:zmtzawqlp@live.com'));
                                  //   }
                                  // },
                                  // specialTextSpanBuilder:
                                  //     MySpecialTextSpanBuilder(),
                                  //overflow: ExtendedTextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.grey),
                                  maxLines: 5,
                                  // overflowWidget: TextOverflowWidget(
                                  //   child: Row(
                                  //     mainAxisSize: MainAxisSize.min,
                                  //     children: <Widget>[
                                  //       const Text('\u2026 '),
                                  //       InkWell(
                                  //         child: const Text('more'),
                                  //         onTap: () {
                                  //           launchUrl(Uri.parse(
                                  //               'https://github.com/fluttercandies/extended_text'));
                                  //         },
                                  //       )
                                  //     ],
                                  //   ),
                                  // ),
                                  // selectionEnabled: true,
                                  // selectionControls:
                                  //     _myExtendedMaterialTextSelectionControls,
                                ),
                                padding: const EdgeInsets.only(
                                    left: margin,
                                    right: margin,
                                    bottom: margin),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: margin),
                                child: buildTagsWidget(item),
                              ),
                              PicGridView(
                                tuChongItem: item,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: margin),
                                child:
                                    buildBottomWidget(item, showAvatar: false),
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(
                                    vertical: margin),
                                color: Colors.grey.withValues(alpha: 0.2),
                                height: margin,
                              )
                            ],
                          );
                        },
                        sourceList: listSourceRepository,
                      ),
                    )
                  ],
                )),
          )
        ],
      ),
    );
    return result;
    // return ExtendedTextSelectionPointerHandler(
    //   //default behavior
    //   // child: result,
    //   //custom your behavior
    //   builder: (List<ExtendedTextSelectionState> states) {
    //     return Listener(
    //       child: result,
    //       behavior: HitTestBehavior.translucent,
    //       onPointerDown: (PointerDownEvent value) {
    //         for (final ExtendedTextSelectionState state in states) {
    //           if (!state.containsPosition(value.position)) {
    //             //clear other selection
    //             state.clearSelection();
    //           }
    //         }
    //       },
    //       onPointerMove: (PointerMoveEvent value) {
    //         //clear other selection
    //         for (final ExtendedTextSelectionState state in states) {
    //           state.clearSelection();
    //         }
    //       },
    //     );
    //   },
    // );
  }

  @override
  void dispose() {
    listSourceRepository.dispose();
    clearMemoryImageCache('CropImage');
    // just for test
    VMHelper().forceGC();
    super.dispose();
  }

  @override
  void initState() {
    // _myExtendedMaterialTextSelectionControls = MyTextSelectionControls();
    super.initState();
  }

  Future<bool> onRefresh() {
    return listSourceRepository.refresh().whenComplete(() {
      dateTimeNow = DateTime.now();
    });
  }
}
