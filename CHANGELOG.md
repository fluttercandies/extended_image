## [0.5.5]

* Features:
  Add call back [CanMovePage] for ExtendedImageGesturePageView. [related issue](https://github.com/fluttercandies/extended_image/issues/32) 
  
## [0.5.4]

* Issues:
  Fix issue about borderRadius and border
  Fix demo error about extended_text 

## [0.5.3]

* Improve codes base on v1.7.8

## [0.5.1]

* Features:
  Add call back [onSlidingPage] when is sliding page, you can change other widgets state in page.[ExtendedImageSlidePage]
* Add [enableSlideOutPage] parameter to define whether enable slide out page. [ExtendedImage]  

## [0.4.3]

* Breaking Change:
  Parameter [gestureConfig] is obsolete. [initGestureConfigHandler] is used to setting GestureConfig now.

* Issues:
  Fix issue about slide page.
  
* Features: 
  Support to slide page at loading/failed state

## [0.4.2]

* add README-ZH.md
  
## [0.4.1]

* add SlideType to support slide only image or whole page[ExtendedImageSlidePage]

## [0.4.0]

* support to slide out page

## [0.3.8]

* update path_provider 1.1.0

## [0.3.6]

* handle loadfailed when re-addListener

## [0.3.4]

* add physics parameter for ExtendedImageGesturePageView

## [0.3.3]

* disabled informationCollector to keep backwards compatibility for now (ExtendedNetworkImageProvider)

## [0.3.2]

* import extended_image_library for network cache

## [0.3.1]

* fix issue that AnimationController.stop() called after AnimationController.dispose().
* show how to build a double tap scale animation.

## [0.2.9]

* add handleDoubleTap method to support zoom image base on double tap position.

## [0.2.8]

* add inertia scroll when image is zoom in and it's moving page.

## [0.2.7]

* fix issue that wrong behavior of page view scroll when image has big width or big height.

## [0.2.6]

* fix issue that wrong behavior of page view scroll when image is zoom in.

## [0.2.5]

* add onDoubleTap parameter to custom double tap behavior under ExtendedImageMode.Gesture

## [0.2.3]

* add enableMemoryCache parameter, whether cache in PaintingBinding.instance.imageCache
* add clearMemoryCacheIfFailed parameter, when failed to load image, whether clear memory cache,if ture, image will reload in next time.
* auto cancel network request is obsolete.

## [0.2.2]

* update path_provider version from 0.4.1 to 0.5.0+1

## [0.2.1]

* add cancelToken,retries,timeLimit and timeRetry parameters for ExtendedImage.network method
* add default cancelToken for ExtendedImage.network method
* fix issue about cancel network image request
* fix gesture page view scrolls not smooth

## [0.2.0]

* support zoom/pan image and view image in page view like wechat(support zoom in and scroll next or previous image)

## [0.1.8]

* remove image_picker_saver from extended_image.
  obsolete saveNetworkImageToPhoto method(if you want to save photo,you can import image_picker_saver and get data from getNetworkImageData method)

## [0.1.7]

* public instantiateImageCodec method so that you can handle image data by override this in ExtendedNetworkImageProvider

## [0.1.6]

* add getNetworkImageData method

## [0.1.5]

* change toMd5 to keyToMd5

## [0.1.4]

* public imageProvider for ExtendedImageState

## [0.1.3]

* add extended image.
