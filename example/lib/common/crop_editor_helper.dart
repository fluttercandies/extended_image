//import 'dart:typed_data';
import 'dart:ui' hide Image;
import 'package:extended_image/extended_image.dart';
import 'package:image/image.dart';
//import 'package:image_editor/image_editor.dart';

Future<List<int>> cropImageDataWithDartLibrary(
    {ExtendedImageEditorState state}) async {
  ///crop rect base on raw image
  final Rect cropRect = state.getCropRect();

  var data = state.rawImageData;

  final EditActionDetails editAction = state.editAction;

  var time1 = DateTime.now();

  ///if you don't want to block ui, use compute/isolate,but it costs more time.
  //Image src = await compute(decodeImage, data);
  Image src = decodeImage(data);

  var time2 = DateTime.now();

  print("${time2.difference(time1)} : decode");

  //clear orientation
  src = bakeOrientation(src);

  if (editAction.needCrop)
    src = copyCrop(src, cropRect.left.toInt(), cropRect.top.toInt(),
        cropRect.width.toInt(), cropRect.height.toInt());

  if (editAction.needFlip)
    src = copyFlip(src, flipX: editAction.flipX, flipY: editAction.flipY);

  if (editAction.hasRotateAngle) src = copyRotate(src, editAction.rotateAngle);

  var time3 = DateTime.now();
  print("${time3.difference(time2)} : crop/flip/rotate");

  //var fileData = encodePng(src, level: 1);
  ///you can encode your image as you want
  ///
  ///if you don't want to block ui, use compute/isolate,but it costs more time.
  //var fileData = await compute(encodeJpg, src);
  var fileData = encodeJpg(src);

  var time4 = DateTime.now();
  print("${time4.difference(time3)} : encode");
  print("${time4.difference(time1)} : total time");
  return fileData;
}

Image copyFlip(Image src, {bool flipX = false, bool flipY = false}) {
  if (!flipX && !flipY) return src;

  Image dst = Image(src.width, src.height,
      channels: src.channels, exif: src.exif, iccp: src.iccProfile);

  for (int yi = 0; yi < src.height; ++yi,) {
    for (int xi = 0; xi < src.width; ++xi,) {
      var sx = flipY ? src.width - 1 - xi : xi;
      var sy = flipX ? src.height - 1 - yi : yi;
      dst.setPixel(xi, yi, src.getPixel(sx, sy));
    }
  }

  return dst;
}

// Future<Uint8List> cropImageDataWithNativeLibrary(
//     {ExtendedImageEditorState state}) async {
//   final rect = state.getCropRect();
//   final action = state.editAction;
//   final radian = action.rotateAngle;

//   final flipHorizontal = action.flipY;
//   final flipVertical = action.flipX;
//   final img = state.rawImageData;

//   ImageEditorOption option = ImageEditorOption();

//   if (action.needCrop) option.addOption(ClipOption.fromRect(rect));

//   if (action.needFlip)
//     option.addOption(
//         FlipOption(horizontal: flipHorizontal, vertical: flipVertical));

//   if (action.hasRotateAngle) option.addOption(RotateOption.radian(radian));

//   final start = DateTime.now();
//   final result = await ImageEditor.editImage(
//     image: img,
//     imageEditorOption: option,
//   );

//   print("total time: ${DateTime.now().difference(start)}");
//   return result;
// }
