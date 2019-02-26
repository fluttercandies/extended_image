import 'dart:convert';
import 'dart:io';
//import 'dart:typed_data';
//import 'dart:ui';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
//import 'dart:ui' as ui show Image, PictureRecorder;

const String CacheImageFolderName = "cacheimage";

String toMd5(String str) => md5.convert(utf8.encode(str)).toString();

///crop image
//ui.Image getCroppedImage(ui.Image image, Rect src, Rect dst) {
//  var pictureRecorder = new ui.PictureRecorder();
//  Canvas canvas = new Canvas(pictureRecorder);
//  canvas.drawImageRect(image, src, dst, Paint());
//  return pictureRecorder
//      .endRecording()
//      .toImage(dst.width.floor(), dst.height.floor());
//}

/// Clear the disk cache directory then return if it succeed.
///  <param name="duration">timespan to compute whether file has expired or not</param>
Future<bool> clearDiskCachedImages({Duration duration}) async {
  try {
    Directory _cacheImagesDirectory = Directory(
        join((await getTemporaryDirectory()).path, CacheImageFolderName));
    if (duration == null) {
      _cacheImagesDirectory.deleteSync(recursive: true);
    } else {
      var now = DateTime.now();
      for (var file in _cacheImagesDirectory.listSync()) {
        FileStat fs = file.statSync();
        if (now.subtract(duration).isAfter(fs.changed)) {
          print("remove expired cached image");
          file.deleteSync(recursive: true);
        }
      }
    }
  } catch (_) {
    return false;
  }
  return true;
}
