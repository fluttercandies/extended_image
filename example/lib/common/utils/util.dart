import 'dart:typed_data';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:photo_manager/photo_manager.dart';

///
///  create by zmtzawqlp on 2020/1/31
///
double? initScale({
  required Size imageSize,
  required Size size,
  double? initialScale,
}) {
  final double n1 = imageSize.height / imageSize.width;
  final double n2 = size.height / size.width;
  if (n1 > n2) {
    final FittedSizes fittedSizes =
        applyBoxFit(BoxFit.contain, imageSize, size);
    //final Size sourceSize = fittedSizes.source;
    final Size destinationSize = fittedSizes.destination;
    return size.width / destinationSize.width;
  } else if (n1 / n2 < 1 / 4) {
    final FittedSizes fittedSizes =
        applyBoxFit(BoxFit.contain, imageSize, size);
    //final Size sourceSize = fittedSizes.source;
    final Size destinationSize = fittedSizes.destination;
    return size.height / destinationSize.height;
  }

  return initialScale;
}

/// Save network image to the photo library.
Future<bool> saveNetworkImageToPhoto(String url, {bool useCache = true}) async {
  if (kIsWeb) {
    return false;
  }
  final String title = '${DateTime.now().millisecondsSinceEpoch}.jpg';
  final Uint8List? data = await getNetworkImageData(url, useCache: useCache);
  final AssetEntity? imageEntity = await PhotoManager.editor.saveImage(
    data!,
    title: title,
  );
  return imageEntity != null;
}
