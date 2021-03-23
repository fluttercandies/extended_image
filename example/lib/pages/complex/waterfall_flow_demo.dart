import 'package:example/common/data/tu_chong_repository.dart';
import 'package:example/common/data/tu_chong_source.dart';
import 'package:example/common/utils/vm_helper.dart';
import 'package:example/common/widget/item_builder.dart';
import 'package:flutter/material.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:extended_image/extended_image.dart';

@FFRoute(
  name: 'fluttercandies://WaterfallFlowDemo',
  routeName: 'WaterfallFlow',
  description: 'WaterfallFlow with ExtendedImage.',
  exts: <String, dynamic>{
    'group': 'Complex',
    'order': 0,
  },
)
class WaterfallFlowDemo extends StatefulWidget {
  @override
  _WaterfallFlowDemoState createState() => _WaterfallFlowDemoState();
}

class _WaterfallFlowDemoState extends State<WaterfallFlowDemo> {
  TuChongRepository? listSourceRepository;
  @override
  void initState() {
    listSourceRepository = TuChongRepository();
    super.initState();
  }

  @override
  void dispose() {
    listSourceRepository?.dispose();
    clearMemoryImageCache('WaterfallFlow');
    // just for test
    VMHelper().forceGC();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: <Widget>[
          AppBar(
            title: const Text('WaterfallFlowDemo'),
          ),
          Expanded(
              child: LoadingMoreList<TuChongItem>(
            ListConfig<TuChongItem>(
              extendedListDelegate:
                  const SliverWaterfallFlowDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 300,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
              ),
              itemBuilder: buildWaterfallFlowItem,
              sourceList: listSourceRepository!,
              padding: const EdgeInsets.all(5.0),
              lastChildLayoutType: LastChildLayoutType.foot,
            ),
          ))
        ],
      ),
    );
  }
}
