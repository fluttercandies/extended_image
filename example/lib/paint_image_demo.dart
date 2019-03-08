import 'dart:math';

import 'package:example/main.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:oktoast/oktoast.dart';
import 'dart:ui' as ui show Image;

class PaintImageDemo extends StatefulWidget {
  @override
  _PaintImageDemoState createState() => _PaintImageDemoState();
}

class _PaintImageDemoState extends State<PaintImageDemo> {
  BoxShape boxShape;

  @override
  void initState() {
    boxShape = BoxShape.circle;
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var url = imageTestUrl;
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
                child: Text("save network image to photo"),
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
                width: ScreenUtil.instance.setWidth(400),
                height: ScreenUtil.instance.setWidth(400),
                fit: BoxFit.fill,
                cache: true,
                beforePaintImage: (
                    {@required Canvas canvas,
                    @required Rect rect,
                    @required ui.Image image}) {
                  canvas.save();
//                  canvas.translate(
//                      rect.left + ScreenUtil.instance.setWidth(400) / 2.0,
//                      rect.top + ScreenUtil.instance.setWidth(400) / 2.0);
//                  ;
                  // clipheart(rect, canvas);
                  canvas.clipPath(clipheart(rect, canvas));
                  // canvas.clipPath(Path()..addOval(rect));
                },
                afterPaintImage: (
                    {@required Canvas canvas,
                    @required Rect rect,
                    @required ui.Image image}) {
//                  canvas.drawLine(rect.topLeft, rect.bottomRight,
//                      Paint()..color = Colors.red);

                  //clipPath.close();

                  canvas.restore();
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
    int num_points = 1000;
    List<Offset> points = new List<Offset>();
    double dt = (2 * pi / num_points);

    for (double t = 0; t <= 2 * pi; t += dt) {
      var oo = Offset(X(t), Y(t));
      // print(oo);
      points.add(oo);
    }
    ;
    double wxmin = points[0].dx;
    double wxmax = wxmin;
    double wymin = points[0].dy;
    double wymax = wymin;

    points.forEach((point) {
      if (wxmin > point.dx) wxmin = point.dx;
      if (wxmax < point.dx) wxmax = point.dx;
      if (wymin > point.dy) wymin = point.dy;
      if (wymax < point.dy) wymax = point.dy;
    });

    Rect rect1 = Rect.fromLTWH(wxmin, wymin, wxmax - wxmin, wymax - wymin);

    double xx = ScreenUtil.instance.setWidth(400) /
        (max(rect1.width, rect1.height) * 1.1);

    double top = rect.top + ScreenUtil.instance.setWidth(400) / 2.0;
    double left = rect.left + ScreenUtil.instance.setWidth(400) / 2.0;

    List<Offset> points1 = new List<Offset>();
    points.forEach((point) {
      points1.add(Offset(left + point.dx * xx, top + -point.dy * xx));
    });
//    canvas.drawPath(
//        Path()..addPolygon(points1, true), Paint()..color = Colors.red);

    return Path()..addPolygon(points1, false);
  }

  // The curve's parametric equations.
  double X(double t) {
    double sin_t = sin(t);
    return (16 * sin_t * sin_t * sin_t);
  }

  double Y(double t) {
    return (13 * cos(t) - 5 * cos(2 * t) - 2 * cos(3 * t) - cos(4 * t));
  }
}
