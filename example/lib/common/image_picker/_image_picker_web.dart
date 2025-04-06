@JS()
library image_saver;

import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

@JS()
external void _exportRaw(String key, JSAny? value);

class ImageSaver {
  ImageSaver._();
  static Future<String> save(String name, Uint8List fileData) async {
    _exportRaw(name, fileData as JSAny);
    return name;
  }
}

Future<Uint8List> pickImage(BuildContext context) async {
  final Completer<Uint8List> completer = Completer<Uint8List>();
  final web.HTMLInputElement input =
      web.document.createElement('input') as web.HTMLInputElement;
  input
    ..type = 'file'
    ..accept = 'image/*';
  input.onChange.listen((web.Event e) async {
    final web.FileList files = input.files!;
    final web.FileReader reader = web.FileReader();
    final web.File? file = files.item(0);
    if (file == null) {
      return completer.completeError('No file selected');
    }
    reader.readAsArrayBuffer(file);
    reader.onLoadEnd.listen((web.Event e) {
      final Uint8List data =
          (reader.result as JSArrayBuffer).toDart.asUint8List();
      completer.complete(data);
    });
  });

  input.click();
  return completer.future;
}
