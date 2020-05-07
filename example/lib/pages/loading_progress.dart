import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:flutter_candies_demo_library/flutter_candies_demo_library.dart';

@FFRoute(
    name: 'fluttercandies://loadingprogress',
    routeName: 'loading progress',
    description: 'show how to make loading progress for network image')
class LoadingProgress extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: <Widget>[
          AppBar(
            title: const Text('loading progress demo'),
          ),
          Expanded(
            child: ExtendedImage.network(
              'https://raw.githubusercontent.com/fluttercandies/flutter_candies/master/gif/extended_text/special_text.jpg',
              handleLoadingProgress: true,
              clearMemoryCacheIfFailed: true,
              clearMemoryCacheWhenDispose: true,
              cache: false,
              loadStateChanged: (ExtendedImageState state) {
                if (state.extendedImageLoadState == LoadState.loading) {
                  final ImageChunkEvent loadingProgress = state.loadingProgress;
                  final double progress = loadingProgress?.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes
                      : null;
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          width: 150.0,
                          child: LinearProgressIndicator(
                            value: progress,
                          ),
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        Text('${((progress ?? 0.0) * 100).toInt()}%'),
                      ],
                    ),
                  );
                }
                return null;
              },
            ),
          )
        ],
      ),
    );
  }
}
