import 'package:example/common/data/tu_chong_repository.dart';
import 'package:example/common/data/tu_chong_source.dart';
import 'package:example/common/utils/vm_helper.dart';
import 'package:example/common/widget/common_widget.dart';
import 'package:example/common/widget/memory_usage_chart.dart';
import 'package:extended_image/extended_image.dart';
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/material.dart';
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
  // you can define custom ImageCahce, and clear memory only for those images.
  final String imageCacheName = 'MemoryUsage';
  double? _compressionRatio;
  int? _maxBytes;
  bool _clearMemoryCacheWhenDispose = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('MemoryUsage'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            MemoryUsageChart(),
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
                    child: Stack(
                      children: <Widget>[
                        Positioned.fill(
                          child: ExtendedImage.network(
                            item.imageUrl,
                            shape: BoxShape.rectangle,
                            // memory usage start
                            compressionRatio: _compressionRatio,
                            maxBytes: _maxBytes,
                            clearMemoryCacheWhenDispose:
                                _clearMemoryCacheWhenDispose,
                            imageCacheName: imageCacheName,
                            // memory usage end
                            border: Border.all(
                                color: Colors.grey.withValues(alpha: 0.4),
                                width: 1.0),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(10.0),
                            ),
                            loadStateChanged: (ExtendedImageState value) {
                              if (value.extendedImageLoadState ==
                                  LoadState.loading) {
                                return CommonCircularProgressIndicator();
                              }
                              return null;
                            },
                          ),
                        ),
                        Positioned(
                          top: 5.0,
                          right: 5.0,
                          child: Container(
                            padding: const EdgeInsets.all(3.0),
                            decoration: BoxDecoration(
                              color: Colors.grey.withValues(alpha: 0.6),
                              border: Border.all(
                                  color: Colors.grey.withValues(alpha: 0.4),
                                  width: 1.0),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(5.0),
                              ),
                            ),
                            child: Text(
                              '${index + 1}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
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

  @override
  void dispose() {
    listSourceRepository.dispose();
    // clear ImageCache which named 'MemoryUsage'
    clearMemoryImageCache(imageCacheName);
    // just for test
    VMHelper().forceGC();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    listSourceRepository = TuChongRepository();
    // try the following parameters, they can reduce memory usage
    _maxBytes = 500 << 10;
    //_compressionRatio = 0.4;
    _clearMemoryCacheWhenDispose = true;
  }
}
