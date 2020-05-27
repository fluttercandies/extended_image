import 'package:example/main.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_candies_demo_library/flutter_candies_demo_library.dart';
import 'package:ff_annotation_route/ff_annotation_route.dart';

@FFRoute(
    name: 'fluttercandies://image',
    routeName: 'image',
    description:
        'cache image,save to photo Library,image border,shape,borderRadius')
class ImageDemo extends StatefulWidget {
  @override
  _ImageDemoState createState() => _ImageDemoState();
}

class _ImageDemoState extends State<ImageDemo> {
  BoxShape boxShape;
  //CancellationToken cancellationToken;
  @override
  void initState() {
    //cancellationToken = CancellationToken();
    boxShape = BoxShape.circle;
    super.initState();
  }

  @override
  void dispose() {
    //cancellationToken.cancel();
    super.dispose();
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
              RaisedButton(
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
              RaisedButton(
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
                RaisedButton(
                  child: const Text('clear all cache'),
                  onPressed: () {
                    clearDiskCachedImages().then((bool done) {
                      showToast(done ? 'clear succeed' : 'clear failed',
                          position: ToastPosition(align: Alignment.topCenter));
                    });
                  },
                ),
              Expanded(
                child: Container(),
              ),
              if (!kIsWeb)
                RaisedButton(
                  child: const Text('save network image to photo'),
                  onPressed: () {
                    saveNetworkImageToPhoto(url).then((bool done) {
                      showToast(done ? 'save succeed' : 'save failed',
                          position: ToastPosition(align: Alignment.topCenter));
                    });
                  },
                ),
            ],
          ),
          Expanded(
            child: Align(
              child: ExtendedImage.network(
                url,
                width: ScreenUtil.instance.setWidth(400),
                height: ScreenUtil.instance.setWidth(400),
                fit: BoxFit.fill,
                cache: true,
                border: Border.all(color: Colors.red, width: 1.0),
                shape: boxShape,
                borderRadius: const BorderRadius.all(Radius.circular(30.0)),
                //cancelToken: cancellationToken,
              ),
            ),
          )
        ],
      ),
    );
  }
}
