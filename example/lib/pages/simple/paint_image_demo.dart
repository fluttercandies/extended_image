import 'dart:math';
import 'dart:ui' as ui show Image;

import 'package:example/main.dart';
import 'package:extended_image/extended_image.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/material.dart';

@FFRoute(
  name: 'fluttercandies://paintimage',
  routeName: 'Paint image',
  description: 'Paint any thing before or after raw image is painted.',
  exts: <String, dynamic>{
    'group': 'Simple',
    'order': 3,
  },
)
class PaintImageDemo extends StatefulWidget {
  @override
  _PaintImageDemoState createState() => _PaintImageDemoState();
}

class _PaintImageDemoState extends State<PaintImageDemo> {
  PaintType? paintType;
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
          const Text(
            'you can paint anything before or after Image paint',
            style: TextStyle(color: Colors.grey),
          ),
          Row(
            children: <Widget>[
              TextButton(
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
              TextButton(
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
                width: 200,
                height: 200,
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
                    canvas.drawPath(
                        clipheart(rect, canvas),
                        Paint()
                          ..color =
                              const Color(0x55ea5504).withValues(alpha: 0.2)
                          ..isAntiAlias = false
                          ..filterQuality = FilterQuality.low);
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
    const double dt = 2 * pi / numPoints;

    for (double t = 0.0; t <= 2 * pi; t += dt) {
      final Offset oo = Offset(doX(t), doY(t));
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

    final double xx = 200 / (max(rect1.width, rect1.height) * 1.1);

    final double top = rect.top + 200 / 2.0;
    final double left = rect.left + 200 / 2.0;

    final List<Offset> points1 = <Offset>[];
    for (final Offset point in points) {
      points1.add(Offset(left + point.dx * xx, top + -point.dy * xx));
    }

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
}

enum PaintType { ClipHeart, PaintHeart }
