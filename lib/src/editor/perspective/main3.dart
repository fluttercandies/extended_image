import 'dart:ui' as ui;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  double bulgeValue = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Image Bulge Effect'),
        ),
        body: Column(
          children: [
            Slider(
              value: bulgeValue,
              min: -1,
              max: 1,
              onChanged: (value) {
                setState(() => bulgeValue = value);
              },
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: BulgeImage(
                    imagePath: 'assets/harley_quinn.webp',
                    bulge: bulgeValue,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BulgeImage extends StatefulWidget {
  final String imagePath;
  final double bulge;

  BulgeImage({required this.imagePath, required this.bulge});

  @override
  _BulgeImageState createState() => _BulgeImageState();
}

class _BulgeImageState extends State<BulgeImage> {
  ui.Image? image;
  FragmentShader? shader;

  @override
  void initState() {
    super.initState();
    _loadImage();
    _loadShader();
  }

  Future<void> _loadImage() async {
    final data = await rootBundle.load(widget.imagePath);
    final bytes = data.buffer.asUint8List();
    ui.decodeImageFromList(bytes, (img) {
      setState(() {
        image = img;
      });
    });
  }

  Future<void> _loadShader() async {
    final program = await FragmentProgram.fromAsset('shaders/shader.frag');
    setState(() {
      shader = program.fragmentShader();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (image == null || shader == null) {
      return Container();
    }
    return CustomPaint(
      painter: BulgePainter(
        image: image!,
        shader: shader!,
        bulge: widget.bulge,
      ),
      size: Size(image!.width.toDouble(), image!.height.toDouble()),
    );
  }
}

class BulgePainter extends CustomPainter {
  final ui.Image image;
  final FragmentShader shader;
  final double bulge;

  BulgePainter({
    required this.image,
    required this.shader,
    required this.bulge,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final FittedSizes fittedSizes = applyBoxFit(BoxFit.contain,
        Size(image.width.toDouble(), image.height.toDouble()), size);

    final Size sourceSize = fittedSizes.source;
    Size destinationSize = fittedSizes.destination;

    // 动态计算 extraSize
    final double extraSize =
        true ? 0 : destinationSize.width * bulge.abs() * 0.5;
    final double halfWidthDelta = (size.width - destinationSize.width) / 2.0;
    final double halfHeightDelta = (size.height - destinationSize.height) / 2.0;
    final Alignment alignment = Alignment.center;

    final double dx = halfWidthDelta + alignment.x * halfWidthDelta;
    final double dy = halfHeightDelta + alignment.y * halfHeightDelta;
    final Offset destinationPosition = Offset(dx, dy);
    final Rect destinationRect = destinationPosition & destinationSize;

    // 设置着色器的分辨率 (uResolution)
    shader.setFloat(0, destinationRect.width + extraSize);
    shader.setFloat(1, destinationRect.height + extraSize);

    // 设置 bulge (uBulge)
    shader.setFloat(2, bulge);

    // 设置偏移 (uOffset)
    shader.setFloat(3, destinationRect.left - extraSize / 2);
    shader.setFloat(4, destinationRect.top - extraSize / 2);

    // 绑定纹理采样器 (uTexture)
    shader.setImageSampler(0, image);

    paint.shader = shader;
    paint.style = PaintingStyle.fill;

    // 绘制到目标矩形
    canvas.drawRect(
      Rect.fromLTWH(
        destinationRect.left - extraSize / 2,
        destinationRect.top - extraSize / 2,
        destinationRect.width + extraSize,
        destinationRect.height + extraSize,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
