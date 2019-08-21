# extended_image

[![pub package](https://img.shields.io/pub/v/extended_image.svg)](https://pub.dartlang.org/packages/extended_image) [![GitHub stars](https://img.shields.io/github/stars/fluttercandies/extended_image)](https://github.com/fluttercandies/extended_image/stargazers) [![GitHub forks](https://img.shields.io/github/forks/fluttercandies/extended_image)](https://github.com/fluttercandies/extended_image/network)  [![GitHub license](https://img.shields.io/github/license/fluttercandies/extended_image)](https://github.com/fluttercandies/extended_image/blob/master/LICENSE)  [![GitHub issues](https://img.shields.io/github/issues/fluttercandies/extended_image)](https://github.com/fluttercandies/extended_image/issues) <a target="_blank" href="https://jq.qq.com/?_wv=1027&k=5bcc0gy"><img border="0" src="https://pub.idqqimg.com/wpa/images/group.png" alt="flutter-candies" title="flutter-candies"></a>

文档语言: [English](README.md) | [中文简体](README-ZH.md)

强大的官方 Image 扩展组件, 支持加载以及失败显示，缓存网络图片，缩放拖拽图片，图片浏览(微信掘金效果)，滑动退出页面(微信掘金效果)，裁剪，保存，绘制自定义效果等功能

- [Flutter 什么功能都有的 Image](https://juejin.im/post/5c867112f265da2dd427a340)
- [Flutter 可以缩放拖拽的图片](https://juejin.im/post/5ca758916fb9a05e1c4d01bb)
- [Flutter 仿掘金微信图片滑动退出页面效果](https://juejin.im/post/5cf62ab0e51d45776031afb2)

## 目录

- [extended_image](#extendedimage)
  - [目录](#%E7%9B%AE%E5%BD%95)
  - [缓存网络图片](#%E7%BC%93%E5%AD%98%E7%BD%91%E7%BB%9C%E5%9B%BE%E7%89%87)
    - [简单使用](#%E7%AE%80%E5%8D%95%E4%BD%BF%E7%94%A8)
    - [使用 Extendednetworkimageprovider](#%E4%BD%BF%E7%94%A8-Extendednetworkimageprovider)
  - [加载状态](#%E5%8A%A0%E8%BD%BD%E7%8A%B6%E6%80%81)
    - [例子](#%E4%BE%8B%E5%AD%90)
  - [缩放拖拽](#%E7%BC%A9%E6%94%BE%E6%8B%96%E6%8B%BD)
    - [双击图片动画](#%E5%8F%8C%E5%87%BB%E5%9B%BE%E7%89%87%E5%8A%A8%E7%94%BB)
  - [图片浏览](#%E5%9B%BE%E7%89%87%E6%B5%8F%E8%A7%88)
  - [滑动退出页面](#%E6%BB%91%E5%8A%A8%E9%80%80%E5%87%BA%E9%A1%B5%E9%9D%A2)
    - [首先开启滑动退出页面效果](#%E9%A6%96%E5%85%88%E5%BC%80%E5%90%AF%E6%BB%91%E5%8A%A8%E9%80%80%E5%87%BA%E9%A1%B5%E9%9D%A2%E6%95%88%E6%9E%9C)
    - [把你的页面用ExtendedImageSlidePage包一下](#%E6%8A%8A%E4%BD%A0%E7%9A%84%E9%A1%B5%E9%9D%A2%E7%94%A8ExtendedImageSlidePage%E5%8C%85%E4%B8%80%E4%B8%8B)
    - [确保你的页面是透明背景的](#%E7%A1%AE%E4%BF%9D%E4%BD%A0%E7%9A%84%E9%A1%B5%E9%9D%A2%E6%98%AF%E9%80%8F%E6%98%8E%E8%83%8C%E6%99%AF%E7%9A%84)
    - [Push一个透明的页面](#Push%E4%B8%80%E4%B8%AA%E9%80%8F%E6%98%8E%E7%9A%84%E9%A1%B5%E9%9D%A2)
  - [Border BorderRadius Shape](#Border-BorderRadius-Shape)
  - [清除缓存和保存](#%E6%B8%85%E9%99%A4%E7%BC%93%E5%AD%98%E5%92%8C%E4%BF%9D%E5%AD%98)
    - [清除缓存](#%E6%B8%85%E9%99%A4%E7%BC%93%E5%AD%98)
    - [保存网络图片](#%E4%BF%9D%E5%AD%98%E7%BD%91%E7%BB%9C%E5%9B%BE%E7%89%87)
  - [裁剪](#%E8%A3%81%E5%89%AA)
  - [绘制](#%E7%BB%98%E5%88%B6)
  - [其他 APIs](#%E5%85%B6%E4%BB%96-APIs)

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

### 使用 Extendednetworkimageprovider

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

## 加载状态

Extended Image一共有3种状态，分别是正在加载，完成，失败(loading,completed,failed)，你可以通过实现loadStateChanged回调来定义显示的效果

loadStateChanged 不仅仅只在网络图片中可以使用, 如果你的图片很大，需要长时间加载，
你可以把enableLoadState设置为了true，这样也会有状态回调了，（默认只有网络图片,enableLoadState为true）

![img](https://github.com/fluttercandies/Flutter_Candies/blob/master/gif/extended_image/custom.gif)

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

| 参数/方法                    | 描述                                                                                               | 默认 |
| ---------------------------- | -------------------------------------------------------------------------------------------------- | ---- |
| extendedImageInfo            | 图片的信息，包括底层image和image的大小                                                             | -    |
| extendedImageLoadState       | 状态(loading,completed,failed)                                                                     | -    |
| returnLoadStateChangedWidget | 如果这个为true的话，状态回调返回的widget将不会对(width/height/gesture/border/shape）等效果进行包装 | -    |
| imageProvider                | 图片的Provider                                                                                     | -    |
| invertColors                 | 是否反转颜色                                                                                       | -    |
| imageStreamKey               | 图片流的唯一键                                                                                     | -    |
| reLoadImage()                | 如果图片加载失败，你可以通过调用这个方法来重新加载图片                                             | -    |

```dart
abstract class ExtendedImageState {
  void reLoadImage();
  ImageInfo get extendedImageInfo;
  LoadState get extendedImageLoadState;

  ///return widget which from LoadStateChanged fucntion  immediately
  bool returnLoadStateChangedWidget;

  ImageProvider get imageProvider;

  bool get invertColors;

  Object get imageStreamKey;
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
| mode                     | 图片模式，一种为默认，一种是支持手势 (none,gestrue)                   | none |
| initGestureConfigHandler | 手势的配置回调(图片加载完成时).你可以根据图片的信息比如宽高，来初始化 | -    |
| onDoubleTap              | 支持手势的时候，双击回调                                              | -    |

GestureConfig

| 参数              | 描述                                                                                                 | 默认值         |
| ----------------- | ---------------------------------------------------------------------------------------------------- | -------------- |
| minScale          | 缩放最小值                                                                                           | 0.8            |
| animationMinScale | 缩放动画最小值，当缩放结束时回到minScale值                                                           | minScale * 0.8 |
| maxScale          | 缩放最大值                                                                                           | 5.0            |
| animationMaxScale | 缩放动画最大值，当缩放结束时回到maxScale值                                                           | maxScale * 1.2 |
| speed             | 缩放拖拽速度，与用户操作成正比                                                                       | 1.0            |
| inertialSpeed     | 拖拽惯性速度，与惯性速度成正比                                                                       | 100            |
| cacheGesture      | 是否缓存手势状态，可用于ExtendedImageGesturePageView中保留状态，使用clearGestureDetailsCache方法清除 | false          |
| inPageView        | 是否使用ExtendedImageGesturePageView展示图片                                                         | false          |

```dart
ExtendedImage.network(
  imageTestUrl,
  fit: BoxFit.contain,
  //enableLoadState: false,
  mode: ExtendedImageMode.Gesture,
  initGestureConfigHandler: (state) {
    return GestureConfig(
        minScale: 0.9,
        animationMinScale: 0.7,
        maxScale: 3.0,
        animationMaxScale: 3.5,
        speed: 1.0,
        inertialSpeed: 100.0,
        initialScale: 1.0,
        inPageView: false);
  },
)
```

### 双击图片动画

支持双击动画，具体双击图片什么样子的效果，可以自定义

```dart
onDoubleTap: (ExtendedImageGestureState state) {
  ///you can use define pointerDownPosition as you can,
  ///default value is double tap pointer down postion.
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

## 图片浏览

支持跟微信/掘金一样的图片查看效果

ExtendedImageGesturePageView跟官方PageView一样的使用，不同的是，它避免了跟缩放拖拽手势冲突

支持缓存手势的状态，就是说你缩放了图片，然后下一个，再回到之前的图片，图片的缩放状态可以保存，
如果你缓存了手势，记住在合适的时候使用clearGestureDetailsCache()清除掉，比如页面销毁的时候


![img](https://github.com/fluttercandies/Flutter_Candies/blob/master/gif/extended_image/photo_view.gif)

GestureConfig

| 参数         | 描述                                                                                                 | 默认  |
| ------------ | ---------------------------------------------------------------------------------------------------- | ----- |
| cacheGesture | 是否缓存手势状态，可用于ExtendedImageGesturePageView中保留状态，使用clearGestureDetailsCache方法清除 | false |
| inPageView   | 是否使用ExtendedImageGesturePageView展示图片                                                         | false |

```dart
ExtendedImageGesturePageView.builder(
  itemBuilder: (BuildContext context, int index) {
    var item = widget.pics[index].picUrl;
    Widget image = ExtendedImage.network(
      item,
      fit: BoxFit.contain,
      mode: ExtendedImageMode.Gesture,
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

| parameter          | description              | default |
| ------------------ | ------------------------ | ------- |
| enableSlideOutPage | 是否开启滑动退出页面效果 | false   |

### 把你的页面用ExtendedImageSlidePage包一下

注意：onSlidingPage回调，你可以使用它来设置滑动页面的时候,页面上其他元素的状态。但是注意别直接使用setState来刷新，因为这样会导致ExtendedImage的状态重置掉，你应该只通知需要刷新的Widgets进行刷新

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

ExtendedImageGesturePage的参数

| parameter                  | description                                                           | default                           |
| -------------------------- | --------------------------------------------------------------------- | --------------------------------- |
| child                      | 需要包裹的页面                                                        | -                                 |
| slidePageBackgroundHandler | 在滑动页面的时候根据Offset自定义整个页面的背景色                      | defaultSlidePageBackgroundHandler |
| slideScaleHandler          | 在滑动页面的时候根据Offset自定义整个页面的缩放值                      | defaultSlideScaleHandler          |
| slideEndHandler            | 滑动页面结束的时候计算是否需要pop页面                                 | defaultSlideEndHandler            |
| slideAxis                  | 滑动页面的方向（both,horizontal,vertical）,掘金是vertical，微信是Both | both                              |
| resetPageDuration          | 滑动结束，如果不pop页面，整个页面回弹动画的时间                       | milliseconds: 500                 |
| slideType                  | 滑动整个页面还是只是图片(wholePage/onlyImage)                         | SlideType.onlyImage               |
| onSlidingPage              | 滑动页面的回调，你可以在这里改变页面上其他元素的状态                  | -                                 |
| canMovePage                | 是否滑动页面.有些场景如果Scale大于1.0，并不想滑动页面，可以返回false  | true                              |

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

### Push一个透明的页面

这里我把官方的MaterialPageRoute 和CupertinoPageRoute拷贝出来了，
改为TransparentMaterialPageRoute/TransparentCupertinoPageRoute，因为它们的opaque不能设置为false

```dart
  Navigator.push(
    context,
    Platform.isAndroid
        ? TransparentMaterialPageRoute(builder: (_) => page)
        : TransparentCupertinoPageRoute(builder: (_) => page),
  );
```

[滑动退出页面相关代码演示 1](https://github.com/fluttercandies/extended_image/blob/master/example/lib/common/crop_image.dart)

[滑动退出页面相关代码演示 2](https://github.com/fluttercandies/extended_image/blob/master/example/lib/common/pic_swiper.dart)

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

清除本地缓存，可以调用clearDiskCachedImages方法

```dart
// Clear the disk cache directory then return if it succeed.
///  <param name="duration">timespan to compute whether file has expired or not</param>
Future<bool> clearDiskCachedImages({Duration duration})
```

根据某一个url清除缓存， 可以调用clearDiskCachedImage方法.
```dart
/// clear the disk cache image then return if it succeed.
///  <param name="url">clear specific one</param>
Future<bool> clearDiskCachedImage(String url) async {
```

清除内存缓存，可以调用clearMemoryImageCache方法

```dart
///clear all of image in memory
 clearMemoryImageCache();

/// get ImageCache
 getMemoryImageCache() ;
```

### 保存网络图片

这是一个例子，使用到[image_picker_saver](https://github.com/cnhefang/image_picker_saver)
插件，ExtendedImage做的只是提供网络图片的数据源

```dart
///save netwrok image to photo
Future<bool> saveNetworkImageToPhoto(String url, {bool useCache: true}) async {
  var data = await getNetworkImageData(url, useCache: useCache);
  var filePath = await ImagePickerSaver.saveFile(fileData: data);
  return filePath != null && filePath != "";
}
```

## 裁剪

![img](https://raw.githubusercontent.com/fluttercandies/Flutter_Candies/master/gif/extended_image/crop.gif)

你可以通过
[ExtendedRawImage](https://github.com/fluttercandies/extended_image/blob/master/lib/src/image/extended_raw_image.dart)(可以在状态回调的时候使用),soucreRect 是你想要显示图片的哪一部分，这个在各个app里面应该是比较常见的操作


```dart
ExtendedRawImage(
  image: image,
  width: num400,
  height: num300,
  fit: BoxFit.fill,
  soucreRect: Rect.fromLTWH(
      (image.width - width) / 2.0, 0.0, width, image.height.toDouble()),
)
```

[crop image demo](https://github.com/fluttercandies/extended_image/blob/master/example/lib/crop_image_demo.dart)

## 绘制

![img](https://raw.githubusercontent.com/fluttercandies/Flutter_Candies/master/gif/extended_image/paint.gif)

提供了 BeforePaintImage and AfterPaintImage 两个回调, 这样你就能绘制你想要的东西或者进图片进行Clip。

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

在例子中可以看到把图片Clip成了一个桃心，你也可以根据你的要求，做出不同的Clip
[绘制例子](https://github.com/fluttercandies/extended_image/blob/master/example/lib/paint_image_demo.dart)
[下拉刷新头当中，也使用了这个技巧](https://github.com/fluttercandies/extended_image/tree/master/example/lib/common/push_to_refresh_header.dart)

## 其他 APIs

ExtendedImage

| 参数                     | 描述                               | 默认 |
| ------------------------ | ---------------------------------- | ---- |
| enableMemoryCache        | 是否缓存到内存                     | true |
| clearMemoryCacheIfFailed | 如果图片加载失败，是否清掉内存缓存 | true |
