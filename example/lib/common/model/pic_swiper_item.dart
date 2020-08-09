import 'package:flutter/cupertino.dart';

class PicSwiperItem {
  PicSwiperItem({
    @required this.picUrl,
    this.des = '',
  });
  final String picUrl;
  final String des;
}
