import 'package:example/common/data/tu_chong_source.dart';
import 'package:example/common/utils/screen_util.dart';
import 'package:flutter/material.dart';
import 'crop_image.dart';

const int maxPicGridViewCount = 9;

/// Grid view to show picture
class PicGridView extends StatelessWidget {
  const PicGridView({
    @required this.tuChongItem,
  });
  final TuChongItem tuChongItem;
  @override
  Widget build(BuildContext context) {
    if (!tuChongItem.hasImage) {
      return Container();
    }

    Widget widget = LayoutBuilder(builder: (BuildContext c, BoxConstraints b) {
      final double margin = ScreenUtil.instance.setWidth(22);
      final double size = b.maxWidth;
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

      double totalWidth = size;
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
          itemBuilder: (BuildContext s, int index) {
            return CropImage(
              index: index,
              tuChongItem: tuChongItem,
              knowImageSize: true,
            );
          },
          physics: const NeverScrollableScrollPhysics(),
          itemCount:
              tuChongItem.images.length.clamp(1, maxPicGridViewCount) as int,
          padding: const EdgeInsets.all(0.0),
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
