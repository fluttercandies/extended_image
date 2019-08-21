# extended_image

[![pub package](https://img.shields.io/pub/v/extended_image.svg)](https://pub.dartlang.org/packages/extended_image) [![GitHub stars](https://img.shields.io/github/stars/fluttercandies/extended_image)](https://github.com/fluttercandies/extended_image/stargazers) [![GitHub forks](https://img.shields.io/github/forks/fluttercandies/extended_image)](https://github.com/fluttercandies/extended_image/network)  [![GitHub license](https://img.shields.io/github/license/fluttercandies/extended_image)](https://github.com/fluttercandies/extended_image/blob/master/LICENSE)  [![GitHub issues](https://img.shields.io/github/issues/fluttercandies/extended_image)](https://github.com/fluttercandies/extended_image/issues) <a target="_blank" href="https://jq.qq.com/?_wv=1027&k=5bcc0gy"><img border="0" src="https://pub.idqqimg.com/wpa/images/group.png" alt="flutter-candies" title="flutter-candies"></a>

Language: [English](README.md) | [中文简体](README-ZH.md)

A powerful extended official image for Dart, which support placeholder(loading)/ failed state,cache network,zoom pan image,photo view,slide out page,crop,save,paint etc.

## Table of contents

- [extended_image](#extendedimage)
  - [Table of contents](#Table-of-contents)
  - [Cache Network](#Cache-Network)
    - [Simple use](#Simple-use)
    - [Use Extendednetworkimageprovider](#Use-Extendednetworkimageprovider)
  - [Load State](#Load-State)
    - [demo code](#demo-code)
  - [Zoom Pan](#Zoom-Pan)
    - [double tap animation](#double-tap-animation)
  - [Photo View](#Photo-View)
  - [Slide Out Page](#Slide-Out-Page)
    - [enable slide out page](#enable-slide-out-page)
    - [include your page in ExtendedImageSlidePage](#include-your-page-in-ExtendedImageSlidePage)
    - [make sure your page background is transparent](#make-sure-your-page-background-is-transparent)
    - [push with transparent page route](#push-with-transparent-page-route)
  - [Border BorderRadius Shape](#Border-BorderRadius-Shape)
  - [Clear Save](#Clear-Save)
    - [clear](#clear)
    - [save network](#save-network)
  - [Crop](#Crop)
  - [Paint](#Paint)
  - [Other APIs](#Other-APIs)

## Cache Network

### Simple use

You can use `ExtendedImage.network` as Image Widget

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

### Use Extendednetworkimageprovider

[ExtendedNetworkImageProvider](https://github.com/fluttercandies/extended_image/blob/master/lib/src/extended_network_image_provider.dart)

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

| parameter   | description                                                                           | default             |
| ----------- | ------------------------------------------------------------------------------------- | ------------------- |
| url         | The URL from which the image will be fetched.                                         | required            |
| scale       | The scale to place in the [ImageInfo] object of the image.                            | 1.0                 |
| headers     | The HTTP headers that will be used with [HttpClient.get] to fetch image from network. | -                   |
| cache       | whether cache image to local                                                          | false               |
| retries     | the time to retry to request                                                          | 3                   |
| timeLimit   | time limit to request image                                                           | -                   |
| timeRetry   | the time duration to retry to request                                                 | milliseconds: 100   |
| cancelToken | token to cancel network request                                                       | CancellationToken() |

## Load State

Extended Image provide 3 states(loading,completed,failed), you can define your state widget with
loadStateChanged call back.

loadStateChanged is not only for network, if your image need long time to load,
you can set enableLoadState(default value is ture for network and others are false) to ture

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

ExtendedImageState(LoadStateChanged call back)

| parameter/method             | description                                                                                                                                   | default |
| ---------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------- | ------- |
| extendedImageInfo            | image info                                                                                                                                    | -       |
| extendedImageLoadState       | LoadState(loading,completed,failed)                                                                                                           | -       |
| returnLoadStateChangedWidget | if this is ture, return widget which from LoadStateChanged fucntion immediately(width/height/gesture/border/shape etc, will not effect on it) | -       |
| imageProvider                | ImageProvider                                                                                                                                 | -       |
| invertColors                 | invertColors                                                                                                                                  | -       |
| imageStreamKey               | key of image                                                                                                                                  | -       |
| reLoadImage()                | if image load failed,you can reload image by call it                                                                                          | -       |

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

### demo code

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

## Zoom Pan

![img](https://github.com/fluttercandies/Flutter_Candies/blob/master/gif/extended_image/zoom.gif)

ExtendedImage

| parameter                | description                                                                     | default |
| ------------------------ | ------------------------------------------------------------------------------- | ------- |
| mode                     | image mode (none,gestrue)                                                       | none    |
| initGestureConfigHandler | init GestureConfig when image is ready，for example, base on image width/height | -       |
| onDoubleTap              | call back of double tap under ExtendedImageMode.Gesture                         | -       |

GestureConfig

| parameter         | description                                                                                                                                                      | default         |
| ----------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------- |
| minScale          | min scale                                                                                                                                                        | 0.8             |
| animationMinScale | the min scale for zooming then animation back to minScale when scale end                                                                                         | minScale \_ 0.8 |
| maxScale          | max scale                                                                                                                                                        | 5.0             |
| animationMaxScale | the max scale for zooming then animation back to maxScale when scale end                                                                                         | maxScale \_ 1.2 |
| speed             | speed for zoom/pan                                                                                                                                               | 1.0             |
| inertialSpeed     | inertial speed for zoom/pan                                                                                                                                      | 100             |
| cacheGesture      | save Gesture state (for example in ExtendedImageGesturePageView, gesture state will not change when scroll back),remember clearGestureDetailsCache at right time | false           |
| inPageView        | whether in ExtendedImageGesturePageView                                                                                                                          | false           |

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

### double tap animation

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

## Photo View

ExtendedImageGesturePageView is the same as PageView and it's made for show zoom/pan image.

if you have cache the gesture, remember call clearGestureDetailsCache() method at the right time.(for example,page view page is disposed)

![img](https://github.com/fluttercandies/Flutter_Candies/blob/master/gif/extended_image/photo_view.gif)

GestureConfig

| parameter    | description                                                                                                                                                      | default |
| ------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- |
| cacheGesture | save Gesture state (for example in ExtendedImageGesturePageView, gesture state will not change when scroll back),remember clearGestureDetailsCache at right time | false   |
| inPageView   | whether in ExtendedImageGesturePageView                                                                                                                          | false   |

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


## Slide Out Page

Extended Image support to slide out page as WeChat.

![img](https://raw.githubusercontent.com/fluttercandies/Flutter_Candies/master/gif/extended_image/slide.gif)

### enable slide out page

ExtendedImage

| parameter          | description                   | default |
| ------------------ | ----------------------------- | ------- |
| enableSlideOutPage | whether enable slide out page | false   |

### include your page in ExtendedImageSlidePage

take care of onSlidingPage call back, you can update other widgets' state as you want.
but, do not setState directly here, image state will changed, you should only notify the widgets which are needed to change

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

ExtendedImageGesturePage

| parameter                  | description                                                                      | default                           |
| -------------------------- | -------------------------------------------------------------------------------- | --------------------------------- |
| child                      | The [child] contained by the ExtendedImageGesturePage.                           | -                                 |
| slidePageBackgroundHandler | build background when slide page                                                 | defaultSlidePageBackgroundHandler |
| slideScaleHandler          | custom scale of page when slide page                                             | defaultSlideScaleHandler          |
| slideEndHandler            | call back of slide end,decide whether pop page                                   | defaultSlideEndHandler            |
| slideAxis                  | axis of slide(both,horizontal,vertical)                                          | SlideAxis.both                    |
| resetPageDuration          | reset page position when slide end(not pop page)                                 | milliseconds: 500                 |
| slideType                  | slide whole page or only image                                                   | SlideType.onlyImage               |
| onSlidingPage              | call back when it's sliding page, change other widgets state on page as you want | -                                 |
| canMovePage                | whether we should move page                                                      | true                              |

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

### make sure your page background is transparent

if you use ExtendedImageSlidePage and slideType =SlideType.onlyImage,
make sure your page background is transparent

### push with transparent page route

you should push page with TransparentMaterialPageRoute/TransparentCupertinoPageRoute

```dart
  Navigator.push(
    context,
    Platform.isAndroid
        ? TransparentMaterialPageRoute(builder: (_) => page)
        : TransparentCupertinoPageRoute(builder: (_) => page),
  );
```

[Slide Out Page Demo Code 1](https://github.com/fluttercandies/extended_image/blob/master/example/lib/common/crop_image.dart)

[Slide Out Page Demo Code 2](https://github.com/fluttercandies/extended_image/blob/master/example/lib/common/pic_swiper.dart)

## Border BorderRadius Shape

ExtendedImage

| parameter    | description                                                                                                                                                             | default |
| ------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- |
| border       | BoxShape.circle and BoxShape.rectangle,If this is [BoxShape.circle] then [borderRadius] is ignored.                                                                     | -       |
| borderRadius | If non-null, the corners of this box are rounded by this [BorderRadius].,Applies only to boxes with rectangular shapes; ignored if [shape] is not [BoxShape.rectangle]. | -       |
| shape        | BoxShape.circle and BoxShape.rectangle,If this is [BoxShape.circle] then [borderRadius] is ignored.                                                                     | -       |

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

## Clear Save

### clear

to clear disk cached , call clearDiskCachedImages method.

```dart
// Clear the disk cache directory then return if it succeed.
///  <param name="duration">timespan to compute whether file has expired or not</param>
Future<bool> clearDiskCachedImages({Duration duration})
```

to clear disk cached with specific url, call clearDiskCachedImage method.
```dart
/// clear the disk cache image then return if it succeed.
///  <param name="url">clear specific one</param>
Future<bool> clearDiskCachedImage(String url) async {
```

to clear memory cache , call clearMemoryImageCache method.

```dart
///clear all of image in memory
 clearMemoryImageCache();

/// get ImageCache
 getMemoryImageCache() ;
```

### save network

call saveNetworkImageToPhoto and save image with [image_picker_saver](https://github.com/cnhefang/image_picker_saver)


```dart
///save netwrok image to photo
Future<bool> saveNetworkImageToPhoto(String url, {bool useCache: true}) async {
  var data = await getNetworkImageData(url, useCache: useCache);
  var filePath = await ImagePickerSaver.saveFile(fileData: data);
  return filePath != null && filePath != "";
}
```

## Crop

get your raw image by [Load State](#Load State), and crop image by setting soureRect.

[ExtendedRawImage](https://github.com/fluttercandies/extended_image/blob/master/lib/src/image/extended_raw_image.dart)
soureRect is which you want to show image rect.

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


## Paint

provide BeforePaintImage and AfterPaintImage callback, you will have the chance to paint things you want.

![img](https://raw.githubusercontent.com/fluttercandies/Flutter_Candies/master/gif/extended_image/paint.gif)

ExtendedImage

| parameter        | description                                            | default |
| ---------------- | ------------------------------------------------------ | ------- |
| beforePaintImage | you can paint anything if you want before paint image. | -       |
| afterPaintImage  | you can paint anything if you want after paint image.  | -       |

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

see [paint image demo](https://github.com/fluttercandies/extended_image/blob/master/example/lib/paint_image_demo.dart)
and [push to refresh header which is used in crop image demo](https://github.com/fluttercandies/extended_image/tree/master/example/lib/common/push_to_refresh_header.dart)

## Other APIs

ExtendedImage

| parameter                | description                                                                                    | default |
| ------------------------ | ---------------------------------------------------------------------------------------------- | ------- |
| enableMemoryCache        | whether cache in PaintingBinding.instance.imageCache)                                          | true    |
| clearMemoryCacheIfFailed | when failed to load image, whether clear memory cache.if ture, image will reload in next time. | true    |
