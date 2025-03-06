import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Distortion',
      theme: ThemeData.dark(),
      home: const Scaffold(
        body: Center(
          child: ImageDistortionPage(),
        ),
      ),
    );
  }
}

class ImageDistortionPage extends StatefulWidget {
  const ImageDistortionPage({super.key});

  @override
  State<ImageDistortionPage> createState() => _ImageDistortionPageState();
}

class _ImageDistortionPageState extends State<ImageDistortionPage> {
  ui.Image? _image;
  double _intensity = 100.0;

  @override
  void initState() {
    super.initState();
    _loadImage('assets/harley_quinn.webp');
  }

  Future<void> _loadImage(String asset) async {
    final ByteData data = await rootBundle.load(asset);
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(Uint8List.view(data.buffer), completer.complete);
    final ui.Image image = await completer.future;
    setState(() {
      _image = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      child: Column(
        children: [
          Expanded(
            child: _image == null
                ? const Center(child: CircularProgressIndicator())
                : Center(
                    child: CustomPaint(
                      size: Size(100, 100),
                      painter: ImageDistortionPainter(
                        image: _image!,
                        intensity: _intensity,
                      ),
                    ),
                  ),
          ),
          Slider(
            value: _intensity,
            min: -200,
            max: 200,
            onChanged: (value) {
              setState(() {
                _intensity = value;
              });
            },
          ),
        ],
      ),
    );
  }
}

class ImageDistortionPainter extends CustomPainter {
  final ui.Image image;
  final double intensity;

  ImageDistortionPainter({required this.image, required this.intensity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final srcRect =
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());

    // 创建网格变形
    final mesh = _createMesh(
      image.width,
      image.height,
      200, 200,
      // image.width ~/ 5,
      // image.height ~/ 5,
    );
    canvas.translate(-150, -400);
    canvas.scale(0.5, 0.5);
    // 绘制变形后的图片
    // 绘制变形后的图片
    for (var quad in mesh) {
      final src = quad[0];
      final dst = quad[1];
      final path = Path()
        ..moveTo(dst[0].dx, dst[0].dy)
        ..lineTo(dst[1].dx, dst[1].dy)
        ..lineTo(dst[2].dx, dst[2].dy)
        ..lineTo(dst[3].dx, dst[3].dy)
        ..close();

      canvas.save();
      canvas.clipPath(path);

      canvas.drawImageRect(image, Rect.fromPoints(src[0], src[2]),
          Rect.fromPoints(dst[0], dst[2]), paint);
      canvas.restore();
    }
  }

  List<List<List<Offset>>> _createMesh(
      int width, int height, int rows, int cols) {
    final mesh = <List<List<Offset>>>[];
    final dx = width / cols;
    final dy = height / rows;

    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        final src = [
          Offset(j * dx, i * dy),
          Offset((j + 1) * dx, i * dy),
          Offset((j + 1) * dx, (i + 1) * dy),
          Offset(j * dx, (i + 1) * dy),
        ];

        final dst = src.map((p) {
          final x = p.dx - width / 2;
          final y = p.dy - height / 2;
          final z = intensity *
              (1 - (x * x + y * y) / (width * width / 4 + height * height / 4));
          return Offset(p.dx + z * x / width, p.dy + z * y / height);
        }).toList();

        mesh.add([src, dst]);
      }
    }

    return mesh;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
