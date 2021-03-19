import 'package:example/common/data/tu_chong_source.dart';
import 'package:example/common/widget/common_widget.dart';
import 'package:example/common/widget/memory_usage_view.dart';
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'waterfall_flow_demo.dart';

@FFRoute(
  name: 'fluttercandies://MemoryUsageDemo',
  routeName: 'MemoryUsage',
  description: 'show how to reduce memory usage.',
  exts: <String, dynamic>{
    'group': 'Complex',
    'order': 3,
  },
)
class MemoryUsageDemo extends StatefulWidget {
  @override
  _MemoryUsageDemoState createState() => _MemoryUsageDemoState();
}

class _MemoryUsageDemoState extends State<MemoryUsageDemo> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('MemoryUsage'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.photo_library),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: () {
                PaintingBinding.instance?.imageCache?.clear();
              },
            ),
          ],
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            MemoryUsageView(),
            Expanded(child: WaterfallFlowDemo(
              imageBuilder: (TuChongItem item) {
                return ExtendedImage.network(item.imageUrl,
                    shape: BoxShape.rectangle,
                    clearMemoryCacheWhenDispose: false,
                    //compressionRatio: 0.1,
                    //maxBytes: 500 << 10,
                    border: Border.all(
                        color: Colors.grey.withOpacity(0.4), width: 1.0),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(10.0),
                    ), loadStateChanged: (ExtendedImageState value) {
                  if (value.extendedImageLoadState == LoadState.loading) {
                    return CommonCircularProgressIndicator();
                  } else if (value.extendedImageLoadState ==
                      LoadState.completed) {
                    item.imageRawSize = Size(
                        value.extendedImageInfo.image.width.toDouble(),
                        value.extendedImageInfo.image.height.toDouble());
                  }
                  return null;
                });
              },
            )),
          ],
        ));
  }
}
