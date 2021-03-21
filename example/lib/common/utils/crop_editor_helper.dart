//import 'dart:typed_data';
import 'dart:isolate';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/foundation.dart';

// ignore: implementation_imports
import 'package:http/src/response.dart';
import 'package:http_client_helper/http_client_helper.dart';

// import 'package:isolate/load_balancer.dart';
// import 'package:isolate/isolate_runner.dart';
import 'package:extended_image/extended_image.dart';
import 'package:image/image.dart';
import 'package:image_editor/image_editor.dart';

// final Future<LoadBalancer> loadBalancer =
//     LoadBalancer.create(1, IsolateRunner.spawn);

Future<dynamic> isolateDecodeImage(List<int> data) async {
  final ReceivePort response = ReceivePort();
  await Isolate.spawn(_isolateDecodeImage, response.sendPort);
  final dynamic sendPort = await response.first;
  final ReceivePort answer = ReceivePort();
  // ignore: always_specify_types
  sendPort.send([answer.sendPort, data]);
  return answer.first;
}

void _isolateDecodeImage(SendPort port) {
  final ReceivePort rPort = ReceivePort();
  port.send(rPort.sendPort);
  rPort.listen((dynamic message) {
    final SendPort send = message[0] as SendPort;
    final List<int> data = message[1] as List<int>;
    send.send(decodeImage(data));
  });
}

Future<dynamic> isolateEncodeImage(Image src) async {
  final ReceivePort response = ReceivePort();
  await Isolate.spawn(_isolateEncodeImage, response.sendPort);
  final dynamic sendPort = await response.first;
  final ReceivePort answer = ReceivePort();
  // ignore: always_specify_types
  sendPort.send([answer.sendPort, src]);
  return answer.first;
}

void _isolateEncodeImage(SendPort port) {
  final ReceivePort rPort = ReceivePort();
  port.send(rPort.sendPort);
  rPort.listen((dynamic message) {
    final SendPort send = message[0] as SendPort;
    final Image src = message[1] as Image;
    send.send(encodeJpg(src));
  });
}

Future<List<int>?> cropImageDataWithDartLibrary(
    {required ExtendedImageEditorState state}) async {
  print('dart library start cropping');

  ///crop rect base on raw image
  final Rect? cropRect = state.getCropRect();

  print('getCropRect : $cropRect');

  // in web, we can't get rawImageData due to .
  // using following code to get imageCodec without download it.
  // final Uri resolved = Uri.base.resolve(key.url);
  // // This API only exists in the web engine implementation and is not
  // // contained in the analyzer summary for Flutter.
  // return ui.webOnlyInstantiateImageCodecFromUrl(
  //     resolved); //

  final Uint8List data = kIsWeb &&
          state.widget.extendedImageState.imageWidget.image
              is ExtendedNetworkImageProvider
      ? await _loadNetwork(state.widget.extendedImageState.imageWidget.image
          as ExtendedNetworkImageProvider)

      ///toByteData is not work on web
      ///https://github.com/flutter/flutter/issues/44908
      // (await state.image.toByteData(format: ui.ImageByteFormat.png))
      //     .buffer
      //     .asUint8List()
      : state.rawImageData;

  final EditActionDetails editAction = state.editAction!;

  final DateTime time1 = DateTime.now();

  //Decode source to Animation. It can holds multi frame.
  Animation? src;
  //LoadBalancer lb;
  if (kIsWeb) {
    src = decodeAnimation(data);
  } else {
    src = await compute(decodeAnimation, data);
  }
  if (src != null) {
    //handle every frame.
    src.frames = src.frames.map((image) {
      final DateTime time2 = DateTime.now();
      //clear orientation
      image = bakeOrientation(image);

      if (editAction.needCrop) {
        image = copyCrop(image, cropRect!.left.toInt(), cropRect.top.toInt(),
            cropRect.width.toInt(), cropRect.height.toInt());
      }

      if (editAction.needFlip) {
        late Flip mode;
        if (editAction.flipY && editAction.flipX) {
          mode = Flip.both;
        } else if (editAction.flipY) {
          mode = Flip.horizontal;
        } else if (editAction.flipX) {
          mode = Flip.vertical;
        }
        image = flip(image, mode);
      }

      if (editAction.hasRotateAngle) {
        image = copyRotate(image, editAction.rotateAngle);
      }
      final DateTime time3 = DateTime.now();
      print('${time3.difference(time2)} : crop/flip/rotate');
      return image;
    }).toList();
  }

  /// you can encode your image
  ///
  /// it costs much time and blocks ui.
  //var fileData = encodeJpg(src);

  /// it will not block ui with using isolate.
  //var fileData = await compute(encodeJpg, src);
  //var fileData = await isolateEncodeImage(src);
  List<int>? fileData;
  print('start encode');
  final DateTime time4 = DateTime.now();
  if (src != null) {
    bool onlyOneFrame = src.numFrames == 1;
    //If there's only one frame, encode it to jpg.
    if (kIsWeb) {
      fileData = onlyOneFrame ? encodeJpg(src.first) : encodeGifAnimation(src);
    } else {
      //fileData = await lb.run<List<int>, Image>(encodeJpg, src);
      fileData = onlyOneFrame
          ? await compute(encodeJpg, src.first)
          : await compute(encodeGifAnimation, src);
    }
  }
  final DateTime time5 = DateTime.now();
  print('${time5.difference(time4)} : encode');
  print('${time5.difference(time1)} : total time');
  return fileData;
}

Future<List<int>?> cropImageDataWithNativeLibrary(
    {required ExtendedImageEditorState state}) async {
  print('native library start cropping');

  final Rect? cropRect = state.getCropRect();
  final EditActionDetails action = state.editAction!;

  final int rotateAngle = action.rotateAngle.toInt();
  final bool flipHorizontal = action.flipY;
  final bool flipVertical = action.flipX;
  final Uint8List img = state.rawImageData;

  final ImageEditorOption option = ImageEditorOption();

  if (action.needCrop) {
    option.addOption(ClipOption.fromRect(cropRect!));
  }

  if (action.needFlip) {
    option.addOption(
        FlipOption(horizontal: flipHorizontal, vertical: flipVertical));
  }

  if (action.hasRotateAngle) {
    option.addOption(RotateOption(rotateAngle));
  }

  final DateTime start = DateTime.now();
  final Uint8List? result = await ImageEditor.editImage(
    image: img,
    imageEditorOption: option,
  );

  print('${DateTime.now().difference(start)} ：total time');
  return result;
}

/// it may be failed, due to Cross-domain
Future<Uint8List> _loadNetwork(ExtendedNetworkImageProvider key) async {
  try {
    final Response? response = await HttpClientHelper.get(Uri.parse(key.url),
        headers: key.headers,
        timeLimit: key.timeLimit,
        timeRetry: key.timeRetry,
        retries: key.retries,
        cancelToken: key.cancelToken);
    return response!.bodyBytes;
  } on OperationCanceledError catch (_) {
    print('User cancel request ${key.url}.');
    return Future<Uint8List>.error(
        StateError('User cancel request ${key.url}.'));
  } catch (e) {
    return Future<Uint8List>.error(StateError('failed load ${key.url}. \n $e'));
  }
}
