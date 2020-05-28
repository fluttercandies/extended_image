@JS()
library image_saver;

// ignore:avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:html';

import 'dart:typed_data';
import 'package:flutter/widgets.dart';
import 'package:js/js.dart';

@JS()
external void _exportRaw(String key, Uint8List value);

class ImageSaver {
  static Future<String> save(String name, Uint8List fileData) async {
    _exportRaw(name, fileData);
    return name;
  }
}

Future<Uint8List> pickImage(BuildContext context) async {
  final Completer<Uint8List> completer = Completer<Uint8List>();
  final InputElement input = document.createElement('input') as InputElement;

  input
    ..type = 'file'
    ..accept = 'image/*';
  input.onChange.listen((Event e) async {
    final List<File> files = input.files;
    final FileReader reader = FileReader();
    reader.readAsArrayBuffer(files[0]);
    reader.onError.listen((ProgressEvent error) => completer.completeError(error));
    await reader.onLoad.first;
    completer.complete(reader.result as Uint8List);
  });
  input.click();
  return completer.future;
}
