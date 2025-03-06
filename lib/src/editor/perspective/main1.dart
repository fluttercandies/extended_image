import 'package:flutter/material.dart';
import 'dart:ui' as ui;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Perspective Transformation',
      theme: ThemeData.dark(),
      home: const Scaffold(
        body: Center(
          child: PerspectiveTransformPage(),
        ),
      ),
    );
  }
}

class PerspectiveTransformPage extends StatefulWidget {
  const PerspectiveTransformPage({super.key});

  @override
  State<PerspectiveTransformPage> createState() =>
      _PerspectiveTransformPageState();
}

class _PerspectiveTransformPageState extends State<PerspectiveTransformPage> {
  ui.Image? image;
  late List<Offset> points;

  @override
  void initState() {
    super.initState();
    points = [
      const Offset(100, 100), // top-left
      const Offset(200, 100), // top-center
      const Offset(300, 100), // top-right
      const Offset(300, 200), // right-center
      const Offset(300, 300), // bottom-right
      const Offset(200, 300), // bottom-center
      const Offset(100, 300), // bottom-left
      const Offset(100, 200), // left-center
    ];
    _loadImage();
  }

  int? activePointIndex;
  void _loadImage() async {
    final imageData =
        await DefaultAssetBundle.of(context).load('assets/harley_quinn.webp');
    final codec =
        await ui.instantiateImageCodec(imageData.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    setState(() {
      image = frame.image;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (image == null) {
      return const CircularProgressIndicator();
    }

    return GestureDetector(
      onPanStart: (details) {
        for (int i = 0; i < points.length; i++) {
          if ((points[i] - details.localPosition).distance < 20) {
            activePointIndex = i;
            break;
          }
        }
      },
      onPanUpdate: (details) {
        if (activePointIndex != null) {
          _updatePoints(activePointIndex!, details.localPosition);
        }
      },
      onPanEnd: (details) {
        activePointIndex = null;
      },
      onPanCancel: () {
        activePointIndex = null;
      },
      child: CustomPaint(
        size: Size.infinite,
        painter: PerspectivePainter(
          image: image!,
          points: points,
        ),
      ),
    );
  }

  void _updatePoints(int index, Offset newOffset) {
    setState(() {
      if (index % 2 == 1) {
        // 更新中点
        Offset delta = newOffset - points[index];
        points[index] = newOffset;
        // 更新相邻顶点的位置
        int prevIndex = (index - 1) % points.length;
        int nextIndex = (index + 1) % points.length;
        points[prevIndex] += delta;
        points[nextIndex] += delta;
      } else {
        var list = [0, 2, 4, 6]..remove(index);

        var xxx = _adjustPoint(
          newOffset,
          points[list[0]],
          points[list[1]],
          points[list[2]],
        );

        // 更新顶点
        points[index] = xxx;
      }
      // 重新计算所有中点的位置
      for (int i = 0; i < points.length; i += 2) {
        points[(i + 1) % points.length] = Offset(
          (points[i].dx + points[(i + 2) % points.length].dx) / 2,
          (points[i].dy + points[(i + 2) % points.length].dy) / 2,
        );
      }
    });
  }

  bool _isPointInTriangle(Offset p, Offset p0, Offset p1, Offset p2) {
    // 检查点 p 是否在三角形 p0, p1, p2 内部
    double dX = p.dx - p2.dx;
    double dY = p.dy - p2.dy;
    double dX21 = p2.dx - p1.dx;
    double dY12 = p1.dy - p2.dy;
    double D = dY12 * (p0.dx - p2.dx) + dX21 * (p0.dy - p2.dy);
    double s = dY12 * dX + dX21 * dY;
    double t = (p2.dy - p0.dy) * dX + (p0.dx - p2.dx) * dY;
    if (D < 0) return s <= 0 && t <= 0 && s + t >= D;
    return s >= 0 && t >= 0 && s + t <= D;
  }

  Offset _projectPointToLineSegment(Offset p, Offset p1, Offset p2) {
    // 将点 p 投影到线段 p1-p2 上
    double dx = p2.dx - p1.dx;
    double dy = p2.dy - p1.dy;
    if (dx == 0 && dy == 0) {
      return p1;
    }
    double t =
        ((p.dx - p1.dx) * dx + (p.dy - p1.dy) * dy) / (dx * dx + dy * dy);
    t = t.clamp(0.0, 1.0);
    return Offset(p1.dx + t * dx, p1.dy + t * dy);
  }

  Offset _adjustPoint(Offset newOffset, Offset p0, Offset p1, Offset p2) {
    if (_isPointInTriangle(newOffset, p0, p1, p2)) {
      // 如果点在三角形内部，将点移动到最近的边上
      Offset projection1 = _projectPointToLineSegment(newOffset, p0, p1);
      Offset projection2 = _projectPointToLineSegment(newOffset, p1, p2);
      Offset projection3 = _projectPointToLineSegment(newOffset, p2, p0);

      double distance1 = (newOffset - projection1).distance;
      double distance2 = (newOffset - projection2).distance;
      double distance3 = (newOffset - projection3).distance;

      if (distance1 <= distance2 && distance1 <= distance3) {
        return projection1;
      } else if (distance2 <= distance1 && distance2 <= distance3) {
        return projection2;
      } else {
        return projection3;
      }
    }
    return newOffset;
  }
}

class PerspectivePainter extends CustomPainter {
  final ui.Image image;
  final List<Offset> points;

  PerspectivePainter({required this.image, required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // 绘制原始图片的矩形区域
    final srcRect =
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());

    // 创建透视变换矩阵
    final matrix = _computeTransformMatrix(
      source: [
        Offset(0, 0),
        Offset(image.width.toDouble(), 0),
        Offset(image.width.toDouble(), image.height.toDouble()),
        Offset(0, image.height.toDouble()),
      ],
      destination: [points[0], points[2], points[4], points[6]],
    );

    // 应用变换
    canvas.save();
    canvas.transform(matrix.storage);
    canvas.drawImage(image, Offset.zero, paint);
    canvas.restore();

    // 绘制控制点和边框
    final pointPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path()..addPolygon(points, true);
    canvas.drawPath(path, borderPaint);

    for (var point in points) {
      canvas.drawCircle(point, 8, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

Matrix4 _computeTransformMatrix({
  required List<Offset> source,
  required List<Offset> destination,
}) {
  // 验证输入是否正确
  assert(source.length == 4 && destination.length == 4, "需要 4 个源点和 4 个目标点");

  // 将 Offset 转为矩阵用的 List
  List<double> toList(List<Offset> points) =>
      points.expand((p) => [p.dx, p.dy]).toList();

  final src = toList(source);
  final dst = toList(destination);

  final a = <double>[
    // 每个点的公式展开
    src[0], src[1], 1, 0, 0, 0, -dst[0] * src[0], -dst[0] * src[1],
    0, 0, 0, src[0], src[1], 1, -dst[1] * src[0], -dst[1] * src[1],
    src[2], src[3], 1, 0, 0, 0, -dst[2] * src[2], -dst[2] * src[3],
    0, 0, 0, src[2], src[3], 1, -dst[3] * src[2], -dst[3] * src[3],
    src[4], src[5], 1, 0, 0, 0, -dst[4] * src[4], -dst[4] * src[5],
    0, 0, 0, src[4], src[5], 1, -dst[5] * src[4], -dst[5] * src[5],
    src[6], src[7], 1, 0, 0, 0, -dst[6] * src[6], -dst[6] * src[7],
    0, 0, 0, src[6], src[7], 1, -dst[7] * src[6], -dst[7] * src[7],
  ];

  final b = <double>[
    dst[0],
    dst[1],
    dst[2],
    dst[3],
    dst[4],
    dst[5],
    dst[6],
    dst[7],
  ];

  // 通过高斯消元法计算矩阵
  final h = _solveLinearEquation(a, b);

  // 构造 Matrix4
  final matrix = Matrix4.identity();
  matrix.setEntry(0, 0, h[0]);
  matrix.setEntry(0, 1, h[1]);
  matrix.setEntry(0, 3, h[2]);
  matrix.setEntry(1, 0, h[3]);
  matrix.setEntry(1, 1, h[4]);
  matrix.setEntry(1, 3, h[5]);
  matrix.setEntry(3, 0, h[6]);
  matrix.setEntry(3, 1, h[7]);
  matrix.setEntry(3, 3, 1);

  return matrix;
}

List<double> _solveLinearEquation(List<double> a, List<double> b) {
  // 解线性方程组 ax = b 的实现
  final n = b.length;
  final x = List<double>.filled(n, 0.0);

  for (int i = 0; i < n; i++) {
    int max = i;
    for (int j = i + 1; j < n; j++) {
      if (a[j * n + i].abs() > a[max * n + i].abs()) {
        max = j;
      }
    }

    for (int k = i; k < n; k++) {
      final temp = a[i * n + k];
      a[i * n + k] = a[max * n + k];
      a[max * n + k] = temp;
    }

    final temp = b[i];
    b[i] = b[max];
    b[max] = temp;

    for (int j = i + 1; j < n; j++) {
      final factor = a[j * n + i] / a[i * n + i];
      b[j] -= factor * b[i];
      for (int k = i; k < n; k++) {
        a[j * n + k] -= factor * a[i * n + k];
      }
    }
  }

  for (int i = n - 1; i >= 0; i--) {
    double sum = 0.0;
    for (int j = i + 1; j < n; j++) {
      sum += a[i * n + j] * x[j];
    }
    x[i] = (b[i] - sum) / a[i * n + i];
  }

  return x;
}
