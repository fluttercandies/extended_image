import 'package:example/common/data/tu_chong_repository.dart';
import 'package:example/common/data/tu_chong_source.dart';
import 'package:example/common/widget/common_widget.dart';
import 'package:example/common/widget/memory_usage_view.dart';
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'package:loading_more_list/loading_more_list.dart';

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
 late TuChongRepository listSourceRepository;
  final String imageCacheName = 'MemoryUsage';
  @override
  void initState() {
    listSourceRepository = TuChongRepository(maxLength: 2000);
    super.initState();
  }

  @override
  void dispose() {
    listSourceRepository.dispose();
    clearMemoryImageCache(imageCacheName);
    super.dispose();
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
            Expanded(
                child: LoadingMoreList<TuChongItem>(
              ListConfig<TuChongItem>(
                extendedListDelegate:
                    const SliverWaterfallFlowDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 300,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
                ),
                itemBuilder: (
                  BuildContext c,
                  TuChongItem item,
                  int index,
                ) {
                  return AspectRatio(
                    aspectRatio: item.imageSize.width / item.imageSize.height,
                    child: ExtendedImage.network(
                      item.imageUrl,
                      shape: BoxShape.rectangle,
                      //clearMemoryCacheWhenDispose: true,
                      border: Border.all(
                          color: Colors.grey.withOpacity(0.4), width: 1.0),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(10.0),
                      ),
                      loadStateChanged: (ExtendedImageState value) {
                        if (value.extendedImageLoadState == LoadState.loading) {
                          return CommonCircularProgressIndicator();
                        }
                        return null;
                      },
                      imageCacheName: imageCacheName,
                    ),
                  );
                },
                sourceList: listSourceRepository,
                padding: const EdgeInsets.all(5.0),
                lastChildLayoutType: LastChildLayoutType.foot,
              ),
            )),
          ],
        ));
  }
}
