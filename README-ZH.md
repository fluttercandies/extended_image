# extended_image

[![pub package](https://img.shields.io/pub/v/extended_image.svg)](https://pub.dartlang.org/packages/extended_image) [![GitHub stars](https://img.shields.io/github/stars/fluttercandies/extended_image)](https://github.com/fluttercandies/extended_image/stargazers) [![GitHub forks](https://img.shields.io/github/forks/fluttercandies/extended_image)](https://github.com/fluttercandies/extended_image/network) [![GitHub license](https://img.shields.io/github/license/fluttercandies/extended_image)](https://github.com/fluttercandies/extended_image/blob/master/LICENSE) [![GitHub issues](https://img.shields.io/github/issues/fluttercandies/extended_image)](https://github.com/fluttercandies/extended_image/issues) <a href="https://qm.qq.com/q/ZyJbSVjfSU">![FlutterCandies QQ 群](https://img.shields.io/badge/dynamic/yaml?url=https%3A%2F%2Fraw.githubusercontent.com%2Ffluttercandies%2F.github%2Frefs%2Fheads%2Fmain%2Fdata.yml&query=%24.qq_group_number&label=QQ%E7%BE%A4&logo=qq&color=1DACE8)

文档语言: [English](README.md) | 中文简体

强大的官方 Image 扩展组件, 支持加载以及失败显示，缓存网络图片，缩放拖拽图片，图片浏览(微信掘金效果)，滑动退出页面(微信掘金效果)，编辑图片(裁剪旋转翻转)，保存，绘制自定义效果等功能

[Web demo for ExtendedImage](https://fluttercandies.github.io/extended_image/)

* [Flutter 什么功能都有的Image](https://juejin.cn/post/6844903794656952328)
* [Flutter 可以缩放拖拽的图片](https://juejin.cn/post/6844903814324027400)
* [Flutter 仿掘金微信图片滑动退出页面效果](https://juejin.cn/post/6844903860163575815)
* [Flutter 图片裁剪旋转翻转编辑器](https://juejin.cn/post/6844903939670802446)
* [Flutter 图片全家桶](https://juejin.cn/post/6844904122571816968)
* [Flutter 什么，微信现在才支持实况图！？](https://juejin.cn/post/7418391732162854927)

ExtendedImage 是官方 Image 的扩展三方库，主要扩展功能如下:

| 功能                                           | ExtendedImage                                                                  | Flutter 官方 Image          |
| ---------------------------------------------- | ------------------------------------------------------------------------------ | --------------------------- |
| 缓存网络图片资源本地以及从本地加载网络缓存资源 | 支持                                                                           | 不支持                      |
| 压缩显示                                       | 支持，在官方的基础上，更多的灵活选项 compressionRatio 和 maxBytes 进行压缩显示 | 支持 cacheHeight,cacheWidth |
| 自动释放图片资源                               | 支持                                                                           | 需手动管理图片资源          |
| 缩放模式                                       | 支持                                                                           | 不支持                      |
| 编辑模式                                       | 支持                                                                           | 不支持                      |
| 拖动图片退出页面效果                           | 支持                                                                           | 不支持                      |



## 目录

- [extended\_image](#extended_image)
  - [目录](#目录)
  - [导入](#导入)
  - [缓存网络图片](#缓存网络图片)
    - [简单使用](#简单使用)
    - [使用 ExtendedNetworkImageProvider](#使用-extendednetworkimageprovider)
  - [加载状态](#加载状态)
    - [例子](#例子)
  - [缩放拖拽](#缩放拖拽)
    - [双击图片动画](#双击图片动画)
  - [图片编辑](#图片编辑)
    - [裁剪框的宽高比](#裁剪框的宽高比)
    - [裁剪图层 Painter](#裁剪图层-painter)
    - [翻转、旋转、重新设置裁剪比例、撤消、重做、重置](#翻转旋转重新设置裁剪比例撤消重做重置)
      - [翻转](#翻转)
      - [旋转](#旋转)
      - [重新设置裁剪比例](#重新设置裁剪比例)
      - [撤消](#撤消)
      - [重做](#重做)
      - [重置](#重置)
      - [历史](#历史)
      - [配置更新](#配置更新)
    - [裁剪数据](#裁剪数据)
      - [使用 dart 库(稳定)](#使用-dart-库稳定)
      - [使用原生库(快速)](#使用原生库快速)
  - [图片浏览](#图片浏览)
  - [滑动退出页面](#滑动退出页面)
    - [首先开启滑动退出页面效果](#首先开启滑动退出页面效果)
    - [把你的页面用 ExtendedImageSlidePage 包一下](#把你的页面用-extendedimageslidepage-包一下)
    - [确保你的页面是透明背景的](#确保你的页面是透明背景的)
    - [Push 一个透明的页面](#push-一个透明的页面)
  - [Border BorderRadius Shape](#border-borderradius-shape)
  - [清除缓存和保存](#清除缓存和保存)
    - [清除缓存](#清除缓存)
    - [保存网络图片](#保存网络图片)
  - [显示裁剪图片](#显示裁剪图片)
  - [绘制](#绘制)
  - [Notch](#notch)
  - [内存使用](#内存使用)
  - [其他 APIs](#其他-apis)


## 导入

*  空安全

``` yaml
environment:
  sdk: '>=2.12.0 <3.0.0'
  flutter: '>=2.0'
dependencies:
  extended_image: ^4.0.0
```

*  非空安全

1.22.6 到 2.0, Flutter Api 有 breaking change，所以 1.22.6 以下的，请使用非空安全版本

``` yaml
environment:
  sdk: '>=2.6.0 <2.12.0'
  flutter: '>1.17.0 <=1.22.6'
dependencies:
  extended_image: ^3.0.0-non-null-safety
```

## 缓存网络图片

### 简单使用

你可以直接使用 ExtendedImage.network，这跟官方是一样。

```dart
ExtendedImage.network(
  url,
  width: ScreenUtil.instance.setWidth(400),
  height: ScreenUtil.instance.setWidth(400),
  fit: BoxFit.fill,
  cache: true,
  border: Border.all(color: Colors.red, width: 1.0),
  shape: boxShape,
  borderRadius: BorderRadius.all(Radius.circular(30.0)),
  //cancelToken: cancellationToken,
)
```

### 使用 ExtendedNetworkImageProvider

你也可以通过[ExtendedNetworkImageProvider](https://github.com/fluttercandies/extended_image_library/blob/master/lib/src/extended_network_image_provider.dart)，设置更多的网络请求的参数

```dart
ExtendedNetworkImageProvider(
  this.url, {
  this.scale = 1.0,
  this.headers,
  this.cache: false,
  this.retries = 3,
  this.timeLimit,
  this.timeRetry = const Duration(milliseconds: 100),
  CancellationToken cancelToken,
})  : assert(url != null),
      assert(scale != null),
      cancelToken = cancelToken ?? CancellationToken();
```

| 参数        | 描述                  | 默认                |
| ----------- | --------------------- | ------------------- |
| url         | 网络请求地址          | required            |
| scale       | ImageInfo 中的 scale  | 1.0                 |
| headers     | HttpClient 的 headers | -                   |
| cache       | 是否缓存到本地        | false               |
| retries     | 请求尝试次数          | 3                   |
| timeLimit   | 请求超时              | -                   |
| timeRetry   | 请求重试间隔          | milliseconds: 100   |
| cancelToken | 用于取消请求的 Token  | CancellationToken() |

当然你也可以继承任何的 ExtendedProvider,并且覆写 instantiateImageCodec 方法，这样你可以统一处理图片的元数据，比如进行压缩图片。

## 加载状态

Extended Image 一共有 3 种状态，分别是正在加载，完成，失败(loading,completed,failed)，你可以通过实现 loadStateChanged 回调来定义显示的效果

loadStateChanged 不仅仅只在网络图片中可以使用, 如果你的图片很大，需要长时间加载，
你可以把 enableLoadState 设置为了 true，这样也会有状态回调了，（默认只有网络图片,enableLoadState 为 true）

![img](https://github.com/fluttercandies/Flutter_Candies/blob/master/gif/extended_image/custom.gif)

注意:

- 如果你不想重写某个状态，那么请返回 null

- 如果你想重写完成图片的 size 或者 sourceRect, 你可以通过使用 ExtendedRawImage 来完成

- 如果你想增加一些新效果 (比如动画), 你可以重写并且使用 ExtendedImageState.completedWidget

- ExtendedImageState.completedWidget 包含手势或者裁剪, 这样你不会丢失它们

```dart
/// custom load state widget if you want
    final LoadStateChanged loadStateChanged;

enum LoadState {
  //loading
  loading,
  //completed
  completed,
  //failed
  failed
}

  ///whether has loading or failed state
  ///default is false
  ///but network image is true
  ///better to set it's true when your image is big and take some time to ready
  final bool enableLoadState;
```

ExtendedImageState 状态回调

| 参数/方法                    | 描述                                                                                                   | 默认 |
| ---------------------------- | ------------------------------------------------------------------------------------------------------ | ---- |
| extendedImageInfo            | 图片的信息，包括底层 image 和 image 的大小                                                             | -    |
| extendedImageLoadState       | 状态(loading,completed,failed)                                                                         | -    |
| returnLoadStateChangedWidget | 如果这个为 true 的话，状态回调返回的 widget 将不会对(width/height/gesture/border/shape）等效果进行包装 | -    |
| imageProvider                | 图片的 Provider                                                                                        | -    |
| invertColors                 | 是否反转颜色                                                                                           | -    |
| imageStreamKey               | 图片流的唯一键                                                                                         | -    |
| reLoadImage()                | 如果图片加载失败，你可以通过调用这个方法来重新加载图片                                                 | -    |
| completedWidget              | 返回图片完成的 Widget，它包含手势以及裁剪                                                              | -    |
| loadingProgress              | 返回网络图片加载进度 (ImageChunkEvent )                                                                | -    |

```dart
abstract class ExtendedImageState {
  void reLoadImage();
  ImageInfo get extendedImageInfo;
  LoadState get extendedImageLoadState;

  ///return widget which from LoadStateChanged function  immediately
  bool returnLoadStateChangedWidget;

  ImageProvider get imageProvider;

  bool get invertColors;

  Object get imageStreamKey;

  Widget get completedWidget;
}
```

### 例子

```dart
ExtendedImage.network(
  url,
  width: ScreenUtil.instance.setWidth(600),
  height: ScreenUtil.instance.setWidth(400),
  fit: BoxFit.fill,
  cache: true,
  loadStateChanged: (ExtendedImageState state) {
    switch (state.extendedImageLoadState) {
      case LoadState.loading:
        _controller.reset();
        return Image.asset(
          "assets/loading.gif",
          fit: BoxFit.fill,
        );
        break;
      ///if you don't want override completed widget
      ///please return null or state.completedWidget
      //return null;
      //return state.completedWidget;
      case LoadState.completed:
        _controller.forward();
        return FadeTransition(
          opacity: _controller,
          child: ExtendedRawImage(
            image: state.extendedImageInfo?.image,
            width: ScreenUtil.instance.setWidth(600),
            height: ScreenUtil.instance.setWidth(400),
          ),
        );
        break;
      case LoadState.failed:
        _controller.reset();
        return GestureDetector(
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Image.asset(
                "assets/failed.jpg",
                fit: BoxFit.fill,
              ),
              Positioned(
                bottom: 0.0,
                left: 0.0,
                right: 0.0,
                child: Text(
                  "load image failed, click to reload",
                  textAlign: TextAlign.center,
                ),
              )
            ],
          ),
          onTap: () {
            state.reLoadImage();
          },
        );
        break;
    }
  },
)
```

## 缩放拖拽

![img](https://github.com/fluttercandies/Flutter_Candies/blob/master/gif/extended_image/zoom.gif)

ExtendedImage

| 参数                     | 描述                                                                  | 默认 |
| ------------------------ | --------------------------------------------------------------------- | ---- |
| mode                     | 图片模式，默认/手势/编辑 (none, gesture, editor)                      | none |
| initGestureConfigHandler | 手势配置的回调(图片加载完成时).你可以根据图片的信息比如宽高，来初始化 | -    |
| onDoubleTap              | 支持手势的时候，双击回调                                              | -    |
| extendedImageGestureKey  | 你可以通过这个key来手动控制缩放和平移                                 | -    |


GestureConfig

| 参数              | 描述                                                                                                         | 默认值                       |
| ----------------- | ------------------------------------------------------------------------------------------------------------ | ---------------------------- |
| minScale          | 缩放最小值                                                                                                   | 0.8                          |
| animationMinScale | 缩放动画最小值，当缩放结束时回到 minScale 值                                                                 | minScale \* 0.8              |
| maxScale          | 缩放最大值                                                                                                   | 5.0                          |
| animationMaxScale | 缩放动画最大值，当缩放结束时回到 maxScale 值                                                                 | maxScale \* 1.2              |
| speed             | 缩放拖拽速度，与用户操作成正比                                                                               | 1.0                          |
| inertialSpeed     | 拖拽惯性速度，与惯性速度成正比                                                                               | 100                          |
| cacheGesture      | 是否缓存手势状态，可用于 ExtendedImageGesturePageView 中保留状态，**使用 clearGestureDetailsCache 方法清除** | false                        |
| inPageView        | 是否使用 ExtendedImageGesturePageView 展示图片                                                               | false                        |
| initialAlignment  | 当图片的初始化缩放大于 1.0 的时候，根据相对位置初始化图片                                                    | InitialAlignment.center      |
| hitTestBehavior   | 设置hittest的行为                                                                                            | HitTestBehavior.deferToChild |

```dart
ExtendedImage.network(
  imageTestUrl,
  fit: BoxFit.contain,
  //enableLoadState: false,
  mode: ExtendedImageMode.gesture,
  initGestureConfigHandler: (state) {
    return GestureConfig(
        minScale: 0.9,
        animationMinScale: 0.7,
        maxScale: 3.0,
        animationMaxScale: 3.5,
        speed: 1.0,
        inertialSpeed: 100.0,
        initialScale: 1.0,
        inPageView: false,
        initialAlignment: InitialAlignment.center,
        );
  },
)
```

### 双击图片动画

支持双击动画，具体双击图片什么样子的效果，可以自定义

```dart
onDoubleTap: (ExtendedImageGestureState state) {
  ///you can use define pointerDownPosition as you can,
  ///default value is double tap pointer down position.
  var pointerDownPosition = state.pointerDownPosition;
  double begin = state.gestureDetails.totalScale;
  double end;

  //remove old
  _animation?.removeListener(animationListener);

  //stop pre
  _animationController.stop();

  //reset to use
  _animationController.reset();

  if (begin == doubleTapScales[0]) {
    end = doubleTapScales[1];
  } else {
    end = doubleTapScales[0];
  }

  animationListener = () {
    //print(_animation.value);
    state.handleDoubleTap(
        scale: _animation.value,
        doubleTapPosition: pointerDownPosition);
  };
  _animation = _animationController
      .drive(Tween<double>(begin: begin, end: end));

  _animation.addListener(animationListener);

  _animationController.forward();
},
```

## 图片编辑

![img](https://github.com/fluttercandies/Flutter_Candies/blob/master/gif/extended_image/editor.gif)

```dart
    ExtendedImage.network(
      imageTestUrl,
      fit: BoxFit.contain,
      mode: ExtendedImageMode.editor,
      extendedImageEditorKey: editorKey,
      initEditorConfigHandler: (state) {
        return EditorConfig(
            maxScale: 8.0,
            cropRectPadding: EdgeInsets.all(20.0),
            hitTestSize: 20.0,
            cropAspectRatio: _aspectRatio.aspectRatio);
      },
    );
```

ExtendedImage

| 参数                     | 描述                                                                    | 默认 |
| ------------------------ | ----------------------------------------------------------------------- | ---- |
| mode                     | 图片模式，默认/手势/编辑 (none, gesture, editor)                        | none |
| initGestureConfigHandler | 编辑器配置的回调(图片加载完成时).你可以根据图片的信息比如宽高，来初始化 | -    |
| extendedImageEditorKey   | key of ExtendedImageEditorState 用于裁剪旋转翻转                        | -    |

EditorConfig

| 参数                   | 描述                                                                               | 默认                                                         |
| ---------------------- | ---------------------------------------------------------------------------------- | ------------------------------------------------------------ |
| maxScale               | 最大的缩放倍数                                                                     | 5.0                                                          |
| cropRectPadding        | 裁剪框跟图片 layout 区域之间的距离。最好是保持一定距离，不然裁剪框边界很难进行拖拽 | EdgeInsets.all(20.0)                                         |
| cornerSize             | 裁剪框四角图形的大小                                                               | Size(30.0, 5.0)                                              |
| cornerColor            | 裁剪框四角图形的颜色                                                               | primaryColor                                                 |
| lineColor              | 裁剪框线的颜色                                                                     | scaffoldBackgroundColor.withOpacity(0.7)                     |
| lineHeight             | 裁剪框线的高度                                                                     | 0.6                                                          |
| editorMaskColorHandler | 蒙层的颜色回调，你可以根据是否手指按下来设置不同的蒙层颜色                         | scaffoldBackgroundColor.withOpacity(pointerDown ? 0.4 : 0.8) |
| hitTestSize            | 裁剪框四角以及边线能够拖拽的区域的大小                                             | 20.0                                                         |
| animationDuration      | 当裁剪框拖拽变化结束之后，自动适应到中间的动画的时长                               | Duration(milliseconds: 200)                                  |
| tickerDuration         | 当裁剪框拖拽变化结束之后，多少时间才触发自动适应到中间的动画                       | Duration(milliseconds: 400)                                  |
| cropAspectRatio        | 裁剪框的宽高比                                                                     | null(无宽高比)                                               |
| initialCropAspectRatio | 初始化的裁剪框的宽高比                                                             | null(custom: 填充满图片原始宽高比)                           |
| initCropRectType       | 剪切框的初始化类型(根据图片初始化区域或者图片的 layout 区域)                       | imageRect                                                    |
| hitTestBehavior        | 设置hittest的行为                                                                  | HitTestBehavior.deferToChild                                 |
| controller             | 提供旋转,翻转,撤销,重做,重置, 重新设置裁剪比例等操作                               | null                                                         |


### 裁剪框的宽高比

这是一个 double 类型，你可以自定义裁剪框的宽高比。
如果为 null，那就没有宽高比限制。
如果小于等于 0，宽高比等于图片的宽高比。
下面是一些定义好了的宽高比

```dart
class CropAspectRatios {
  /// no aspect ratio for crop
  static const double custom = null;

  /// the same as aspect ratio of image
  /// [cropAspectRatio] is not more than 0.0, it's original
  static const double original = 0.0;

  /// ratio of width and height is 1 : 1
  static const double ratio1_1 = 1.0;

  /// ratio of width and height is 3 : 4
  static const double ratio3_4 = 3.0 / 4.0;

  /// ratio of width and height is 4 : 3
  static const double ratio4_3 = 4.0 / 3.0;

  /// ratio of width and height is 9 : 16
  static const double ratio9_16 = 9.0 / 16.0;

  /// ratio of width and height is 16 : 9
  static const double ratio16_9 = 16.0 / 9.0;
}
```

### 裁剪图层 Painter

你现在可以通过覆写 [EditorConfig.editorCropLayerPainter] 里面的方法来自定裁剪图层.

```dart
class EditorCropLayerPainter {
  const EditorCropLayerPainter();
  void paint(
    Canvas canvas,
    Size size,
    ExtendedImageCropLayerPainter painter,
    Rect rect,
  ) {
    // Draw the mask layer
    paintMask(canvas, rect, painter);

    // Draw the grid lines
    paintLines(canvas, size, painter);

    // Draw the corners of the crop area
    paintCorners(canvas, size, painter);
  }

  /// draw crop layer corners
  void paintCorners(
      Canvas canvas, Size size, ExtendedImageCropLayerPainter painter) {
  }

  /// draw crop layer lines
  void paintMask(
      Canvas canvas, Rect rect, ExtendedImageCropLayerPainter painter) {
  }
  

  /// draw crop layer lines
  void paintLines(
      Canvas canvas, Size size, ExtendedImageCropLayerPainter painter) {
  } 
}
```

### 翻转、旋转、重新设置裁剪比例、撤消、重做、重置

#### 翻转

```dart
   _editorController.flip();

  void flip({
    bool animation = false,
    Duration duration = const Duration(milliseconds: 200),
  })
```



 #### 旋转

```dart
   _editorController.rotate();

  void rotate({
    double degrees = 90,
    bool animation = false,
    Duration duration = const Duration(milliseconds: 200),
    bool rotateCropRect = true,
  })
```



 #### 重新设置裁剪比例

```dart
   _editorController.updateCropAspectRatio(CropAspectRatios.ratio4_3);
```



 #### 撤消

```dart
  bool canUndo = _editorController.canUndo;
   _editorController.undo();

```

 #### 重做

```dart
  bool canRedo = _editorController.canRedo;
   _editorController.redo();
```

#### 重置

```dart
   _editorController.reset();
```

#### 历史

```dart
   _editorController.currentIndex;
   _editorController.history;
   _editorController.saveCurrentState();   
```

#### 配置更新

```dart
   _editorController.updateConfig(EditorConfig config);
   _editorController.config;
```

### 裁剪数据

#### 使用 dart 库(稳定)

- 添加 [Image](https://github.com/brendan-duncan/image) 库到 pubspec.yaml, 它是用来裁剪/旋转/翻转图片数据的

```yaml
dependencies:
  image: any
```

- 从 ExtendedImageEditorState 中获取裁剪区域以及图片数据

```dart
  ///crop rect base on raw image
  final Rect cropRect = state.getCropRect();

  var data = state.rawImageData;
```

- 将 flutter 的图片数据转换为 image 库的数据

```dart
  /// it costs much time and blocks ui.
  //Image src = decodeImage(data);

  /// it will not block ui with using isolate.
  //Image src = await compute(decodeImage, data);
  //Image src = await isolateDecodeImage(data);
  final lb = await loadBalancer;
  Image src = await lb.run<Image, List<int>>(decodeImage, data);
```

- 翻转，旋转，裁剪数据

```dart
  //相机拍照的图片带有旋转，处理之前需要去掉
  image = bakeOrientation(image);
  if (editAction.hasRotateDegrees) {
    image = copyRotate(image, angle: editAction.rotateDegrees);
  }

  if (editAction.flipY) {
    image = flip(image, direction: FlipDirection.horizontal);
  }

  if (editAction.needCrop) {
    image = copyCrop(
      image,
      x: cropRect.left.toInt(),
      y: cropRect.top.toInt(),
      width: cropRect.width.toInt(),
      height: cropRect.height.toInt(),
    );
  }
```

- 将数据转为为图片的元数据

获取到的将是图片的元数据，你可以使用它来保存或者其他的一些用途

```dart
  /// you can encode your image
  ///
  /// it costs much time and blocks ui.
  //var fileData = encodeJpg(src);

  /// it will not block ui with using isolate.
  //var fileData = await compute(encodeJpg, src);
  //var fileData = await isolateEncodeImage(src);
  var fileData = await lb.run<List<int>, Image>(encodeJpg, src);
```

#### 使用原生库(快速)

- 添加 [ImageEditor](https://github.com/fluttercandies/flutter_image_editor) 库到 pubspec.yaml, 它是用来裁剪/旋转/翻转图片数据的。

```yaml
dependencies:
  image_editor: any
```

- 从 ExtendedImageEditorState 中获取裁剪区域以及图片数据

```dart
  ///crop rect base on raw image
  final Rect cropRect = state.getCropRect();

  final img = state.rawImageData;
```

- 准备裁剪选项

```dart
  if (action.hasRotateDegrees) {
    final int rotateDegrees = action.rotateDegrees.toInt();
    option.addOption(RotateOption(rotateDegrees));
  }
  if (action.flipY) {
    option.addOption(const FlipOption(horizontal: true, vertical: false));
  }

  if (action.needCrop) {
    Rect cropRect = imageEditorController.getCropRect()!;
    option.addOption(ClipOption.fromRect(cropRect));
  }
```

- 使用 editImage 方法进行裁剪

获取到的将是图片的元数据，你可以使用它来保存或者其他的一些用途

```dart
  final result = await ImageEditor.editImage(
    image: img,
    imageEditorOption: option,
  );
```

[more detail](https://github.com/fluttercandies/extended_image/blob/master/example/lib/common/utils/crop_editor_helper.dart)

## 图片浏览

支持跟微信/掘金一样的图片查看效果

ExtendedImageGesturePageView 跟官方 PageView 一样的使用，不同的是，它避免了跟缩放拖拽手势冲突

支持缓存手势的状态，就是说你缩放了图片，然后下一个，再回到之前的图片，图片的缩放状态可以保存，
如果你缓存了手势，记住在合适的时候使用 clearGestureDetailsCache()清除掉，比如页面销毁的时候

![img](https://github.com/fluttercandies/Flutter_Candies/blob/master/gif/extended_image/photo_view.gif)

ExtendedImageGesturePageView

| parameter   | description                                                              | default |
| ----------- | ------------------------------------------------------------------------ | ------- |
| canMovePage | 是否滑动页面.有些场景如果 Scale 大于 1.0，并不想滑动页面，可以返回 false | true    |

GestureConfig

| 参数         | 描述                                                                                                     | 默认  |
| ------------ | -------------------------------------------------------------------------------------------------------- | ----- |
| cacheGesture | 是否缓存手势状态，可用于 ExtendedImageGesturePageView 中保留状态，使用 clearGestureDetailsCache 方法清除 | false |
| inPageView   | 是否使用 ExtendedImageGesturePageView 展示图片                                                           | false |

```dart
ExtendedImageGesturePageView.builder(
  itemBuilder: (BuildContext context, int index) {
    var item = widget.pics[index].picUrl;
    Widget image = ExtendedImage.network(
      item,
      fit: BoxFit.contain,
      mode: ExtendedImageMode.gesture,
      gestureConfig: GestureConfig(
        inPageView: true, initialScale: 1.0,
        //you can cache gesture state even though page view page change.
        //remember call clearGestureDetailsCache() method at the right time.(for example,this page dispose)
        cacheGesture: false
      ),
    );
    image = Container(
      child: image,
      padding: EdgeInsets.all(5.0),
    );
    if (index == currentIndex) {
      return Hero(
        tag: item + index.toString(),
        child: image,
      );
    } else {
      return image;
    }
  },
  itemCount: widget.pics.length,
  onPageChanged: (int index) {
    currentIndex = index;
    rebuild.add(index);
  },
  controller: PageController(
    initialPage: currentIndex,
  ),
  scrollDirection: Axis.horizontal,
),
```

## 滑动退出页面

支持微信掘金滑动退出页面的效果

![img](https://raw.githubusercontent.com/fluttercandies/Flutter_Candies/master/gif/extended_image/slide.gif)

### 首先开启滑动退出页面效果

ExtendedImage

| parameter                 | description                                                                              | default |
| ------------------------- | ---------------------------------------------------------------------------------------- | ------- |
| enableSlideOutPage        | 是否开启滑动退出页面效果                                                                 | false   |
| heroBuilderForSlidingPage | 滑动退出页面的 transform 必须作用在 Hero 上面，这样在退出页面的时候，Hero 动画才不会奇怪 | null    |

### 把你的页面用 ExtendedImageSlidePage 包一下

注意：onSlidingPage 回调，你可以使用它来设置滑动页面的时候,页面上其他元素的状态。但是注意别直接使用 setState 来刷新，因为这样会导致 ExtendedImage 的状态重置掉，你应该只通知需要刷新的 Widgets 进行刷新

```dart
    return ExtendedImageSlidePage(
      child: result,
      slideAxis: SlideAxis.both,
      slideType: SlideType.onlyImage,
      onSlidingPage: (state) {
        ///you can change other widgets' state on page as you want
        ///base on offset/isSliding etc
        //var offset= state.offset;
        var showSwiper = !state.isSliding;
        if (showSwiper != _showSwiper) {
          // do not setState directly here, the image state will change,
          // you should only notify the widgets which are needed to change
          // setState(() {
          // _showSwiper = showSwiper;
          // });

          _showSwiper = showSwiper;
          rebuildSwiper.add(_showSwiper);
        }
      },
    );
```

ExtendedImageGesturePage 的参数

| parameter                  | description                                                             | default                           |
| -------------------------- | ----------------------------------------------------------------------- | --------------------------------- |
| child                      | 需要包裹的页面                                                          | -                                 |
| slidePageBackgroundHandler | 在滑动页面的时候根据 Offset 自定义整个页面的背景色                      | defaultSlidePageBackgroundHandler |
| slideScaleHandler          | 在滑动页面的时候根据 Offset 自定义整个页面的缩放值                      | defaultSlideScaleHandler          |
| slideEndHandler            | 滑动页面结束的时候计算是否需要 pop 页面                                 | defaultSlideEndHandler            |
| slideAxis                  | 滑动页面的方向（both,horizontal,vertical）,掘金是 vertical，微信是 Both | both                              |
| resetPageDuration          | 滑动结束，如果不 pop 页面，整个页面回弹动画的时间                       | milliseconds: 500                 |
| slideType                  | 滑动整个页面还是只是图片(wholePage/onlyImage)                           | SlideType.onlyImage               |
| onSlidingPage              | 滑动页面的回调，你可以在这里改变页面上其他元素的状态                    | -                                 |
| slideOffsetHandler         | 在滑动页面的时候自定义 Offset                                           | -                                 |

下面是默认实现，你也可以根据你的喜好，来定义属于自己方式

```dart
Color defaultSlidePageBackgroundHandler(
    {Offset offset, Size pageSize, Color color, SlideAxis pageGestureAxis}) {
  double opacity = 0.0;
  if (pageGestureAxis == SlideAxis.both) {
    opacity = offset.distance /
        (Offset(pageSize.width, pageSize.height).distance / 2.0);
  } else if (pageGestureAxis == SlideAxis.horizontal) {
    opacity = offset.dx.abs() / (pageSize.width / 2.0);
  } else if (pageGestureAxis == SlideAxis.vertical) {
    opacity = offset.dy.abs() / (pageSize.height / 2.0);
  }
  return color.withOpacity(min(1.0, max(1.0 - opacity, 0.0)));
}

bool defaultSlideEndHandler(
    {Offset offset, Size pageSize, SlideAxis pageGestureAxis}) {
  if (pageGestureAxis == SlideAxis.both) {
    return offset.distance >
        Offset(pageSize.width, pageSize.height).distance / 3.5;
  } else if (pageGestureAxis == SlideAxis.horizontal) {
    return offset.dx.abs() > pageSize.width / 3.5;
  } else if (pageGestureAxis == SlideAxis.vertical) {
    return offset.dy.abs() > pageSize.height / 3.5;
  }
  return true;
}

double defaultSlideScaleHandler(
    {Offset offset, Size pageSize, SlideAxis pageGestureAxis}) {
  double scale = 0.0;
  if (pageGestureAxis == SlideAxis.both) {
    scale = offset.distance / Offset(pageSize.width, pageSize.height).distance;
  } else if (pageGestureAxis == SlideAxis.horizontal) {
    scale = offset.dx.abs() / (pageSize.width / 2.0);
  } else if (pageGestureAxis == SlideAxis.vertical) {
    scale = offset.dy.abs() / (pageSize.height / 2.0);
  }
  return max(1.0 - scale, 0.8);
}
```

### 确保你的页面是透明背景的

如果你设置 slideType =SlideType.onlyImage, 请确保的你页面是透明的，毕竟没法操控你页面上的颜色

### Push 一个透明的页面

这里我把官方的 MaterialPageRoute 和 CupertinoPageRoute 拷贝出来了，
改为 TransparentMaterialPageRoute/TransparentCupertinoPageRoute，因为它们的 opaque 不能设置为 false

```dart
  Navigator.push(
    context,
    Platform.isAndroid
        ? TransparentMaterialPageRoute(builder: (_) => page)
        : TransparentCupertinoPageRoute(builder: (_) => page),
  );
```

[滑动退出页面相关代码演示 1](https://github.com/fluttercandies/extended_image/blob/master/example/lib/common/widget/crop_image.dart)

[滑动退出页面相关代码演示 2](https://github.com/fluttercandies/extended_image/blob/master/example/lib/common/widget/pic_swiper.dart)

## Border BorderRadius Shape

ExtendedImage

| 参数         | 描述                                               | 默认 |
| ------------ | -------------------------------------------------- | ---- |
| border       | 跟官方的含义一样，你可以通过它设置边框             | -    |
| borderRadius | 跟官方的含义一样，你可以通过它设置圆角             |
| shape        | 跟官方的含义一样，你可以通过它设置裁剪（矩形和圆） | -    |

```dart
ExtendedImage.network(
  url,
  width: ScreenUtil.instance.setWidth(400),
  height: ScreenUtil.instance.setWidth(400),
  fit: BoxFit.fill,
  cache: true,
  border: Border.all(color: Colors.red, width: 1.0),
  shape: boxShape,
  borderRadius: BorderRadius.all(Radius.circular(30.0)),
),
```

![img](https://raw.githubusercontent.com/fluttercandies/Flutter_Candies/master/gif/extended_image/image.gif)

## 清除缓存和保存

### 清除缓存

清除本地缓存，可以调用 clearDiskCachedImages 方法

```dart
// Clear the disk cache directory then return if it succeed.
///  <param name="duration">timespan to compute whether file has expired or not</param>
Future<bool> clearDiskCachedImages({Duration duration})
```

根据某一个 url 清除缓存， 可以调用 clearDiskCachedImage 方法.

```dart
/// clear the disk cache image then return if it succeed.
///  <param name="url">clear specific one</param>
Future<bool> clearDiskCachedImage(String url) async {
```

根据 url 获取缓存图片文件

```dart
Future<File> getCachedImageFile(String url) async {
```

清除内存缓存，可以调用 clearMemoryImageCache 方法

```dart
///clear all of image in memory
 clearMemoryImageCache();

/// get ImageCache
 getMemoryImageCache() ;
```

### 保存网络图片

这是一个例子，使用到[image_picker_saver](https://github.com/cnhefang/image_picker_saver)
插件，ExtendedImage 做的只是提供网络图片的数据源

```dart
///save network image to photo
Future<bool> saveNetworkImageToPhoto(String url, {bool useCache: true}) async {
  var data = await getNetworkImageData(url, useCache: useCache);
  var filePath = await ImagePickerSaver.saveFile(fileData: data);
  return filePath != null && filePath != "";
}
```

## 显示裁剪图片

![img](https://raw.githubusercontent.com/fluttercandies/Flutter_Candies/master/gif/extended_image/crop.gif)

你可以通过
[ExtendedRawImage](https://github.com/fluttercandies/extended_image/blob/master/lib/src/image/raw_image.dart)(可以在状态回调的时候使用),sourceRect 是你想要显示图片的哪一部分，这个在各个 app 里面应该是比较常见的操作

```dart
ExtendedRawImage(
  image: image,
  width: num400,
  height: num300,
  fit: BoxFit.fill,
  sourceRect: Rect.fromLTWH(
      (image.width - width) / 2.0, 0.0, width, image.height.toDouble()),
)
```

## 绘制

![img](https://raw.githubusercontent.com/fluttercandies/Flutter_Candies/master/gif/extended_image/paint.gif)

提供了 BeforePaintImage and AfterPaintImage 两个回调, 这样你就能绘制你想要的东西或者进图片进行 Clip。

ExtendedImage

| parameter        | description    | default |
| ---------------- | -------------- | ------- |
| beforePaintImage | 在绘制图片之前 | -       |
| afterPaintImage  | 在绘制图片之后 | -       |

```dart
  ExtendedImage.network(
    url,
    width: ScreenUtil.instance.setWidth(400),
    height: ScreenUtil.instance.setWidth(400),
    fit: BoxFit.fill,
    cache: true,
    beforePaintImage: (Canvas canvas, Rect rect, ui.Image image) {
      if (paintType == PaintType.ClipHeart) {
        if (!rect.isEmpty) {
          canvas.save();
          canvas.clipPath(clipheart(rect, canvas));
        }
      }
      return false;
    },
    afterPaintImage: (Canvas canvas, Rect rect, ui.Image image) {
      if (paintType == PaintType.ClipHeart) {
        if (!rect.isEmpty) canvas.restore();
      } else if (paintType == PaintType.PaintHeart) {
        canvas.drawPath(
            clipheart(rect, canvas),
            Paint()
              ..colorFilter =
                  ColorFilter.mode(Color(0x55ea5504), BlendMode.srcIn)
              ..isAntiAlias = false
              ..filterQuality = FilterQuality.low);
      }
    },
  );
```

在例子中可以看到把图片 Clip 成了一个桃心，你也可以根据你的要求，做出不同的 Clip
[绘制例子](https://github.com/fluttercandies/extended_image/blob/master/example/lib/pages/simple/paint_image_demo.dart)
[下拉刷新头当中，也使用了这个技巧](https://github.com/fluttercandies/extended_image/blob/master/example/lib/common/widget/push_to_refresh_header.dart)

## Notch

设置图片初始化的 Insets，不会影响放大。

ExtendedImage

| parameter    | description              | default         |
| ------------ | ------------------------ | --------------- |
| layoutInsets | 设置图片初始化时候的边距 | EdgeInsets.zero |

```dart
  ExtendedImage.network(
    url,
    fit: BoxFit.contain,
    layoutInsets: MediaQuery.of(context).padding
  );
```

## 内存使用

现在你可以通过下面设置来减少图片内存的占用.

* ExtendedResizeImage

| parameter                                                | description                                                                   | default  |
| -------------------------------------------------------- | ----------------------------------------------------------------------------- | -------- |
| [ExtendedResizeImage.compressionRatio]                   | 图片压缩率，大于0小于1                                                        | null     |
| [ExtendedResizeImage.maxBytes]                           | 图片的大小的最大值. 默认值为 50KB. 这是图片实际的的大小，而不是解码之后的大小 | 50 << 10 |
| [ExtendedResizeImage.width]/[ExtendedResizeImage.height] | 宽和高用于decode和缓存. 跟官方的[ResizeImage]一致。                           | null     |

```dart
    ExtendedImage.network(
      'imageUrl',  
      compressionRatio: 0.1,
      maxBytes: null,
      cacheWidth: null,
      cacheHeight: null,  
    )

    ExtendedImage(
      image: ExtendedResizeImage(
        ExtendedNetworkImageProvider(
          'imageUrl',  
        ),
        compressionRatio: 0.1,
        maxBytes: null,
        width: null,
        height: null,
      ),
    )
```

* clearMemoryCacheWhenDispose

| parameter                   | description                                                                                                                                                    | default |
| --------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- |
| clearMemoryCacheWhenDispose | 在Flutter 2.0之后也许不会起作用, 因为没法在图片没有完成之前释放掉(https://github.com/fluttercandies/extended_image/issues/317).  现在只会释放已完成的图片资源. | false   |



```dart
   ExtendedImage.network(
     'imageUrl',     
     clearMemoryCacheWhenDispose: true,
   )
```

* imageCacheName

| parameter      | description                                                                               | default |
| -------------- | ----------------------------------------------------------------------------------------- | ------- |
| imageCacheName | 你可以指定一个 ImageCache 来缓存一些图片。这样你可以一起处理它们，不会影响其他的图片缓存. | null    |

```dart
   ExtendedImage.network(
     'imageUrl',  
     imageCacheName: 'MemoryUsage',
   )
     
  /// clear when this page is disposed   
  @override
  void dispose() {
    // clear ImageCache which named 'MemoryUsage'
    clearMemoryImageCache(imageCacheName);
    super.dispose();
  }   
```

## 其他 APIs

ExtendedImage

| 参数                        | 描述                                     | 默认  |
| --------------------------- | ---------------------------------------- | ----- |
| enableMemoryCache           | 是否缓存到内存                           | true  |
| clearMemoryCacheIfFailed    | 如果图片加载失败，是否清掉内存缓存       | true  |
| clearMemoryCacheWhenDispose | 如果图片从 tree 中移除，是否清掉内存缓存 | false |
