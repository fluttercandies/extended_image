import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_candies_demo_library/flutter_candies_demo_library.dart';

@FFRoute(
    name: "fluttercandies://picswiper",
    routeName: "PicSwiper",
    argumentNames: [
      "index",
      "pics",
      "tuChongItem",
    ],
    showStatusBar: false,
    pageRouteType: PageRouteType.transparent)
class PicSwiperPage extends StatelessWidget {
  final int index;
  final List<PicSwiperItem> pics;
  final TuChongItem tuChongItem;
  PicSwiperPage({
    this.index,
    this.pics,
    this.tuChongItem,
  });
  @override
  Widget build(BuildContext context) {
    return PicSwiper(
      index: index,
      pics: pics,
      tuChongItem: tuChongItem,
    );
  }
}
