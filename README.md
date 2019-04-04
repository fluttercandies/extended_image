# extended_image

[![pub package](https://img.shields.io/pub/v/extended_image.svg)](https://pub.dartlang.org/packages/extended_image)

extended official image with load state,crop,save,clip,paint etc.

[Chinese bolg](https://juejin.im/post/5c867112f265da2dd427a340)

extended image is the same as official image.

# Cache network image
You can use [ExtendedNetworkImageProvider](https://github.com/fluttercandies/extended_image/blob/master/lib/src/extended_network_image_provider.dart)

```dart
 ExtendedNetworkImageProvider(this.url,
      {this.scale = 1.0,
      this.headers,
      this.cache: false,
      this.retries = 3,
      this.timeLimit,
      this.timeRetry = const Duration(milliseconds: 100)})
      : assert(url != null),
        assert(scale != null);

  ///time Limit to request image
  final Duration timeLimit;

  ///the time to retry to request
  final int retries;

  ///the time duration to retry to request
  final Duration timeRetry;

  ///whether cache image to local
  final bool cache;

  /// The URL from which the image will be fetched.
  final String url;

  /// The scale to place in the [ImageInfo] object of the image.
  final double scale;

  /// The HTTP headers that will be used with [HttpClient.get] to fetch image from network.
  final Map<String, String> headers;  
```

More: timeRetry/retries/timeLimit are used for request parameter

or just use with following code
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

# Circle/BorderRadius/Border

Circle/BorderRadius/Border are easy to be used.

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

# Clear and Save

Clear disk cached , you can set duration to clear expired images or clear all of them.
```dart
// Clear the disk cache directory then return if it succeed.
///  <param name="duration">timespan to compute whether file has expired or not</param>
Future<bool> clearDiskCachedImages({Duration duration}) 
```

```dart
///clear all of image in memory
 clearMemoryImageCache();

/// get ImageCache
 getMemoryImageCache() ;
```
 
 Save with image_picker_saver
```dart
///save netwrok image to photo
Future<bool> saveNetworkImageToPhoto(String url, {bool useCache: true}) async {
  var data = await getNetworkImageData(url, useCache: useCache);
  var filePath = await ImagePickerSaver.saveFile(fileData: data);
  return filePath != null && filePath != "";
}
```

![](https://github.com/fluttercandies/Flutter_Candies/blob/master/gif/extended_image/image.gif)


# Custom load state
    /// custom load state widget if you want
    final LoadStateChanged loadStateChanged;
    
  provide LoadStateChanged function to build custom load widget,
  it's not just for network image, if your image need long to load,
  you can define your loading widget or crop your image at that moment.
  see [custom image demo](https://github.com/fluttercandies/extended_image/blob/master/example/lib/custom_image_demo.dart)


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

![](https://github.com/fluttercandies/Flutter_Candies/tree/master/gif/extended_image/custom.gif)

#  Crop image
 you can crop image with ExtendedRawImage, soureRect is which you want to show image rect.
 [crop image demo](https://github.com/fluttercandies/extended_image/blob/master/example/lib/crop_image_demo.dart)

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

![](https://github.com/fluttercandies/Flutter_Candies/tree/master/gif/extended_image/crop.gif)


# paint any thing if you want when image is ready

provide BeforePaintImage and AfterPaintImage, you will have the chance to paint thing you want.
see [paint image demo](https://github.com/fluttercandies/extended_image/blob/master/example/lib/paint_image_demo.dart)
and [push to refresh header which is used in crop image demo](https://github.com/fluttercandies/extended_image/tree/master/example/lib/common/push_to_refresh_header.dart)

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
                           ..colorFilter = ColorFilter.mode(
                               Color(0x55ea5504), BlendMode.srcIn)
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
               )
 ```
 
 ![](https://github.com/fluttercandies/Flutter_Candies/tree/master/gif/extended_image/paint.gif)
