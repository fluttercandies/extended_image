 [English](https://github.com/fluttercandies/extended_image) | 简体中文

`extended_image`基于官方的`Image`扩展而来，支持图片加载中/加载失败状态展示、缓存网络图片、缩放、平移、照片墙、滑动退出、剪裁、保存、自定义绘制等。

- [Flutter 什么功能都有的 Image](https://juejin.im/post/5c867112f265da2dd427a340)
- [Flutter 可以缩放拖拽的图片](https://juejin.im/post/5ca758916fb9a05e1c4d01bb)
- [Flutter 仿掘金微信图片滑动退出页面效果](https://juejin.im/post/5cf62ab0e51d45776031afb2)


###  1. <a name=''></a>目录

<!-- vscode-markdown-toc -->
* 1. [目录](#)
* 2. [使用 ExtendedNetworkImageProvider](#ExtendedNetworkImageProvider)
* 1. [加载状态](#loadState)
	* 1.1. [ExtendedImageState(LoadStateChanged callback)](#ExtendedImageStateLoadStateChangedcallback)
	* 1.2. [demo code](#democode)
* 2. [移动和缩放](#Pan)
	* 2.1. [ExtendedImage](#ExtendedImage)
	* 2.2. [GestureConfig](#GestureConfig)
	* 2.3. [双击动画](#doubleClick)
* 3. [图片墙](#potoView)
* 4. [滑动退出](#sileOut)
	* 4.1. [将你的页面包在 `ExtendedImageSlidePage`中](#ExtendedImageSlidePage)
	* 4.2. [首先保证你的页面背景透明](#transBC)
	* 4.3. [push 一个透明背景的路由](#push)
* 5. [Border BorderRadius Shape](#BorderBorderRadiusShape)
* 6. [清除缓存 / 保存图片](#clearAndSave)
	* 6.1. [清除缓存](#clear)
	* 6.2. [保存网络图片](#save)
* 7. [Crop(剪裁)](#Crop)
* 8. [Paint(自定义绘制)](#Paint)
* 9. [其他 API](#API)


`ExtendedImage.network` 参考官方的和官方的[Image.network](https://api.flutter.dev/flutter/widgets/Image/Image.network.html) 实现，因此可以像官方一样使用。

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

###  2. <a name='ExtendedNetworkImageProvider'></a>使用 ExtendedNetworkImageProvider

[ExtendedNetworkImageProvider](https://github.com/fluttercandies/extended_image_library/blob/master/lib/src/extended_network_image_provider.dart)

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

| 参数名      | 描述                                                                                                                  | 默认值              |
| ----------- | --------------------------------------------------------------------------------------------------------------------- | ------------------- |
| url         | 图片地址.                                                                                                             | required            |
| scale       | 放在[ImageInfo] 对象中的图片比例                                                                                      | 1.0                 |
| headers     | \<[HttpHeaders](https://api.flutter.dev/flutter/dart-io/HttpHeaders-class.html)> 使用[HttpClient.get]获取图片的请求头 | -                   |
| cache       | 是否缓存图片到本地                                                                                                    | false               |
| retries     | 加载失败重试的次数                                                                                                    | 3                   |
| timeLimit   | 请求图片的超时时间                                                                                                    | -                   |
| timeRetry   | 加载失败重试的时间间隔                                                                                                | milliseconds: 100   |
| cancelToken | 用于取消请求的token                                                                                                   | CancellationToken() |

##  1. <a name='loadState'></a>加载状态

`Extended Image`提供 三种状态：加载中、完成、失败。你可以使用`loadStateChanged`回调自定义状态微件。

`loadStateChanged`不仅适用于网络加载，更适用于一些语言长时间加载的图片任务，此时你就可以将`loadStateChanged`设置为`true`

`loadStateChanged`默认值只有在加载网络资源时为`true`，其他情况都为`false`.

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

###  1.1. <a name='ExtendedImageStateLoadStateChangedcallback'></a>ExtendedImageState(LoadStateChanged callback)

| 参数/方法                    | 描述                                                                                                             | 默认值 |
| ---------------------------- | ---------------------------------------------------------------------------------------------------------------- | ------ |
| extendedImageInfo            | 图片信息                                                                                                         | -      |
| extendedImageLoadState       | 加载状态，LoadState(loading,completed,failed)                                                                    | -      |
| returnLoadStateChangedWidget | 如果是`true`，则立即返回一个由`LoadStateChanged`方法构建的微件(width/height/gesture/border/shape 等属性将不生效) | -      |
| imageProvider                | ImageProvider                                                                                                    | -      |
| invertColors                 | invertColors                                                                                                     | -      |
| imageStreamKey               | key                                                                                                              | -      |
| reLoadImage()                | 加载失败时重新加载的回调                                                                                         | -      |

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

###  1.2. <a name='democode'></a>demo code

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

##  2. <a name='Pan'></a>移动和缩放

![img](https://github.com/fluttercandies/Flutter_Candies/blob/master/gif/extended_image/zoom.gif)

###  2.1. <a name='ExtendedImage'></a>ExtendedImage

| parameter     | description                                    | default |
| ------------- | ---------------------------------------------- | ------- |
| mode          | 手势模式 ：`none`不接受手势，`gestrue`接受手势 | none    |
| gestureConfig | 图片手势的配置项                               | -       |
| onDoubleTap   | 双击回调 `ExtendedImageMode.Gesture`           | -       |

###  2.2. <a name='GestureConfig'></a>GestureConfig

| parameter         | description                                                                                                                                                                  | default         |
| ----------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------- |
| minScale          | 最小缩放倍数                                                                                                                                                                 | 0.8             |
| animationMinScale | 缩放到最小比例时用于执行回弹动画的缩放比例                                                                                                                                   | minScale \_ 0.8 |
| maxScale          | 最大缩放比例                                                                                                                                                                 | 5.0             |
| animationMaxScale | 缩放到最大比例时用于执行回弹动画的缩放比例                                                                                                                                   | maxScale \_ 1.2 |
| speed             | 缩放/移动的速度(相对于实际缩放大小/移动距离的倍数)                                                                                                                           | 1.0             |
| inertialSpeed     | inerial speed for zoom/pan                                                                                                                                                   | 100             |
| cacheGesture      | 是否保存手势状态，例如在`PageView`中，对于一个缩放过的图片，滑到下一张在回来之后是否保存之前缩放的状态。设置保存状态后要在合适的时机清除这些状态(`clearGestureDetailsCache`) | false           |
| inPageView        | 是否将图片放在` ExtendedImageGesturePageView`中                                                                                                                              | false           |

```dart
ExtendedImage.network(
  imageTestUrl,
  fit: BoxFit.contain,
  //enableLoadState: false,
  mode: ExtendedImageMode.Gesture,
  gestureConfig: GestureConfig(
    minScale: 0.9,
    animationMinScale: 0.7,
    maxScale: 3.0,
    animationMaxScale: 3.5,
    speed: 1.0,
    inertialSpeed: 100.0,
    initialScale: 1.0,
    inPageView: false,
  ),
)
```

###  2.3. <a name='doubleClick'></a>双击动画

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

##  3. <a name='potoView'></a>图片墙

`ExtendedImageGesturePageView` 是一个和` PageView `相似的微件，但是增加了移动和缩放的功能。

如果你保存了手势状态，那么一定要记得 __清理这些手势状态__ (例如在PageView.dispose中清理)。

![img](https://github.com/fluttercandies/Flutter_Candies/blob/master/gif/extended_image/photo_view.gif)

`GestureConfig`

| parameter    | description                                                                                                                                                                  | default |
| ------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- |
| cacheGesture | 是否保存手势状态，例如在`PageView`中，对于一个缩放过的图片，滑到下一张在回来之后是否保存之前缩放的状态。设置保存状态后要在合适的时机清除这些状态(`clearGestureDetailsCache`) | false   |
| inPageView   | 是否在`ExtendedImageGesturePageView`中使用                                                                                                                                   | false   |

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


##  4. <a name='sileOut'></a>滑动退出

`Extended Image`支持仿微信/掘金的图片滑动退出预览

![img](https://raw.githubusercontent.com/fluttercandies/Flutter_Candies/master/gif/extended_image/slide.gif)

###  4.1. <a name='ExtendedImageSlidePage'></a>将你的页面包在 `ExtendedImageSlidePage`中

```dart
 var page = ExtendedImageSlidePage(
      child: PicSwiper(
          index,
          listSourceRepository
          .map<PicSwiperItem>(
          (f) => PicSwiperItem(f.imageUrl, des: f.title))
          .toList(),
       ),
      slideAxis: SlideAxis.both,
      slideType: SlideType.onlyImage,
);
```

__`ExtendedImageGesturePage`__

| 参数                       | 描述                                          | 默认值                            |
| -------------------------- | --------------------------------------------- | --------------------------------- |
| child                      | 作为`ExtendedImageGesturePage`子微件          | -                                 |
| slidePageBackgroundHandler | 定义滑动页面外的背景                          | defaultSlidePageBackgroundHandler |
| slideScaleHandler          | 定义当前滑动页面的缩放比                      | defaultSlideScaleHandler          |
| slideEndHandler            | 滑动结束（退出页面时触发）的回调              | defaultSlideEndHandler            |
| slideAxis                  | 滑动方向：both,horizontal,vertical            | SlideAxis.both                    |
| resetPageDuration          | 滑动结束（但没有触发退出操作）松开手指的回调  | milliseconds: 500                 |
| slideType                  | 滑动整个页面(wholePage)/只滑动图片(onlyImage) | SlideType.onlyImage               |




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

###  4.2. <a name='transBC'></a>首先保证你的页面背景透明

如果你使用了`ExtendedImageSlidePage` 并且设置`slideType = SlideType.onlyImage`,那么请务必确认你的页面背景设置为透明。

###  4.3. <a name='push'></a>push 一个透明背景的路由

使用 `TransparentMaterialPageRoute`/`TransparentCupertinoPageRoute`来push一个新页面

```dart
  Navigator.push(
    context,
    Platform.isAndroid
        ? TransparentMaterialPageRoute(builder: (_) => page)
        : TransparentCupertinoPageRoute(builder: (_) => page),
  );
```


[crop image demo](https://github.com/fluttercandies/extended_image/blob/master/example/lib/photo_view_demo.dart)



##  5. <a name='BorderBorderRadiusShape'></a>Border BorderRadius Shape

`ExtendedImage`

| 参数         | 描述                                                                                                                        | 默认值 |
| ------------ | --------------------------------------------------------------------------------------------------------------------------- | ------ |
| border       | `BoxShape.circle` /`BoxShape.rectangle`，如果设置了`BoxShape.circle`，那么`borderRadius`属性将会被忽略。                    | -      |
| borderRadius | 如果不为null，使用`BorderRadius`设置。仅适用于具有`shape = BoxShape.rectangle`; 如果`shape`不是`BoxShape.rectangle`则忽略。 | -      |
| shape        | `BoxShape.circle` /`BoxShape.rectangle`，如果设置了`BoxShape.circle`，那么`borderRadius`属性将会被忽略。                    | -      |

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
)
```

![img](https://raw.githubusercontent.com/fluttercandies/Flutter_Candies/master/gif/extended_image/image.gif)

##  6. <a name='clearAndSave'></a>清除缓存 / 保存图片

###  6.1. <a name='clear'></a>清除缓存

清除磁盘缓存，调用`clearDiskCachedImages`方法即可

```dart
// Clear the disk cache directory then return if it succeed.
///  <param name="duration">timespan to compute whether file has expired or not</param>
Future<bool> clearDiskCachedImages({Duration duration})
```

清除内存缓存，调用`clearMemoryImageCache`即可

```dart
///clear all of image in memory
 clearMemoryImageCache();

/// get ImageCache
 getMemoryImageCache() ;
```

###  6.2. <a name='save'></a>保存网络图片

调用 `saveNetworkImageToPhoto`方法并使用 `ImagePickerSaver`来保存图片。

```dart
///save netwrok image to photo
Future<bool> saveNetworkImageToPhoto(String url, {bool useCache: true}) async {
  var data = await getNetworkImageData(url, useCache: useCache);
  var filePath = await ImagePickerSaver.saveFile(fileData: data);
  return filePath != null && filePath != "";
}
```

##  7. <a name='Crop'></a>Crop(剪裁)

使用[Load State](#Load State)获得原始图像，然后设置`soureRect`剪裁图片。

[ExtendedRawImage](https://github.com/fluttercandies/extended_image/blob/master/lib/src/image/extended_raw_image.dart)
`soureRect`是用来显示图片的区域。

![img](https://raw.githubusercontent.com/fluttercandies/Flutter_Candies/master/gif/extended_image/crop.gif)

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


##  8. <a name='Paint'></a>Paint(自定义绘制)

如果想自定义图片绘制，这里提供了两个回调，`BeforePaintImage` ,  `AfterPaintImage`

![img](https://raw.githubusercontent.com/fluttercandies/Flutter_Candies/master/gif/extended_image/paint.gif)

`ExtendedImage`

| 参数             | 描述                                 | 默认值 |
| ---------------- | ------------------------------------ | ------ |
| beforePaintImage | 加载图片前，绘制一些你想要的内容     | -      |
| afterPaintImage  | 图片渲染完成后，绘制一些你想要的内容 | -      |

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

 [paint image demo](https://github.com/fluttercandies/extended_image/blob/master/example/lib/paint_image_demo.dart)
 [使用剪裁图片实现下拉刷新头部的demo](https://github.com/fluttercandies/extended_image/tree/master/example/lib/common/push_to_refresh_header.dart)

##  9. <a name='API'></a>其他 API

__`ExtendedImage`__

| 参数                     | 描述                                                                     | 默认值 |
| ------------------------ | ------------------------------------------------------------------------ | ------ |
| enableMemoryCache        | 是否清除内存缓存，`PaintingBinding.instance.imageCache`                  | true   |
| clearMemoryCacheIfFailed | 当无法加载图像时，是否清除内存缓存.如果为 `true`，图像将在下次重新加载。 | true   |
