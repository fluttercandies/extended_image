import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
//import 'package:image_picker/image_picker.dart' as picker;
import 'package:flutter/cupertino.dart';
import 'package:flutter_candies_demo_library/flutter_candies_demo_library.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

Future<Uint8List> pickImage(BuildContext context) async {
  List<AssetEntity> assets = <AssetEntity>[];
  final List<AssetEntity> result = await AssetPicker.pickAssets(
    context,
    maxAssets: 1,
    pathThumbSize: 84,
    gridCount: 3,
    pageSize: 300,
    selectedAssets: assets,
    requestType: RequestType.image,
    textDelegate: PickerTextDelegate(),
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
  static Future<String> save(String name, Uint8List fileData) async {
    final AssetEntity imageEntity =
        await PhotoManager.editor.saveImage(fileData);
    final File file = await imageEntity.file;
    return file.path;
  }
}

class PickerTextDelegate implements TextDelegate {
  factory PickerTextDelegate() => _instance;

  PickerTextDelegate._internal();

  static final PickerTextDelegate _instance = PickerTextDelegate._internal();

  @override
  String confirm = 'OK';

  @override
  String cancel = 'Cancel';

  @override
  String edit = 'Edit';

  @override
  String emptyPlaceHolder = 'empty';

  @override
  String gifIndicator = 'GIF';

  @override
  String heicNotSupported = 'not support HEIC yet';

  @override
  String loadFailed = 'load failed';

  @override
  String original = 'Original';

  @override
  String preview = 'Preview';

  @override
  String select = 'Select';

  @override
  String unSupportedAssetType = 'not support yet';

  @override
  String durationIndicatorBuilder(Duration duration) {
    const String separator = ':';
    final String minute = duration.inMinutes.toString().padLeft(2, '0');
    final String second =
        ((duration - Duration(minutes: duration.inMinutes)).inSeconds)
            .toString()
            .padLeft(2, '0');
    return '$minute$separator$second';
  }
}
