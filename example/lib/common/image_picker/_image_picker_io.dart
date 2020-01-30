import 'dart:async';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart' as picker;
import 'package:image_picker_saver/image_picker_saver.dart';

Future<Uint8List> pickImage() async {
  final file =
      await picker.ImagePicker.pickImage(source: picker.ImageSource.gallery);
  return file.readAsBytes();
}

class ImageSaver {
  static Future<String> save(String name, Uint8List fileData) async {
    return await ImagePickerSaver.saveFile(fileData: fileData);
  }
}
