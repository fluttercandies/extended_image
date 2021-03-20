import 'package:example/common/utils/util.dart';
import 'package:example/main.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:oktoast/oktoast.dart';

@FFRoute(
  name: 'fluttercandies://image',
  routeName: 'Image',
  description: 'Cached image with border,shape,borderRadius.',
  exts: <String, dynamic>{
    'group': 'Simple',
    'order': 0,
  },
)
class ImageDemo extends StatefulWidget {
  @override
  _ImageDemoState createState() => _ImageDemoState();
}

class _ImageDemoState extends State<ImageDemo> {
  BoxShape? boxShape;
  @override
  void initState() {
    boxShape = BoxShape.circle;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final String url = imageTestUrl;
    return Material(
      child: Column(
        children: <Widget>[
          AppBar(
            title: const Text('ImageDemo'),
          ),
          Row(
            children: <Widget>[
              TextButton(
                child: const Text('BoxShape.circle'),
                onPressed: () {
                  setState(() {
                    boxShape = BoxShape.circle;
                  });
                },
              ),
              Expanded(
                child: Container(),
              ),
              TextButton(
                child: const Text('BoxShape.rectangle'),
                onPressed: () {
                  setState(() {
                    boxShape = BoxShape.rectangle;
                  });
                },
              ),
            ],
          ),
          Row(
            children: <Widget>[
              if (!kIsWeb)
                TextButton(
                  child: const Text('clear all cache'),
                  onPressed: () {
                    clearDiskCachedImages().then((bool done) {
                      showToast(done ? 'clear succeed' : 'clear failed',
                          position:
                              const ToastPosition(align: Alignment.topCenter));
                    });
                  },
                ),
              Expanded(
                child: Container(),
              ),
              if (!kIsWeb)
                TextButton(
                  child: const Text('save network image to photo'),
                  onPressed: () {
                    saveNetworkImageToPhoto(url).then((bool done) {
                      showToast(done ? 'save succeed' : 'save failed',
                          position:
                              const ToastPosition(align: Alignment.topCenter));
                    });
                  },
                ),
            ],
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(30),
              alignment: Alignment.center,
              child: AspectRatio(
                aspectRatio: 1.0,
                child: ExtendedImage.network(
                  url,
                  fit: BoxFit.fill,
                  cache: true,
                  border: Border.all(color: Colors.red, width: 5.0),
                  shape: boxShape,
                  borderRadius: const BorderRadius.all(Radius.circular(30.0)),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
