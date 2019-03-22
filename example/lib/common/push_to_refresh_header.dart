import 'dart:math';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pull_to_refresh_notification/pull_to_refresh_notification.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui show Image;

double get maxDragOffset => ScreenUtil.getInstance().setWidth(180);
double hideHeight = maxDragOffset / 2.3;
double refreshHeight = maxDragOffset / 1.5;

class PullToRefreshHeader extends StatelessWidget {
  final PullToRefreshScrollNotificationInfo info;
  final DateTime lastRefreshTime;
  final Color color;
  PullToRefreshHeader(this.info, this.lastRefreshTime, {this.color});

  @override
  Widget build(BuildContext context) {
    if (info == null) return Container();
    String text = "";
    if (info.mode == RefreshIndicatorMode.armed) {
      text = "Release to refresh";
    } else if (info.mode == RefreshIndicatorMode.refresh ||
        info.mode == RefreshIndicatorMode.snap) {
      text = "Loading...";
    } else if (info.mode == RefreshIndicatorMode.done) {
      text = "Refresh completed.";
    } else if (info.mode == RefreshIndicatorMode.drag) {
      text = "Pull to refresh";
    } else if (info.mode == RefreshIndicatorMode.canceled) {
      text = "Cancel refresh";
    }

    final TextStyle ts = TextStyle(
      color: Colors.grey,
    ).copyWith(fontSize: ScreenUtil.getInstance().setSp(26));

    double dragOffset = info?.dragOffset ?? 0.0;

    DateTime time = lastRefreshTime ?? DateTime.now();
    final top = -hideHeight + dragOffset;
    return Container(
      height: dragOffset,
      color: color ?? Colors.transparent,
      //padding: EdgeInsets.only(top: dragOffset / 3),
      //padding: EdgeInsets.only(bottom: 5.0),
      child: Stack(
        children: <Widget>[
          Positioned(
            left: 0.0,
            right: 0.0,
            top: top,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Container(
                    alignment: Alignment.centerRight,
                    child: RefreshImage(top),
                    margin: EdgeInsets.only(right: 12.0),
                  ),
                ),
                Column(
                  children: <Widget>[
                    Text(
                      text,
                      style: ts,
                    ),
                    Text(
                      "Last updated:" +
                          DateFormat("yyyy-MM-dd hh:mm").format(time),
                      style: ts.copyWith(
                          fontSize: ScreenUtil.getInstance().setSp(24)),
                    )
                  ],
                ),
                Expanded(
                  child: Container(),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class RefreshImage extends StatelessWidget {
  final double top;
  RefreshImage(this.top);
  @override
  Widget build(BuildContext context) {
    final double imageSize = ScreenUtil.getInstance().setWidth(80);
    return ExtendedImage.asset(
      "assets/flutterCandies_grey.png",
      width: imageSize,
      height: imageSize,
      afterPaintImage: (Canvas canvas, Rect rect, ui.Image image, Paint paint) {
        final double imageHeight = image.height.toDouble();
        final double imageWidth = image.width.toDouble();
        final Size size = rect.size;
        final double y =
            (1 - min(top / (refreshHeight - hideHeight), 1)) * imageHeight;

        canvas.drawImageRect(
            image,
            Rect.fromLTWH(0.0, y, imageWidth, imageHeight - y),
            Rect.fromLTWH(rect.left, rect.top + y / imageHeight * size.height,
                size.width, (imageHeight - y) / imageHeight * size.height),
            Paint()
              ..colorFilter =
                  ColorFilter.mode(Color(0xFFea5504), BlendMode.srcIn)
              ..isAntiAlias = false
              ..filterQuality = FilterQuality.low);

        //canvas.restore();
      },
    );
  }
}
