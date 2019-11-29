import 'package:example/common/item_builder.dart';
import 'package:example/common/tu_chong_repository.dart';
import 'package:example/common/tu_chong_source.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:ff_annotation_route/ff_annotation_route.dart';
//import 'package:extended_image_library/extended_image_library.dart';

@FFRoute(
    name: "fluttercandies://WaterfallFlowDemo",
    routeName: "WaterfallFlow",
    description:
        "show how to build loading more WaterfallFlow with ExtendedImage.")
class WaterfallFlowDemo extends StatefulWidget {
  @override
  _WaterfallFlowDemoState createState() => _WaterfallFlowDemoState();
}

class _WaterfallFlowDemoState extends State<WaterfallFlowDemo> {
  TuChongRepository listSourceRepository;
  @override
  void initState() {
    listSourceRepository = new TuChongRepository();
    super.initState();
  }

  @override
  void dispose() {
    listSourceRepository?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: <Widget>[
          AppBar(
            title: Text("WaterfallFlowDemo"),
          ),
          Expanded(
            child: 
            LoadingMoreList(
              ListConfig<TuChongItem>(
                waterfallFlowDelegate: WaterfallFlowDelegate(
                  crossAxisCount: 2,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
                ),
                itemBuilder: buildWaterfallFlowItem,
                sourceList: listSourceRepository,
                padding: EdgeInsets.all(5.0),
                lastChildLayoutType: LastChildLayoutType.foot,
                collectGarbage: (List<int> garbages) {
                  ///collectGarbage
                  garbages.forEach((index) {
                    final provider = ExtendedNetworkImageProvider(
                      listSourceRepository[index].imageUrl,
                    );
                    provider.evict();
                  });
                },
                // viewportBuilder: (int firstIndex, int lastIndex) {
                //   print("viewport : [$firstIndex,$lastIndex]");
                // },
              ),
            ),
          )
        ],
      ),
    );
  }
}
