import 'dart:math';
import 'dart:ui' as ui show Image;
import 'package:example/main.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:flutter_candies_demo_library/flutter_candies_demo_library.dart';

@FFRoute(
    name: 'fluttercandies://paintimage',
    routeName: 'paint image',
    description: 'show how to paint any thing before/after image is painted')
class PaintImageDemo extends StatefulWidget {
  @override
  _PaintImageDemoState createState() => _PaintImageDemoState();
}

class _PaintImageDemoState extends State<PaintImageDemo> {
  PaintType paintType;
  @override
  void initState() {
    paintType = PaintType.ClipHeart;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final String url = imageTestUrl;
    return Material(
      child: Column(
        children: <Widget>[
          AppBar(
            title: const Text('PaintImageDemo'),
          ),
          Text(
            'you can paint anything before or after Image paint',
            style: TextStyle(color: Colors.grey),
          ),
          Row(
            children: <Widget>[
              RaisedButton(
                child: const Text('ClipHeart'),
                onPressed: () {
                  setState(() {
                    paintType = PaintType.ClipHeart;
                  });
                },
              ),
              Expanded(
                child: Container(),
              ),
              RaisedButton(
                child: const Text('PaintHeart'),
                onPressed: () {
                  setState(() {
                    paintType = PaintType.PaintHeart;
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
                beforePaintImage:
                    (Canvas canvas, Rect rect, ui.Image image, Paint paint) {
                  if (paintType == PaintType.ClipHeart) {
                    if (!rect.isEmpty) {
                      canvas.save();
                      canvas.clipPath(clipheart(rect, canvas));
                    }
                  }
                  return false;
                },
                afterPaintImage:
                    (Canvas canvas, Rect rect, ui.Image image, Paint paint) {
                  if (paintType == PaintType.ClipHeart) {
                    if (!rect.isEmpty) {
                      canvas.restore();
                    }
                  } else if (paintType == PaintType.PaintHeart) {
                    // canvas.drawPath(
                    //     clipheart(rect, canvas),
                    //     Paint()
                    //       ..colorFilter = ColorFilter.mode(
                    //           Color(0x55ea5504), BlendMode.srcIn)
                    //       ..isAntiAlias = false
                    //       ..filterQuality = FilterQuality.low);
                    canvas.drawPath(
                        clipheart(rect, canvas),
                        Paint()
                          // ..colorFilter = ColorFilter.mode(
                          //     Color(0x55ea5504), BlendMode.srcIn)
                          ..color = const Color(0x55ea5504).withOpacity(0.2)
                          ..isAntiAlias = false
                          ..filterQuality = FilterQuality.low);

//                    canvas.drawImageRect(
//                        image,
//                        Rect.fromLTWH(0.0, y, imageWidth, imageHeight - y),
//                        Rect.fromLTWH(
//                            rect.left,
//                            rect.top + y / imageHeight * size.height,
//                            size.width,
//                            (imageHeight - y) / imageHeight * size.height),
//                        Paint()
//                          ..colorFilter = ColorFilter.mode(
//                              Color(0x22ea5504), BlendMode.srcIn)
//                          ..isAntiAlias = false
//                          ..filterQuality = FilterQuality.low);
                  }
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  Path clipheart(
    Rect rect,
    Canvas canvas,
  ) {
    const int numPoints = 1000;
    final List<Offset> points = <Offset>[];
    final double dt = 2 * pi / numPoints;

    for (double t = 0.0; t <= 2 * pi; t += dt) {
      final Offset oo = Offset(doX(t), doY(t));
      // print(oo);
      points.add(oo);
    }
    double wxmin = points[0].dx;
    double wxmax = wxmin;
    double wymin = points[0].dy;
    double wymax = wymin;

    for (final Offset point in points) {
      if (wxmin > point.dx) {
        wxmin = point.dx;
      }
      if (wxmax < point.dx) {
        wxmax = point.dx;
      }
      if (wymin > point.dy) {
        wymin = point.dy;
      }
      if (wymax < point.dy) {
        wymax = point.dy;
      }
    }

    final Rect rect1 =
        Rect.fromLTWH(wxmin, wymin, wxmax - wxmin, wymax - wymin);

    final double xx = ScreenUtil.instance.setWidth(400) /
        (max(rect1.width, rect1.height) * 1.1);

    final double top = rect.top + ScreenUtil.instance.setWidth(400) / 2.0;
    final double left = rect.left + ScreenUtil.instance.setWidth(400) / 2.0;

    final List<Offset> points1 = <Offset>[];
    for (final Offset point in points) {
      points1.add(Offset(left + point.dx * xx, top + -point.dy * xx));
    }

//    canvas.drawPath(
//        Path()..addPolygon(points1, true), Paint()..color = Colors.red);

    return Path()..addPolygon(points1, false);
  }

  // The curve's parametric equations.
  double doX(double t) {
    final double sinT = sin(t);
    return 16 * sinT * sinT * sinT;
  }

  double doY(double t) {
    return 13 * cos(t) - 5 * cos(2 * t) - 2 * cos(3 * t) - cos(4 * t);
  }

//  Path pathHeart(Rect rect) {
//    final double width = rect.width;
//    final double height = rect.height;
//    Path path = new Path();
//    path.moveTo(width / 2, height / 4);
//    path.cubicTo((width * 6) / 7, height / 9, (width * 13) / 13,
//        (height * 2) / 5, width / 2, (height * 7) / 12);
//    //canvas.drawPath(path, _paint);
//
//    Path path2 = new Path();
//    path2.moveTo(width / 2, height / 4);
//    path2.cubicTo(width / 7, height / 9, width / 21, (height * 2) / 5,
//        width / 2, (height * 7) / 12);
//    //canvas.drawPath(path2, _paint);
//    //path.
//  }
}

enum PaintType { ClipHeart, PaintHeart }
