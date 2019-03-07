import 'package:example/common/tu_chong_repository.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'package:oktoast/oktoast.dart';

import 'common/tu_chong_repository.dart';

class ImageDemo extends StatefulWidget {
  @override
  _ImageDemoState createState() => _ImageDemoState();
}

class _ImageDemoState extends State<ImageDemo> {
  TuChongRepository tuChongRepository;
  BoxShape boxShape;
  @override
  void initState() {
    boxShape = BoxShape.circle;
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
//    var index = tuChongRepository.length;
//
//    var url = randomUrl(index);
    var url = "https://photo.tuchong.com/4870004/f/298584322.jpg";
    return Material(
      child: Column(
        children: <Widget>[
          AppBar(
            title: Text("ImageDemo"),
          ),
          Row(
            children: <Widget>[
              RaisedButton(
                child: Text("BoxShape.circle"),
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
                child: Text("BoxShape.rectangle"),
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
              RaisedButton(
                child: Text("clear all cache"),
                onPressed: () {
                  clearDiskCachedImages().then((bool done) {
                    showToast(done ? "clear succeed" : "clear failed",
                        position: ToastPosition(align: Alignment.topCenter));
                  });
                },
              ),
              Expanded(
                child: Container(),
              ),
              RaisedButton(
                child: Text("save image to photo"),
                onPressed: () {
                  saveNetworkImageToPhoto(url).then((bool done) {
                    showToast(done ? "save succeed" : "save failed",
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
                width: 200.0,
                height: 200.0,
                fit: BoxFit.fill,
                cache: true,
                border: Border.all(color: Colors.red, width: 1.0),
                shape: boxShape,
                borderRadius: BorderRadius.all(Radius.circular(30.0)),
              ),
            ),
          )
        ],
      ),
    );
  }
}
