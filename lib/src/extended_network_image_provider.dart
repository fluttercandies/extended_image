import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui show instantiateImageCodec, Codec;

import 'package:extended_image/src/extended_image.dart';
import 'package:extended_image/src/extended_image_utils.dart';
import 'package:extended_image/src/extended_network_image_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart';
import 'package:http_client_helper/http_client_helper.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker_saver/image_picker_saver.dart';
import 'package:transparent_image/transparent_image.dart';

class ExtendedNetworkImageProvider
    extends ImageProvider<ExtendedNetworkImageProvider> {
  /// Creates an object that fetches the image at the given URL.
  ///
  /// The arguments must not be null.
  ExtendedNetworkImageProvider(this.url,
      {this.scale = 1.0, this.headers, this.cache: false})
      : assert(url != null),
        assert(scale != null);

  ///whether cache image to local
  final bool cache;

  /// The URL from which the image will be fetched.
  final String url;

  /// The scale to place in the [ImageInfo] object of the image.
  final double scale;

  /// The HTTP headers that will be used with [HttpClient.get] to fetch image from network.
  final Map<String, String> headers;

  LoadState loadState = LoadState.loading;

  @override
  ImageStreamCompleter load(ExtendedNetworkImageProvider key) {
    // TODO: implement load
    return MultiFrameImageStreamCompleter(
        codec: _loadAsync(key),
        scale: key.scale,
        informationCollector: (StringBuffer information) {
          information.writeln('Image provider: $this');
          information.write('Image key: $key');
        });
  }

  @override
  Future<ExtendedNetworkImageProvider> obtainKey(
      ImageConfiguration configuration) {
    // TODO: implement obtainKey
    return SynchronousFuture<ExtendedNetworkImageProvider>(this);
  }

  Future<ui.Codec> _loadAsync(ExtendedNetworkImageProvider key) async {
    assert(key == this);
    loadState = LoadState.loading;
    final md5Key = toMd5(key.url);
    ui.Codec reuslt;
    if (cache) {
      try {
        var data = await _loadCache(key, md5Key);
        if (data != null) reuslt = await ui.instantiateImageCodec(data);
      } catch (e) {
        print(e);
      }
    }

    if (reuslt == null) {
      try {
        var data = await _loadNetwork(key);
        if (data != null) reuslt = await ui.instantiateImageCodec(data);
      } catch (e) {
        print(e);
      }
    }

    //failed
    loadState = (reuslt != null ? LoadState.completed : LoadState.failed);

    if (reuslt == null) {
      reuslt = await ui.instantiateImageCodec(kTransparentImage);
    }

    return reuslt;
  }

  ///get the image from cache folder.
  Future<Uint8List> _loadCache(
      ExtendedNetworkImageProvider key, String md5Key) async {
    Directory _cacheImagesDirectory = Directory(
        join((await getTemporaryDirectory()).path, CacheImageFolderName));
    //exist, try to find cache image file
    if (_cacheImagesDirectory.existsSync()) {
      File cacheFlie = File(join(_cacheImagesDirectory.path, md5Key));
      if (cacheFlie.existsSync()) {
        return await cacheFlie.readAsBytes();
      }
    }
    //create folder
    else {
      await _cacheImagesDirectory.create();
    }

    //load from network
    Uint8List data = await _loadNetwork(key);
    if (data != null) {
      //cache image file
      await (File(join(_cacheImagesDirectory.path, md5Key))).writeAsBytes(data);
      return data;
    }

    return null;
  }

  /// get the image from network.
  Future<Uint8List> _loadNetwork(ExtendedNetworkImageProvider key) async {
    try {
      Response response = await HttpClientHelper.get(url, headers: headers);
      return response.bodyBytes;
    } catch (e) {}
    return null;
  }

  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) return false;
    final ExtendedNetworkImageProvider typedOther = other;
    return url == typedOther.url && scale == typedOther.scale;
  }

  @override
  int get hashCode => hashValues(url, scale);

  @override
  String toString() => '$runtimeType("$url", scale: $scale)';
}

Future<bool> saveNetworkImageToPhoto(String url, {bool useCache: true}) async {
  ExtendedNetworkImageProvider imageProvider =
      new ExtendedNetworkImageProvider(url);
  String uId = toMd5(url);

  bool done = false;
  if (useCache) {
    try {
      var result = await imageProvider._loadCache(imageProvider, uId);
      var filePath = await ImagePickerSaver.saveFile(fileData: result);
      done = filePath != null && filePath != "";
    } catch (e) {
      //debugPrint(e.toString());
    }
  }

  if (!done) {
    var result = await imageProvider._loadNetwork(imageProvider);
    var filePath = await ImagePickerSaver.saveFile(fileData: result);
    done = filePath != null && filePath != "";
  }

  return done;
}
