import 'package:flutter/material.dart';
import 'crop_image.dart';
import 'package:flutter_candies_demo_library/flutter_candies_demo_library.dart';

const int maxPicGridViewCount = 9;

/// Grid view to show picture
class PicGridView extends StatelessWidget {
  final TuChongItem tuChongItem;
  PicGridView({
    @required this.tuChongItem,
  });
  @override
  Widget build(BuildContext context) {
    if (!tuChongItem.hasImage) return Container();

    Widget widget = LayoutBuilder(builder: (c, b) {
      final double margin = ScreenUtil.instance.setWidth(22);
      var size = b.maxWidth;
      int rowCount = 3;
      //single image
      if (tuChongItem.images.length == 1) {
        return Padding(
          padding: EdgeInsets.all(margin),
          child: CropImage(
            index: 0,
            tuChongItem: tuChongItem,
            knowImageSize: true,
          ),
        );
      }

      var totalWidth = size;
      if (tuChongItem.images.length == 4) {
        totalWidth = size / 3 * 2;
        rowCount = 2;
      }
      return Container(
        margin: EdgeInsets.all(margin),
        width: totalWidth,
        child: GridView.builder(
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: rowCount,
              crossAxisSpacing: 2.0,
              mainAxisSpacing: 2.0),
          itemBuilder: (s, index) {
            return CropImage(
              index: index,
              tuChongItem: tuChongItem,
              knowImageSize: true,
            );
          },
          physics: NeverScrollableScrollPhysics(),
          itemCount: tuChongItem.images.length.clamp(1, maxPicGridViewCount),
          padding: EdgeInsets.all(0.0),
        ),
      );
    });
    // if (margin != null) {
    //   widget = Padding(
    //     padding: margin,
    //     child: widget,
    //   );
    // }
    widget = Align(
      child: widget,
      alignment: Alignment.centerLeft,
    );
    return widget;
  }
}
