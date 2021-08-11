import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

//import 'package:image_picker/image_picker.dart' as picker;
import 'package:flutter/cupertino.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

Future<Uint8List?> pickImage(BuildContext context) async {
  List<AssetEntity> assets = <AssetEntity>[];
  final List<AssetEntity>? result = await AssetPicker.pickAssets(
    context,
    maxAssets: 1,
    pathThumbSize: 84,
    gridCount: 3,
    pageSize: 300,
    selectedAssets: assets,
    requestType: RequestType.image,
    textDelegate: EnglishTextDelegate(),
  );
  if (result != null) {
    assets = List<AssetEntity>.from(result);
    return assets.first.originBytes;
  }
  return null;
  // final File file =

  //     await picker.ImagePicker.pickImage(source: picker.ImageSource.gallery);
  // return file.readAsBytes();
}

class ImageSaver {
  static Future<String?> save(String name, Uint8List fileData) async {
    final AssetEntity? imageEntity =
        await PhotoManager.editor.saveImage(fileData);
    final File? file = await imageEntity?.file;
    return file?.path;
  }
}
