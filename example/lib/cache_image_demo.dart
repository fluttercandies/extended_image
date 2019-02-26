import 'package:example/common/tu_chong_repository.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'package:oktoast/oktoast.dart';

import 'common/tu_chong_repository.dart';

class CacheImageDemo extends StatefulWidget {
  @override
  _CacheImageDemoState createState() => _CacheImageDemoState();
}

class _CacheImageDemoState extends State<CacheImageDemo> {
  TuChongRepository tuChongRepository;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tuChongRepository = TuChongRepository();
    tuChongRepository.loadMore().whenComplete(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    var index = tuChongRepository.length;

    var url = randomUrl(index);
    return Material(
      child: Column(
        children: <Widget>[
          AppBar(
            title: Text("CacheImageDemo"),
          ),
          Row(
            children: <Widget>[
              RaisedButton(
                child: Text("random image"),
                onPressed: () {
                  setState(() {});
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
            ],
          ),
          Expanded(
            child: index == 0
                ? Container()
                : ExtendedImage.network(
                    url,
                    width: 200.0,
                    height: 200.0,
                    cache: true,
                  ),
          )
        ],
      ),
    );
  }

  String randomUrl(int index) {
    if (index <= 0) return "";
    var rng = new Random();
    var imageindex = rng.nextInt(index);
    String url = "";
    if (imageindex > -1) {
      url = tuChongRepository[imageindex].imageUrl;
    }
    return url;
  }
}
