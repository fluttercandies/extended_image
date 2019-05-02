import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui show instantiateImageCodec, Codec;
import 'package:extended_image/src/network/extended_network_image_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart';
import 'package:http_client_helper/http_client_helper.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class ExtendedNetworkImageProvider
    extends ImageProvider<ExtendedNetworkImageProvider> {
  /// Creates an object that fetches the image at the given URL.
  ///
  /// The arguments must not be null.
  ExtendedNetworkImageProvider(
    this.url, {
    this.scale = 1.0,
    this.headers,
    this.cache: false,
    this.retries = 3,
    this.timeLimit,
    this.timeRetry = const Duration(milliseconds: 100),
    CancellationToken cancelToken,
  })  : assert(url != null),
        assert(scale != null),
        cancelToken = cancelToken ?? CancellationToken();

  ///time limit to request image
  final Duration timeLimit;

  ///the number of times to retry the request
  final int retries;

  ///the time duration in which to retry to request
  final Duration timeRetry;

  ///whether to cache image to local
  final bool cache;

  /// The URL from which the image will be fetched.
  final String url;

  /// The scale to place in the [ImageInfo] object of the image.
  final double scale;

  /// The HTTP headers that will be used with [HttpClient.get] to fetch image from network.
  final Map<String, String> headers;

  ///token to cancel network request
  final CancellationToken cancelToken;

//  /// cancel network request by extended image
//  /// if false, cancel by user
//  final bool autoCancel;

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
    final md5Key = keyToMd5(key.url);
    ui.Codec result;
    if (cache) {
      try {
        var data = await _loadCache(key, md5Key);
        if (data != null) {
          result = await instantiateImageCodec(data);
        }
      } catch (e) {
        print(e);
      }
    }

    if (result == null) {
      try {
        var data = await _loadNetwork(key);
        if (data != null) {
          result = await instantiateImageCodec(data);
        }
      } catch (e) {
        print(e);
      }
    }

    //Failed to load
    if (result == null) {
      //reuslt = await ui.instantiateImageCodec(kTransparentImage);
      return Future.error(StateError('Failed to load $url.'));
    }

    return result;
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
      Response response = await HttpClientHelper.get(url,
          headers: key.headers,
          timeLimit: key.timeLimit,
          timeRetry: key.timeRetry,
          retries: key.retries,
          cancelToken: key.cancelToken);
      return response.bodyBytes;
    } on OperationCanceledError catch (_) {
      print('User cancel request $url.');
      return Future.error(StateError('User cancel request $url.'));
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

  ///override this method, so that you can handle data,
  ///for example compress
  Future<ui.Codec> instantiateImageCodec(Uint8List data) async {
    return await ui.instantiateImageCodec(data);
  }
}

///save netwrok image to photo
//Future<bool> saveNetworkImageToPhoto(String url, {bool useCache: true}) async {
//  var data = await getNetworkImageData(url, useCache: useCache);
//  var filePath = await ImagePickerSaver.saveFile(fileData: data);
//  return filePath != null && filePath != "";
//}

///get network image data from cached
Future<Uint8List> getNetworkImageData(String url, {bool useCache: true}) async {
  ExtendedNetworkImageProvider imageProvider =
      new ExtendedNetworkImageProvider(url);
  String uId = keyToMd5(url);

  if (useCache) {
    try {
      return await imageProvider._loadCache(imageProvider, uId);
    } catch (e) {}
  }

  return await imageProvider._loadNetwork(imageProvider);
}
