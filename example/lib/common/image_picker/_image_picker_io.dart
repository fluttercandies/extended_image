import 'dart:async';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart' as picker;

Future<Uint8List> pickImage() async {
  final file =
      await picker.ImagePicker.pickImage(source: picker.ImageSource.gallery);
  return file.readAsBytes();
}
